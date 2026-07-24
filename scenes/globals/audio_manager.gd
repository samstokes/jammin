extends Node

func play_sfx(audio_stream: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = audio_stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
