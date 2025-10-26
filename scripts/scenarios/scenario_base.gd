class_name ScenarioBase extends Control

@onready var game_ui: GameUI = $CanvasLayer/GameUI

var dialogue

func setup_signals() -> void:
	game_ui.returned_to_main_menu.connect(stop_dialogic)
	Dialogic.signal_event.connect(on_dialogic_signal)
	
func stop_dialogic():
	Dialogic.end_timeline(true)
	
func on_dialogic_signal(function: String):
	if function.begins_with("sound_"):
			call_audio_manager(function.get_slice("sound_", 1))

func call_audio_manager(sound_type: String):
	if SoundEffect.SOUND_EFFECT_TYPE.has(sound_type):
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.get(sound_type))
	else:
		push_error("No se encontro el sonido necesario")
