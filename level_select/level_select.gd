class_name LevelSelect

extends Control

const LEVELS: Array[String] = [
	"res://levels/00_tutorial.tscn",
	"res://levels/01_praise_helix.tscn",
	"res://levels/02_spice_of_life.tscn",
	"res://levels/03_tower_1.tscn",
	"res://levels/04_cascades.tscn",
	"res://levels/05_tower_1_redux.tscn",
	"res://levels/06_beam_1.tscn",
	"res://levels/07_beam_2.tscn",
	"res://levels/08_fez_3.tscn",
]

@onready var _level_widget_container: GridContainer = $VBoxContainer/LevelWidgetContainer
@onready var _mouse_blocking_color_rect: ColorRect = $MouseBlockingColorRect


func _ready() -> void:
	ScreenFadeLayer.instant_fade_in()
	for level_widget: LevelWidget in _level_widget_container.get_children():
		level_widget.play_button_pressed.connect(_block_mouse_clicks)


func _block_mouse_clicks() -> void:
	_mouse_blocking_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
