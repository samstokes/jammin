extends Node

@export var strum_success_tolerance = 0.2
@export var seconds_bought_base = 0.5

signal missed_beat 
# ^ two different kinds of missed beats, btw: 
# 1. hit a key but not on beat or
# 2. missed a beat entirely (no button press)
signal hit_beat

@onready var track_player: TrackPlayer = $TrackPlayer 
@onready var clock_guitar_node: Node2D = %Clock/ClockGuitar
@onready var clock_note_container_node: Node2D = %Clock/NotesContainer
@onready var clock_play_hand_node: Node2D = %Clock/ClockPlayHand
@onready var clock_doom_hand_node: Node2D = %Clock/ClockDoomHand
@onready var game_over_dialog_node: Node = %GameOverDialog
@onready var game_won_dialog_node: Node = %GameWonDialog
@onready var song_label_node: Label = %SongLabel

var clock_measure_beat_sfx = preload("res://sfx/glass_005.ogg")
var clock_measure_start_sfx = preload("res://sfx/glass_006.ogg")
var strum_success_sfx = preload("res://sfx/tick_001.ogg")
var strum_failure_sfx = preload("res://sfx/click_001.ogg")
var game_over_sfx = preload("res://sfx/explosionCrunch_004.ogg")

var clock_note_scene = preload("res://entities/clock_note/clock_note.tscn")
var game_over_scene = preload("res://scenes/game_over/game_over.tscn")

var _current_notes: Array[SpawnedClockNoteData] = []

func _ready() -> void:
	track_player.spawn_note_event.connect(_spawn_clock_note)
	track_player.beat.connect(_on_beat)
	track_player.track_ended.connect(_on_game_won)

	var track = StayFreshPlayableTrack.new().track()
	print("Playing track: %s" % [track.debug_string()])
	track_player.play_track(track)

	song_label_node.text = track.track_details.title + "\n" + track.track_details.artist

func _bounce_clock(strength: float = 1.1) -> void: 
	var tween = create_tween()
	tween.tween_property(clock_guitar_node, "scale", Vector2(strength, strength), 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(clock_guitar_node, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)

func _on_beat():
	_bounce_clock()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key_string = OS.get_keycode_string(event.keycode).to_lower()
		# If the key is an alphabetic character, strum the clock guitar with that character
		var playable_characters = "abcdefghijklmnopqrstuvwxyz"
		if key_string in playable_characters:
			_strum_clock_guitar(key_string)

func _strum_clock_guitar(key_string: String) -> void:
	var current_track_time_secs = track_player.get_track_position_secs()

	# Find the oldest note that was strummed or mistrummed within the strum_success_tolerance
	var strummed_note = null
	var mistrummed_note = null
	for note_data in _current_notes:
		var is_with_in_tolerance = abs(current_track_time_secs - note_data.time_in_track) <= strum_success_tolerance
		if !is_with_in_tolerance:
			continue
		var is_matching_character = note_data.character == key_string
		if is_matching_character:
			if strummed_note == null or note_data.time_in_track < strummed_note.time_in_track:
				strummed_note = note_data
		else:
			if mistrummed_note == null or note_data.time_in_track < mistrummed_note.time_in_track:
				mistrummed_note = note_data

	# We always prefer to handle a strummed note over a mistrummed note, so we check for strummed_note first.
	if strummed_note != null:
		_on_note_strummed_correctly(strummed_note)
	else:
		if mistrummed_note != null:
			_on_note_strummed_incorrectly(mistrummed_note)

func _on_note_strummed_correctly(note_data: SpawnedClockNoteData) -> void:
	# Remove the note from the current notes list and free its node
	_current_notes.erase(note_data)
	note_data.node.queue_free()

	AudioManager.play_sfx(strum_success_sfx)
	hit_beat.emit()

func _on_note_strummed_incorrectly(note_data: SpawnedClockNoteData) -> void:
	# Remove the note from the current notes list and free its node
	_current_notes.erase(note_data)
	note_data.node.queue_free()

	AudioManager.play_sfx(strum_failure_sfx)
	missed_beat.emit()

func _on_note_missed(note_data: SpawnedClockNoteData) -> void:
	_current_notes.erase(note_data)
	note_data.node.queue_free()

	AudioManager.play_sfx(strum_failure_sfx)
	missed_beat.emit()

func _process(delta: float) -> void:
	clock_play_hand_node.angle = track_player.get_measure_progress() * TAU

	# Evalute if we've missed any notes that are currently on the clock guitar
	var current_time_secs = track_player.get_track_position_secs()
	for note_data in _current_notes:
		var time_past_note = current_time_secs - note_data.time_in_track
		if time_past_note > strum_success_tolerance:
			_on_note_missed(note_data)

func _spawn_clock_note(event: PlayableTrack.SpawnNoteTrackEvent) -> void:
	var clock_note_instance = clock_note_scene.instantiate()
	clock_note_instance.character = event.playable_character

	var beat_angle = TAU * track_player.get_measure_progress_for_time_secs(event.time_in_track)
	clock_note_instance.angle = beat_angle
	clock_note_instance.length = clock_guitar_node.radius
	clock_note_instance.position = Vector2.ZERO
	clock_note_container_node.add_child(clock_note_instance)

	var spawned_note_data = SpawnedClockNoteData.new()
	spawned_note_data.character = event.playable_character
	spawned_note_data.time_in_track = event.time_in_track
	spawned_note_data.node = clock_note_instance
	_current_notes.append(spawned_note_data)

class SpawnedClockNoteData:
	var character: String
	var time_in_track: float
	var node: Node2D

func _on_doom() -> void:
	# Reveal the game over dialog and stop the audio processing.
	game_over_dialog_node.show()
	track_player.stop_track()

	AudioManager.play_sfx(game_over_sfx)
	set_process(false)

func _on_game_won() -> void:
	# Reveal the game won dialog and stop the audio processing.
	game_won_dialog_node.show()

	AudioManager.get_node("AudioProcessing").stop()
	set_process(false)

func _on_score_tracker_streak_extended(streak: int) -> void:
	# Reward longer streaks.
	# Fiddle with this formula to implement diminishing returns instead
	var streak_seconds_bought = seconds_bought_base * (1.1 ** streak - 0.1)
	
	clock_doom_hand_node.buy_time(streak_seconds_bought)
