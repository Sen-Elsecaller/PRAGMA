# register.gd
# Clase encargada de gestionar el registro de usuarios
extends Control

# ========== SEÑALES ==========
signal go_to_login
signal register_success(user_data: Dictionary)
signal register_failed(error_message: String)

# ========== REFERENCIAS A NODOS ==========
@onready var nombre: TextEdit = %Username
@onready var password: LineEdit = %Password
@onready var email: TextEdit = %Email
@onready var validation_label: Label = %RegisterValidationLabel
@onready var http: HTTPRequest = HTTPRequest.new()

# ========== CONFIGURACIÓN ==========
const API_URL = "http://127.0.0.1:8000/api/usuarios/registro/"
const MIN_PASSWORD_LENGTH = 6

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	
	password.secret = true
	password.placeholder_text = "Contraseña"
	
	validation_label.text = ""

# ========== VALIDACIÓN ==========

# Valida el formato de un correo electrónico
func _is_valid_email(email_text: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email_text) != null

# Obtiene texto limpio de un TextEdit o LineEdit
func _get_clean_text(node) -> String:
	if node == null:
		return ""
	return node.text.replace("\n", "").replace("\r", "").strip_edges()

# Valida todos los campos antes de enviar
func _validate_all_fields() -> bool:
	validation_label.text = ""
	
	var nombre_text = _get_clean_text(nombre)
	if nombre_text.is_empty():
		validation_label.text = "El nombre es obligatorio"
		return false
	
	var email_text = _get_clean_text(email)
	if email_text.is_empty():
		validation_label.text = "El correo electrónico es obligatorio"
		return false
	elif not _is_valid_email(email_text):
		validation_label.text = "Formato de correo inválido (ej: usuario@dominio.com)"
		return false
	
	var password_text = _get_clean_text(password)
	if password_text.is_empty():
		validation_label.text = "La contraseña es obligatoria"
		return false
	elif password_text.length() < MIN_PASSWORD_LENGTH:
		validation_label.text = "La contraseña debe tener al menos %d caracteres" % MIN_PASSWORD_LENGTH
		return false
	
	return true

# ========== REGISTRO ==========

# Enviar datos de registro al backend
func _on_submit_pressed() -> void:
	if not _validate_all_fields():
		return
	
	validation_label.text = "Registrando usuario..."
	
	var nombre_text = _get_clean_text(nombre)
	var email_text = _get_clean_text(email)
	var password_text = _get_clean_text(password)
	
	var data = {
		"nombre": nombre_text,
		"email": email_text,
		"password": password_text
	}
	var headers = ["Content-Type: application/json"]
	
	var error = http.request(API_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	if error != OK:
		validation_label.text = "Error al conectar con el servidor"
		register_failed.emit("Error de conexión")

# Maneja respuesta del servidor
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	
	if response_code == 201:
		validation_label.text = "¡Usuario registrado correctamente!"
		
		var user_data = {
			"nombre": _get_clean_text(nombre),
			"email": _get_clean_text(email)
		}
		
		register_success.emit(user_data)
		
		await get_tree().create_timer(1.5).timeout
		_clear_fields()
		go_to_login.emit()
		
	elif response_code == 400:
		_handle_validation_error(response_text)
		
	elif response_code == 500:
		validation_label.text = "Error interno del servidor"
		register_failed.emit("Error interno del servidor")
		
	else:
		validation_label.text = "Error inesperado (Código: %d)" % response_code
		register_failed.emit("Error inesperado: código %d" % response_code)

# Maneja errores de validación del servidor
func _handle_validation_error(response_text: String) -> void:
	var json = JSON.new()
	if json.parse(response_text) == OK:
		var resp = json.data
		if resp.has("email"):
			validation_label.text = "El correo ya está registrado"
			register_failed.emit("El correo ya está registrado")
		elif resp.has("nombre"):
			validation_label.text = "El nombre ya existe"
			register_failed.emit("El nombre ya existe")
		else:
			validation_label.text = "Datos inválidos. Revisa la información"
			register_failed.emit("Datos inválidos")
	else:
		validation_label.text = "Error de validación del servidor"
		register_failed.emit("Error de validación")

# ========== UTILIDADES ==========

# Limpia todos los campos del formulario
func _clear_fields() -> void:
	nombre.text = ""
	email.text = ""
	password.text = ""
	validation_label.text = ""

# Cambiar a la pantalla de login
func _on_login_pressed() -> void:
	go_to_login.emit()
