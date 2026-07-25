extends Node

var game_scene = preload("res://scenes/clock_jam/clock_jam.tscn")

func transition_to_clock_jam() -> void:
	var root = get_tree().root
	var current_scene = get_tree().current_scene

	# Remove the current scene and free its resources
	root.remove_child(current_scene)
	current_scene.queue_free()

	# Instantiate the new game scene and set it as the current scene
	# Here we could optionally pass parameters to the new scene if needed, such as the song id to play
	var game_instance = game_scene.instantiate()
	root.add_child(game_instance)
	get_tree().current_scene = game_instance
