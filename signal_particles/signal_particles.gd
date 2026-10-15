class_name SignalParticles

extends GPUParticles2D

@export var instruction: Frog.OnBlockedBehavior:
	set(new_value):
		instruction = new_value
		if is_node_ready():
			_update_visuals()

@onready var _texture_clockwise: CompressedTexture2D = preload(
	"res://instruction_animated_icons/clockwise.png"
)
@onready var _texture_counterclockwise: CompressedTexture2D = preload(
	"res://instruction_animated_icons/counterclockwise.png"
)
@onready var _texture_flip: CompressedTexture2D = preload(
	"res://instruction_animated_icons/flip_horizontal.png"
)


func _ready() -> void:
	_update_visuals()


func _update_visuals() -> void:
	var canvas_item_material: CanvasItemMaterial = material
	match instruction:
		Frog.OnBlockedBehavior.TURN_CW:
			texture = _texture_clockwise
			canvas_item_material.particles_anim_h_frames = 16
		Frog.OnBlockedBehavior.TURN_CCW:
			texture = _texture_counterclockwise
			canvas_item_material.particles_anim_h_frames = 16
		Frog.OnBlockedBehavior.FLIP:
			texture = _texture_flip
			canvas_item_material.particles_anim_h_frames = 8
