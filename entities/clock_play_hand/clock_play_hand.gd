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

func _draw():
	var offset_angle = angle - (PI / 2)
	var directional_vector = Vector2(cos(offset_angle), sin(offset_angle))

	var end_point = directional_vector * length
	draw_line(Vector2.ZERO, end_point, color, thickness)
