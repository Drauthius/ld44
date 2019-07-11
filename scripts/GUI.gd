extends CanvasLayer

onready var money = $MarginContainer/VBoxContainer/HBoxContainer/Money
onready var score = $MarginContainer/VBoxContainer/HBoxContainer2/Score

func _ready():
	score.get_parent().show()

func get_score():
	return int(score.text)

func set_score(new_score):
	score.text = str(new_score)

func hide_score():
	score.get_parent().hide()

func get_money():
	return int(money.text)

func set_money(new_amount):
	money.text = "$" + str(new_amount)