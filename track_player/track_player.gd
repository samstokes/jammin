# TrackPlayer is responsible for playing a PlayableTrack and emitting signals
# that allow for other parts of the game to respond to events in the track.
class_name TrackPlayer
extends Node

# Signals related to the state of the track player.
signal track_started()
signal is_playing_changed(is_playing)
signal track_ended()

# Signals related to musically meaningful events in the track.
# Useful for syncing visuals to the music
signal beat()
signal measure()

# Signals related to specific events in the track, such as spawning notes.
signal spawn_note_event(event : PlayableTrack.SpawnNoteTrackEvent)

# Internal state
@onready var _audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D

var _is_playing: bool = false
var _current_track: PlayableTrack = null
var _last_processed_time_secs: float = 0.0
var _track_events: Array[PlayableTrack.TrackEvent] = []

func _ready() -> void:
	_audio_player.finished.connect(_on_audio_player_finished)

# Starts playing the given track
#
# This stops any existing playing track if any is playing
func play_track(track: PlayableTrack) -> void:
	_maybe_stop_current_track()

	_last_processed_time_secs = 0.0
	_current_track = track
	_audio_player.stream = track.audio_resource
	_is_playing = true
	# We assume that the events are sorted by time, so we can just duplicate the array and process it in order
	_track_events = track.events.duplicate()

	is_playing_changed.emit(true)
	track_started.emit()

	_audio_player.play()

func stop_track() -> void:
	_maybe_stop_current_track()

func get_track_position_secs() -> float:
	return _audio_player.get_playback_position()

# Returns a float between 0.0 and 1.0 representing the progress through the current measure of the song
func get_measure_progress() -> float:
	return get_measure_progress_for_time_secs(get_track_position_secs())

func get_measure_progress_for_time_secs(time_secs: float) -> float:
	if _current_track == null:
		return 0.0
	var beat_length_secs = 60.0 / _current_track.track_details.bpm
	var current_beat = int(floor(time_secs / beat_length_secs))
	var current_measure = int(floor(current_beat / _current_track.track_details.beats_per_measure))
	var measure_start_time_secs = current_measure * _current_track.track_details.beats_per_measure * beat_length_secs
	return (time_secs - measure_start_time_secs) / (beat_length_secs * _current_track.track_details.beats_per_measure)

func _on_audio_player_finished() -> void:
	_maybe_stop_current_track()
	track_ended.emit()

func _maybe_stop_current_track() -> void:
	if !_is_playing:
		return
	
	_is_playing = false
	is_playing_changed.emit(false)

	_audio_player.stop()

func _process(delta: float) -> void:
	if !_is_playing:
		return

	# Process any track events that are scheduled to occur up to the current playback position
	var next_track_time_secs = get_track_position_secs()

	var events_to_process = []
	while _track_events.size() > 0 and _track_events[0].time.time_from_song_start <= next_track_time_secs:
		events_to_process.append(_track_events.pop_front())
	for event in events_to_process:
		match event.type:
			PlayableTrack.TrackEventType.SPAWN_NOTE:
				spawn_note_event.emit(event.spawn_note_event)
			PlayableTrack.TrackEventType.COMPLETED:
				track_ended.emit()
	
	# Fire any events related to the beat or measure if we have crossed a beat or measure boundary
	var previous_beat = int(floor(_last_processed_time_secs / (60.0 / _current_track.track_details.bpm)))
	var current_beat = int(floor(next_track_time_secs / (60.0 / _current_track.track_details.bpm)))
	if current_beat != previous_beat:
		beat.emit()

	var previous_measure = int(floor(previous_beat / _current_track.track_details.beats_per_measure))
	var current_measure = int(floor(current_beat / _current_track.track_details.beats_per_measure))
	if current_measure != previous_measure:
		measure.emit()
	
	_last_processed_time_secs = next_track_time_secs
