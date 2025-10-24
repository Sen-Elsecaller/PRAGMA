extends Control

@onready var game_ui: GameUI = $CanvasLayer/GameUI

var dialogue

func _ready() -> void:
	game_ui.returned_to_main_menu.connect(stop_dialogic)
	Dialogic.start("classroom1")
	Dialogic.signal_event.connect(activate_efecto_latido)
	
func stop_dialogic():
	Dialogic.end_timeline(true)

func activate_efecto_latido(effect: String):
	EffectsManager.play_sound(effect)
