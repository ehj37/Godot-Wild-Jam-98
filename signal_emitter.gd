@tool

class_name SignalEmitter

extends GridEntity

signal options_changed

@export var power_on: bool = true:
	set(new_value):
		power_on = new_value
		if is_node_ready():
			_on_power_on_changed()
@export var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		if is_node_ready():
			_on_instruction_changed()

# TODO: Implement stuck/locked buttons
@export var power_button_stuck: bool = false
@export var instruction_button_stuck: bool = false

var _effected_grid_locations: Array[Vector2i]

@onready var config_panel: MiniConfigPanel = $MiniConfigPanel


func get_effected_grid_locations(_grid: Grid) -> Array[Vector2i]:
	return _effected_grid_locations


func update(_grid: Grid) -> void:
	assert(false, "Override me!")


func _ready() -> void:
	super()

	assert(config_panel, "Must provide a config panel for signal emitter.")
	config_panel.instruction = instruction
	config_panel.power_on = power_on
	config_panel.instruction_changed.connect(_on_config_panel_instruction_changed)
	config_panel.power_on_changed.connect(_on_config_panel_power_on_changed)


func _on_instruction_changed() -> void:
	# For restoring from the undo action
	if config_panel.instruction != instruction:
		config_panel.instruction = instruction


func _on_power_on_changed() -> void:
	# For restoring from the undo action
	if config_panel.power_on != power_on:
		config_panel.power_on = power_on


func _on_config_panel_instruction_changed(new_instruction: Frog.OnBlockedBehavior) -> void:
	instruction = new_instruction
	queue_redraw()
	options_changed.emit()


func _on_config_panel_power_on_changed(new_power_on: bool) -> void:
	power_on = new_power_on
	queue_redraw()
	options_changed.emit()
