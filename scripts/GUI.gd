extends CanvasLayer

onready var score = $MarginContainer/VBoxContainer/HBoxContainer/Score
onready var money = $MarginContainer/VBoxContainer/HBoxContainer2/Money

func get_score():
	return int(score.text)

func set_score(new_score):
	score.text = str(new_score)

func get_money():
	return int(money.text)

func set_money(new_amount):
	money.text = str(new_amount)