@tool

class_name SignalEmitter

extends GridEntity

@export var on_blocked_behavior: Frog.OnBlockedBehavior


func get_effected_grid_locations() -> Array[Vector2i]:
	assert(false, "Override me!")
	return []
