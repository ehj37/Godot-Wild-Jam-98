extends Node2D

var _low_pass_filter_tween: Tween

@onready var _music_full_stream: AudioStreamOggVorbis = preload("res://music/full_bells.ogg")
@onready var _music_loop_stream: AudioStreamOggVorbis = preload("res://music/loop_bells.ogg")


func apply_low_pass_filter_to_music() -> void:
	if _low_pass_filter_tween && _low_pass_filter_tween.is_valid():
		_low_pass_filter_tween.kill()

	var low_pass_filter: AudioEffectLowPassFilter = _get_music_low_pass_filter_effect()
	_low_pass_filter_tween = create_tween()
	_low_pass_filter_tween.tween_property(low_pass_filter, "cutoff_hz", 600, 0.5)


func remove_low_pass_filter_from_music() -> void:
	if _low_pass_filter_tween && _low_pass_filter_tween.is_valid():
		_low_pass_filter_tween.kill()

	var low_pass_filter: AudioEffectLowPassFilter = _get_music_low_pass_filter_effect()
	_low_pass_filter_tween = create_tween()
	# NOTE: Max value.
	_low_pass_filter_tween.tween_property(low_pass_filter, "cutoff_hz", 20500, 0.5)
	low_pass_filter.cutoff_hz = 20500


func play_sound_effect(stream: AudioStreamOggVorbis, pitch_scale: float = 1.0) -> void:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.stream = stream
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.bus = "SoundEffects"
	audio_player.pitch_scale = pitch_scale
	add_child(audio_player)

	audio_player.play()


func _get_music_low_pass_filter_effect() -> AudioEffectLowPassFilter:
	var music_bus_index: int = AudioServer.get_bus_index("Music")
	var low_pass_filter: AudioEffectLowPassFilter = AudioServer.get_bus_effect(music_bus_index, 0)
	return low_pass_filter


func _play_music() -> void:
	var full_audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	full_audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_full_stream.loop = false
	full_audio_player.stream = _music_full_stream
	full_audio_player.bus = "Music"
	add_child(full_audio_player)
	full_audio_player.play()
	await full_audio_player.finished

	full_audio_player.queue_free()

	var loop_audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	loop_audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_loop_stream.loop = true
	loop_audio_player.stream = _music_loop_stream
	loop_audio_player.bus = "Music"
	add_child(loop_audio_player)
	loop_audio_player.play()


func _ready() -> void:
	_play_music()
	apply_low_pass_filter_to_music()
