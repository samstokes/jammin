extends TextureRect

@export var main_game_path: = "res://scenes/clock_jam/clock_jam.tscn"

func _ready() -> void:
	gui_input.connect(_on_start_opt_clicked)

func _on_start_opt_clicked(event)-> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var tween = create_tween().set_parallel(true)
		if event.pressed:
			tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.1)
		else:
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
			await get_tree().create_timer(0.2).timeout
			get_tree().change_scene_to_file(main_game_path)
		
