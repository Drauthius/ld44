extends KinematicBody2D


export var health = 5
export var worth : int = 15

var is_dead = false

func _ready():
	pass



func get_worth():
	return worth

func die():
	SoundService.fleshthump() #TODO add sound
	if is_dead:
		return
	
	health -= 1
	if health <= 0:
		is_dead = true
		#SoundService.enemy02_death()
		emit_signal("death", self)
		$AnimationPlayer.play("death")
