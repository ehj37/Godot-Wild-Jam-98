extends Node

signal snapshots_updated(num_level_snapshots: int, current_snapshot_cursor: int)
signal sync_successful
signal sync_unsuccessful
signal sync_requested
signal undo_requested
signal redo_requested
signal reset_requested
