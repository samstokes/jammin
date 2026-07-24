extends Node

@export var beats_per_minute = 128.0
@export var beats_per_clock_cycle = 4.0

var current_song_time: float = 0.0
var beat_count: int = 0

@onready var clock_guitar_node: Node2D = %Clock/ClockGuitar
@onready var clock_note_container_node: Node2D = %Clock/NotesContainer
@onready var clock_play_hand_node: Node2D = %Clock/ClockPlayHand


var clock_note_scene = preload("res://entities/clock_note/clock_note.tscn")
var playable_characters = ["A", "S", "D", "E", "F", "J", "K", "L"]

func _ready() -> void:
	# TODO: Start the song

	# Spawn some initial notes on beats
	_spawn_clock_note()
	_spawn_clock_note()
	_spawn_clock_note()
	_spawn_clock_note()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key_string = OS.get_keycode_string(event.keycode)
		if key_string in playable_characters:
			_strum_clock_guitar()

func _strum_clock_guitar():
	print("Strum!")
	# Check for notes that are in the strum zone
	# Ensure that the key played is the same as the note's character
	# If one is found, play a success strum sound and remove the note
	# If no notes are found, play a miss strum sound
	pass

func _process(delta: float) -> void:
	# Update the current song time and check for beat changes
	var previous_time = current_song_time
	current_song_time += delta

	var previous_beat = int(previous_time * beats_per_minute / 60.0)
	var current_beat = int(current_song_time * beats_per_minute / 60.0)
	if current_beat > previous_beat:
		beat_count += 1
		_on_beat()

	var seconds_per_beat = 60.0 / beats_per_minute
	var beats_per_second = 1.0 / seconds_per_beat
	var delta_angle = delta * beats_per_second * TAU / beats_per_clock_cycle
	clock_play_hand_node.angle += delta_angle

func _on_beat():
	print("Beat!")

	# Bounce the clock guitar node to indicate a beat with a tween. Scale it up to 1.2x and then back down to 1.0x over 0.2 seconds total.
	var tween = create_tween()
	tween.tween_property(clock_guitar_node, "scale", Vector2(1.1, 1.1), 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(clock_guitar_node, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)

func _spawn_clock_note():
	var clock_note_instance = clock_note_scene.instantiate()
	var random_character = playable_characters[randi() % playable_characters.size()]
	clock_note_instance.character = random_character
	# Only spawn on even beats for now, 1/4 increments of the clock
	var random_beat = randi() % int(beats_per_clock_cycle * 4) * 0.25
	clock_note_instance.angle = TAU - (random_beat / beats_per_clock_cycle * TAU)
	clock_note_instance.length = clock_guitar_node.radius
	clock_note_instance.position = Vector2.ZERO
	clock_note_container_node.add_child(clock_note_instance)
