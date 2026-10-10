@tool

class_name Frog

extends GridEntity

enum Direction { UP, DOWN, LEFT, RIGHT }
enum OnCollideBehavior { TURN_CW, TURN_CCW, FLIP, STOP }

const DIRECTION_TO_GRID_LOCATION_OFFSET: Dictionary = {
	Direction.UP: Vector2i.UP,
	Direction.DOWN: Vector2i.DOWN,
	Direction.LEFT: Vector2i.LEFT,
	Direction.RIGHT: Vector2i.RIGHT
}

@export var direction: Direction:
	set(new_value):
		direction = new_value
		_set_sprite_from_direction()
@export var on_collide_behavior: OnCollideBehavior


func get_next_grid_location() -> Vector2i:
	return grid_location + DIRECTION_TO_GRID_LOCATION_OFFSET.get(direction)


func _ready() -> void:
	super()

	if !Engine.is_editor_hint():
		_set_sprite_from_direction()


func _set_sprite_from_direction() -> void:
	var sprite_up: Sprite2D = get_node("SpriteUp")
	var sprite_down: Sprite2D = get_node("SpriteDown")
	var sprite_side: Sprite2D = get_node("SpriteSide")
	sprite_up.visible = direction == Direction.UP
	sprite_down.visible = direction == Direction.DOWN
	sprite_side.visible = direction == Direction.LEFT || direction == Direction.RIGHT
	sprite_side.flip_h = direction == Direction.LEFT
