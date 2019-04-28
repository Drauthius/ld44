extends KinematicBody2D

const QPI = PI/4.0

export var normal_speed = 90
export var shooting_distance = 200
export var evasion_distance = 150
export var bullet_speed = 180
var shooting_distance_sqrd = shooting_distance*shooting_distance
var evasion_distance_sqrd = evasion_distance*evasion_distance
#export var max_speed = 400
export var cornered_distance = 20
export var bounds = Vector2(1024, 600)

export var time_until_removal = 4
export var time_until_next_shot = 0.8
var death_timer = 0.0
var shooting_timer = 0.0
var is_dead = false
var worth = 0
var difficulty = 0

signal death(KinematicBody2D)

var behaviour_timer = 0.0
export var timer_long = 2.0
export var timer_short = 0.2
var angle = 0.0

enum {PURSUE, SHOOT, EVADE, RIGHT, LEFT} 
var behaviour_state = PURSUE
var rand_direction = RIGHT

onready var player = $"../Player"

onready var Bullet = preload("res://scenes/BulletBig.tscn")
onready var MuzzleFlash = preload("res://scenes/MuzzleFlash.tscn")
onready var SoundService = $"/root/SoundService"

func _ready():
	SoundService.enemy02_spawn()
	if difficulty <= 2:
		time_until_next_shot *= max(1, 2 - difficulty)

func _physics_process(delta):
	if is_dead:
		death_timer += delta
		if death_timer > time_until_removal:
			queue_free()
		return
	
	var player_distance_sqrd = position.distance_squared_to(player.position)
	angle = (-position + player.position).angle() + PI
	
	if behaviour_state == PURSUE:
		if player_distance_sqrd < shooting_distance_sqrd:
			behaviour_state = SHOOT
		pass
	elif behaviour_state == SHOOT:
		if player_distance_sqrd < evasion_distance_sqrd:
			if position.x >= cornered_distance and position.y >= cornered_distance and \
			   position.x <= bounds.x - cornered_distance and position.y <= bounds.y - cornered_distance:
				if difficulty > 2:
					behaviour_state = EVADE
		elif player_distance_sqrd > shooting_distance_sqrd:
			behaviour_state = PURSUE
	
	var current_speed = normal_speed
	var direction = (player.position - position).normalized()
	
	#evasion handling
	if behaviour_state == EVADE:
		behaviour_timer += delta
		if rand_direction == RIGHT:
			direction = (-direction + direction.tangent()).normalized()
		else:
			direction = (-direction - direction.tangent()).normalized()
		if behaviour_timer > timer_short:
			behaviour_timer = 0.0
			behaviour_state = PURSUE
	
	#movement handling
	if behaviour_state != SHOOT:
		var _velocity = move_and_slide(direction * current_speed, Vector2(0, 0), true, 1, 0.0, false)
		if angle > 5*QPI and angle < 7*QPI:
			$AnimationPlayer.play("down_run")
		elif angle > 3*QPI and angle < 5*QPI:
			$AnimationPlayer.play("right_run")
		elif angle > QPI and angle < 3*QPI:
			$AnimationPlayer.play("up_run")
		else:
			$AnimationPlayer.play("left_run")
	
	#handle shooting
	if behaviour_state == SHOOT:
		if angle > 5*QPI and angle < 7*QPI:
			$AnimationPlayer.play("down")
		elif angle > 3*QPI and angle < 5*QPI:
			$AnimationPlayer.play("right")
		elif angle > QPI and angle < 3*QPI:
			$AnimationPlayer.play("up")
		else:
			$AnimationPlayer.play("left")
		
		if shooting_timer < time_until_next_shot:
			shooting_timer += delta
		else:
			shooting_timer = 0.0
			var bullet = Bullet.instance()
			bullet.position = get_global_transform().get_origin() - Vector2(16, 0).rotated(angle)
			bullet.rotation = angle - PI
			bullet.init(Color("e3c7ff"))
			bullet.lifetime = shooting_distance / float(bullet_speed)
			bullet.speed = bullet_speed
			$Gun.add_child(bullet)
			SoundService.gunshot_enemy02()
			
			# Muzzle flash
			var muzzle_flash = MuzzleFlash.instance()
			muzzle_flash.position = -Vector2(16, 0).rotated(angle)
			muzzle_flash.rotation = bullet.rotation
			add_child(muzzle_flash)
		pass

func die():
	if not is_dead:
		is_dead = true
		SoundService.enemy02_death()
		#set_deferred("$CollisionShape2D.disabled", true)
		emit_signal("death", self)
		$AnimationPlayer.play("left_death")
	else:
		$AnimationPlayer.play("left_death")
		$AnimationPlayer.seek(0.1)

