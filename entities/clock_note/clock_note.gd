@tool
extends Node2D

@export var length = 100.0:
	set(value):
		length = value
		queue_redraw()
@export var color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()
@export var thickness = 5.0:
	set(value):
		thickness = value
		queue_redraw()
@export var angle = 0.0:
	set(value):
		angle = value
		queue_redraw()
@export var character = "A":
	set(value):
		character = value
		queue_redraw()
@export var label_offset = 20.0:
	set(value):
		label_offset = value
		queue_redraw()	

@onready var _note_label_node: Label = $NoteLabel

func _draw():
	var offset_angle = angle - (PI / 2)
	var directional_vector = Vector2(cos(offset_angle), sin(offset_angle))

	var end_point = directional_vector * length
	draw_line(Vector2.ZERO, end_point, color, thickness)

	if _note_label_node:
		var label_position = directional_vector * (length + label_offset)
		_note_label_node.text = character
		_note_label_node.position = label_position - _note_label_node.size / 2

