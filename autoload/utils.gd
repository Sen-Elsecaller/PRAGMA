extends Node

var carousel_scenarios_array: Array[CarouselScenarioRes]
var game_controller: GameController = null

func _ready() -> void:
	game_controller = get_node("/root/GameController")
	
	for scenario in Carousel_Scenarios:
		carousel_scenarios_array.append(load(Carousel_Scenarios[scenario]))

const CAROUSEL_SCENARIOS_PATH = "res://resource/carousel_scenarios/"

const Carousel_Scenarios := {
	"Classroom1": CAROUSEL_SCENARIOS_PATH + "classroom1.tres",
	"Library1": CAROUSEL_SCENARIOS_PATH + "library1.tres"
}
