@tool

class_name Grid

extends Node2D

enum Residency { FROG, PIPE, TILE, SIGNAL_EMITTER }

const SQUARE_SIDE_DIM: int = 32
const SQUARE_DIM: Vector2i = Vector2i(Grid.SQUARE_SIDE_DIM, Grid.SQUARE_SIDE_DIM)
const NUM_GRID_SQUARES_X: int = 16
const NUM_GRID_SQUARES_Y: int = 11

var _residency_by_grid_location: Dictionary
var _radio_tile_grid_locations: Array[Vector2i]


static func get_global_position_upper_left(grid_position: Vector2i) -> Vector2:
	return Vector2(SQUARE_SIDE_DIM * grid_position.x, SQUARE_SIDE_DIM * grid_position.y)


static func get_global_position_center(grid_position: Vector2i) -> Vector2:
	var global_position_upper_left: Vector2 = get_global_position_upper_left(grid_position)
	var center_offset: Vector2 = 0.5 * Vector2(SQUARE_SIDE_DIM, SQUARE_SIDE_DIM)
	return global_position_upper_left + center_offset


static func get_nearest_grid_location(global_pos: Vector2) -> Vector2i:
	return Vector2i(floori(global_pos.x / SQUARE_SIDE_DIM), floori(global_pos.y / SQUARE_SIDE_DIM))


static func is_in_bounds(grid_position: Vector2i) -> bool:
	return (
		grid_position.x >= 0
		&& grid_position.x < NUM_GRID_SQUARES_X
		&& grid_position.y >= 0
		&& grid_position.y < NUM_GRID_SQUARES_Y
	)


func is_empty(grid_location: Vector2i) -> bool:
	return !_residency_by_grid_location.has(grid_location)


func get_residency_at(grid_location: Vector2i) -> Residency:
	if !is_empty(grid_location):
		return _residency_by_grid_location.get(grid_location)

	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	return -1


func register_residency(residency: Residency, grid_location: Vector2i) -> void:
	assert(!_residency_by_grid_location.has(grid_location))
	_residency_by_grid_location[grid_location] = residency


func unregister_residency(residency: Residency, grid_location: Vector2i) -> void:
	assert(_residency_by_grid_location.get(grid_location) == residency)
	_residency_by_grid_location.erase(grid_location)


func update_residency(
	residency: Residency, prev_grid_location: Vector2i, next_grid_location: Vector2i
) -> void:
	unregister_residency(residency, prev_grid_location)
	register_residency(residency, next_grid_location)


func register_radio_tile(grid_location: Vector2i) -> void:
	assert(!_radio_tile_grid_locations.has(grid_location))
	_radio_tile_grid_locations.append(grid_location)


func win_condition_met() -> bool:
	for radiio_tile_grid_location: Vector2i in _radio_tile_grid_locations:
		if get_residency_at(radiio_tile_grid_location) != Residency.FROG:
			return false

	return true


func get_num_frogs() -> int:
	return _residency_by_grid_location.values().count(Residency.FROG)


func _draw() -> void:
	for i: int in range(NUM_GRID_SQUARES_X):
		for j: int in range(NUM_GRID_SQUARES_Y):
			var global_position_upper_left: Vector2 = get_global_position_upper_left(Vector2i(i, j))
			var grid_square_rect: Rect2 = Rect2(global_position_upper_left, SQUARE_DIM)
			draw_rect(grid_square_rect, Color.BLUE, false, 1.0)
