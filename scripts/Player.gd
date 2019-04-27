extends KinematicBody2D

export var speed: int = 300

func _physics_process(delta):
	var dir = Vector2(0, 0)
	
	if Input.is_action_pressed("game_down"):
		dir.y += 1
	if Input.is_action_pressed("game_up"):
		dir.y -= 1
	if Input.is_action_pressed("game_right"):
		dir.x += 1
	if Input.is_action_pressed("game_left"):
		dir.x -= 1
	
	move_and_slide(dir.normalized() * speed)