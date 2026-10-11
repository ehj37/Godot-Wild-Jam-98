@tool

class_name Frog

extends GridEntity

enum Direction { UP, RIGHT, DOWN, LEFT }
enum OnBlockedBehavior { TURN_CW, TURN_CCW, FLIP, STOP }

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
		_update_on_blocked_indicator()
@export var on_blocked_behavior: OnBlockedBehavior:
	set(new_value):
		on_blocked_behavior = new_value
		_update_on_blocked_indicator()

@onready var _number_label: Label = $NumberLabel


func get_next_grid_location() -> Vector2i:
	return grid_location + DIRECTION_TO_GRID_LOCATION_OFFSET.get(direction)


func get_next_direction() -> Direction:
	match on_blocked_behavior:
		OnBlockedBehavior.TURN_CW:
			return wrapi(direction + 1, 0, Direction.values().size()) as Direction
		OnBlockedBehavior.TURN_CCW:
			return wrapi(direction - 1, 0, Direction.values().size()) as Direction
		OnBlockedBehavior.FLIP:
			return wrapi(direction + 2, 0, Direction.values().size()) as Direction
		OnBlockedBehavior.STOP:
			# TODO: Hm
			pass

	assert(false, "Unhandled OnBlockedBehavior")
	return Direction.UP


func _ready() -> void:
	super()

	if !Engine.is_editor_hint():
		var frog_number: int = GridState.get_num_frogs()
		_number_label.text = str(frog_number)
		_set_sprite_from_direction()
		_update_on_blocked_indicator()


func _set_sprite_from_direction() -> void:
	var sprite_up: Sprite2D = get_node("SpriteUp")
	var sprite_down: Sprite2D = get_node("SpriteDown")
	var sprite_side: Sprite2D = get_node("SpriteSide")
	sprite_up.visible = direction == Direction.UP
	sprite_down.visible = direction == Direction.DOWN
	sprite_side.visible = direction == Direction.LEFT || direction == Direction.RIGHT
	sprite_side.flip_h = direction == Direction.LEFT


func _update_on_blocked_indicator() -> void:
	var on_blocked_indicator: OnBlockedIndicator = get_node("OnBlockedIndicator")
	on_blocked_indicator.direction = direction
	on_blocked_indicator.on_blocked_behavior = on_blocked_behavior
