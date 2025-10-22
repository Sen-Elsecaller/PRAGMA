extends Control

var base_carousel_scenario = preload("res://scenes/ui/carousel_scene.tscn")

func _ready() -> void:
	for scenario in Utils.carousel_scenarios_array:
		var carousel_scenario_instance = base_carousel_scenario.instantiate()
		carousel_scenario_instance.scenario_resource = scenario
		add_child(carousel_scenario_instance)
