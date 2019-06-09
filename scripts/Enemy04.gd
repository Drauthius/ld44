extends "res://scripts/Enemy.gd"

export(float, 0.0, 100.0) var pursue_tire_time = 2.5
export(float, 0.0, 5000.0) var pursue_distance_rest = 80.0 # Getting too close removes the rest.
export(float, 0.0, 100.0) var pursue_rest_time = 4.0 # How long to rest before pursuing again

onready var old_pursue_distance = pursue_distance
onready var old_pursue_distance_squared = pursue_distance_squared
onready var pursue_distance_rest_squared = pursue_distance_rest * pursue_distance_rest

func _on_process(_delta : float) -> void:
	# Make sure that we're not pursuing for too long.
	if state == States.PURSUING and $Timer.is_stopped():
		$Timer.start(pursue_tire_time)
		$PursueCooldown.stop()

func die() -> void:
	# Reset the old pursue distance if shot.
	_on_PursueCooldown_timeout()
	$PursueCooldown.stop()
	
	# Reset the pursue timer.
	if state == States.IDLE or state == States.WANDERING or state == States.PURSUING:
		$Timer.stop()
	
	.die()

func _on_MatingArea_body_entered(body : PhysicsBody2D) -> void:
	if state == States.DEAD:
		return
	
	if body.is_in_group("Mate"):
		if mate and is_instance_valid(mate) and mate.state != States.DEAD:
			print("already has a mate")
		elif not $MatingCooldown.is_stopped():
			print("mating cooldown")
		elif body.mate or body.state == States.MATING:
			print("mate alreday has a mate")
		elif state != States.IDLE and state != States.WANDERING:
			print("busy with something")
		elif body.position.distance_squared_to(body.target.position) < pursue_distance_squared:
			print("mate too close to its target")
		else:
			print("mate with me")
			
			# Set up the mate
			self.mate = body
			mate.mate = self
			# Change the state
			self.state = States.MATING
			mate.state = States.MATING
			# Target each other
			self.target = mate
			mate.target = self
			# Stop any lingering timers
			$Timer.stop()
			mate.get_node("Timer").stop()
			# Start the mate timer
			$MatingCooldown.start()

func _on_Timer_timeout() -> void:
	match state:
		States.PURSUING:
			state = States.IDLE
			$AnimationPlayer.seek(0.0, true)
			$AnimationPlayer.stop()
			$PursueCooldown.start(pursue_rest_time)
			# Decrease the pursue distance ("feeling threatened")
			pursue_distance = pursue_distance_rest
			pursue_distance_squared = pursue_distance_rest_squared
		_:
			._on_Timer_timeout()

func _on_PursueCooldown_timeout() -> void:
	# Reset the pursue distance
	pursue_distance = old_pursue_distance
	pursue_distance_squared = old_pursue_distance_squared