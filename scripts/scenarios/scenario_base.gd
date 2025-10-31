class_name ScenarioBase extends Control

@onready var game_ui: GameUI = $CanvasLayer/GameUI
const SCENARIO_SELECTOR = preload("uid://btrw7gm53yrcs")
var DIALOGUE_RESOURCE: DialogueResource
var ballon_instance: CanvasLayer

func setup_signals() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.got_dialogue.connect(_on_line_emited)
	game_ui.returned_to_main_menu.connect(_stop_scenario)
	
func _stop_scenario():
	Utils.balloon_instance.queue_free()
	
func _on_dialogue_started(_dialogue):
	pass

func _on_dialogue_ended(_dialogue):
	print(Database.game_variables_dict)
	Utils.game_controller.change_gui_scene(SCENARIO_SELECTOR, false, false)

func _on_line_emited(line: DialogueLine):
	var sound_tag = line.get_tag_value("sound")
	var emotion_tag = line.get_tag_value("emotion")
	var effect_tag = line.get_tag_value("effect")
	var outcome_text_tag = line.get_tag_value("outcome_text")
	if sound_tag != "" and SoundEffect.SOUND_EFFECT_TYPE.has(sound_tag): 
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.get(sound_tag))
	
	if effect_tag != "":
		print(effect_tag)
		
	if emotion_tag != "":
		print(emotion_tag)

	if outcome_text_tag != "":
		print(outcome_text_tag)
