class_name StayFreshPlayableTrack

func track() -> PlayableTrack:
	var playable_track = PlayableTrackBuilder.new()

	playable_track.set_audio_resource(load("uid://cyjei6geq4i5j"))
	playable_track.set_title("Stay Fresh")
	playable_track.set_artist("Android52")
	playable_track.set_bpm(128)
	playable_track.set_beats_per_measure(4)

	var message_to_spawn = "helloworld"

	# Spawn a bunch of test data notes!
	# One each other measure for 8 measures, counting down from a to z
	var next_character_index = 0
	for measure_index in range(8):
		if measure_index < 1:
			continue # Skip the first measure to give the player time to get ready

		var character_index = 25 - measure_index

		for beat_index in range(4):
			var character = message_to_spawn[next_character_index % message_to_spawn.length()]
			next_character_index += 1

			var spawn_time = PlayableTrackBuilder.BeatTime.new()
			spawn_time.measure = measure_index
			spawn_time.beat = beat_index

			var note_time = PlayableTrackBuilder.BeatTime.new()
			note_time.measure = measure_index + 1
			note_time.beat = beat_index - 1
			playable_track.spawn_note(spawn_time, note_time, character)
		
	return playable_track.build()
