@tool

class_name FrogPipe

extends GridEntity

@export var direction: Frog.Direction:
	set(new_value):
		direction = new_value
		var sprite: Sprite2D = get_node("Sprite2D")
		match direction:
			Frog.Direction.UP:
				sprite.rotation = 0
			Frog.Direction.DOWN:
				sprite.rotation = PI
			Frog.Direction.LEFT:
				sprite.rotation = 1.5 * PI
			Frog.Direction.RIGHT:
				sprite.rotation = PI / 2


func get_spawn_location() -> Vector2i:
	return grid_location + Frog.DIRECTION_TO_GRID_LOCATION_OFFSET.get(direction)
