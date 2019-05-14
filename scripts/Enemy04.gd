extends KinematicBody2D

const QPI = PI/4.0

export var walk_speed : int = 70
export var run_speed : int = 110
var current_speed : int = 0
var direction : Vector2 = Vector2()
export var charge_distance : int = 220
export var charge_distance_span : int = 30
export var charge_speed : int = 300
export var charge_chance : float = 0.75
export var charge_timer : float = 2.0
export var charge_cooldown : float = 1.0
#var charge_distance_sqrd = charge_distance * charge_distance
var charge_target
var mate

export var health = 5
signal death(KinematicBody2D)

export var timer_long = 1.0
export var timer_short = 0.5
export var time_until_removal = 4
var death_timer = 0.0
var is_dead = false
export var worth : int = 5
var difficulty = 0
enum {PURSUE, CHARGE, CHARGING, EVADE, MATING, WANDER, WAIT}
var behaviour_switch = WANDER
var behaviour_timer = 0.0

onready var player = $"../Player"

func _ready():
	SoundService.enemy04_spawn()


func _physics_process(delta):
	if is_dead:
		death_timer += delta
		if death_timer > time_until_removal:
			queue_free()
		return
	elif $"..".is_choosing:
		$AnimationPlayer.stop()
		return
	
	behaviour_timer += delta
	if behaviour_timer < 0.0:
		return
	
	if behaviour_switch == CHARGE:
		if behaviour_timer > charge_timer:
			behaviour_switch = CHARGING
			direction = (player.position - position).normalized()
			charge_target = position + direction * (charge_distance + charge_distance_span)
			#charge_target = player.position
			_set_sprite(direction.angle())
			$AnimationPlayer.playback_speed = 2.0
		return
	elif behaviour_switch == MATING:
		if mate == null or mate.is_dead:
			behaviour_timer = WANDER
			return
		direction = (mate.position - position).normalized()
		direction = direction * 0.1 + direction.tangent()
		var coll = move_and_collide(direction * delta * run_speed)
	elif behaviour_switch == PURSUE:
		current_speed = run_speed
		direction = (player.position - position).normalized()
		var velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
		_set_sprite(direction.angle(), velocity.length_squared() <= 1000)
	elif behaviour_switch == WANDER and not $WalkTimer.is_stopped():
		if $WalkTimer.is_stopped():
			$WalkTimer.start()
			direction = _get_random_direction()
			current_speed = walk_speed
		var velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
		_set_sprite(direction.angle(), velocity.length_squared() <= 1000)
		pass
	elif behaviour_switch == WAIT and not $WaitTimer.is_stopped():
		if $WaitTimer.is_stopped():
			$WaitTimer.start()
			direction = _get_random_direction()
			current_speed = 0
		direction = (player.position - position).normalized()
		var velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
		_set_sprite(direction.angle(), velocity.length_squared() <= 1000)
			
	elif behaviour_switch == CHARGING:
		direction = (charge_target - position).normalized()
		var coll = move_and_collide(direction * delta * charge_speed)
		if coll:
			if coll.collider.is_in_group("Living"):
				coll.collider.die()
			behaviour_switch = PURSUE
			behaviour_timer = -charge_cooldown
			$AnimationPlayer.stop()
			$AnimationPlayer.playback_speed = 1.0
		elif position.distance_squared_to(charge_target) < 10:
			behaviour_switch = PURSUE
			behaviour_timer = -charge_cooldown
			$AnimationPlayer.stop()
			$AnimationPlayer.playback_speed = 1.0
		return
	
	# Check for player collision
	for i in range(get_slide_count()):
		var coll = get_slide_collision(i)
		if coll.collider == player:
			player.die()
			$AnimationPlayer.stop()

func _set_sprite(angle, paused = false):
	angle += PI
	var wide = true
	
	if angle > 5*QPI and angle < 7*QPI:
		$AnimationPlayer.play("down_run")
		wide = false
	elif angle > 3*QPI and angle < 5*QPI:
		$AnimationPlayer.play("right_run")
	elif angle > QPI and angle < 3*QPI:
		$AnimationPlayer.play("up_run")
		wide = false
	else:
		$AnimationPlayer.play("left_run")
	
	if paused:
		$AnimationPlayer.advance(0.01)
		$AnimationPlayer.stop()
	
	# They're very oblong, so rotate the collision shape.
	if wide:
		$CollisionShape2D.rotation = PI/2
	else:
		$CollisionShape2D.rotation = 0

func _get_random_direction():
	var angle = randf() * 2 * PI
	return Vector2(cos(angle), sin(angle))

func get_worth():
	return worth

func die():
	SoundService.fleshthump() #TODO add sound
	if is_dead:
		return
	
	print("health ", health)
	health -= 1
	if health <= 0:
		is_dead = true
		#SoundService.enemy02_death()
		emit_signal("death", self)
		$AnimationPlayer.play($AnimationPlayer.current_animation.replace("down_", "right_"))
		$AnimationPlayer.play($AnimationPlayer.current_animation.replace("up_", "left_"))
		$AnimationPlayer.play($AnimationPlayer.current_animation.replace("_run", "_death"))
		# Bug?? Play won't change the current animation when called by Game from a signal
		$AnimationPlayer.current_animation = $AnimationPlayer.current_animation.replace("_run", "_death")


func _on_MatingArea_body_entered(body):
	if mate != null:
		print("mate: ", mate, ", returning ")
		return
	
	if body.is_in_group("Mate"):
		body.mate = self
		behaviour_switch = MATING
		mate = body



