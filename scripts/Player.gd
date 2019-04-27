extends KinematicBody2D

export var speed: int = 200

var angle = 0
var is_dead = false

const QPI = PI/4

onready var Bullet = preload("res://scenes/Bullet.tscn")

func _process(_delta):
	if is_dead:
		return
	
	angle = (get_global_mouse_position() - position).angle() + PI
	
	if angle > 5*QPI and angle < 7*QPI:
		$AnimationPlayer.play("down")
	elif angle > 3*QPI and angle < 5*QPI:
		$AnimationPlayer.play("right")
	elif angle > QPI and angle < 3*QPI:
		$AnimationPlayer.play("up")
	else:
		$AnimationPlayer.play("left")
	$AnimationPlayer.advance(0.01)

func _physics_process(_delta):
	if is_dead:
		return
	
	# Movement
	var dir = Vector2(0, 0)

	if Input.is_action_pressed("game_down"):
		dir.y += 1
	if Input.is_action_pressed("game_up"):
		dir.y -= 1
	if Input.is_action_pressed("game_right"):
		dir.x += 1
	if Input.is_action_pressed("game_left"):
		dir.x -= 1
	
	var velocity = move_and_slide(dir.normalized() * speed)
	
	if velocity.length_squared() <= 0.001:
		$AnimationPlayer.stop()
	else:
		$AnimationPlayer.play()
	
	# Firing
	if Input.is_action_just_pressed("game_fire"):
		var bullet = Bullet.instance()
		bullet.position = -Vector2(16, 0).rotated(angle)
		bullet.rotation = angle - PI
		bullet.init(Color("002868"))
		add_child(bullet)

func die():
	if not is_dead:
		is_dead = true
		$AnimationPlayer.play("death")