extends Control

var base_carousel_scenario = preload("res://scenes/ui/carousel_scene.tscn")

signal info_pressed

func _ready() -> void:
	for scenario in Database.get_scenarios_resources():
		var carousel_scenario_instance: CarouselScene = base_carousel_scenario.instantiate()
		carousel_scenario_instance.scenario_resource = scenario
		carousel_scenario_instance.info_pressed.connect(on_info_pressed)
		add_child(carousel_scenario_instance)

func on_info_pressed(carousel_resource: CarouselScenarioRes):
	info_pressed.emit(carousel_resource)
