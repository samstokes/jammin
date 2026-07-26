# Runtime representation of a playable track in the game.
# 
# It contains the following information:
# - The song played
# - Metadata about the song (artist, title, bpm, etc.)
# - The sequence of events that occur during the song, such as
#   - When a note is spawned
#   - Visual effects that occur on the beat or measure

class_name PlayableTrack

var audio_resource: AudioStream
var track_details: TrackDetails
var events: Array[TrackEvent] = []

static func from_registry(song_id: int) -> PlayableTrack:
	# keep these in sync with song_registry.json and the individual PlayableTrackXxx classes
	match song_id:
		1: return PlayableTrackStayFresh.track()
		2: return PlayableTrackMxLxfx.track()
		_:
			assert(false, "selected a song we don't have a playable track for")
			return null # not really

func debug_string() -> String:
	var events_debug_string = "["
	for event in events:
		events_debug_string += "\n" + event.debug_string() + ", "
	events_debug_string += "\n]"
	return "PlayableTrack(audio_resource=%s, track_details=%s, events=[%s])" % [audio_resource, track_details.debug_string(), events_debug_string]

class TrackDetails:
	var title: String
	var artist: String
	var bpm: float
	var beats_per_measure: int

	func debug_string() -> String:
		return "TrackDetails(title=%s, artist=%s, bpm=%f, beats_per_measure=%d)" % [title, artist, bpm, beats_per_measure]

class TrackTime:
	var time_from_song_start: float

	func debug_string() -> String:
		return "TrackTime(time_from_song_start=%d)" % [time_from_song_start]

enum TrackEventType {
	SPAWN_NOTE,
	COMPLETED,
}
	
class SpawnNoteTrackEvent:
	var playable_character: String
	var time_in_track: float

	func debug_string() -> String:
		return "SpawnNoteTrackEvent(playable_character=%s, time_in_track=%d)" % [playable_character, time_in_track]

class CompletedTrackEvent:
	func debug_string() -> String:
		return "CompletedTrackEvent()"

class TrackEvent:
	var time: TrackTime
	var type: TrackEventType
	var spawn_note_event: SpawnNoteTrackEvent
	var completed_event: CompletedTrackEvent

	func debug_string() -> String:
		var event_debug: String
		match type:
			TrackEventType.SPAWN_NOTE: event_debug = spawn_note_event.debug_string()
			TrackEventType.COMPLETED: event_debug = completed_event.debug_string()
		return "TrackEvent(time=%s, type=%s, %s)" % [time.debug_string(), type, event_debug]
	
