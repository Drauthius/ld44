extends KinematicBody2D

const QPI = PI/4.0

export var normal_speed : int = 150
export var charge_distance : int = 220
export var charge_distance_span : int = 30
export var charge_speed : int = 300
export var charge_chance : float = 0.75
export var charge_timer : float = 2.0
export var charge_cooldown : float = 1.0
#var charge_distance_sqrd = charge_distance * charge_distance
var charge_target
var mate

export var evade_chance : float = 0.5

export var time_until_removal = 4
var death_timer = 0.0
var is_dead = false
export var worth : int = 5
var difficulty = 0

signal death(KinematicBody2D)

export var timer_long = 1.0
export var timer_short = 0.5
enum {PURSUE, CHARGE, CHARGING, EVADE}
var behaviour_switch = PURSUE
var behaviour_timer = 0.0
var evade_dir

onready var player = $"../Player"

func _ready():
	SoundService.enemy01_spawn()

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
	
	if behaviour_switch == PURSUE:
		if behaviour_timer > timer_long:
			if difficulty >= 1 and abs(position.distance_to(player.position) - charge_distance) < charge_distance_span and randf() < charge_chance:
				behaviour_switch = CHARGE
				_set_sprite(player.position.angle_to_point(position), true)
				$Tween.interpolate_property($AnimationPlayer, "playback_speed", 1.0, 4.0, charge_timer, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
			elif difficulty >= 2 and randf() < evade_chance:
				behaviour_switch = EVADE
			behaviour_timer = 0.0
	elif behaviour_switch == EVADE:
		if behaviour_timer > timer_short:
			behaviour_switch = PURSUE
			behaviour_timer = 0.0
			evade_dir = "l" if randf() < 0.5 else "r"
	elif behaviour_switch == CHARGE:
		if behaviour_timer > charge_timer:
			behaviour_switch = CHARGING
			var direction = (player.position - position).normalized()
			charge_target = position + direction * (charge_distance + charge_distance_span)
			#charge_target = player.position
			_set_sprite(direction.angle())
			$AnimationPlayer.playback_speed = 2.0
		return
	elif behaviour_switch == CHARGING:
		var direction = (charge_target - position).normalized()
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
	
	var current_speed = normal_speed
	var direction = (player.position - position).normalized()
	if behaviour_switch == EVADE:
		if evade_dir == "r":
			direction = (direction + direction.tangent()).normalized()
		else:
			direction = (direction - direction.tangent()).normalized()
	
	var velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
	_set_sprite(direction.angle(), velocity.length_squared() <= 1000)
	
	# Check for player collision
	for i in range(get_slide_count()):
		var coll = get_slide_collision(i)
		if coll.collider == player:
			player.die()
			$AnimationPlayer.stop()

func get_worth():
	return worth

func die():
	if not is_dead:
		SoundService.enemy01_death()
		is_dead = true
		$Tween.stop_all()
		$AnimationPlayer.playback_speed = 1.0
		#$CollisionShape2D.set_deferred("disabled", true) # This is a feature.
		emit_signal("death", self)
	
	$AnimationPlayer.play($AnimationPlayer.current_animation.replace("_run", "_death"))
	# Bug?? Play won't change the current animation when called by Game from a signal
	$AnimationPlayer.current_animation = $AnimationPlayer.current_animation.replace("_run", "_death")

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

func _on_Tween_tween_completed(_object, _key):
	$AnimationPlayer.playback_speed = 1.0