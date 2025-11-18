class_name FeedbackData extends Resource

var timestamp_inicio: String
var timestamp_fin: String = ""
var elecciones: Array[PlayerChoice]


func _init() -> void:
	timestamp_inicio = _get_iso_timestamp()

func finalizar_sesion() -> void:
	timestamp_fin = _get_iso_timestamp()

func _get_iso_timestamp() -> String:
	var dt = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02dT%02d:%02d:%02d" % [
		dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second
	]
