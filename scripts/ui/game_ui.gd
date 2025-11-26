class_name GameUI extends Control

@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var content_history: VBoxContainer = %Content
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
const DIALOGUE_RECORD = preload("uid://bn3ejoudgfx7e")

signal returned_to_main_menu
signal dialogue_history_pressed

func _ready() -> void:
	sfx_slider.set_value_no_signal(ConfigFileHandler.load_config_settings("settings").get("sfx_volume"))
	music_slider.set_value_no_signal(ConfigFileHandler.load_config_settings("settings").get("music_volume"))

func _on_update_dialogue_history(character: String, text: String):
	var dialogue: DialogueRecord = DIALOGUE_RECORD.instantiate()
	dialogue.character = character
	dialogue.text = text
	content_history.add_child(dialogue)
	
func _on_exit_pressed() -> void:
	EffectsManager.post_fx.toggle_fx("VignetteFX", false)
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_BACK)
	AudioManager.toggle_bgm_music()
	Utils.game_controller.return_to_main_menu()
	
func _on_menu_button_pressed() -> void:
	animations.play("open_game_menu")

func _on_close_menu_pressed() -> void:
	animations.play("close_game_menu")
	
func _on_dialogue_history_pressed() -> void:
	animations.play("open_dialogue_history")

func _on_close_dialogue_history_pressed() -> void:
	animations.play("close_dialogue_history")

func _on_settings_pressed() -> void:
	animations.play("open_settings_menu")

func _on_close_settings_pressed() -> void:
	animations.play("close_settings_menu")

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value)
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_ITEM1)
	ConfigFileHandler.save_config_settings("settings", "sfx_volume", value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value)
	ConfigFileHandler.save_config_settings("settings", "sfx_volume", value)
