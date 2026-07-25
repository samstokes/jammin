extends AudioStreamPlayer

@export var bpm := 120
@export var beats_per_measure := 4
@export var title := "Stay Fresh"
@export var artist := "Android52"

var song_pos: float = 0.0
var song_pos_in_beats: int = 1
var sec_per_beat: float = 60.0/bpm
var last_reported_beat: int = 0
var measure_num: int = 1

signal measure(position)
signal beat(position)
signal song(title, artist, beats_per_measure)

# Called when the node enters the scene tree for the first time.
# V1: play music immediately and set up the bpm dynamically from exported data
func _ready() -> void:
	sec_per_beat = 60.0/bpm
	play()

# Update and track information every frame
func _physics_process(delta: float) -> void:
	if playing:
		song_pos = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_pos -= AudioServer.get_output_latency()
		song_pos_in_beats = int(floor(song_pos/sec_per_beat))
		_track_beat_and_measure()

func _track_beat_and_measure() -> void:
	if last_reported_beat < song_pos_in_beats:
		if measure_num > beats_per_measure:
			measure_num = 1
		if measure_num == beats_per_measure:
			emit_signal("measure", song_pos_in_beats)
		last_reported_beat = song_pos_in_beats
		measure_num += 1
		emit_signal("beat", song_pos_in_beats)

func get_measure_in_seconds() -> float:
	return sec_per_beat*beats_per_measure
	
	# TAU rad * (1/ [ (X*sec/beat) * ( Y * beat / measure) ]
	# = 2pi*rad/measure * (1/ [ (X*sec/beat) * ( Y * beat / measure) ] 
	# = 2pi*rad/measure * [beat/ (X*sec)] * [measure/ (Y*beat)]
	# = 2pi*rad / (X*Y) sec
func get_rads_per_second() -> float:
	return TAU/(sec_per_beat * beats_per_measure)

func nearest_beat() -> int:
	return round(song_pos / sec_per_beat)

func delta_time_and_nearest_beat() -> Vector2:
	var nearest_beat_time = nearest_beat() * sec_per_beat
	var abs_delta_to_nearest_beat = abs(song_pos - nearest_beat_time)
	var nearest_beat_in_measure = int(round(nearest_beat_time /sec_per_beat)) % int(beats_per_measure)
	return Vector2(abs_delta_to_nearest_beat, nearest_beat_in_measure)

func reset(song_info: AudioManager.SongInfo) -> bool:
	stop()
	var file = AudioStreamMP3.load_from_file(song_info.UID)
	if file == null:
		print("Could not load next MP3")
		play()
		return false
	stream = file
	bpm = song_info.bpm
	beats_per_measure = song_info.beats_per_measure
	title = song_info.title
	artist = song_info.artist
	song_pos = 0.0
	song_pos_in_beats = 1
	sec_per_beat = 60.0/bpm
	last_reported_beat = 0
	measure_num = 1
	emit_signal("song", title, artist, beats_per_measure)
	play()
	return true
	
