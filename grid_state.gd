extends Node

enum Residency { FROG, PIPE, TILE, SIGNAL_EMITTER }

var _residency_by_grid_location: Dictionary


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


func get_num_frogs() -> int:
	return _residency_by_grid_location.values().count(Residency.FROG)
