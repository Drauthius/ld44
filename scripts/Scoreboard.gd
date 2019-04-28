extends CanvasLayer

const API_KEY_FILE = "res://resources/gamejolt_api_key.res"
const SAVE_FILE = "user://savegame.save"

onready var global_list_rank = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Rank
onready var global_list_name = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Name
onready var global_list_score = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Score
onready var local_list = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ItemList

onready var post_label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Label
onready var post_edit = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/LineEdit
onready var post_button = $ColorRect/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/Button

onready var highlight_color = $ColorRect.theme.get("Button/styles/normal").bg_color

var can_connect = false
var current_score

func _ready():
	hide()
	
	# API key is secret
	var file = File.new()
	if file.open(API_KEY_FILE, File.READ) == 0:
		var api_key = file.get_line()
		file.close()
		
		$GameJoltAPI.private_key = api_key
		can_connect = true
		_set_global_list_message("Connecting", Color(0.8, 0.8, 0.2))
	
	# Read old save data
	if file.open(SAVE_FILE, File.READ) == 0:
		var json = parse_json(file.get_line())
		if not json["name"].empty():
			post_edit.text = json["name"]
		for score in json["scores"]:
			local_list.add_item(str(score))
		file.close()

func show():
	$ColorRect.show()
	$GameJoltAPI.fetch_global_scores()

func hide():
	$ColorRect.hide()

func disable_posting(reason = null):
	post_label.text = reason if reason else "Score too low (<100)"
	post_edit.editable = false
	post_button.disabled = true

func enable_posting(reason = null):
	post_label.text = reason if reason else "Post score"
	post_edit.editable = true
	post_button.disabled = post_edit.text.empty()

func add_score(score):
	current_score = score
	
	local_list.add_item(str(score))
	var count = local_list.get_item_count()
	local_list.set_item_custom_bg_color(count - 1, highlight_color)
	
	var swapped = true
	while swapped:
		swapped = false
		for i in range(1, count):
			if int(local_list.get_item_text(i-1)) < int(local_list.get_item_text(i)):
				local_list.move_item(i-1, i)
				swapped = true
		count = count - 1
	
	# Save only the top 10
	while local_list.get_item_count() > 10:
		local_list.remove_item(10)
	
	if not can_connect:
		_set_global_list_message("Connection failed", Color(0.8, 0.2, 0.2))
		disable_posting("Connection failed")
	elif score < 100:
		disable_posting()
	else:
		enable_posting()
	
	_save()

func _save():
	var save = {
		"name": post_edit.text,
		"scores": []
	}
	for i in range(0, local_list.get_item_count()):
		save.scores.append(int(local_list.get_item_text(i)))
		
	var file = File.new()
	if file.open(SAVE_FILE, File.WRITE) == 0:
		file.store_line(to_json(save))
		file.close()

func _set_global_list_message(msg = null, color = null):
	global_list_rank.clear()
	global_list_name.clear()
	global_list_score.clear()
	if msg:
		global_list_name.add_item(msg)
		if color:
			global_list_name.set_item_custom_fg_color(0, color)

func _on_RestartButton_pressed():
	var err = get_tree().reload_current_scene()
	if err != 0:
		print(err)

func _on_PostButton_pressed():
	disable_posting("Posting score...")
	$GameJoltAPI.add_guest_score(str(current_score), int(current_score), post_edit.text)
	_save()

func _on_PostName_text_changed(new_text):
	post_button.disabled = new_text.empty()

func _on_GameJoltAPI_gamejolt_request_completed(requestResults):
	if requestResults.requestPath == "/scores/":
		_set_global_list_message()
		if $GameJoltAPI.is_ok(requestResults):
			var scores = requestResults.responseBody.scores
			for i in range(scores.size()):
				global_list_rank.add_item(str(i+1))
				global_list_name.add_item(scores[i].guest)
				global_list_score.add_item(str(scores[i].score))
				if scores[i].guest == post_edit.text:
					global_list_rank.set_item_custom_bg_color(i, highlight_color)
					global_list_name.set_item_custom_bg_color(i, highlight_color)
					global_list_score.set_item_custom_bg_color(i, highlight_color)
		else:
			_set_global_list_message("Connection failed", Color(0.8, 0.2, 0.2))
			disable_posting("Connection failed")
	else:
		if $GameJoltAPI.is_ok(requestResults):
			post_label.text = "Score posted"
			$GameJoltAPI.fetch_global_scores()
		else:
			enable_posting("Post failed")