extends Node

@onready var clock_guitar_node: Node2D = $Clock/ClockGuitar
@onready var clock_note_container_node: Node2D = $Clock/NotesContainer

var clock_note_scene = preload("res://entities/clock_note/clock_note.tscn")
var characters = ["A", "B", "C", "D", "E", "F", "G"]

func _ready() -> void:
	_spawn_clock_note()
	_spawn_clock_note()
	_spawn_clock_note()
	_spawn_clock_note()

func _process(delta: float) -> void:
	# spawn a clock note every 2 seconds
	pass

func _spawn_clock_note():
	var clock_note_instance = clock_note_scene.instantiate()
	var random_character = characters[randi() % characters.size()]
	clock_note_instance.character = random_character
	clock_note_instance.angle = randf() * TAU
	clock_note_instance.length = clock_guitar_node.radius
	clock_note_instance.position = Vector2.ZERO
	clock_note_container_node.add_child(clock_note_instance)