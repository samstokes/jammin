extends Node

signal skipped_beat

var valid_hit: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var clock_jammer = get_tree().root.get_node("ClockJammer")
	clock_jammer.connect("hit_beat", _on_beat_hit)

func _on_beat_hit() -> void:
	valid_hit = true

func beat_window_end() -> void:
	if !valid_hit:
		emit_signal("skipped_beat")
		valid_hit = false
	
