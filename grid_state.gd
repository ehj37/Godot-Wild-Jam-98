extends Node

enum Residency { FROG, PIPE, TILE }

var _residency_by_grid_location: Dictionary


func is_empty(grid_location: Vector2i) -> bool:
	return !_residency_by_grid_location.has(grid_location)


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
