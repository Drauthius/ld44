extends KinematicBody2D

var player
var direction = Vector2()
export var normal_speed = 100
export var max_speed = 400
var is_dead = false
var death_timer
export var time_until_removal = 4

func _ready():
	player = $"../Player"
	death_timer = 0.0
#	player = get_parent().get_node("Player")
	pass 

func _physics_process(delta):
	if is_dead:
		death_timer += delta
		if death_timer > time_until_removal:
			queue_free()
		return
	var current_speed = normal_speed
	direction = (player.position - position).normalized()
	move_and_slide(direction * current_speed)
	
	var QPI = PI/4.0
	var angle = direction.angle() + PI
	
	if angle > 5*QPI and angle < 7*QPI:
		$AnimationPlayer.play("down_run")
	elif angle > 3*QPI and angle < 5*QPI:
		$AnimationPlayer.play("right_run")
	elif angle > QPI and angle < 3*QPI:
		$AnimationPlayer.play("up_run")
	else:
		$AnimationPlayer.play("left_run")
	$AnimationPlayer.advance(0.01)
	
	pass

func die():
	is_dead = true
	$CollisionShape2D.disabled = true
	
	var QPI = PI/4.0
	var angle = direction.angle() + PI
	
	if angle > 5*QPI and angle < 7*QPI:
		$AnimationPlayer.play("down_death")
	elif angle > 3*QPI and angle < 5*QPI:
		$AnimationPlayer.play("right_death")
	elif angle > QPI and angle < 3*QPI:
		$AnimationPlayer.play("up_death")
	else:
		$AnimationPlayer.play("left_death")
#	$AnimationPlayer.advance(0.01)
	pass
