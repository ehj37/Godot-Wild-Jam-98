extends Node2D


func play_sound_effect(stream: AudioStreamOggVorbis, pitch_scale: float = 1.0) -> void:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.stream = stream
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.bus = "SoundEffects"
	audio_player.pitch_scale = pitch_scale
	add_child(audio_player)

	audio_player.play()
