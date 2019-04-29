extends Node2D

export var respawn_cost_initial : int = 150

onready var Enemies = [
	preload("res://scenes/Enemy01.tscn"),
	preload("res://scenes/Enemy02.tscn")
]
onready var ChoicePanel = preload("res://scenes/ChoicePanel.tscn")
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
		var difficulty = $GUI.get_score() / 50
		var enemy_index = null
		if $GUI.get_score() < 100:
			var rand = randf()
			enemy_index = int(rand * rand * 2)
		else:
			var rand = randf()
			enemy_index = int(rand * rand * Enemies.size())
			
		num_spawns += enemy_index + 1
		var enemy = Enemies[enemy_index].instance()
		enemy.position = $SpawnPoints.get_child(spawn_point).position
		enemy.worth = (enemy_index + 1) * 5
		enemy.difficulty = difficulty
		add_child(enemy)
		enemy.connect("death", self, "_on_Enemy_death")

func _on_ScoreTimer_timeout():
	$GUI.set_score($GUI.get_score() + 1)

func _on_Enemy_death(enemy):
	if not $ScoreTimer.is_stopped():
		$GUI.set_score($GUI.get_score() + 5)
		$GUI.set_money($GUI.get_money() + enemy.worth)

func _on_Player_death():
	$ScoreTimer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Don't give players that can't shoot straight an option.
	if $GUI.get_score() > 10:
		var choice = ChoicePanel.instance()
		add_child(choice)
		choice.connect("give_up", self, "_on_Choice_give_up")
		choice.connect("respawn", self, "_on_Choice_respawn")
		choice.set_sum(respawn_cost_initial * pow($Player.num_deaths, 2), $GUI.get_money())
		$SpawnTimer.paused = true
	else:
		_on_Choice_give_up()

func _on_Choice_give_up():
	Scoreboard.show()
	Scoreboard.add_score($GUI.get_score())

func _on_Choice_respawn():
	$ScoreTimer.start()
	$GUI.set_money($GUI.get_money() - respawn_cost_initial * pow($Player.num_deaths, 2))
	$SpawnTimer.paused = false
	$Player.respawn()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)