# carousel_node.gd (en Notes)
extends Control

var base_choice_scene = preload("res://scenes/ui/choice_scene.tscn")

func _ready() -> void:
	var notas = ConfigFileHandler.get_notes()
	for nota_dict in notas:
		var choice_scene_instance: ChoiceScene = base_choice_scene.instantiate()
		
		# Reconstruir PlayerChoice desde el diccionario
		var choice = PlayerChoice.new()
		choice.scenario_name = nota_dict.get("scenario_name", "")
		choice.question = nota_dict.get("question", "")
		choice.selected_response = nota_dict.get("selected_response", "")
		choice.character = "Narrador"  # O usa nota_dict si guardaste character
		choice.emotion = nota_dict.get("emotion", "")
		choice.outcome_text = nota_dict.get("outcome_text", "")
		choice.feedback = nota_dict.get("feedback", "")
		choice.response_time = nota_dict.get("response_time", 0.0)
		
		choice_scene_instance.player_choice = choice
		add_child(choice_scene_instance)
