# Almacena toda la información de una sesión de juego, incluyendo timestamps
# y las decisiones del jugador para ser enviadas al backend
class_name FeedbackData extends Resource

# Timestamps de la sesión (formato ISO 8601)
var timestamp_inicio: String
var timestamp_fin: String = ""

# Lista de todas las decisiones tomadas durante la sesión
var elecciones: Array[PlayerChoice]

func _init() -> void:
	timestamp_inicio = _get_iso_timestamp()

# Marca el fin de la sesión y registra el timestamp de finalización
func finalizar_sesion() -> void:
	timestamp_fin = _get_iso_timestamp()

# Genera timestamp en formato ISO 8601 (compatible con Django/PostgreSQL)
func _get_iso_timestamp() -> String:
	var dt = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02dT%02d:%02d:%02d" % [
		dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second
	]

# Convierte la sesión a diccionario para serialización JSON
func to_dict() -> Dictionary:
	return {
		"timestamp_inicio": timestamp_inicio,
		"timestamp_fin": timestamp_fin,
		"decisiones": elecciones.map(func(choice): return choice.to_dict())
	}
