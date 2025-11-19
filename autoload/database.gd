extends Node

signal player_name_changed

var already_skipped: bool = false

enum SCENARIOS {
	NA,
	CLASSROOM1,
	LIBRARY1
}

const SCENARIOS_RESOURCES_PATH = "res://resource/carousel_scenarios/"
const SCENARIOS_RESOURCES := {
	SCENARIOS.CLASSROOM1: preload(SCENARIOS_RESOURCES_PATH + "classroom1.tres"),
	SCENARIOS.LIBRARY1: preload(SCENARIOS_RESOURCES_PATH + "library1.tres")
}
var played_scenarios = {
	SCENARIOS.CLASSROOM1: false,
	SCENARIOS.LIBRARY1: false
}

var player_name
var stress_level: int = 0



var game_variables_dict: Dictionary = {}
enum GAME_VARIABLES {
	CORRECT_ANSWER,
	MEDIUM_ANSWER,
	BAD_ANSWER
}

var game_sessions: Array [Dictionary]


enum {
	CHARACTER,
	NARRATOR,
	PLAYER
}

const ACTORS = {
	character = {
		texture_type = preload("res://assets/nueva_interfaz/Bloque_Chat_Personaje_Largo_2.svg"),
		pivot_side = Utils.PivotPosition.CENTER_LEFT,
	},
	narrator = {
		texture_type = preload("res://assets/nueva_interfaz/Bloque_Chat_Narrador_Largo.svg"),
		pivot_side = Utils.PivotPosition.CENTER,
	},
	player = {
		texture_type = preload("res://assets/nueva_interfaz/Bloque_Chat_Personaje_Largo_1.svg"),
		pivot_side = Utils.PivotPosition.CENTER_RIGHT
	}
}

var dialogue_textures: Dictionary = {
	CHARACTER: preload("res://assets/interfaz/Texto-1.png"),
	NARRATOR: preload("res://assets/interfaz/Fondo-Ajustes.png"),
	PLAYER: preload("res://assets/interfaz/Texto-2.png"),
}

func _ready() -> void:
	player_name_changed.connect(_on_player_name_changed)
	_on_player_name_changed()
	for game_variable in GAME_VARIABLES:
		game_variables_dict[game_variable] = 0
	
func get_scenarios_resources() -> Array[CarouselScenarioRes]:
	var array: Array[CarouselScenarioRes] = []
	for scenario in SCENARIOS_RESOURCES.values():
		array.append(scenario)
	return array
	

func _on_player_name_changed():
	player_name = ConfigFileHandler.load_config_settings("settings").get("useralias")

func manage_variable(variable: String, amount: int):
	if game_variables_dict.has(variable):
		game_variables_dict[variable] += amount
		print(game_variables_dict[variable])
