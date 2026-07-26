class_name PlayableTrackMxLxfx

static func track() -> PlayableTrack:
	var playable_track = PlayableTrackBuilder.from_registry("mx lxfx !")

	var message_to_spawn = "helloworld"

	# Spawn a bunch of test data notes!
	# One each other measure for 8 measures, counting down from a to z
	var next_character_index = 0
	# Song has a long intro with no beats
	for measure_index in range(7, 23):
		var effective_measure_index = measure_index - 7

		for beat_index in range(4):
			# Song starts on the off beat
			if effective_measure_index == 0:
				if beat_index < 2:
					continue
			
			var character = message_to_spawn[next_character_index % message_to_spawn.length()]
			next_character_index += 1

			var spawn_time = PlayableTrackBuilder.BeatTime.new()
			spawn_time.measure = measure_index
			spawn_time.beat = beat_index

			var note_time = PlayableTrackBuilder.BeatTime.new()
			note_time.measure = measure_index + 1
			note_time.beat = beat_index - 1
			playable_track.spawn_note(spawn_time, note_time, character)
	
	var completed_time = PlayableTrackBuilder.BeatTime.new()
	completed_time.measure = 24
	completed_time.beat = 0
	playable_track.completed(completed_time)
	
	return playable_track.build()
