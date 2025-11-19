extends Node

var config = ConfigFile.new()
var save_file:  = {
	"user_data": {
		"nombre": "Gerald"
		},
		
	"sesiones": [],
	
	"notas": []
	
}

const SETTINGS_FILE_PATH = "user://settings.ini"
const DATA_FILE_PATH = "user://SaveDataFile.json"

signal repeated_note
signal note_saved

func _init():
	#TODO ELIMINAR RESET save_file Y TERMINAR DE CONFIGURAR EL GUARDADO
	#ConfigFile
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("settings", "sound", 3)
		config.set_value("settings", "useralias", "Gerald")
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	
	if FileAccess.file_exists(DATA_FILE_PATH):
		set_data()
	else:
		save_data_all()
	
func save_config_settings(section: String, key: String, value) -> void:
	config.load(SETTINGS_FILE_PATH)
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE_PATH)

func load_config_settings(section: String) -> Dictionary:
	config.load(SETTINGS_FILE_PATH)
	var settings: Dictionary = {}
	for key in config.get_section_keys(section):
		settings[key] = config.get_value(section, key)
	return settings

func save_data(section: String, key: String, value) -> void:
	if not save_file.has(section):
		save_file[section] = {}
	save_file[section][key] = value
	save_data_all()

func save_data_all() -> void:
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_file))
	file.close()
	
func load_data() -> void:
	if !FileAccess.file_exists(DATA_FILE_PATH):
		return
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(text)
	if result == null:
		push_error("Error parseando JSON, usando valores por defecto")
		return
	if typeof(result) == TYPE_DICTIONARY:
		save_file = result
		
func set_data() -> void:
	load_data()
	
# Actualmente reinicia el savefile, pero no el estado del juego
func reset_data() -> void:
	save_file = {
		"user_data": {
			"nombre": "Gerald"
			},
			
		"sesiones": [],
		
		"notas": []
	}
	save_data_all()

func save_session(feedback_data: FeedbackData) -> void:
	var session_dict = feedback_data.to_dict()
	save_file["sesiones"].append(session_dict)
	save_data_all()

func add_note(nota_dict: Dictionary) -> void:
	for nota in save_file["notas"]:
		if nota.get("feedback", "") == nota_dict.get("feedback", ""):
			repeated_note.emit()
			return
	
	save_file["notas"].append(nota_dict)
	note_saved.emit()
	save_data_all()
	
func get_notes() -> Array:
	return save_file["notas"]
