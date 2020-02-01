extends Node2D

signal on_hit(Node2D)

func _on_Area2D_area_entered(area):
	emit_signal("on_hit", area.owner)
