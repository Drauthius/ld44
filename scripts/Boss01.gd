extends "res://scripts/Enemy.gd"

func _play_sound(clip : String):
	SoundService.call(sound + "_" + clip)