@tool

class_name FrogPipe

extends GridEntity

@export var disabled: bool = false
@export var direction: Frog.Direction:
	set(new_value):
		direction = new_value
		var sprite: Sprite2D = get_node("Sprite2D")
		sprite.rotation = direction * PI / 2.0
@export var on_blocked_behavior: Frog.OnBlockedBehavior


func get_spawn_location() -> Vector2i:
	return grid_location + Frog.DIRECTION_TO_GRID_LOCATION_OFFSET.get(direction)
