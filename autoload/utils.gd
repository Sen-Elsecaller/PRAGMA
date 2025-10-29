extends Node

var carousel_scenarios_array: Array[CarouselScenarioRes]
var game_controller: GameController = null
var rng: RandomNumberGenerator = null
var balloon_instance: CanvasLayer

const CAROUSEL_SCENARIOS_PATH = "res://resource/carousel_scenarios/"
const Carousel_Scenarios := {
	"Classroom1": preload(CAROUSEL_SCENARIOS_PATH + "classroom1.tres"),
	"Library1": preload(CAROUSEL_SCENARIOS_PATH + "library1.tres")
}

var game_variables_dict: Dictionary = {}

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_set_balloon_instance)
	game_controller = get_node("/root/GameController")
	rng = RandomNumberGenerator.new()
	
	for scenario in Carousel_Scenarios:
		carousel_scenarios_array.append(Carousel_Scenarios[scenario])

func _set_balloon_instance(_dialogue):
	balloon_instance = game_controller.find_child("ExampleBalloon", true, false)
	print(balloon_instance)
