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

func buy_time(seconds: float) -> void:
	var extra_angle = seconds * doom_rads_per_second
	
	var new_angle = angle - extra_angle
	new_angle = maxf(new_angle, 0.0)
	
	var tween = create_tween()
	tween.tween_property(self, "angle", new_angle, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
