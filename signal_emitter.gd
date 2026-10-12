@tool

class_name SignalEmitter

extends GridEntity

signal options_changed

@export var config_panel: ConfigPanel
@export var power_on: bool = true:
	set(new_value):
		power_on = new_value
		# For restoring from the undo action
		if !Engine.is_editor_hint() && config_panel.power_on != power_on:
			config_panel.power_on = power_on
@export var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		# For restoring from the undo action
		if !Engine.is_editor_hint() && config_panel.instruction != instruction:
			config_panel.instruction = instruction

# TODO: Implement stuck/locked buttons
@export var power_button_stuck: bool = false
@export var instruction_button_stuck: bool = false


func get_effected_grid_locations() -> Array[Vector2i]:
	assert(false, "Override me!")
	return []


func _ready() -> void:
	super()

	if !Engine.is_editor_hint():
		assert(config_panel, "Must provide a config panel for signal emitter.")
		config_panel.instruction = instruction
		config_panel.power_on = true
		config_panel.instruction_changed.connect(_on_instruction_changed)
		config_panel.power_on_changed.connect(_on_power_on_changed)


func _on_instruction_changed(new_instruction: Frog.OnBlockedBehavior) -> void:
	instruction = new_instruction
	queue_redraw()
	options_changed.emit()


func _on_power_on_changed(new_power_on: bool) -> void:
	power_on = new_power_on
	queue_redraw()
	options_changed.emit()
