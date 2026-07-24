@tool
extends Node2D

@export var radius = 100.0:
	set(value):
		radius = value
		queue_redraw()
@export var color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()
@export var thickness = 5.0:
	set(value):
		thickness = value
		queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, color, false, thickness)
