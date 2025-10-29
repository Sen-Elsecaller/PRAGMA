extends Node

var game_variables_dict: Dictionary = {}
enum GAME_VARIABLES {
	CORRECT_ANSWER,
	MEDIUM_ANSWER,
	BAD_ANSWER
}

var game_sessions: Array [Dictionary]


func _ready() -> void:
	for game_variable in GAME_VARIABLES:
		game_variables_dict[game_variable] = 0
		
func manage_variable(variable: String, amount: int):
	if game_variables_dict.has(variable):
		game_variables_dict[variable] += amount
		print(game_variables_dict[variable])
