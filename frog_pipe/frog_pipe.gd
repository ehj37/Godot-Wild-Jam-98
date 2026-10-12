@tool

class_name FrogPipe

extends GridEntity

@export var config_panel: ConfigPanel
@export var disabled: bool = false:
	set(new_value):
		disabled = new_value
		# For restoring from the undo action
		if !Engine.is_editor_hint() && config_panel.power_on == disabled:
			config_panel.power_on = !disabled
@export var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		# For restoring from the undo action
		if !Engine.is_editor_hint() && config_panel.instruction != instruction:
			config_panel.instruction = instruction

@export var direction: Frog.Direction:
	set(new_value):
		direction = new_value
		var sprite: Sprite2D = get_node("Sprite2D")
		sprite.rotation = direction * PI / 2.0


func get_spawn_location() -> Vector2i:
	return grid_location + Frog.DIRECTION_TO_GRID_LOCATION_OFFSET.get(direction)


func _ready() -> void:
	super()

	if !Engine.is_editor_hint():
		config_panel.power_on = !disabled
		config_panel.instruction = instruction

		config_panel.power_on_changed.connect(
			func(new_power_on: bool) -> void: disabled = !new_power_on
		)
		config_panel.instruction_changed.connect(
			func(new_instruction: Frog.OnBlockedBehavior) -> void: instruction = new_instruction
		)
