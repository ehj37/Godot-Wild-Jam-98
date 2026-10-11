@tool

class_name SignalTower

extends SignalEmitter


func get_effected_grid_locations() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for i: int in range(grid_location.x - 1, grid_location.x + 2):
		for j: int in range(grid_location.y - 1, grid_location.y + 2):
			result.append(Vector2i(i, j))
	return result


func _draw() -> void:
	var effected_grid_locations: Array[Vector2i] = get_effected_grid_locations()
	for effected_grid_location: Vector2i in effected_grid_locations:
		var center_global_pos: Vector2 = Grid.get_global_position_center(effected_grid_location)
		var beam_relative_pos: Vector2 = center_global_pos - global_position
		var signal_rect: Rect2 = Rect2(beam_relative_pos.x - 10, beam_relative_pos.y - 10, 20, 20)
		draw_rect(signal_rect, Color.FUCHSIA, true)
