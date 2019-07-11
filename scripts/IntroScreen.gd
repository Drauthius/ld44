extends TextureRect

func _ready():
	randomize()
	SoundService.main_menu()

func _on_StartButton_pressed():
	SoundService.game_start()
	var _err = get_tree().change_scene("res://scenes/Level01.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()