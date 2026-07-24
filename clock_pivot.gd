extends Node2D

@export var bpm = 60
var angular_speed = PI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# delta is time in seconds, so... 
	# if I want to do this with bpm... 
	# lets say we have a 60bpm song. 
	# bps = (bpm)/60  = 1
	# we want to go around the circle every 1 second...
	# rotation = 2pi * bps = 2pi * bpm/60
	rotation += (2 * PI * bpm/ 60 /4) * delta
	# angular_speed * delta
	# 2 * PI * bpm * delta / 60
