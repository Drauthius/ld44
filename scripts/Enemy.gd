extends KinematicBody2D
class_name Enemy

export(int, 1, 1000) var movement_speed = 150
export(String, "enemy01", "enemy02", "enemy03", "enemy04", "boss01") var sound
export(int, 1, 100) var hitpoints = 1
export(int, 0, 100) var worth = 5
export(float, 0.0, 1000.0) var despawn_time = 4.0
export(float, 0.0, 1000.0) var mating_time = 5.0

export(float, 0.0, 5000.0) var pursue_distance = 5000.0
export(float, 0.0, 1.0) var wander_chance = 0.5
export(float, 0.0, 100.0) var wander_time = 2.0

export(float, 0.0, 100.0) var alter_behaviour_time = 1.0
export(bool) var can_evade = false
export(float, 0.0, 1.0) var evade_chance = 0.5
export(float, 0.0, 100.0) var evade_time = 0.5

export(bool) var can_charge = false
export(float, 0.0, 1.0) var charge_chance = 0.75
export(Vector2) var charge_distance = Vector2(190.0, 250.0)
export(float, 0.0, 100.0) var charge_up_time = 2.0
export(float, 0.0, 100.0) var charge_down_time = 1.0
export(int, 1, 1000) var charge_speed = 300

export(bool) var can_flee = false
export(float, 0.0, 1000.0) var flee_distance
export(float, 0.0, 100.0) var flee_time = 0.5

export(Vector2) var attack_distance # min,max
export(bool) var can_shoot = false
export(float, 0.1, 10.0) var shoot_time = 0.8
export(PackedScene) var Bullet = preload("res://scenes/BulletBig.tscn")
export(Color) var bullet_modulate
export(PackedScene) var MuzzleFlash = preload("res://scenes/MuzzleFlash.tscn")
export(float, 1, 1000) var bullet_speed = 180

export(bool) var rotate_collision = false # Whether to rotate the collision shape when going left/right

signal death(KinematicBody2D)

const HPI : float = PI/2.0
const QPI : float = PI/4.0
const STOPPED_SQUARED : float = 1000.0

enum States {IDLE, WANDERING, PURSUING, CHARGE_WINDUP, CHARGING, CHARGE_WINDDOWN, SHOOTING, EVADING, FLEEING, MATING, DEAD}
var state = States.IDLE

enum Evade {LEFT, RIGHT}
var evade_direction

var charge_target : Vector2
var wander_direction : Vector2
var cornered : bool = false

var mate : Enemy

var current_animation : String

onready var player : Node = $"../Player"
onready var target : Node = player
onready var pursue_distance_squared : float = pursue_distance * pursue_distance
onready var attack_distance_squared : Vector2 = attack_distance * attack_distance
onready var flee_distance_squared : float = flee_distance * flee_distance
onready var charge_distance_squared : Vector2 = charge_distance * charge_distance

func _ready() -> void:
	SoundService.call(sound + "_spawn")

func _process(delta : float) -> void:
	if state == States.DEAD:
		return
	elif $"..".is_choosing: # TODO: Remove
		$AnimationPlayer.stop()
		return
	
	if state == States.MATING:
		if not target or not is_instance_valid(target) or target.state == States.DEAD:
			target = player
			state = States.IDLE
		return # They only have eyes for each other.
	elif not $Timer.is_stopped() and state != States.IDLE and state != States.WANDERING:
		return # Wait for the timer if in a state that matters.
	elif state == States.CHARGING:
		return # Wait until the charging has completed.
	
	var distance_squared := position.distance_squared_to(target.position)
	
	if can_flee and not cornered and distance_squared < flee_distance_squared:
		state = States.FLEEING
		evade_direction = Evade.LEFT if randf() < 0.5 else Evade.RIGHT
		$Timer.start(flee_time)
	elif can_shoot and distance_squared >= attack_distance.x and distance_squared <= attack_distance_squared.y:
		state = States.SHOOTING
		$Timer.start(shoot_time)
		_set_sprite(target.position.angle_to_point(position), true)
	elif distance_squared < pursue_distance_squared or state == States.PURSUING: # Locked on?
		state = States.PURSUING
		if (can_charge or can_evade) and $Timer.is_stopped():
			$Timer.start(alter_behaviour_time) # There is a % chance to charge or evade, evaluated every alter_behaviour_time period.
	elif state != States.WANDERING:
		state = States.IDLE
		if $Timer.is_stopped():
			$Timer.start(alter_behaviour_time) # There is a % chance to wander.
	
	_on_process(delta)

func _physics_process(delta : float) -> void:
	if state == States.DEAD:
		return
	elif $"..".is_choosing: # TODO: Remove
		return
	
	if state == States.PURSUING or state == States.EVADING or state == States.CHARGING or state == States.FLEEING or state == States.WANDERING or state == States.MATING:
		var targetPos : Vector2 = charge_target if state == States.CHARGING else target.position
		var direction : Vector2 = (targetPos - position).normalized()
		var tangent := direction.tangent()
		var speed : float = movement_speed
		
		if state == States.CHARGING:
			speed = charge_speed
		if state == States.FLEEING:
			direction = -direction
		if evade_direction == Evade.LEFT:
			tangent = -tangent
		if state == States.WANDERING:
			direction = wander_direction
			speed *= 0.75
		
		if state == States.EVADING or state == States.FLEEING or state == States.MATING:
			direction = (direction + tangent).normalized()
		
		var velocity := move_and_slide(direction * speed, Vector2(0, 0), true, 1, 0.0, false)
		var stopped := velocity.length_squared() <= STOPPED_SQUARED
		cornered = stopped if state == States.FLEEING else false
		_set_sprite(direction.angle(), stopped, state == States.WANDERING)
		
		# Check for player collision
		for i in range(get_slide_count()):
			var coll = get_slide_collision(i)
			if coll.collider == target:
				if state == States.MATING:
					if $Timer.is_stopped():
						$Timer.start(mating_time)
				else:
					target.die()
			elif state == States.CHARGING:
				if coll.collider.is_in_group("Living"):
					coll.collider.die()
				$Timer.stop()
				_on_Timer_timeout()
	
	_on_physics_process(delta)

func get_worth() -> int:
	return worth

func die() -> void:
	hitpoints -= 1
	if hitpoints <= 0 and state != States.DEAD:
		SoundService.call(sound + "_death")
		state = States.DEAD
		
		$Tween.stop_all() # Make sure no tweening is going on
		$AnimationPlayer.playback_speed = 1.0 # Reset potentially modified playback speed
		
		$Timer.start(despawn_time)
		
		emit_signal("death", self)
	elif SoundService.has_method(sound + "_hit"):
		SoundService.call(sound + "_hit")
		if state != States.DEAD:
			return
	
	if hitpoints <= -3:
		$CollisionShape2D.set_deferred("disabled", true) # No longer affects physics
		$Timer.paused = true # Make sure the explosion isn't interrupted by a "normal" despawn
		if current_animation.begins_with("left_") or current_animation.begins_with("up_"):
			$AnimationPlayer.play("left_explosion")
		else:
			$AnimationPlayer.play("right_explosion")
		return
	
	# Play the death animation for every shot it receives
	var anim := current_animation.replace("_run", "_death").replace("_walk", "_death")
	current_animation = anim
	$AnimationPlayer.play(anim)
	# Bug?? Play won't change the current animation when called by Game from a signal
	$AnimationPlayer.current_animation = anim

func _get_random_direction() -> Vector2:
	var angle := randf() * 2 * PI
	return Vector2(cos(angle), sin(angle))

func _set_sprite(angle : float, paused : bool = false, walking : bool = false) -> void:
	angle += PI
	var wide := true
	var anim := "_walk" if walking else "_run"
	
	if angle > 5*QPI and angle < 7*QPI:
		$AnimationPlayer.play("down" + anim)
		wide = false
	elif angle > 3*QPI and angle < 5*QPI:
		$AnimationPlayer.play("right" + anim)
	elif angle > QPI and angle < 3*QPI:
		$AnimationPlayer.play("up" + anim)
		wide = false
	else:
		$AnimationPlayer.play("left" + anim)
	
	current_animation = $AnimationPlayer.current_animation
	if paused:
		$AnimationPlayer.seek(0.0, true)
		$AnimationPlayer.stop()
	
	if rotate_collision:
		$CollisionShape2D.rotation = HPI if wide else 0.0

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	if anim_name.ends_with("_explosion"):
		queue_free()

func _on_Tween_tween_completed(_object, _key) -> void:
	$AnimationPlayer.playback_speed = 1.0

func _on_Timer_timeout() -> void:
	match state:
		States.DEAD:
			queue_free()
		States.SHOOTING:
			var angle : float = target.position.angle_to_point(position) + PI
			var bullet = Bullet.instance()
			bullet.position = get_global_transform().get_origin() - Vector2(16, 0).rotated(angle)
			bullet.rotation = angle - PI
			bullet.init(bullet_modulate)
			bullet.lifetime = attack_distance.y / float(bullet_speed) * 1.1
			bullet.speed = bullet_speed
			$Gun.add_child(bullet)
			SoundService.call(sound + "_gunshot")
			
			# Muzzle flash
			if MuzzleFlash:
				var muzzle_flash = MuzzleFlash.instance()
				muzzle_flash.position = -Vector2(16, 0).rotated(angle)
				muzzle_flash.rotation = bullet.rotation
				add_child(muzzle_flash)
		States.PURSUING:
			var distance_squared : float = position.distance_squared_to(target.position)
			if can_charge and distance_squared >= charge_distance_squared.x and distance_squared <= charge_distance_squared.y and randf() < charge_chance:
				state = States.CHARGE_WINDUP
				$Tween.interpolate_property($AnimationPlayer, "playback_speed", 1.5, 4.0, charge_up_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
				$Timer.start(charge_up_time)
			elif can_evade and randf() < evade_chance:
				state = States.EVADING
				evade_direction = Evade.LEFT if randf() < 0.5 else Evade.RIGHT
				$Timer.start(evade_time)
		States.CHARGE_WINDUP:
			state = States.CHARGING
			var direction : Vector2 = (target.position - position).normalized()
			charge_target = position + direction * charge_distance.y * 1.1
			var time : float = position.distance_to(charge_target) / charge_speed
			#$Tween.interpolate_property($AnimationPlayer, "playback_speed", 4.0, 0.0, time, Tween.TRANS_QUINT, Tween.EASE_IN)
			#$Tween.start()
			$Timer.start(time)
		States.CHARGING:
			state = States.CHARGE_WINDDOWN
			$AnimationPlayer.stop()
			$Timer.start(charge_down_time)
		States.CHARGE_WINDDOWN:
			state = States.PURSUING
		States.IDLE:
			if randf() < wander_chance:
				state = States.WANDERING
				wander_direction = _get_random_direction()
				$Timer.start(wander_time)
		States.MATING:
			print("POP out a baby")
			state = States.IDLE
			target = player
			mate = null
		States.EVADING, States.FLEEING, States.WANDERING:
			state = States.IDLE

# Override these instead of the default _process/_physics_process.
func _on_process(_delta : float) -> void:
	pass
func _on_physics_process(_delta : float) -> void:
	pass