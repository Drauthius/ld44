#belongs to ExplosionArea -> rename from LaserFocus.gd!!
extends Area2D

export var lifetime : float = 0.35
export var push : int = 5

var remove = false

func _ready():
	$Timer.set_wait_time(0.9)
	$Timer.start()
	pass 


func _on_Timer_timeout():
	$CollisionShape2D.disabled = false

func _on_AnimationPlayer_animation_finished(anim_name):
	$CollisionShape2D.disabled = true
	queue_free()


func _on_ExplosionArea_body_entered(body):
	if body.is_in_group("Living"):
		if not body.is_in_group("Immovable"):
			# Push back
			var direction = (position - body.position).normalized()
			body.position += direction * push
		body.die()
