@tool

class_name SignalBeam

extends SignalEmitter

enum Direction { UP, DOWN, LEFT, RIGHT }

@export var direction: Direction

@onready var _signal_particles: SignalParticles = $SignalParticles


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
	var block_hit: bool = false
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
				block_hit = true
				break

			_effected_grid_locations.append(Vector2i(i, j))

		if block_hit:
			break

	var beam_start_global: Vector2 = _get_beam_start_global_position()
	var beam_end_global: Vector2 = _get_beam_end_global_position()
	var beam_mid_point_global: Vector2 = (
		beam_start_global + (beam_end_global - beam_start_global) / 2
	)
	_signal_particles.global_position = beam_mid_point_global

	var beam_grid_length: int = _get_beam_grid_length()
	if beam_grid_length == 0:
		_signal_particles.visible = false
		return

	_signal_particles.visible = true

	var signal_particles_particle_process_material: ParticleProcessMaterial = (
		_signal_particles.process_material
	)
	var beam_direction: Vector2 = _get_beam_direction()
	if beam_direction.x != 0:
		signal_particles_particle_process_material.emission_box_extents.y = 8
		signal_particles_particle_process_material.emission_box_extents.x = (
			0.5 * beam_grid_length * Grid.SQUARE_SIDE_DIM
		)
	else:
		signal_particles_particle_process_material.emission_box_extents.x = 8
		signal_particles_particle_process_material.emission_box_extents.y = (
			0.5 * beam_grid_length * Grid.SQUARE_SIDE_DIM
		)

	_signal_particles.amount = beam_grid_length * 10


func _ready() -> void:
	super()

	_signal_particles.instruction = instruction
	_signal_particles.visible = power_on


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


func _get_beam_grid_length() -> int:
	if _effected_grid_locations.size() == 0:
		return 0

	var beam_start_grid_location: Vector2 = _effected_grid_locations.front()
	var beam_end_grid_location: Vector2 = _effected_grid_locations.back()
	var beam_grid_location_delta: Vector2 = beam_end_grid_location - beam_start_grid_location
	return max(abs(beam_grid_location_delta.x), abs(beam_grid_location_delta.y)) + 1


func _get_beam_direction() -> Vector2:
	if _effected_grid_locations.size() == 0:
		return Vector2.ZERO

	var beam_end_grid_location: Vector2 = _effected_grid_locations.back()
	var beam_end_global_position_center: Vector2 = Grid.get_global_position_center(
		beam_end_grid_location
	)
	return (beam_end_global_position_center - global_position).normalized()


func _get_beam_start_global_position() -> Vector2:
	var beam_direction: Vector2 = _get_beam_direction()
	return global_position + 0.5 * beam_direction * Grid.SQUARE_SIDE_DIM


func _get_beam_end_global_position() -> Vector2:
	var beam_grid_length: int = _get_beam_grid_length()
	var beam_direction: Vector2 = _get_beam_direction()
	var beam_start_global_position: Vector2 = _get_beam_start_global_position()
	return beam_start_global_position + beam_direction * beam_grid_length * Grid.SQUARE_SIDE_DIM


func _on_instruction_changed() -> void:
	super()

	if is_node_ready():
		_signal_particles.instruction = instruction


func _on_power_on_changed() -> void:
	super()

	if is_node_ready():
		_signal_particles.visible = power_on


func _draw() -> void:
	if Engine.is_editor_hint() || !power_on:
		return

	var beam_start_local: Vector2 = to_local(_get_beam_start_global_position())
	var beam_end_local: Vector2 = to_local(_get_beam_end_global_position())
	draw_line(beam_start_local, beam_end_local, Color("ebeb00"), 4)
