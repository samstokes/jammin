## Counts down toward game end over the course of doom_seconds.

extends "res://entities/clock_play_hand/clock_play_hand.gd"

@export var doom_seconds = 60.0

signal doom

@onready var doom_rads_per_second = TAU / doom_seconds


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var delta_angle_doom = delta * doom_rads_per_second
	angle += delta_angle_doom
	
	if angle >= TAU:
		angle = TAU
		doom.emit()
		set_process(false)
