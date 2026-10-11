class_name OnBlockedIndicator

extends Node2D

var direction: Frog.Direction:
	set(new_value):
		direction = new_value
		_update()
var on_blocked_behavior: Frog.OnBlockedBehavior:
	set(new_value):
		on_blocked_behavior = new_value
		_update()


func _update() -> void:
	var sprite_cw: AnimatedSprite2D = get_node("SpriteCW")
	var sprite_flip_vertical: AnimatedSprite2D = get_node("SpriteFlipVertical")
	match on_blocked_behavior:
		Frog.OnBlockedBehavior.TURN_CW:
			sprite_cw.visible = true
			sprite_cw.flip_h = false
			sprite_flip_vertical.visible = false
		Frog.OnBlockedBehavior.TURN_CCW:
			sprite_cw.visible = true
			sprite_cw.flip_h = true
			sprite_flip_vertical.visible = false
		Frog.OnBlockedBehavior.FLIP:
			sprite_flip_vertical.visible = true
			if direction == Frog.Direction.RIGHT || direction == Frog.Direction.LEFT:
				sprite_flip_vertical.rotation = PI / 2
			else:
				sprite_flip_vertical.rotation = 0

			sprite_cw.visible = false
		Frog.OnBlockedBehavior.STOP:
			pass
