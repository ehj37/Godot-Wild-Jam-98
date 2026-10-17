extends Control

enum SmileAmount { NONE, SMALL, NORMAL, HUMUNGOUS }

@export var starting_smile: SmileAmount

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.set_frame_and_progress(starting_smile, 0)
