extends Node

signal player_name_changed

var already_skipped: bool = false

enum SCENARIOS {
	NA,
	CLASSROOM1,
	CLASSROOM2,
	LIBRARY1
}

const SCENARIOS_BACKGROUNDS_PATH = "res://assets/backgrounds/"
const SCENARIOS_BACKGROUNDS := {
	"Sala de Clases - Silla": preload(SCENARIOS_BACKGROUNDS_PATH + "classroom_chair.png"),
	"Sala de Clases - Pizarra": preload(SCENARIOS_BACKGROUNDS_PATH + "classroom_whiteboard.jpg"),
}

const SCENARIOS_RESOURCES_PATH = "res://resource/carousel_scenarios/"
const SCENARIOS_RESOURCES := {
	SCENARIOS.CLASSROOM1: SCENARIOS_RESOURCES_PATH + "classroom1.tres",
	SCENARIOS.CLASSROOM2: SCENARIOS_RESOURCES_PATH + "classroom2.tres",
	SCENARIOS.NA: SCENARIOS_RESOURCES_PATH + "proximamente.tres"
}
var played_scenarios = {
	SCENARIOS.CLASSROOM1: false,
	SCENARIOS.LIBRARY1: false
}

const ABOUT_INFO: = {
	"Credits": preload("res://resource/about_info/credits.tres"),
	"Privacy": preload("res://resource/about_info/privacy.tres"),
	"Use": preload("res://resource/about_info/use.tres")
}

var styles = {
	"animated_button": {
		"normal": preload("res://resource/styles/animated_button/normal.tres"),
		"hover": preload("res://resource/styles/animated_button/hover.tres"),
		"pressed": preload("res://resource/styles/animated_button/pressed.tres"),
		"focus": preload("res://resource/styles/animated_button/focus.tres")
	}
}

var player_name
var stress_level: int = 0

var scenario_variables := {
	"Classroom1": {
		stress_level: 0,
		already_skipped: false
	}
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
	
func get_scenarios_resources() -> Array[CarouselScenarioRes]:
	var array: Array[CarouselScenarioRes] = []
	for scenario in SCENARIOS_RESOURCES.values():
		array.append(load(scenario))
	return array
	

func _on_player_name_changed():
	player_name = ConfigFileHandler.load_config_settings("settings").get("useralias")
