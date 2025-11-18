class_name GameUI extends Control

@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var content_history: VBoxContainer = %Content
const DIALOGUE_RECORD = preload("uid://bn3ejoudgfx7e")

signal returned_to_main_menu
signal dialogue_history_pressed

func _ready() -> void:
	pass

func _on_update_dialogue_history(character: String, text: String):
	var dialogue: DialogueRecord = DIALOGUE_RECORD.instantiate()
	dialogue.character = character
	dialogue.text = text
	content_history.add_child(dialogue)
	
func _on_exit_pressed() -> void:
	EffectsManager.post_fx.toggle_fx("VignetteFX", false)
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_BACK)
	Utils.game_controller.return_to_main_menu()
	
func _on_menu_button_pressed() -> void:
	animations.play("open_game_menu")

func _on_close_menu_pressed() -> void:
	animations.play("close_game_menu")
	
func _on_dialogue_history_pressed() -> void:
	animations.play("open_dialogue_history")

func _on_close_dialogue_history_pressed() -> void:
	animations.play("close_dialogue_history")
