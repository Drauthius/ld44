extends "res://scripts/Bullet.gd"

export var vertical_speed : float = 50
export var gravitational_acceleration : float = 10

var velocity = Vector2()
var init_vertical_speed : float


func _ready():
	velocity = speed * direction + Vector2(0, vertical_speed)
	init_vertical_speed = direction.y


func _on_physics_process(_delta : float) -> void:
	if not $AnimationPlayer.is_playing():
		velocity += Vector2(0, gravitational_acceleration) * _delta
		position += velocity * _delta
		#update rotation
	if velocity.y + init_vertical_speed < vertical_speed:
		despawn()