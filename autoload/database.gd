extends Node

var already_skipped: bool = false



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

var responses_textures_normal: Dictionary = {
	1: preload("res://assets/interfaz/Opcion-1.png"),
	2: preload("res://assets/interfaz/Opcion-2.png"),
	3: preload("res://assets/interfaz/Opcion-3.png"),
	4: preload("res://assets/interfaz/Opcion-4.png")
}
var responses_textures_pressed: Dictionary = {
	1: preload("res://assets/interfaz/Opcion-1A.png"),
	2: preload("res://assets/interfaz/Opcion-2A.png"),
	3: preload("res://assets/interfaz/Opcion-3A.png"),
	4: preload("res://assets/interfaz/Opcion-4A.png")
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
