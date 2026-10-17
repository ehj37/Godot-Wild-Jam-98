extends Node

@warning_ignore_start("unused_signal")
signal snapshots_updated(num_level_snapshots: int, current_snapshot_cursor: int)
signal sync_successful
signal sync_unsuccessful
signal sync_requested
signal undo_requested
signal redo_requested
signal reset_requested
signal level_ready(level_name: String)
