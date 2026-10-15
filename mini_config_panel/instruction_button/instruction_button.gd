@tool

class_name InstructionButton

extends Control

signal instruction_button_pressed(new_instruction: Frog.OnBlockedBehavior)

var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		_update_sprites()

@onready var _sprite_clockwise: AnimatedSprite2D = $CenterContainer/SpriteClockwise
@onready var _sprite_flip_horizontal: AnimatedSprite2D = $CenterContainer/SpriteFlipHorizontal
@onready var _button: Button = $CenterContainer/Button


func start() -> void:
	_sprite_clockwise.play()
	_sprite_flip_horizontal.play()
	_button.disabled = false


func stop() -> void:
	_sprite_clockwise.pause()
	_sprite_flip_horizontal.pause()
	_button.disabled = true


func _on_button_pressed() -> void:
	instruction = wrapi(instruction + 1, 0, Frog.OnBlockedBehavior.size()) as Frog.OnBlockedBehavior
	_update_sprites()
	instruction_button_pressed.emit(instruction)


func _ready() -> void:
	_update_sprites()


func _update_sprites() -> void:
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
