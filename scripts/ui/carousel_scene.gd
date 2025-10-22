class_name CarouselScene extends MarginContainer

@onready var photo = %Photo
@onready var scenario_name = %ScenarioName
var scenario_resource: CarouselScenarioRes


func _ready() -> void:
	photo.texture = scenario_resource.main_photo
	scenario_name.text = scenario_resource.scenario_name

func _on_play_button_pressed() -> void:
	Utils.game_controller.change_gui_scene(scenario_resource.scene, false, false)
