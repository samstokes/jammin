extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	$BeatTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_beat_timer_timeout() -> void:
	$BeatTracker.beat_ready()
	remove_theme_color_override("font_color")
	show()
	await get_tree().create_timer(0.2).timeout
	$BeatTracker.beat_expired()
	await get_tree().create_timer(0.3).timeout
	hide()


func _on_beat_tracker_hit() -> void:
	add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)


func _on_beat_tracker_miss() -> void:
	add_theme_color_override("font_color", Color.RED)
