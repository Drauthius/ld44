extends CanvasLayer

onready var score = $MarginContainer/HBoxContainer/Score

func get_score():
	return int(score.text)

func set_score(new_score):
	score.text = str(new_score)