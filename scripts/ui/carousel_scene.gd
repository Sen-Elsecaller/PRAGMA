class_name CarouselScene extends MarginContainer

@onready var photo = %Photo
@onready var scenario_name = %ScenarioName
@onready var info_button: AnimatedTextureButton = %InfoButton
@onready var play_button: AnimatedButton = %PlayButton
var scenario_resource: CarouselScenarioRes

signal info_pressed(scene_resource: CarouselScenarioRes)

func _ready() -> void:
	photo.texture = scenario_resource.main_photo
	scenario_name.text = scenario_resource.scenario_name
	if scenario_name.text == "Proximamente":
		info_button.hide()
		play_button.hide()
	
func _on_play_button_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	Utils.game_controller.current_scenario_name = scenario_resource.scenario_name
	Utils.game_controller.change_gui_scene(scenario_resource.scene, false, false)
	AudioManager.toggle_bgm_music()


func _on_info_button_pressed() -> void:
	info_pressed.emit(scenario_resource)
