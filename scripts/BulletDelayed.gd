extends "res://scripts/Bullet.gd"

func _ready():
	speed = 300
	lifetime = 0.95
	push = 10

func spawn():
	$AnimationPlayer.play("spawn")
	$Timer.start($AnimationPlayer.get_animation("spawn").get_length() + lifetime)

func despawn():
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play_backwards("spawn")