extends Control

@onready var _main_volume_slider: HSlider = get_node(
	"MarginContainer/VBoxContainer/MainVolumeContainer/MainVolumeSlider"
)
@onready var _sound_effect_volume_slider: HSlider = get_node(
	"MarginContainer/VBoxContainer/SoundEffectVolumeContainer/SoundEffectVolumeSlider"
)
@onready var _music_volume_slider: HSlider = get_node(
	"MarginContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider"
)
@onready var _slow_text_button: Button = get_node(
	"MarginContainer/VBoxContainer/TextSpeedContainer/HBoxContainer/SlowTextButton"
)
@onready var _normal_text_button: Button = get_node(
	"MarginContainer/VBoxContainer/TextSpeedContainer/HBoxContainer/NormalTextButton"
)
@onready var _fast_text_button: Button = get_node(
	"MarginContainer/VBoxContainer/TextSpeedContainer/HBoxContainer/FastTextButton"
)


func _ready() -> void:
	var master_bus_index: int = AudioServer.get_bus_index("Master")
	_main_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))

	var sound_effects_bus_index: int = AudioServer.get_bus_index("SoundEffects")
	_sound_effect_volume_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(sound_effects_bus_index)
	)

	var music_bus_index: int = AudioServer.get_bus_index("Music")
	_music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))


func _play_test_value() -> void:
	# TODO
	pass


func _on_main_volume_slider_value_changed(value: float) -> void:
	var master_bus_index: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(master_bus_index, value)


func _on_sound_effect_volume_slider_value_changed(value: float) -> void:
	var sound_effects_bus_index: int = AudioServer.get_bus_index("SoundEffects")
	AudioServer.set_bus_volume_linear(sound_effects_bus_index, value)

	_play_test_value()


func _on_music_volume_slider_value_changed(value: float) -> void:
	var music_bus_index: int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(music_bus_index, value)


func _on_slow_text_button_pressed() -> void:
	_slow_text_button.disabled = true
	_normal_text_button.disabled = false
	_fast_text_button.disabled = false
	DialogConfig.selected_dialog_speed = DialogConfig.DialogSpeed.SLOW


func _on_normal_text_button_pressed() -> void:
	_slow_text_button.disabled = false
	_normal_text_button.disabled = true
	_fast_text_button.disabled = false
	DialogConfig.selected_dialog_speed = DialogConfig.DialogSpeed.NORMAL


func _on_fast_text_button_pressed() -> void:
	_slow_text_button.disabled = false
	_normal_text_button.disabled = false
	_fast_text_button.disabled = true
	DialogConfig.selected_dialog_speed = DialogConfig.DialogSpeed.FAST
