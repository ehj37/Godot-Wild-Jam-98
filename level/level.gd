class_name Level

extends Node2D

signal action_finished

const _FROG_ACTION_DURATION: float = 0.1

@export var grid: Grid
@export var level_name: String
@export_multiline var explanation: String

var _turn_in_progress: bool = false
var _level_won: bool = false
var _level_snapshots: Array[LevelSnapshot]
var _current_snapshot_cursor: int = 0

var _frog_move_tween: Tween
var _new_frog_fade_tween: Tween
var _frog_rotate_timer: Timer

@onready var _frog_packed_scene: PackedScene = preload("res://frog/frog.tscn")


class FrogSnapshot:
	var grid_location: Vector2i
	var direction: Frog.Direction
	var on_blocked_behavior: Frog.OnBlockedBehavior

	@warning_ignore("shadowed_variable")

	func _init(
		grid_location: Vector2i,
		direction: Frog.Direction,
		on_blocked_behavior: Frog.OnBlockedBehavior
	) -> void:
		self.grid_location = grid_location
		self.direction = direction
		self.on_blocked_behavior = on_blocked_behavior


class SignalEmitterSnapshot:
	var grid_location: Vector2i
	var power_on: bool
	var instruction: Frog.OnBlockedBehavior

	@warning_ignore("shadowed_variable")

	func _init(
		grid_location: Vector2i, power_on: bool, instruction: Frog.OnBlockedBehavior
	) -> void:
		self.power_on = power_on
		self.instruction = instruction
		self.grid_location = grid_location


class FrogPipeSnapshot:
	var disabled: bool
	var instruction: Frog.OnBlockedBehavior
	var grid_location: Vector2i

	@warning_ignore("shadowed_variable")

	func _init(
		grid_location: Vector2i, disabled: bool, instruction: Frog.OnBlockedBehavior
	) -> void:
		self.disabled = disabled
		self.instruction = instruction
		self.grid_location = grid_location


class LevelSnapshot:
	var frog_snapshots: Array[FrogSnapshot]
	var signal_emitter_snapshots: Array[SignalEmitterSnapshot]
	var frog_pipe_snapshots: Array[FrogPipeSnapshot]

	@warning_ignore("shadowed_variable")

	func _init(
		frog_snapshots: Array[FrogSnapshot],
		signal_emitter_snapshots: Array[SignalEmitterSnapshot],
		frog_pipe_snapshots: Array[FrogPipeSnapshot]
	) -> void:
		self.frog_snapshots = frog_snapshots
		self.signal_emitter_snapshots = signal_emitter_snapshots
		self.frog_pipe_snapshots = frog_pipe_snapshots


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() || _level_won:
		return

	if Input.is_action_just_pressed("undo"):
		_undo()

	if Input.is_action_just_pressed("redo"):
		_redo()

	if !_turn_in_progress && Input.is_action_just_pressed("test"):
		_turn_in_progress = true
		_apply_turn_speed()

		# NOTE: Currently, there's no reason why this would change as the frogs
		# move. If a moving, non-frog, signal-beam-blocking entity came into
		# being, this would potentially need recomputing (depending on when
		# said entity would move relative to the frogs).
		var signal_emitter_to_effected_grid_locations: Dictionary
		var signal_emitters: Array[SignalEmitter] = _get_signal_emitters()
		for signal_emitter: SignalEmitter in signal_emitters:
			signal_emitter_to_effected_grid_locations.set(
				signal_emitter, signal_emitter.get_effected_grid_locations(grid)
			)

		var frogs: Array[Frog] = _get_frogs()
		for frog: Frog in frogs:
			var next_grid_location: Vector2i = frog.get_next_grid_location()
			if !grid.is_empty(next_grid_location):
				var next_direction: Frog.Direction = frog.get_next_direction()
				frog.direction = next_direction
				# Only do one next grid location check here - interesting if a frog
				# gets into a nook and needs multiple turns to do a 270 deg turn.
				next_grid_location = frog.get_next_grid_location()
				if TurnConfig.get_current_turn_speed() != TurnConfig.TurnSpeed.INSTANT:
					_frog_rotate_timer.start()
					await action_finished

			if grid.is_empty(next_grid_location):
				var next_grid_location_global_position: Vector2 = Grid.get_global_position_center(
					next_grid_location
				)
				if TurnConfig.get_current_turn_speed() != TurnConfig.TurnSpeed.INSTANT:
					_frog_move_tween = get_tree().create_tween()
					_frog_move_tween.tween_property(
						frog,
						"global_position",
						next_grid_location_global_position,
						_FROG_ACTION_DURATION
					)
					_frog_move_tween.finished.connect(action_finished.emit)
					await action_finished

					# NOTE: Don't quite understand what's up with this, but
					# without this, weird warping behavior can occur.
					if _frog_move_tween.is_valid():
						_frog_move_tween.kill()

				grid.update_residency(grid.Residency.FROG, frog.grid_location, next_grid_location)
				frog.grid_location = next_grid_location

				var signal_blocked_behavior: Frog.OnBlockedBehavior = _get_signal_behavior_at(
					frog.grid_location, signal_emitters, signal_emitter_to_effected_grid_locations
				)
				if signal_blocked_behavior != -1:
					frog.on_blocked_behavior = signal_blocked_behavior

		var pipes: Array[FrogPipe] = _get_pipes()
		for pipe: FrogPipe in pipes:
			if pipe.disabled:
				continue

			var spawn_location: Vector2i = pipe.get_spawn_location()
			if grid.is_empty(spawn_location):
				var new_frog: Frog = _add_frog(spawn_location, pipe.direction, pipe.instruction)
				if TurnConfig.get_current_turn_speed() != TurnConfig.TurnSpeed.INSTANT:
					new_frog.modulate.a = 0.0
					_new_frog_fade_tween = get_tree().create_tween()
					_new_frog_fade_tween.tween_property(
						new_frog, "modulate:a", 1.0, _FROG_ACTION_DURATION
					)
					_new_frog_fade_tween.finished.connect(action_finished.emit)
					await action_finished

					if _new_frog_fade_tween.is_valid():
						_new_frog_fade_tween.kill()

				var signal_blocked_behavior: Frog.OnBlockedBehavior = _get_signal_behavior_at(
					new_frog.grid_location,
					signal_emitters,
					signal_emitter_to_effected_grid_locations
				)
				if signal_blocked_behavior != -1:
					new_frog.on_blocked_behavior = signal_blocked_behavior

		_return_to_normal_time_scale()
		# NOTE: All redo history after the current cursor gets wiped.
		_level_snapshots.resize(_current_snapshot_cursor + 1)
		_capture_snapshot()
		_current_snapshot_cursor += 1
		UILayer.on_snapshot_update(_level_snapshots.size(), _current_snapshot_cursor)
		_turn_in_progress = false


func _ready() -> void:
	_capture_snapshot()
	_current_snapshot_cursor = 0
	UILayer.on_snapshot_update(_level_snapshots.size(), _current_snapshot_cursor)

	_frog_rotate_timer = Timer.new()
	_frog_rotate_timer.one_shot = true
	_frog_rotate_timer.wait_time = _FROG_ACTION_DURATION
	_frog_rotate_timer.timeout.connect(action_finished.emit)
	add_child(_frog_rotate_timer)

	UILayer.sync_button_pressed.connect(_on_sync_button_pressed)
	# TODO: Undo should work during a turn. Should skip to the end and instantly
	# revert.
	UILayer.undo_button_pressed.connect(_undo)
	UILayer.redo_button_pressed.connect(_redo)
	UILayer.reset_button_pressed.connect(_reset)
	TurnConfig.turn_speed_changed.connect(_on_turn_speed_changed)

	var radio_tile_maps: Array[GridTileMap] = _get_radio_tile_maps()
	for radio_tile_map: GridTileMap in radio_tile_maps:
		var grid_tile_locations: Array[Vector2i] = radio_tile_map.get_tile_grid_locations()
		for grid_tile_location: Vector2i in grid_tile_locations:
			grid.register_radio_tile(grid_tile_location)

	for pipe: FrogPipe in _get_pipes():
		grid.register_residency(Grid.Residency.PIPE, pipe.grid_location)

	var block_tile_maps: Array[GridTileMap] = _get_block_tile_maps()
	for block_tile_map: GridTileMap in block_tile_maps:
		var grid_tile_locations: Array[Vector2i] = block_tile_map.get_tile_grid_locations()
		for grid_tile_location: Vector2i in grid_tile_locations:
			grid.register_residency(Grid.Residency.TILE, grid_tile_location)

	var signal_emitters: Array[SignalEmitter] = _get_signal_emitters()
	for signal_emitter: SignalEmitter in signal_emitters:
		signal_emitter.options_changed.connect(
			func() -> void: _on_signal_emitter_options_changed(signal_emitter)
		)
		grid.register_residency(Grid.Residency.SIGNAL_EMITTER, signal_emitter.grid_location)
	# NOTE: This needs to come last since signal emitters may be blocked by
	# other entities.
	for signal_emitter: SignalEmitter in signal_emitters:
		signal_emitter.update(grid)


func _get_frogs() -> Array[Frog]:
	var result: Array[Frog]
	result.assign(get_tree().get_nodes_in_group("frog"))
	return result


func _add_frog(
	spawn_location: Vector2i, direction: Frog.Direction, on_blocked_behavior: Frog.OnBlockedBehavior
) -> Frog:
	grid.register_residency(Grid.Residency.FROG, spawn_location)
	var new_frog: Frog = _frog_packed_scene.instantiate()
	new_frog.grid_residency = Grid.Residency.FROG
	new_frog.grid_location = spawn_location
	new_frog.direction = direction
	new_frog.on_blocked_behavior = on_blocked_behavior
	new_frog.number = grid.get_num_frogs()
	add_child(new_frog)
	new_frog.name = "Frog"

	return new_frog


func _remove_frog(frog: Frog) -> void:
	grid.unregister_residency(grid.Residency.FROG, frog.grid_location)
	frog.queue_free()


func _get_pipes() -> Array[FrogPipe]:
	var result: Array[FrogPipe]
	result.assign(get_tree().get_nodes_in_group("frog_pipe"))
	return result


func _get_signal_emitters() -> Array[SignalEmitter]:
	var result: Array[SignalEmitter]
	result.assign(get_tree().get_nodes_in_group("signal_emitter"))
	return result


func _get_block_tile_maps() -> Array[GridTileMap]:
	var result: Array[GridTileMap]
	result.assign(get_tree().get_nodes_in_group("block_tile_map"))
	return result


func _get_radio_tile_maps() -> Array[GridTileMap]:
	var result: Array[GridTileMap]
	result.assign(get_tree().get_nodes_in_group("radio_tile_map"))
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

	var effected_grid_locations: Array[Vector2i] = signal_emitter.get_effected_grid_locations(grid)
	# Note: Ugly, should prob maintain a location -> frog mapping
	for frog: Frog in _get_frogs():
		if effected_grid_locations.has(frog.grid_location):
			frog.on_blocked_behavior = signal_emitter.instruction


# NOTE: I'm not being smart about only recording a snapshot if current snapshot
# differs from the previous one. May be the case that there are no frogs and all
# signal emitters are the same as they were before.
func _capture_snapshot() -> void:
	var frog_snapshots: Array[FrogSnapshot]
	var frogs: Array[Frog] = _get_frogs()
	# NOTE: Frog number is baked into the order of the snapshots, just as it
	# is currently baked into the order from _get_frogs.
	for frog: Frog in frogs:
		var frog_snapshot: FrogSnapshot = FrogSnapshot.new(
			frog.grid_location, frog.direction, frog.on_blocked_behavior
		)
		frog_snapshots.append(frog_snapshot)

	var signal_emitter_snapshots: Array[SignalEmitterSnapshot]
	var signal_emitters: Array[SignalEmitter] = _get_signal_emitters()
	for signal_emitter: SignalEmitter in signal_emitters:
		var signal_emitter_snapshot: SignalEmitterSnapshot = SignalEmitterSnapshot.new(
			signal_emitter.grid_location, signal_emitter.power_on, signal_emitter.instruction
		)
		signal_emitter_snapshots.append(signal_emitter_snapshot)

	var frog_pipe_snapshots: Array[FrogPipeSnapshot]
	var pipes: Array[FrogPipe] = _get_pipes()
	for pipe: FrogPipe in pipes:
		var frog_pipe_snapshot: FrogPipeSnapshot = FrogPipeSnapshot.new(
			pipe.grid_location, pipe.disabled, pipe.instruction
		)
		frog_pipe_snapshots.append(frog_pipe_snapshot)

	var level_snapshot: LevelSnapshot = LevelSnapshot.new(
		frog_snapshots, signal_emitter_snapshots, frog_pipe_snapshots
	)
	_level_snapshots.append(level_snapshot)


func _restore_state_from_snapshot(snapshot_to_restore: LevelSnapshot) -> void:
	var frogs: Array[Frog] = _get_frogs()
	for frog: Frog in frogs:
		_remove_frog(frog)
	for frog_snapshot: FrogSnapshot in snapshot_to_restore.frog_snapshots:
		_add_frog(
			frog_snapshot.grid_location, frog_snapshot.direction, frog_snapshot.on_blocked_behavior
		)

	var signal_emitters: Array[SignalEmitter] = _get_signal_emitters()
	var signal_emitter_snapshot_by_grid_location: Dictionary
	for signal_emitter_snapshot: SignalEmitterSnapshot in (
		snapshot_to_restore.signal_emitter_snapshots
	):
		signal_emitter_snapshot_by_grid_location.set(
			signal_emitter_snapshot.grid_location, signal_emitter_snapshot
		)
	for signal_emitter: SignalEmitter in signal_emitters:
		var signal_emitter_snapshot: SignalEmitterSnapshot = (
			signal_emitter_snapshot_by_grid_location.get(signal_emitter.grid_location)
		)
		assert(
			signal_emitter_snapshot,
			"Not expected that signal emitters can come into or out of being and/or move."
		)
		signal_emitter.power_on = signal_emitter_snapshot.power_on
		signal_emitter.instruction = signal_emitter_snapshot.instruction

	var pipes: Array[FrogPipe] = _get_pipes()
	var frog_pipe_snapshot_by_grid_location: Dictionary
	for frog_pipe_snapshot: FrogPipeSnapshot in snapshot_to_restore.frog_pipe_snapshots:
		frog_pipe_snapshot_by_grid_location.set(
			frog_pipe_snapshot.grid_location, frog_pipe_snapshot
		)
	for pipe: FrogPipe in pipes:
		var frog_pipe_snapshot: FrogPipeSnapshot = frog_pipe_snapshot_by_grid_location.get(
			pipe.grid_location
		)
		assert(
			frog_pipe_snapshot,
			"Not expected that frog pipes can come into or out of being and/or move."
		)
		pipe.disabled = frog_pipe_snapshot.disabled
		pipe.instruction = frog_pipe_snapshot.instruction


func _undo() -> void:
	if _current_snapshot_cursor == 0 || _turn_in_progress:
		return

	_current_snapshot_cursor -= 1
	var snapshot_to_restore: LevelSnapshot = _level_snapshots[_current_snapshot_cursor]
	_restore_state_from_snapshot(snapshot_to_restore)
	UILayer.on_snapshot_update(_level_snapshots.size(), _current_snapshot_cursor)


func _redo() -> void:
	if _current_snapshot_cursor == _level_snapshots.size() - 1 || _turn_in_progress:
		return

	_current_snapshot_cursor += 1
	var snapshot_to_restore: LevelSnapshot = _level_snapshots[_current_snapshot_cursor]
	_restore_state_from_snapshot(snapshot_to_restore)
	UILayer.on_snapshot_update(_level_snapshots.size(), _current_snapshot_cursor)


func _reset() -> void:
	_level_snapshots.resize(1)
	_current_snapshot_cursor = 0
	_restore_state_from_snapshot(_level_snapshots[0])
	UILayer.on_snapshot_update(_level_snapshots.size(), _current_snapshot_cursor)


func _on_sync_button_pressed() -> void:
	if grid.win_condition_met():
		_level_won = true
		UILayer.on_level_won()
	else:
		UILayer.on_sync_failed()


func _apply_turn_speed() -> void:
	var turn_speed: TurnConfig.TurnSpeed = TurnConfig.get_current_turn_speed()
	match turn_speed:
		TurnConfig.TurnSpeed.TENTH:
			Engine.time_scale = 0.1
		TurnConfig.TurnSpeed.NORMAL:
			Engine.time_scale = 1.0
		TurnConfig.TurnSpeed.DOUBLE:
			Engine.time_scale = 2.0
		TurnConfig.TurnSpeed.INSTANT:
			# NOTE: The tween killing should be handled up above, so this
			# shouldn't be strictly necessary.
			for tween: Tween in [_frog_move_tween, _new_frog_fade_tween]:
				if tween && tween.is_valid():
					tween.kill()
			_frog_rotate_timer.stop()
			action_finished.emit()


func _return_to_normal_time_scale() -> void:
	Engine.time_scale = 1.0


func _on_turn_speed_changed(_new_turn_speed: TurnConfig.TurnSpeed) -> void:
	if _turn_in_progress:
		_apply_turn_speed()
