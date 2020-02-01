extends "res://scripts/Bullet.gd"

const scale_factor = 3
export var init_vertical_speed : float = -200 * scale_factor
export var gravitational_acceleration : float = 10 * scale_factor

var velocity = Vector2()
var y0 : float


func _ready():
	velocity = speed * direction + Vector2(0, init_vertical_speed)
	y0 = direction.y
	#$Timer.stop()


func _on_physics_process(_delta : float) -> void:
	if not $AnimationPlayer.is_playing():
		velocity += Vector2(0, gravitational_acceleration)# * _delta
		position += velocity * _delta
		#update rotation
	if false and  velocity.y + y0 < init_vertical_speed:
		despawn()

func _on_Timer_timeout():
	despawn()


func despawn():
	$CollisionShape2D.set_deferred("disabled", false)
	$AnimationPlayer.play("despawn")

func _on_AnimationPlayer_animation_finished(_anim_name):
	if not $CollisionShape2D.disabled:
		queue_free()