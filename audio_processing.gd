extends AudioStreamPlayer

@export var bmp := 120
@export var beats_per_measure := 4

var song_pos = 0.0
var song_pos_in_beats = 1
var sec_per_beat = 60.0/bmp
var last_reported_beat = 0
var measure_num = 1

signal measure(position)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sec_per_beat = 60.0/bmp
	play()

func _physics_process(delta: float) -> void:
	if playing:
		song_pos = $Player.get_playback_position() + AudioServer.get_time_since_last_mix()
		song_pos -= AudioServer.get_output_latency()
		song_pos_in_beats = int(floor(song_pos/sec_per_beat))
		_track_beat_and_measure()
	
func _track_beat_and_measure():
	if last_reported_beat < song_pos_in_beats:
		if measure_num > beats_per_measure:
			measure_num = 1
		if measure_num == 1:
			emit_signal("measure", measure_num)
		last_reported_beat = song_pos_in_beats
		measure_num += 1
		

func get_measure_in_seconds():
	return sec_per_beat*beats_per_measure
