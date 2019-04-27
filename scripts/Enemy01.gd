extends KinematicBody2D

const QPI = PI/4.0

export var normal_speed = 150
export var max_speed = 400
export var time_until_removal = 4

var death_timer = 0.0
var is_dead = false

onready var player = $"../Player"

func _physics_process(delta):
	if is_dead:
		death_timer += delta
		if death_timer > time_until_removal:
			queue_free()
		return
	
	var current_speed = normal_speed
	var direction = (player.position - position).normalized()
	move_and_slide(direction * current_speed)
	
	var angle = direction.angle() + PI
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
	$AnimationPlayer.advance(0.01)
	
	# They're very oblong, so rotate the collision shape.
	if wide:
		$CollisionShape2D.rotation = PI/2
	else:
		$CollisionShape2D.rotation = 0
	
	for i in range(get_slide_count()):
		var coll = get_slide_collision(i)
		if coll.collider == player:
			player.die()
			$AnimationPlayer.stop()

func die():
	is_dead = true
	$CollisionShape2D.disabled = true
	
	$AnimationPlayer.play($AnimationPlayer.current_animation.replace("_run", "_death"))