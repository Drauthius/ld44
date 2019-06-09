extends TextureRect

func _ready():
	SoundService.main_menu()

func _on_StartButton_pressed():
	SoundService.game_start()
	var _err = get_tree().change_scene("res://scenes/Game.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()