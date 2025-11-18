extends Control

var feedback_data: FeedbackData
var base_choice_scene = preload("res://scenes/ui/choice_scene.tscn")

func _ready() -> void:
	for choice in Utils.game_controller.current_feedback.elecciones:
		var choice_scene_instance: ChoiceScene = base_choice_scene.instantiate()
		choice_scene_instance.player_choice = choice
		add_child(choice_scene_instance)
