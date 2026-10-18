extends CanvasLayer

signal fade_finished

var _fade_tween: Tween

@onready var _color_rect: ColorRect = $ColorRect


func instant_fade_in() -> void:
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()

	_color_rect.modulate.a = 0.0


func fade_in() -> void:
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = get_tree().create_tween()
	_fade_tween.finished.connect(fade_finished.emit)
	_fade_tween.tween_property(_color_rect, "modulate:a", 0.0, 1.0)


func fade_out() -> void:
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = get_tree().create_tween()
	_fade_tween.finished.connect(fade_finished.emit)
	_fade_tween.tween_property(_color_rect, "modulate:a", 1.0, 1.0)
