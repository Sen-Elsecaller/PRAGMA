extends Node

var already_skipped: bool = false

var player_name: String = "Gerald"
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
	
	for game_variable in GAME_VARIABLES:
		game_variables_dict[game_variable] = 0
		
func manage_variable(variable: String, amount: int):
	if game_variables_dict.has(variable):
		game_variables_dict[variable] += amount
		print(game_variables_dict[variable])
