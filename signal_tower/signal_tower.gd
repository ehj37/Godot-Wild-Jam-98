@tool

class_name SignalTower

extends SignalEmitter

@onready var _signal_particles: SignalParticles = $SignalParticles


# TODO: Consider grid when determining effected squares. If the beam doesn't go
# through a block, the tower shouldn't either.
func update(_grid: Grid) -> void:
	for i: int in range(grid_location.x - 1, grid_location.x + 2):
		for j: int in range(grid_location.y - 1, grid_location.y + 2):
			_effected_grid_locations.append(Vector2i(i, j))


func _ready() -> void:
	super()

	_signal_particles.instruction = instruction
	_signal_particles.visible = power_on


func _draw() -> void:
	if Engine.is_editor_hint() || !power_on:
		return

	var signal_rect: Rect2 = Rect2(-48, -48, 96, 96)
	var rectangle_color: Color = Frog.INSTRUCTION_TO_COLOR[instruction]
	draw_rect(signal_rect, rectangle_color, false, 1)


func _on_instruction_changed() -> void:
	super()

	if is_node_ready():
		_signal_particles.instruction = instruction


func _on_power_on_changed() -> void:
	super()

	if is_node_ready():
		_signal_particles.visible = power_on
