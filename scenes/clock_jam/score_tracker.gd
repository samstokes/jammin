extends Label

var beats_elapsed: int = 0
var format_string = "Beats Survived: %s"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = format_string % beats_elapsed
	AudioManager.get_node("AudioProcessing").connect("beat", _on_beat)
	
func _on_beat(song_pos_in_beats) -> void:
	beats_elapsed += 1
	text = format_string % beats_elapsed
