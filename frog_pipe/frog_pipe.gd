@tool

class_name FrogPipe

extends GridEntity

@export var disabled: bool = false:
	set(new_value):
		disabled = new_value
		if is_node_ready():
			_update_visuals()
@export var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		if is_node_ready():
			_update_visuals()

@export var direction: Frog.Direction:
	set(new_value):
		direction = new_value
		if is_node_ready():
			_update_visuals()

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _config_panel: MiniConfigPanel = $MiniConfigPanel


func get_spawn_location() -> Vector2i:
	return grid_location + Frog.DIRECTION_TO_GRID_LOCATION_OFFSET.get(direction)


func _ready() -> void:
	super()

	_update_visuals()

	_config_panel.power_on_changed.connect(
		func(new_power_on: bool) -> void: disabled = !new_power_on
	)
	_config_panel.instruction_changed.connect(
		func(new_instruction: Frog.OnBlockedBehavior) -> void: instruction = new_instruction
	)


func _update_visuals() -> void:
	_sprite.rotation = direction * PI / 2.0

	if _config_panel.power_on == disabled:
		_config_panel.power_on = !disabled

	match direction:
		Frog.Direction.UP:
			_config_panel.orientation = MiniConfigPanel.ButtonOrientation.POWER_BOTTOM
		Frog.Direction.DOWN:
			_config_panel.orientation = MiniConfigPanel.ButtonOrientation.POWER_TOP
		Frog.Direction.LEFT:
			_config_panel.orientation = MiniConfigPanel.ButtonOrientation.POWER_RIGHT
		Frog.Direction.RIGHT:
			_config_panel.orientation = MiniConfigPanel.ButtonOrientation.POWER_LEFT
