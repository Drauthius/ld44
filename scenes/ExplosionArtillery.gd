extends "res://scripts/Bullet.gd"

#extends "res://scripts/ExplosionTimed.gd"



export var max_height = 100
var parabola_shift_distance = 0
export var target_position = Vector2()
export var gravity_g = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	parabola_shift_distance = sqrt(2.0*max_height/gravity_g)
	$Timer.set_wait_time(0.9)
	$Timer.start()
	$AnimationPlayer.play("TimedExplosionAnimation")

func _process(_delta : float) -> void:
	
	pass

