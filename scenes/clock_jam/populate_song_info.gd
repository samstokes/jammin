extends Label

func _ready() -> void:
	AudioManager.get_node("AudioProcessing").connect("song", _on_new_song_info)

func _on_new_song_info(title: String, artist: String, beats_per_measure: int):
	text = title + "\n" + artist
