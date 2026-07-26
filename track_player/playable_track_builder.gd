class_name PlayableTrackBuilder

var _playable_track: PlayableTrack

func _init():
	_playable_track = PlayableTrack.new()
	_playable_track.track_details = PlayableTrack.TrackDetails.new()

static func from_registry(title: String) -> PlayableTrackBuilder:
	var info = AudioManager.song_title_to_info[title]
	
	var track = new()
	track.set_audio_resource(load(info.UID))
	track.set_title(info.title)
	track.set_artist(info.artist)
	track.set_bpm(info.bpm)
	track.set_beats_per_measure(info.beats_per_measure)
	
	return track

func set_audio_resource(audio_resource: AudioStream) -> void:
	_playable_track.audio_resource = audio_resource

func set_title(title: String) -> void:
	_playable_track.track_details.title = title

func set_artist(artist: String) -> void:
	_playable_track.track_details.artist = artist

func set_bpm(bpm: float) -> void:
	_playable_track.track_details.bpm = bpm

func set_beats_per_measure(beats_per_measure: int) -> void:
	_playable_track.track_details.beats_per_measure = beats_per_measure

func spawn_note(spawn_time : BeatTime, note_time : BeatTime, character: String) -> void:
	var spawn_note_event = PlayableTrack.SpawnNoteTrackEvent.new()
	spawn_note_event.time_in_track = _track_time_from_measure_and_beat(note_time).time_from_song_start
	spawn_note_event.playable_character = character

	var track_event = PlayableTrack.TrackEvent.new()
	track_event.type = PlayableTrack.TrackEventType.SPAWN_NOTE
	track_event.time = _track_time_from_measure_and_beat(spawn_time)
	track_event.spawn_note_event = spawn_note_event

	_playable_track.events.append(track_event)

func _track_time_from_measure_and_beat(beat_time: BeatTime) -> PlayableTrack.TrackTime:
	if _playable_track.track_details.bpm <= 0 or _playable_track.track_details.beats_per_measure <= 0:
		push_error("BPM and beats per measure must be set before spawning notes.")

	var track_time = PlayableTrack.TrackTime.new()
	var beatOffset = beat_time.measure * _playable_track.track_details.beats_per_measure + beat_time.beat
	var spawnTimeInSeconds = beatOffset * (60.0 / _playable_track.track_details.bpm)
	track_time.time_from_song_start = spawnTimeInSeconds
	return track_time

func build() -> PlayableTrack:
	# TODO: Sort the events by their time_from_song_start to ensure they are in the correct order
	return _playable_track

class BeatTime:
	var measure: int
	var beat: int
