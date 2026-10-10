extends TileMapLayer


func _ready() -> void:
	assert(position == Vector2.ZERO)

	for cell_coords: Vector2i in get_used_cells():
		GridState.register_residency(GridState.Residency.TILE, cell_coords)
