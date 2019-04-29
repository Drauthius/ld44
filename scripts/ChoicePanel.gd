extends CanvasLayer

onready var text = $CenterContainer/Panel/VBoxContainer/Label
onready var yes_button = $CenterContainer/Panel/VBoxContainer/HBoxContainer/YesButton

signal respawn
signal give_up

func set_sum(respawn_cost, monies):
	text.text = text.text.replace("$0", "$" + str(respawn_cost))
	if respawn_cost > monies:
		yes_button.disabled = true

func can_respawn():
	return not yes_button.disabled

func _on_YesButton_pressed():
	emit_signal("respawn")
	queue_free()

func _on_NoButton_pressed():
	emit_signal("give_up")
	queue_free()