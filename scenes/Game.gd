extends Node2D

onready var Enemy = preload("res://scenes/Enemy01.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_SpawnTimer_timeout():
	var spawn_point = randi() % $SpawnPoints.get_child_count()
	var enemy = Enemy.instance()
	enemy.position = $SpawnPoints.get_child(spawn_point).position
	add_child(enemy)