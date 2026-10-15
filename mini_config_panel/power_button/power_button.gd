@tool

class_name PowerButton

extends Control

signal power_button_pressed(new_value: bool)

var power_on: bool = true:
	set(new_value):
		power_on = new_value
		_set_texture_rect_modulate()

@onready var _texture_rect: TextureRect = $CenterContainer/TextureRect


func _ready() -> void:
	_set_texture_rect_modulate()


func _set_texture_rect_modulate() -> void:
	if power_on:
		_texture_rect.modulate = Color.GREEN
	else:
		_texture_rect.modulate = Color.RED


func _on_button_pressed() -> void:
	power_on = !power_on
	power_button_pressed.emit(power_on)
