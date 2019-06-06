extends KinematicBody2D

export(int, 1, 1000) var movement_speed = 150
export(String, "enemy01", "enemy02", "enemy03", "enemy04") var sound
export(int, 1, 100) var hitpoints = 1
export(int, 0, 100) var worth = 5
export(float, 0.0, 1000.0) var despawn_time = 4.0

export(float, 0.0, 100.0) var alter_behaviour_time = 1.0
export(bool) var can_evade = false
export(float, 0.0, 1.0) var evade_chance = 0.5
export(float, 0.0, 100.0) var evade_time = 0.5

export(Vector2) var attack_distance
export(bool) var can_shoot = false
export(float, 0.1, 10.0) var shoot_time = 0.8
export(PackedScene) var Bullet = preload("res://scenes/BulletBig.tscn")
export(PackedScene) var MuzzleFlash = preload("res://scenes/MuzzleFlash.tscn")
export(float, 1, 1000) var bullet_speed = 180

export(bool) var rotate_collision = false # Whether to rotate the collision shape when going left/right

signal death(KinematicBody2D)

const HPI : float = PI/2.0
const QPI : float = PI/4.0
const STOPPED_SQUARED : float = 1000.0

enum States {SPAWNING, PURSUING, CHARGE, CHARGING, SHOOTING, EVADING, MATING, DEAD}
var state = States.SPAWNING

enum Evade {LEFT, RIGHT}
var evade_direction

onready var player = $"../Player"
onready var target = player
onready var attack_distance_squared = attack_distance * attack_distance

func _ready():
	SoundService.call(sound + "_spawn")

func _process(delta):
	if state == States.DEAD or not $Timer.is_stopped():
		return
	elif $"..".is_choosing: # TODO: Remove
		$AnimationPlayer.stop()
		return
	
	if state == States.SPAWNING:
		state = States.PURSUING
	elif can_shoot:
		var distance_squared = position.distance_squared_to(target.position)
		if distance_squared >= attack_distance_squared.x and distance_squared <= attack_distance_squared.y:
			state = States.SHOOTING
			$Timer.start(shoot_time)
		else:
			state = States.PURSUING
	elif state != States.EVADING:
		state = States.PURSUING
		
		if can_evade and $Timer.is_stopped():
			$Timer.start(alter_behaviour_time)
	
	_on_process(delta)

func _physics_process(delta):
	if state == States.DEAD:
		return
	elif $"..".is_choosing: # TODO: Remove
		return
	
	var direction = (target.position - position).normalized()
	if state == States.EVADING:
		if evade_direction == Evade.LEFT:
			direction = (direction - direction.tangent()).normalized()
		else:
			direction = (direction + direction.tangent()).normalized()
		
	if state == States.PURSUING or state == States.EVADING:
		var velocity = move_and_slide(direction * movement_speed, Vector2(0, 0), true, 1, 0.0, false)
		_set_sprite(direction.angle(), velocity.length_squared() <= STOPPED_SQUARED)
		
		# Check for player collision
		for i in range(get_slide_count()):
			var coll = get_slide_collision(i)
			if coll.collider == target:
				target.die()
	
	_on_physics_process(delta)

func die():
	hitpoints -= 1
	if hitpoints <= 0 and state != States.DEAD:
		SoundService.call(sound + "_death")
		state = States.DEAD
		
		$Tween.stop_all() # Make sure no tweening is going on
		$AnimationPlayer.playback_speed = 1.0 # Reset potentially modified playback speed
		
		$Timer.start(despawn_time)
		
		emit_signal("death", self)
	
	if hitpoints <= -3:
		$CollisionShape2D.set_deferred("disabled", true) # No longer affects physics
		$Timer.paused = true # Make sure the explosion isn't interrupted by a "normal" despawn
		if $AnimationPlayer.current_animation.begins_with("left_") or $AnimationPlayer.current_animation.begins_with("up_"):
			$AnimationPlayer.play("left_explosion")
		else:
			$AnimationPlayer.play("right_explosion")
		return
	
	# Play the death animation for every shot it receives
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
	
	if rotate_collision:
		$CollisionShape2D.rotation = HPI if wide else 0

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.ends_with("_explosion"):
		queue_free()

func _on_Tween_tween_completed(_object, _key):
	$AnimationPlayer.playback_speed = 1.0

func _on_Timer_timeout():
	match state:
		States.DEAD:
			queue_free()
		States.SHOOTING:
			var angle = target.position.angle_to_point(position) + PI
			var bullet = Bullet.instance() #GenEditState.GEN_EDIT_STATE_INSTANCE)
			bullet.position = get_global_transform().get_origin() - Vector2(16, 0).rotated(angle)
			bullet.rotation = angle - PI
			bullet.init(Color("e3c7ff"))
			bullet.lifetime = attack_distance.y / float(bullet_speed)
			bullet.speed = bullet_speed
			$Gun.add_child(bullet)
			SoundService.call(sound + "_gunshot")
			
			# Muzzle flash
			var muzzle_flash = MuzzleFlash.instance()
			muzzle_flash.position = -Vector2(16, 0).rotated(angle)
			muzzle_flash.rotation = bullet.rotation
			add_child(muzzle_flash)
		States.PURSUING:
			if can_evade and randf() < evade_chance:
				state = States.EVADING
				evade_direction = Evade.LEFT if randf() < 0.5 else Evade.RIGHT
				$Timer.start(evade_time)
		States.EVADING:
			state = States.PURSUING

# Override these instead of the default _process/_physics_process.
func _on_process(delta):
	pass
func _on_physics_process(delta):
	pass