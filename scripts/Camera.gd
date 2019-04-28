extends Camera2D

var shake_magnitude

func _ready():
	make_current()
	set_process(false)
	
func _process(_delta):
	#if not $CompleteTimer.is_stopped():
	set_offset(Vector2(rand_range(-shake_magnitude.x, shake_magnitude.x), rand_range(-shake_magnitude.y, shake_magnitude.y)))

func shake(magnitude, time):
	shake_magnitude = magnitude
	
	set_process(true)
	$CompleteTimer.wait_time = time
	$CompleteTimer.start()

func _on_CompleteTimer_timeout():
	set_offset(Vector2(0, 0))
	set_process(false)