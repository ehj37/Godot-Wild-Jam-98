extends Node

enum DialogSpeed { SLOW, NORMAL, FAST }

# Not really the right place for this but whatever.
var current_dialog_box: DialogBox
var selected_dialog_speed: DialogSpeed = DialogSpeed.NORMAL
