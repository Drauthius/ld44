extends Area2D

export var speed : int = 400
export var lifetime : float = 0.4
export var push : int = 5

onready var direction = Vector2(cos(rotation), sin(rotation))

func _ready():
	$Timer.start(lifetime)

func init(color):
	#$Sprite.modulate = color
	pass

func _physics_process(delta):
	position += direction * speed * delta

func _on_Timer_timeout():
	queue_free()
	
func _on_Bullet_body_entered(body):
	if body == $"../..":
		return
	
	var groups = body.get_groups()
	if groups.has("Living"):
		# Push back
		body.position += direction * push
		body.die()
	queue_free()