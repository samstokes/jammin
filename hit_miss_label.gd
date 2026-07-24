extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var clock_hand_area = get_node("../ClockPivot/ClockHand/ClockHandArea2D")
	clock_hand_area.hit.connect(_hit)
	clock_hand_area.miss.connect(_miss)

func _hit() -> void:
	print_debug('hit(cross)')
	text = "hit!"
	pass
	
func _miss() -> void:
	print_debug('miss(cross)')
	text = "miss!"
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
