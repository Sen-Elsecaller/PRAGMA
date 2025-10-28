class_name ScenarioBase extends Control

@onready var game_ui: GameUI = $CanvasLayer/GameUI
const SCENARIO_SELECTOR = preload("uid://btrw7gm53yrcs")
var DIALOGUE_RESOURCE: DialogueResource
var ballon_instance: CanvasLayer

func setup_signals() -> void:
	#ballon_instance = get_tree().get_
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	game_ui.returned_to_main_menu.connect(_stop_scenario)
	
func _stop_scenario():
	pass
	
func on_dialogic_signal(function: String):
	if function.begins_with("sound_"):
		call_audio_manager(function.get_slice("sound_", 1))

func call_audio_manager(sound_type: String):
	if SoundEffect.SOUND_EFFECT_TYPE.has(sound_type):
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.get(sound_type))
	else:
		push_error("No se encontro el sonido necesario")

func _on_dialogue_started(_dialogue):
	pass

func _on_dialogue_ended(_dialogue):
	print(Utils.game_variables_dict)
	Utils.game_controller.change_gui_scene(SCENARIO_SELECTOR, false, false)
