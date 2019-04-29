extends Node2D

signal dropped(bodies)
signal exploded
signal opened

func _ready():
	$AnimationPlayer.play("drop")

func _on_Sprite_dropped():
	emit_signal("dropped", $DropZone.get_overlapping_bodies())
	$DropZone/CollisionShape2D.set_deferred("disabled", true)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "drop":
		emit_signal("exploded")
		$AnimationPlayer.play("open")
	else:
		emit_signal("opened")