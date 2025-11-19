class_name PlayerChoice extends Resource

@export var scenario_name: String
@export var question: String
@export var selected_response: String
@export var character: String
@export var emotion: String  # O un enum
@export var outcome_text: String
@export var feedback: String
@export var response_time: float

func to_dict() -> Dictionary:
	return {
		"scenario_name": scenario_name,
		"emotion": emotion,
		"question": Utils.strip_bbcode(question),
		"selected_response": Utils.strip_bbcode(selected_response),
		"outcome_text": Utils.strip_bbcode(outcome_text),
		"feedback": Utils.strip_bbcode(feedback),
		"response_time": response_time
	}
