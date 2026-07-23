extends Node

### Beat tracking for player inputs.
# Likely low precision due to Godot batching input events

# TODO receive beats from another scene (via want_beat(beat) or beat_ready(beat) or something)
# var next_beat = "beat_d"

@export var beatslop_ms: int = 200
var last_beat = INT64_MAX

func _ready() -> void:
	$BeatTimer.start()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("beat_main"):
		# TODO handle slightly early beats.
		# (Can't just subtract from timestamp, since timer won't have fired yet.)
		var is_on_beat = Time.get_ticks_msec() <= last_beat + beatslop_ms
		print("doof!", is_on_beat)

func _on_beat_timer_timeout() -> void:
	last_beat = Time.get_ticks_msec()
	print("doof?")
