# Sistema centralizado de gestión de archivos de configuración y datos de usuario.
# Maneja: configuraciones del juego, autenticación, sesiones, y sincronización con backend
extends Node

# Archivos de configuración
var config = ConfigFile.new()
var save_file: Dictionary = {
	"user_data": { },
	"sesiones": [],
	"notas": []
}

# Rutas de archivos
const SETTINGS_FILE_PATH = "user://settings.ini"
const DATA_FILE_PATH = "user://SaveDataFile.json"

# Señales de sistema
signal repeated_note
signal note_saved
signal session_restored(access_token: String, refresh_token: String, email: String)
signal session_cleared()

# Inicialización: crea archivos de configuración si no existen
func _init():
	_initialize_config_file()
	_initialize_data_file()

func _initialize_config_file():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		# Configuraciones de audio y usuario
		config.set_value("settings", "sfx_volume", 0.5)
		config.set_value("settings", "music_volume", 0.5)
		config.set_value("settings", "useralias", "default")
		config.set_value("settings", "logged", false)
		
		# Configuraciones de autenticación
		config.set_value("auth", "access_token", "")
		config.set_value("auth", "refresh_token", "")
		config.set_value("auth", "user_email", "")
		config.set_value("auth", "last_login", "")
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func _initialize_data_file():
	if FileAccess.file_exists(DATA_FILE_PATH):
		set_data()
	else:
		save_data_all()

# ========================================
# CONFIGURACIONES GENERALES (audio, usuario, etc)
# ========================================

# Guarda un valor específico en la configuración
func save_config_settings(section: String, key: String, value) -> void:
	config.load(SETTINGS_FILE_PATH)
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE_PATH)

# Carga todas las configuraciones de una sección
func load_config_settings(section: String) -> Dictionary:
	config.load(SETTINGS_FILE_PATH)
	var settings: Dictionary = {}
	for key in config.get_section_keys(section):
		settings[key] = config.get_value(section, key)
	return settings

# ========================================
# GESTIÓN DE AUTENTICACIÓN
# ========================================

# Guarda tokens JWT y datos de sesión del usuario
func save_auth_session(access_token: String, refresh_token: String, email: String) -> void:
	config.load(SETTINGS_FILE_PATH)
	config.set_value("auth", "access_token", access_token)
	config.set_value("auth", "refresh_token", refresh_token)
	config.set_value("auth", "user_email", email)
	config.set_value("auth", "last_login", Time.get_datetime_string_from_system())
	config.set_value("settings", "logged", true)
	config.save(SETTINGS_FILE_PATH)

# Actualiza solo el access token (usado cuando se refresca el token)
func update_access_token(access_token: String) -> void:
	config.load(SETTINGS_FILE_PATH)
	config.set_value("auth", "access_token", access_token)
	config.save(SETTINGS_FILE_PATH)

# Recupera todos los datos de autenticación guardados
func load_auth_session() -> Dictionary:
	config.load(SETTINGS_FILE_PATH)
	return {
		"access_token": config.get_value("auth", "access_token", ""),
		"refresh_token": config.get_value("auth", "refresh_token", ""),
		"user_email": config.get_value("auth", "user_email", ""),
		"last_login": config.get_value("auth", "last_login", ""),
		"logged": config.get_value("settings", "logged", false)
	}

# Verifica si existe una sesión válida guardada
func has_saved_session() -> bool:
	config.load(SETTINGS_FILE_PATH)
	var logged = config.get_value("settings", "logged", false)
	var access_token = config.get_value("auth", "access_token", "")
	var refresh_token = config.get_value("auth", "refresh_token", "")
	return logged and access_token != "" and refresh_token != ""

# Elimina todos los datos de sesión (logout)
func clear_auth_session() -> void:
	config.load(SETTINGS_FILE_PATH)
	config.set_value("auth", "access_token", "")
	config.set_value("auth", "refresh_token", "")
	config.set_value("auth", "user_email", "")
	config.set_value("auth", "last_login", "")
	config.set_value("settings", "logged", false)
	config.save(SETTINGS_FILE_PATH)
	session_cleared.emit()

# Intenta restaurar sesión guardada automáticamente al iniciar
func try_restore_session() -> bool:
	if has_saved_session():
		var auth_data = load_auth_session()
		session_restored.emit(
			auth_data["access_token"],
			auth_data["refresh_token"],
			auth_data["user_email"]
		)
		return true
	return false

# ========================================
# GESTIÓN DE DATOS DEL USUARIO (sesiones, notas)
# ========================================

# Guarda un valor en una sección específica del save file
func save_data(section: String, key: String, value) -> void:
	if not save_file.has(section):
		save_file[section] = {}
	save_file[section][key] = value
	save_data_all()

# Escribe todo el save file al disco
func save_data_all() -> void:
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_file))
	file.close()

# Carga el save file desde el disco
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

# Inicializa los datos cargándolos
func set_data() -> void:
	load_data()

# Reinicia el save file a valores por defecto
func reset_data() -> void:
	save_file = {
		"user_data": {
			"nombre": "Gerald"
		},
		"sesiones": [],
		"notas": []
	}
	save_data_all()

# Guarda una sesión de juego completa
func save_session(feedback_data: FeedbackData) -> void:
	var session_dict = feedback_data.to_dict()
	save_file["sesiones"].append(session_dict)
	save_data_all()

# Añade una nota, evitando duplicados por feedback
func add_note(nota_dict: Dictionary) -> void:
	for nota in save_file["notas"]:
		if nota.get("feedback", "") == nota_dict.get("feedback", ""):
			repeated_note.emit()
			return
	
	save_file["notas"].append(nota_dict)
	note_saved.emit()
	save_data_all()

# Obtiene todas las notas guardadas
func get_notes() -> Array:
	return save_file["notas"]

# ========================================
# SINCRONIZACIÓN CON BACKEND
# ========================================

# Envía los datos de sesión al webhook de n8n para procesamiento
func send_session_to_webhook() -> void:
	if !FileAccess.file_exists(DATA_FILE_PATH):
		push_error("Archivo de guardado no existe")
		return
	
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(text)
	if result == null:
		push_error("Error parseando JSON")
		return
	
	if typeof(result) == TYPE_DICTIONARY:
		var http = HTTPRequest.new()
		add_child(http)
		
		var url = "https://athxx.app.n8n.cloud/webhook/savefile-created"
		var headers = ["Content-Type: application/json"]
		var body = JSON.stringify(result)
		
		http.request(url, headers, HTTPClient.METHOD_POST, body)
		await http.request_completed
		http.queue_free()
