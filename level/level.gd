extends Node2D

@export var frog_pipes: Array[FrogPipe]

var _turn_in_progress: bool = false

@onready var _frog_packed_scene: PackedScene = preload("res://frog/frog.tscn")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if !_turn_in_progress && Input.is_action_just_pressed("test"):
		_turn_in_progress = true

		var signal_emitters: Array[SignalEmitter] = _get_signal_emitters()
		# NOTE: Currently, there's no reason why this would change as the frogs
		# move. If a moving, non-frog, signal-beam-blocking entity came into
		# being, this would potentially need recomputing (depending on when
		# said entity would move relative to the frogs).
		var signal_emitter_to_effected_grid_locations: Dictionary
		for signal_emitter: SignalEmitter in signal_emitters:
			signal_emitter_to_effected_grid_locations.set(
				signal_emitter, signal_emitter.get_effected_grid_locations()
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

				var signal_blocked_behavior: Frog.OnBlockedBehavior = _get_signal_behavior_at(
					frog.grid_location, signal_emitters, signal_emitter_to_effected_grid_locations
				)
				if signal_blocked_behavior != -1:
					frog.on_blocked_behavior = signal_blocked_behavior

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
				new_frog.on_blocked_behavior = pipe.instruction
				var signal_blocked_behavior: Frog.OnBlockedBehavior = _get_signal_behavior_at(
					new_frog.grid_location,
					signal_emitters,
					signal_emitter_to_effected_grid_locations
				)
				if signal_blocked_behavior != -1:
					new_frog.on_blocked_behavior = signal_blocked_behavior

				add_child(new_frog)
				new_frog.name = "Frog"
				await get_tree().create_timer(0.0).timeout

		_turn_in_progress = false


func _ready() -> void:
	var signal_emitters: Array[SignalEmitter] = _get_signal_emitters()
	for signal_emitter: SignalEmitter in signal_emitters:
		signal_emitter.options_changed.connect(
			func() -> void: _on_signal_emitter_options_changed(signal_emitter)
		)


func _get_frogs() -> Array[Frog]:
	var result: Array[Frog]
	result.assign(get_tree().get_nodes_in_group("frog"))
	return result


func _get_pipes() -> Array[FrogPipe]:
	var result: Array[FrogPipe]
	result.assign(get_tree().get_nodes_in_group("frog_pipe"))
	return result


func _get_signal_emitters() -> Array[SignalEmitter]:
	var result: Array[SignalEmitter]
	result.assign(get_tree().get_nodes_in_group("signal_emitter"))
	return result


func _get_signal_behavior_at(
	grid_location: Vector2i,
	signal_emitters: Array[SignalEmitter],
	signal_emitter_to_effected_grid_locations: Dictionary
) -> Frog.OnBlockedBehavior:
	for signal_emitter: SignalEmitter in signal_emitters:
		var effected_grid_locations: Array[Vector2i] = (
			signal_emitter_to_effected_grid_locations.get(signal_emitter)
		)
		if effected_grid_locations.has(grid_location):
			return signal_emitter.instruction

	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	return -1


func _on_signal_emitter_options_changed(signal_emitter: SignalEmitter) -> void:
	if !signal_emitter.power_on:
		return

	var effected_grid_locations: Array[Vector2i] = signal_emitter.get_effected_grid_locations()
	# Note: Ugly, should prob maintain a location -> frog mapping
	for frog: Frog in _get_frogs():
		if effected_grid_locations.has(frog.grid_location):
			frog.on_blocked_behavior = signal_emitter.instruction
