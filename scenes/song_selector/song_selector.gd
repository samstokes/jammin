extends Panel

# id will be one of those in song_registry.json
signal selected(song_id: int)

var selected_id: int = -1

func _on_option_button_item_selected(index: int) -> void:
	if index < 0:
		# if they deselected a previously selected song - I think the UI makes this impossible
		%Button.text = "Choose for me!"
	else:
		selected_id = %SongsOptionButton.get_item_id(index)
		%Button.text = "Play!"


func _on_button_pressed() -> void:
	if selected_id < 0:
		var random_idx = randi_range(0, %SongsOptionButton.item_count - 1)
		%SongsOptionButton.call_deferred("select", random_idx)
		selected.emit(%SongsOptionButton.get_item_id(random_idx))
	else:
		selected.emit(selected_id)
