class_name GridTileMap

extends TileMapLayer


func get_tile_grid_locations() -> Array[Vector2i]:
	var result: Array[Vector2i]
	for cell_coords: Vector2i in get_used_cells():
		result.append(cell_coords)
	return result


func _ready() -> void:
	assert(position == Vector2.ZERO)
