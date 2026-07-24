extends Area2D

signal hit
signal miss

var in_area: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:		
	if Input.is_action_just_pressed("beat_main"):
		if in_area:
			emit_signal("hit")
		else:
			emit_signal("miss")
		


func _on_area_entered(area: Area2D) -> void:
	in_area = true
	#print_debug(in_area)


func _on_area_exited(area: Area2D) -> void:
	in_area = false
	#print_debug(in_area)
