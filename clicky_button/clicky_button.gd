extends Button

@onready var _button_down_stream: AudioStreamOggVorbis = preload("./sound_effects/button_down.ogg")
@onready var _button_up_stream: AudioStreamOggVorbis = preload("./sound_effects/button_up.ogg")
@onready var _pressed_stream: AudioStreamOggVorbis = preload("./sound_effects/pressed.ogg")
@onready
var _mouse_entered_stream: AudioStreamOggVorbis = preload("./sound_effects/mouse_entered.ogg")


func _on_button_down() -> void:
	AudioManager.play_sound_effect(_button_down_stream)


func _on_button_up() -> void:
	AudioManager.play_sound_effect(_button_up_stream)


func _on_pressed() -> void:
	AudioManager.play_sound_effect(_pressed_stream)


func _on_mouse_entered() -> void:
	if !disabled:
		AudioManager.play_sound_effect(_mouse_entered_stream)


func _on_mouse_exited() -> void:
	pass
