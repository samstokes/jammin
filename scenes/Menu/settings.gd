extends TextureRect

func _ready() -> void:
	gui_input.connect(_on_settings_clicked)

func _on_settings_clicked(event)-> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var tween = create_tween().set_parallel(true)
		if event.pressed:
			tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.1)
		else:
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
			await tween.finished
