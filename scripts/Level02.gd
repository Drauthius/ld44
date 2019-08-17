extends "res://scripts/Game.gd"

func _on_SpawnTimer_timeout() -> void:
	var num_spawns : int = 0
	while num_spawns < $GUI.get_score() / 100 + 1:
		var rand : float = randf()
		var enemy_index : int = int(rand * rand * Enemies.size())
		num_spawns += enemy_index + 1
		spawn_enemy(Enemies[enemy_index])