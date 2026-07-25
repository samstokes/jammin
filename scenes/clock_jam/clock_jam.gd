extends Node

@export var beats_per_minute = 128.0
@export var beats_per_clock_cycle = 4.0
@export var strum_success_tolerance = 0.1
@export var doom_seconds = 60.0

var doom_rads_per_second = TAU / doom_seconds

var current_song_time: float = 0.0
var beat_count: int = 0

# For accessing Vector2 return from  AudioProcessing.delta_time_and_nearest_beat()
var time_diff_index = 0
var nearest_beat_index = 1

@onready var clock_guitar_node: Node2D = %Clock/ClockGuitar
@onready var clock_note_container_node: Node2D = %Clock/NotesContainer
@onready var clock_play_hand_node: Node2D = %Clock/ClockPlayHand
@onready var clock_doom_hand_node: Node2D = %Clock/ClockDoomHand


var clock_measure_beat_sfx = preload("res://sfx/glass_005.ogg")
var clock_measure_start_sfx = preload("res://sfx/glass_006.ogg")

var strum_success_sfx = preload("res://sfx/tick_001.ogg")
var strum_failure_sfx = preload("res://sfx/click_001.ogg")

var clock_note_scene = preload("res://entities/clock_note/clock_note.tscn")
var playable_characters = ["f", "left"]


var current_notes: Array[SpawnedClockNoteData] = []

func _ready() -> void:
	AudioManager.get_node("AudioProcessing").play(0)
	_spawn_four_notes()
	AudioManager.get_node("AudioProcessing").connect("beat", _on_beat)
	AudioManager.get_node("AudioProcessing").connect("measure", _on_new_measure)
	

# WARNING, DO NOT ERASE IN ASCENDING ORDER
func _on_new_measure(args):
	print("_on_new_measure: ", args)
	
	for note in current_notes:
		if is_instance_valid(note):
			note.node.queue_free()
	current_notes.clear()
	_spawn_four_notes()
		

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key_string = OS.get_keycode_string(event.keycode).to_lower()
		if key_string in playable_characters:
			_strum_clock_guitar(key_string)

func _strum_clock_guitar(key_string: String) -> void:
	AudioManager.play_sfx(strum_success_sfx)

	# Determine if the strum was on a beat by rounding the current song to the nearest beat with a tolerance of 0.1 seconds.
	var time_diff_and_nearest_beat = AudioManager.get_node("AudioProcessing").delta_time_and_nearest_beat()
	var was_on_beat = time_diff_and_nearest_beat[time_diff_index] <= strum_success_tolerance
	print("Strummed (key: %s, on_beat: %s, beat_in_measure: %s)" % [key_string, was_on_beat, time_diff_and_nearest_beat[nearest_beat_index]])

	if !was_on_beat:
		AudioManager.play_sfx(strum_failure_sfx)
		return
	
	var note_at_beat_in_measure = null
	for note_data in current_notes:
		if note_data.beat_in_measure == time_diff_and_nearest_beat[nearest_beat_index]:
			note_at_beat_in_measure = note_data
			break
	if note_at_beat_in_measure == null:
		AudioManager.play_sfx(strum_failure_sfx)
		return
	
	if note_at_beat_in_measure.character != key_string:
		# Lets delete the note
		AudioManager.play_sfx(strum_failure_sfx)
		return
	
	# Successfully hit the note
	AudioManager.play_sfx(strum_success_sfx)
	note_at_beat_in_measure.node.queue_free()
	current_notes.erase(note_at_beat_in_measure)

func _process(delta: float) -> void:
	var delta_angle_play = delta * AudioManager.get_node("AudioProcessing").get_rads_per_second()
	clock_play_hand_node.angle += delta_angle_play
	
	var delta_angle_doom = delta * doom_rads_per_second
	clock_doom_hand_node.angle += delta_angle_doom


func _on_beat(args):
	print("_on_beat: ", args)

	# Bounce the clock guitar node to indicate a beat with a tween. Scale it up to 1.2x 
	# and then back down to 1.0x over 0.2 seconds total.
	var tween = create_tween()
	tween.tween_property(clock_guitar_node, "scale", Vector2(1.1, 1.1), 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(clock_guitar_node, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)

func _spawn_four_notes():
	_spawn_clock_note(0)
	_spawn_clock_note(1)
	_spawn_clock_note(2)
	_spawn_clock_note(3)

func _spawn_clock_note(beat: int = 0):
	var clock_note_instance = clock_note_scene.instantiate()
	var random_character = playable_characters[randi() % playable_characters.size()]
	clock_note_instance.character = random_character

	var beat_angle = beat * (TAU / beats_per_clock_cycle)
	clock_note_instance.angle = beat_angle
	clock_note_instance.length = clock_guitar_node.radius
	clock_note_instance.position = Vector2.ZERO
	clock_note_container_node.add_child(clock_note_instance)

	var spawned_note_data = SpawnedClockNoteData.new()
	spawned_note_data.character = random_character
	spawned_note_data.beat_in_measure = beat % int(beats_per_clock_cycle)
	spawned_note_data.node = clock_note_instance
	current_notes.append(spawned_note_data)

class SpawnedClockNoteData:
	var character: String
	var beat_in_measure: int
	var node: Node2D
