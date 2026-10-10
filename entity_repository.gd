extends Node

var _entities: Array[GridEntity]
var _entity_by_grid_location: Dictionary
var _grid_location_by_entity: Dictionary


func register_entity(entity: GridEntity, grid_location: Vector2i) -> void:
	_add_entity(entity, grid_location)


func get_grid_location(entity: GridEntity) -> Vector2i:
	var grid_location: Vector2i = _grid_location_by_entity.get(entity)
	assert(grid_location)

	return grid_location


func is_empty(grid_location: Vector2i) -> bool:
	return !_entity_by_grid_location.has(grid_location)


func move_entity(entity: GridEntity, new_location: Vector2i) -> void:
	_remove_entity(entity)
	_add_entity(entity, new_location)


func get_frogs() -> Array[Frog]:
	var result: Array[Frog]
	result.assign(_entities.filter(func(e: GridEntity) -> bool: return e is Frog))
	return result


func get_pipes() -> Array[FrogPipe]:
	var result: Array[FrogPipe]
	result.assign(_entities.filter(func(e: GridEntity) -> bool: return e is FrogPipe))
	return result


func _add_entity(entity: GridEntity, grid_location: Vector2i) -> void:
	assert(
		!_entity_by_grid_location.has(grid_location),
		"Entity registered at " + str(grid_location) + " where other entity already exists"
	)

	entity.grid_location = grid_location
	entity.global_position = Grid.get_global_position_center(grid_location)

	_entities.append(entity)
	_entity_by_grid_location.set(grid_location, entity)
	_grid_location_by_entity.set(entity, grid_location)


func _remove_entity(entity: GridEntity) -> void:
	var grid_location: Vector2i = _grid_location_by_entity.get(entity)
	assert(grid_location, "Attempting to remove entity " + str(entity) + " that was never added")

	_entities.erase(entity)
	_grid_location_by_entity.erase(entity)
	_entity_by_grid_location.erase(grid_location)
