extends Area2D

export var speed : int = 400
export var lifetime : float = 0.5

func _ready():
	$Timer.start(lifetime)

func init(color):
	$Sprite.modulate = color

func _physics_process(delta):
	position += Vector2(cos(rotation), sin(rotation)) * speed * delta

func _on_Timer_timeout():
	queue_free()
	
func _on_Bullet_body_entered(body):
	if body == $"..":
		return
	
	var groups = body.get_groups()
	if groups.has("Living"):
		body.die()
	queue_free()