extends Node

onready var SoundService = $"/root/SoundService"


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if (Input.is_key_pressed(KEY_A)):
		SoundService.main_menu()
		pass
	if (Input.is_key_pressed(KEY_DOWN)):
		SoundService.stop_all_music()
		pass
	if (Input.is_key_pressed(KEY_S)):
		SoundService.start_battle()
		pass
	if (Input.is_key_pressed(KEY_D)):
		SoundService.survive_x_waves()
		pass
	if (Input.is_key_pressed(KEY_D)):
		SoundService.survive_2x_waves()
		pass
	if (Input.is_key_pressed(KEY_F)):
		SoundService.death_scene_transition()
		pass
	pass
	
