extends Control

@onready var game_ui: GameUI = $CanvasLayer/GameUI

func _ready() -> void:
	game_ui.returned_to_main_menu.connect(stop_dialogic)
	Dialogic.start("classroom1")


func stop_dialogic():
	pass
