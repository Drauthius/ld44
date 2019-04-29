extends Node2D

export var respawn_cost_initial : int = 150
export var respawn_cost_increase_per_death : int = 100

var is_choosing = false

onready var Enemies = [
	preload("res://scenes/Enemy01.tscn"),
	preload("res://scenes/Enemy02.tscn"),
	preload("res://scenes/Enemy03.tscn")
]
onready var ChoicePanel = preload("res://scenes/ChoicePanel.tscn")
onready var Outhouse = preload("res://scenes/Outhouse.tscn")
onready var Scoreboard = $"/root/Scoreboard"

func _ready():
	randomize()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	$GUI.set_score(0)
	Scoreboard.hide()
	$ScoreTimer.start()
	SoundService.game_start()
	SoundService.game()

func _on_SpawnTimer_timeout():
	var num_spawns = 0
	while num_spawns < $GUI.get_score() / 75 + 1:
		var difficulty = $GUI.get_score() / 50
		var enemy_index = null
		if $GUI.get_score() < 200:
			var rand = randf()
			enemy_index = int(rand * rand * 2)
		else:
			var rand = randf()
			enemy_index = int(rand * rand * Enemies.size())
			
		num_spawns += enemy_index + 1
		
		var enemy = Enemies[enemy_index].instance()
		var spawn_point = randi() % $SpawnPoints.get_child_count()
		enemy.position = $SpawnPoints.get_child(spawn_point).position
		enemy.difficulty = difficulty
		add_child(enemy)
		enemy.connect("death", self, "_on_Enemy_death")

func _on_ScoreTimer_timeout():
	$GUI.set_score($GUI.get_score() + 1)

func _on_Enemy_death(enemy):
	if not $ScoreTimer.is_stopped():
		$GUI.set_score($GUI.get_score() + 5)
		$GUI.set_money($GUI.get_money() + enemy.get_worth())

func _on_Player_death():
	$ScoreTimer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Don't give players that can't shoot straight an option.
	if $GUI.get_score() > 10:
		var choice = ChoicePanel.instance()
		add_child(choice)
		choice.connect("give_up", self, "_on_Choice_give_up")
		choice.connect("respawn", self, "_on_Choice_respawn")
		choice.set_sum(respawn_cost_initial + respawn_cost_increase_per_death * ($Player.num_deaths - 1), $GUI.get_money())
		$SpawnTimer.paused = true
		is_choosing = choice.can_respawn()
	else:
		_on_Choice_give_up()

func _on_Choice_give_up():
	is_choosing = false
	
	Scoreboard.show()
	Scoreboard.add_score($GUI.get_score())
	$SpawnTimer.paused = false # Let them loose

func _on_Choice_respawn():
	SoundService.katching()
	$GUI.set_money($GUI.get_money() - (respawn_cost_initial + respawn_cost_increase_per_death * ($Player.num_deaths - 1)))
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	var outhouse = Outhouse.instance()
	add_child(outhouse)
	outhouse.position = $Player.position
	outhouse.connect("dropped", self, "_on_Outhouse_dropped")
	outhouse.connect("exploded", self, "_on_Outhouse_exploded")
	outhouse.connect("opened", self, "_on_Outhouse_opened")

func _on_Outhouse_dropped(bodies):
	for body in bodies:
		if body.is_in_group("Living"):
			body.die()
	$Player.get_node("Camera2D").shake(Vector2(5, 5), 0.4)
	$Player.respawn()

func _on_Outhouse_exploded():
	$Player.get_node("Camera2D").shake(Vector2(5, 5), 0.4)

func _on_Outhouse_opened():
	$ScoreTimer.start()
	$SpawnTimer.paused = false
	$Player.is_dead = false
	is_choosing = false # Start the enemies a little later