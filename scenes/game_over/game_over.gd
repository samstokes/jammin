extends Node

@onready var retry_button: Button = %RetryButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_button_pressed)

func _on_retry_button_pressed() -> void:
	SceneManager.transition_to_clock_jam()
