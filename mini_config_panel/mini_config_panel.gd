@tool

class_name MiniConfigPanel

extends BoxContainer

signal power_on_changed(power_on: bool)
signal instruction_changed(instruction: Frog.OnBlockedBehavior)

enum ButtonOrientation { POWER_LEFT, POWER_RIGHT, POWER_TOP, POWER_BOTTOM }

const _MOUSE_ENTERED_ALPHA: float = 1.0
const _MOUSE_EXITED_ALPHA: float = 0.6

var orientation: ButtonOrientation:
	set(new_value):
		orientation = new_value
		if self.is_node_ready():
			_update_buttons()

var power_on: bool = true:
	set(new_value):
		power_on = new_value
		if self.is_node_ready():
			_update_buttons()

		power_on_changed.emit(power_on)
var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		instruction_changed.emit(instruction)
		if self.is_node_ready():
			_update_buttons()

@onready var _power_button: PowerButton = $PowerButton
@onready var _instruction_button: InstructionButton = $InstructionButton


func _ready() -> void:
	modulate.a = _MOUSE_EXITED_ALPHA

	_instruction_button.instruction_button_pressed.connect(
		func(new_instruction: Frog.OnBlockedBehavior) -> void: instruction = new_instruction
	)
	_power_button.power_button_pressed.connect(
		func(new_power_on: bool) -> void: power_on = new_power_on
	)

	_update_buttons()


func _update_buttons() -> void:
	_power_button.power_on = power_on
	_instruction_button.instruction = instruction
	if power_on:
		_instruction_button.start()
	else:
		_instruction_button.stop()

	match orientation:
		ButtonOrientation.POWER_TOP:
			move_child(_power_button, 0)
			vertical = true
		ButtonOrientation.POWER_BOTTOM:
			move_child(_instruction_button, 0)
			vertical = true
		ButtonOrientation.POWER_LEFT:
			move_child(_power_button, 0)
			vertical = false
		ButtonOrientation.POWER_RIGHT:
			move_child(_instruction_button, 0)
			vertical = false


func _on_instruction_button_pressed() -> void:
	instruction = wrapi(instruction + 1, 0, Frog.OnBlockedBehavior.size()) as Frog.OnBlockedBehavior


func _on_mouse_entered() -> void:
	modulate.a = _MOUSE_ENTERED_ALPHA


func _on_mouse_exited() -> void:
	modulate.a = _MOUSE_EXITED_ALPHA
