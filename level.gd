extends Node2D

@export var frog_pipes: Array[FrogPipe]

var _turn_in_progress: bool = false

@onready var _frog_packed_scene: PackedScene = preload("res://frog/frog.tscn")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if !_turn_in_progress && Input.is_action_just_pressed("test"):
		_turn_in_progress = true

		var signal_beams: Array[SignalBeam] = _get_signal_beams()
		# NOTE: Currently, there's no reason why this would change as the frogs
		# move. If a moving, non-frog, signal-beam-blocking entity came into
		# being, this would potentially need recomputing (depending on when
		# said entity would move relative to the frogs).
		var signal_beam_to_effected_grid_locations: Dictionary
		for signal_beam: SignalBeam in signal_beams:
			signal_beam_to_effected_grid_locations.set(
				signal_beam, signal_beam.get_effected_grid_locations()
			)

		var frogs: Array[Frog] = _get_frogs()
		for frog: Frog in frogs:
			var next_grid_location: Vector2i = frog.get_next_grid_location()
			if !GridState.is_empty(next_grid_location):
				var next_direction: Frog.Direction = frog.get_next_direction()
				frog.direction = next_direction
				# Only do one next grid location check here - interesting if a frog
				# gets into a nook and needs multiple turns to do a 270 deg turn.
				next_grid_location = frog.get_next_grid_location()

			if GridState.is_empty(next_grid_location):
				GridState.update_residency(
					GridState.Residency.FROG, frog.grid_location, next_grid_location
				)
				frog.grid_location = next_grid_location

				for signal_beam: SignalBeam in signal_beams:
					var effected_grid_locations: Array[Vector2i] = (
						signal_beam_to_effected_grid_locations.get(signal_beam)
					)
					if effected_grid_locations.has(frog.grid_location):
						frog.on_blocked_behavior = signal_beam.on_blocked_behavior

			await get_tree().create_timer(0.0).timeout

		var pipes: Array[FrogPipe] = _get_pipes()
		for pipe: FrogPipe in pipes:
			if pipe.disabled:
				continue

			var spawn_location: Vector2i = pipe.get_spawn_location()
			if GridState.is_empty(spawn_location):
				var new_frog: Frog = _frog_packed_scene.instantiate()
				new_frog.grid_residency = GridState.Residency.FROG
				new_frog.grid_location = spawn_location
				new_frog.direction = pipe.direction
				new_frog.on_blocked_behavior = pipe.on_blocked_behavior
				for signal_beam: SignalBeam in signal_beams:
					var effected_grid_locations: Array[Vector2i] = (
						signal_beam_to_effected_grid_locations.get(signal_beam)
					)
					if effected_grid_locations.has(new_frog.grid_location):
						new_frog.on_blocked_behavior = signal_beam.on_blocked_behavior
				add_child(new_frog)
				new_frog.name = "Frog"
				await get_tree().create_timer(0.0).timeout

		_turn_in_progress = false


func _get_frogs() -> Array[Frog]:
	var result: Array[Frog]
	result.assign(get_tree().get_nodes_in_group("frog"))
	return result


func _get_pipes() -> Array[FrogPipe]:
	var result: Array[FrogPipe]
	result.assign(get_tree().get_nodes_in_group("frog_pipe"))
	return result


func _get_signal_beams() -> Array[SignalBeam]:
	var result: Array[SignalBeam]
	result.assign(get_tree().get_nodes_in_group("signal_beam"))
	return result
