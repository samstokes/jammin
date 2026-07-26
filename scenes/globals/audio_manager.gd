extends Node

var song_registry_path: String = "res://audio/song_registry.json"

var song_id_to_info: Dictionary[int, SongInfo]
var song_title_to_info: Dictionary[String, SongInfo]

func _ready() -> void:
	if (!_load_library()):
		print("Library Failed To Load")

func play_sfx(audio_stream: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = audio_stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _on_audio_processing_finished() -> void:
	load_song()

func _load_library() -> bool:
	song_id_to_info.clear()
	if FileAccess.file_exists(song_registry_path):
		var data_text = FileAccess.get_file_as_string(song_registry_path)
		# Parse array from json
		var data_parsed = JSON.parse_string(data_text)
		for record in data_parsed:
			var curr = SongInfo.new()
			curr.title = record["title"]
			curr.artist = record["artist"]
			curr.bpm = record["bpm"]
			curr.beats_per_measure = record["beats_per_measure"]
			curr.UID = record["UID"]
			song_id_to_info[record["id"]] = curr
			song_title_to_info[record["title"]] = curr
		print("Song Registry Read and stored.")
		return true
	else:
		print("Song Registry Not Detected!")
		return false


func load_song():
	var track_id = randi() % song_id_to_info.size() + 1
	if !AudioManager.get_node("AudioProcessing").reset(song_id_to_info[track_id]):
		print("AudioProcessing Node Not Reset")
	else:
		print("AudioProcessing Node reset")

	
class SongInfo:
	var title: String
	var artist: String
	var bpm: int
	var beats_per_measure: int
	var UID: String
	
