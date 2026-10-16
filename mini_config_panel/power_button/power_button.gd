@tool

class_name PowerButton

extends Control

signal power_button_pressed(new_value: bool)

var power_on: bool = true:
	set(new_value):
		power_on = new_value
		_set_texture_rect_modulate()
var stuck: bool = false:
	set(new_value):
		stuck = new_value
		if is_node_ready():
			_button.disabled = stuck
			_set_texture_rect_modulate()

@onready var _button: Button = $CenterContainer/Button
@onready var _texture_rect: TextureRect = $CenterContainer/TextureRect


func _ready() -> void:
	_button.disabled = stuck
	_set_texture_rect_modulate()


func _set_texture_rect_modulate() -> void:
	if power_on:
		if stuck:
			_texture_rect.modulate = Color("008a00")
		else:
			_texture_rect.modulate = Color("00ff00")
	else:
		if stuck:
			_texture_rect.modulate = Color("6b0000")
		else:
			_texture_rect.modulate = Color("ff0000")


func _on_button_pressed() -> void:
	power_on = !power_on
	power_button_pressed.emit(power_on)
