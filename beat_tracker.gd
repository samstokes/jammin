extends Node

signal hit
signal miss

### Beat tracking for player inputs.
# Likely low precision due to Godot batching input events

var is_on_beat: bool = false
var did_hit: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("beat_main"):
		if is_on_beat:
			did_hit = true
			hit.emit()
		else:
			miss.emit()

# call this slightly *before* the beat to allow for slightly early input
func beat_ready() -> void:
	is_on_beat = true
	did_hit = false

# if the player already hit the beat, this will do nothing, otherwise it will fire a miss signal
func beat_expired() -> void:
	is_on_beat = false
	if not did_hit:
		miss.emit()
