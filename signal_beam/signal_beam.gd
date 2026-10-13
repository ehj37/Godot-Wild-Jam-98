@tool

class_name SignalBeam

extends SignalEmitter

enum Direction { UP, DOWN, LEFT, RIGHT }

@export var direction: Direction


class BeamRange:
	var x_start: int
	var x_end: int
	var y_start: int
	var y_end: int

	@warning_ignore("shadowed_variable")

	func _init(x_start: int, x_end: int, y_start: int, y_end: int) -> void:
		self.x_start = x_start
		self.x_end = x_end
		self.y_start = y_start
		self.y_end = y_end

	func iteration_step() -> Vector2i:
		var x_step: int
		var y_step: int
		if x_start < x_end:
			x_step = 1
		else:
			x_step = -1

		if y_start < y_end:
			y_step = 1
		else:
			y_step = -1

		return Vector2i(x_step, y_step)


func update(grid: Grid) -> void:
	_effected_grid_locations.clear()

	var unblocked_beam_range: BeamRange = _get_unblocked_beam_range()
	var iteration_step: Vector2i = unblocked_beam_range.iteration_step()
	for i: int in range(
		unblocked_beam_range.x_start,
		unblocked_beam_range.x_end + iteration_step.x,
		iteration_step.x
	):
		for j: int in range(
			unblocked_beam_range.y_start,
			unblocked_beam_range.y_end + iteration_step.y,
			iteration_step.y
		):
			var test_location: Vector2i = Vector2i(i, j)
			var test_location_residency: Grid.Residency = grid.get_residency_at(test_location)
			if test_location_residency != -1 && test_location_residency != Grid.Residency.FROG:
				return

			_effected_grid_locations.append(Vector2i(i, j))


func _get_unblocked_beam_range() -> BeamRange:
	var x_start: int
	var x_end: int
	var y_start: int
	var y_end: int

	match direction:
		Direction.UP:
			x_start = grid_location.x
			x_end = grid_location.x
			y_start = grid_location.y - 1
			y_end = 0
		Direction.DOWN:
			x_start = grid_location.x
			x_end = grid_location.x
			y_start = grid_location.y + 1
			y_end = Grid.NUM_GRID_SQUARES_Y - 1
		Direction.LEFT:
			x_start = grid_location.x - 1
			x_end = 0
			y_start = grid_location.y
			y_end = grid_location.y
		Direction.RIGHT:
			x_start = grid_location.x + 1
			x_end = Grid.NUM_GRID_SQUARES_X - 1
			y_start = grid_location.y
			y_end = grid_location.y

	return BeamRange.new(x_start, x_end, y_start, y_end)


func _draw() -> void:
	if Engine.is_editor_hint() || !power_on:
		return

	for effected_grid_location: Vector2i in _effected_grid_locations:
		var center_global_pos: Vector2 = Grid.get_global_position_center(effected_grid_location)
		var beam_relative_pos: Vector2 = center_global_pos - global_position
		var signal_rect: Rect2 = Rect2(beam_relative_pos.x - 10, beam_relative_pos.y - 10, 20, 20)
		draw_rect(signal_rect, Color.FUCHSIA, true)
