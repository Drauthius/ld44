extends KinematicBody2D

var player
var direction = Vector2()
export var normal_speed = 100
export var max_speed = 400

func _ready():
	player = $"../Player"
#	player = get_parent().get_node("Player")
	pass 

func _physics_process(delta):
	var current_speed = normal_speed
	direction = (player.position - position).normalized()
	move_and_slide(direction * current_speed)
	
	var QPI = PI/4.0
	var angle = direction.angle() + PI
	
	if angle > 5*QPI:
		$AnimationPlayer.play("down_run")
	elif angle > 3*QPI:
		$AnimationPlayer.play("right_run")
	elif angle > QPI:
		$AnimationPlayer.play("up_run")
	else:
		$AnimationPlayer.play("left_run")
	$AnimationPlayer.advance(0.01)
	
	pass

func die():
	queue_free()
	pass
