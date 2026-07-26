extends TextureRect

func _ready() -> void:
	gui_input.connect(_on_settings_clicked)

func _on_settings_clicked(event)-> void:
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		
