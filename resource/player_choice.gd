# Representa una única decisión del jugador en un diálogo, incluyendo
# contexto (pregunta, personaje), respuesta seleccionada, y feedback asociado
class_name PlayerChoice extends Resource

# Identificación del contexto
@export var scenario_name: String
@export var character: String

# Datos del diálogo
@export var question: String
@export var selected_response: String

# Resultado de la elección
@export var emotion: String
@export var outcome_text: String
@export var feedback: String

# Métricas
@export var response_time: float

# Convierte la elección a diccionario, limpiando BBCode de los textos
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
