extends Node

var loops = {
#	"drum_01_main_menu": AudioStreamPlayer.new(),
}

var sfx = {
	"gunshot_player": AudioStreamPlayer.new(),
	"meny_click": AudioStreamPlayer.new(),
	"end_game": AudioStreamPlayer.new(),
	"weapon_hit": AudioStreamPlayer.new()
}


var current_bg_music = {
#	"drums": null,
#	"koto": null,
	"music": null
}

var next_bg_music = {
#	"drums": null,
#	"koto": null,
	"music": null
}

func _ready():
#	loops.drum_01_main_menu.stream = preload("res://assets/sounds/music/drums 01 - menu.wav")
	
	sfx.gunshot_player.stream = preload("res://sounds/sfx/gun01.wav")
	
	for key in loops:
		add_child(loops[key])
		loops[key].connect("finished", self, "_on_sound_finished")
		loops[key].set_bus("Music")
		
	for key in sfx:
		add_child(sfx[key])
	
	#something
#	physics_start_player.stream = preload("res://music/physics_start.wav")

func stop_all_music():
	for key in loops:
		if loops[key] != null:
			loops[key].stop()
	for key in current_bg_music:
		current_bg_music[key] = null
		next_bg_music[key] = null

func _on_sound_finished():
	for key in next_bg_music:
		if next_bg_music[key] != null:
			current_bg_music[key] = next_bg_music[key]
	for key in current_bg_music:
		if current_bg_music[key] != null:
			current_bg_music[key].play()
#	if(next_bg_music != null):
#		current_bg_music = next_bg_music
#	current_bg_music.play()
	pass

func play_or_queue(loops):
	var all_are_null = true
	var at_least_one_is_null = false
	for key in loops:
		if current_bg_music[key] == null:
			current_bg_music[key] = loops[key]
			at_least_one_is_null = true
		else:
			all_are_null = false
	print("all_are_null ", all_are_null, "; at_least_one_is_null ", at_least_one_is_null)
	if all_are_null:
		for key in current_bg_music:
			if current_bg_music[key] != null:
				current_bg_music[key].play()
				print("bus ", current_bg_music[key].get_bus() )
	elif at_least_one_is_null:
		pass
	for key in loops:
		next_bg_music[key] = loops[key]

func main_menu():
	var loopses = {
		"drums":loops.drum_01_main_menu,
		"koto": null,
		"flute": null
		}
	play_or_queue(loopses)

func survive_2x_waves():
	var loopses = {
		"drums":loops.drum_04_survive_2x_waves,
		"koto": loops.koto_01_heated_battle,
		"flute": loops.flute_01_lohealth
		}
	play_or_queue(loopses)

func death_scene_transition():
	sfx.death_scene_transition.play()
	pass

func weapon_sacrifice():
	sfx.weapon_sacrifice.play()
	pass

func gunshot_player():
	sfx.gunshot_player.play()

func click():
	sfx.click.play()

func weapon_crit():
	sfx.weapon_crit.play()
	
func weapon_hit():
	sfx.weapon_hit.play()

func endgame():
	sfx.endgame.play()