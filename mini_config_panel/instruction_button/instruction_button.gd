@tool

class_name InstructionButton

extends Control

signal instruction_button_pressed(new_instruction: Frog.OnBlockedBehavior)

var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		if is_node_ready():
			_update_from_state()
var stuck: bool:
	set(new_value):
		stuck = new_value
		if is_node_ready():
			_update_from_state()
var _power_on: bool

@onready var _sprite_clockwise: AnimatedSprite2D = $CenterContainer/SpriteClockwise
@onready var _sprite_flip_horizontal: AnimatedSprite2D = $CenterContainer/SpriteFlipHorizontal
@onready var _button: Button = $CenterContainer/Button


func start() -> void:
	_power_on = true
	_update_from_state()


func stop() -> void:
	_power_on = false
	_update_from_state()


func _on_button_pressed() -> void:
	instruction = wrapi(instruction + 1, 0, Frog.OnBlockedBehavior.size()) as Frog.OnBlockedBehavior
	_update_from_state()
	instruction_button_pressed.emit(instruction)


func _ready() -> void:
	_update_from_state()


func _update_from_state() -> void:
	var sprite_modulate_color: Color
	if _power_on:
		_button.disabled = stuck
		if stuck:
			sprite_modulate_color = Color("9e6600")
		else:
			sprite_modulate_color = Color("ffa500")
		_sprite_clockwise.play()
		_sprite_flip_horizontal.play()
	else:
		sprite_modulate_color = Color("613f00")
		_button.disabled = true
		_sprite_clockwise.pause()
		_sprite_flip_horizontal.pause()

	_sprite_clockwise.modulate = sprite_modulate_color
	_sprite_flip_horizontal.modulate = sprite_modulate_color

	match instruction:
		Frog.OnBlockedBehavior.TURN_CW:
			_sprite_clockwise.visible = true
			_sprite_clockwise.flip_h = false
			_sprite_flip_horizontal.visible = false
		Frog.OnBlockedBehavior.TURN_CCW:
			_sprite_clockwise.visible = true
			_sprite_clockwise.flip_h = true
			_sprite_flip_horizontal.visible = false
		Frog.OnBlockedBehavior.FLIP:
			_sprite_clockwise.visible = false
			_sprite_flip_horizontal.visible = true
