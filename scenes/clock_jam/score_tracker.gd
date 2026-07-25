extends Label

signal streak_extended(streak: int)

var beats_elapsed: int = 0
var current_streak: int = 0 
# ^ maybe this needs to live somewhere else oh well for now
var format_string = "Beats Survived: %s\nCurrent Streak: %s"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = format_string % [beats_elapsed, current_streak]
	AudioManager.get_node("AudioProcessing").connect("beat", _on_beat)
	var clock_jammer = get_tree().root.get_node("ClockJammer")
	clock_jammer.connect("hit_beat", _on_beat_hit)
	clock_jammer.connect("missed_beat", _on_beat_miss)
	get_node("BeatTracker").connect("skipped_beat", _on_beat_miss)
	
	
func _on_beat(song_pos_in_beats) -> void:
	beats_elapsed += 1
	text = format_string % [beats_elapsed, current_streak]
	
func _on_beat_hit() -> void:
	current_streak += 1
	streak_extended.emit(current_streak)
	text = format_string % [beats_elapsed, current_streak]
	
func _on_beat_miss() -> void:
	current_streak = 0
	text = format_string % [beats_elapsed, current_streak]
