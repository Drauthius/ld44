extends Node2D

export(float, 0.01, 100.0) var spawn_time = 2.75

export(bool) var has_score = false
export(float, 0.01, 100.0) var score_time = 1.0

onready var Enemies : Array = [
	preload("res://scenes/Enemy01.tscn"),
	preload("res://scenes/Enemy02.tscn"),
	preload("res://scenes/Enemy03.tscn"),
	preload("res://scenes/Enemy04.tscn"),
	preload("res://scenes/Enemy05.tscn")
]

onready var Bosses : Array = [
	preload("res://scenes/Boss01.tscn")
]

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	SoundService.game()
	$SpawnTimer.start(spawn_time)
	
	$GUI.set_score(0)
	if has_score:
		$ScoreTimer.start(score_time)
	else:
		$GUI.hide_score()

func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("spawn_enemy_01"):
		spawn_enemy(Enemies[0])
	if Input.is_action_just_pressed("spawn_enemy_02"):
		spawn_enemy(Enemies[1])
	if Input.is_action_just_pressed("spawn_enemy_03"):
		spawn_enemy(Enemies[2])
	if Input.is_action_just_pressed("spawn_enemy_04"):
		spawn_enemy(Enemies[3])
	if Input.is_action_just_pressed("spawn_enemy_05"):
		spawn_enemy(Enemies[4])
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func spawn_enemy(Enemy : PackedScene) -> void:
	var enemy = Enemy.instance()
	var spawn_point = randi() % $SpawnPoints.get_child_count()
	enemy.position = $SpawnPoints.get_child(spawn_point).position
	enemy.position += Vector2(randf() * 6 - 3, randf() * 6 - 3) # Variance to avoid some physics problems hopefully
	add_child(enemy)
	enemy.connect("death", self, "_on_Enemy_death")

func _on_SpawnTimer_timeout() -> void:
	pass # Replace in subclass.

func _on_ScoreTimer_timeout() -> void:
	$GUI.set_score($GUI.get_score() + 1)

func _on_Player_death() -> void:
	$ScoreTimer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Death")

func _on_Enemy_death(enemy : Enemy) -> void:
	if $Player.is_dead:
		return
	
	if has_score:
		$GUI.set_score($GUI.get_score() + 5)
	
	$GUI.set_money($GUI.get_money() + enemy.get_worth())