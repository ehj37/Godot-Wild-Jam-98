@tool

class_name FrogPipe

extends GridEntity

@export var disabled: bool = false
@export var instruction: Frog.OnBlockedBehavior
@export var direction: Frog.Direction:
	set(new_value):
		direction = new_value
		var sprite: Sprite2D = get_node("Sprite2D")
		sprite.rotation = direction * PI / 2.0

@onready var _config_panel: ConfigPanel = $ConfigPanel


func get_spawn_location() -> Vector2i:
	return grid_location + Frog.DIRECTION_TO_GRID_LOCATION_OFFSET.get(direction)


func _ready() -> void:
	super()

	if !Engine.is_editor_hint():
		_config_panel.power_on = !disabled
		_config_panel.instruction = instruction

		_config_panel.power_on_changed.connect(
			func(new_power_on: bool) -> void: disabled = !new_power_on
		)
		_config_panel.instruction_changed.connect(
			func(new_instruction: Frog.OnBlockedBehavior) -> void: instruction = new_instruction
		)
