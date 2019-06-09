extends Area2D

export var speed : float = 400.0
export var lifetime : float = 0.35
export var push : int = 5

onready var direction = Vector2(cos(rotation), sin(rotation))

func _ready():
	spawn()

func spawn():
	$Timer.start(lifetime)

func despawn():
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("despawn")

func init(color):
	$Sprite.self_modulate = color

func _physics_process(delta):
	if not $AnimationPlayer.is_playing():
		position += direction * speed * delta

func _on_Timer_timeout():
	despawn()
	
func _on_Bullet_body_entered(body):
	if body == $"../..":
		return
	
	if body.is_in_group("Living"):
		if not body.is_in_group("Immovable"):
			# Push back
			body.position += direction * push
		body.die()
	
	despawn()

func _on_AnimationPlayer_animation_finished(_anim_name):
	if $CollisionShape2D.disabled:
		queue_free()