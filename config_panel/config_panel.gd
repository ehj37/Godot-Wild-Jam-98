class_name ConfigPanel

extends Control

signal power_on_changed(power_on: bool)
signal instruction_changed(instruction: Frog.OnBlockedBehavior)

const _INSTRUCTION_TO_LABEL: Dictionary = {
	Frog.OnBlockedBehavior.TURN_CW: "TURN CLOCKWISE",
	Frog.OnBlockedBehavior.TURN_CCW: "TURN COUNTERCLOCKWISE",
	Frog.OnBlockedBehavior.FLIP: "FLIP DIRECTION",
	Frog.OnBlockedBehavior.STOP: "STOP"
}

var power_on: bool = true:
	set(new_value):
		power_on = new_value
		_update_power_on_botton_text()
		power_on_changed.emit(power_on)
var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		_update_instruction_button_text()
		instruction_changed.emit(instruction)


func _ready() -> void:
	_update_instruction_button_text()
	_update_power_on_botton_text()


func _update_power_on_botton_text() -> void:
	var power_button: Button = get_node(
		"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PowerButton"
	)
	if power_on:
		power_button.text = "ON"
	else:
		power_button.text = "OFF"


func _update_instruction_button_text() -> void:
	var instruction_button: Button = get_node(
		"PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/InstructionButton"
	)
	instruction_button.text = _INSTRUCTION_TO_LABEL.get(instruction)


func _on_power_button_pressed() -> void:
	power_on = !power_on


func _on_instruction_button_pressed() -> void:
	instruction = wrapi(instruction + 1, 0, Frog.OnBlockedBehavior.size()) as Frog.OnBlockedBehavior
