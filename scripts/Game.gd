extends Node2D

onready var Enemies = [
	preload("res://scenes/Enemy01.tscn"),
	preload("res://scenes/Enemy02.tscn")
]
onready var Scoreboard = $"/root/Scoreboard"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	$GUI.set_score(0)
	Scoreboard.hide()
	$ScoreTimer.start()
	SoundService.game_start()

func _on_SpawnTimer_timeout():
	SoundService.game()
	var num_spawns = 0
	while num_spawns < $GUI.get_score() / 50 + 1:
		var spawn_point = randi() % $SpawnPoints.get_child_count()
		var enemy = null
		var enemy_index = null
		if $GUI.get_score() < 100:
			var rand = randf()
			enemy_index = int(rand * rand * 2)
		else:
			var rand = randf()
			enemy_index = int(rand * rand * Enemies.size())
			#enemy_index = randi() % Enemies.size()
			
		num_spawns += enemy_index + 1
		enemy = Enemies[enemy_index].instance()
		enemy.position = $SpawnPoints.get_child(spawn_point).position
		enemy.connect("death", self, "_on_Enemy_death")
		add_child(enemy)
	
	

func _on_ScoreTimer_timeout():
	$GUI.set_score($GUI.get_score() + 1)

func _on_Enemy_death():
	if not $ScoreTimer.is_stopped():
		$GUI.set_score($GUI.get_score() + 5)
		$GUI.set_money($GUI.get_money() + 5)

func _on_Player_death():
	$ScoreTimer.stop()
	Scoreboard.show()
	Scoreboard.add_score($GUI.get_score())