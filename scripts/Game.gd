extends Node2D

onready var Enemy = preload("res://scenes/Enemy01.tscn")
onready var Scoreboard = preload("res://scenes/Scoreboard.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	$GUI.set_score(0)
	$ScoreTimer.start()

func _on_SpawnTimer_timeout():
	var spawn_point = randi() % $SpawnPoints.get_child_count()
	var enemy = Enemy.instance()
	enemy.position = $SpawnPoints.get_child(spawn_point).position
	enemy.connect("death", self, "_on_Enemy_death")
	add_child(enemy)

func _on_ScoreTimer_timeout():
	$GUI.set_score($GUI.get_score() + 1)

func _on_Enemy_death():
	$GUI.set_score($GUI.get_score() + 5)

func _on_Player_death():
	$ScoreTimer.stop()
	add_child(Scoreboard.instance())