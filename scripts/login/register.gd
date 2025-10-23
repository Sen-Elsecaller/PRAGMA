# register_controller.gd
# Controlador de la interfaz de Registro
extends Control

# ========== SEÑALES ==========
signal registro_completado(user_data: Dictionary)
signal volver_a_login

# ========== REFERENCIAS A NODOS ==========
@onready var nombre_input: LineEdit = $TextureRect/MarginContainer/VBoxContainer/Nombre
@onready var email_input: LineEdit = $TextureRect/MarginContainer/VBoxContainer/EmailR
@onready var password_input: LineEdit = $TextureRect/MarginContainer/VBoxContainer/PasswordR
@onready var password_confirm_input: LineEdit = $TextureRect/MarginContainer/VBoxContainer/PasswordR2
@onready var register_button: Button = $TextureRect/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Registerr
@onready var validation_label: Label = $TextureRect/MarginContainer/VBoxContainer/ValidationLabelR

# ========== CONFIGURACIÓN ==========
const API_URL = "http://127.0.0.1:8000/api/usuarios/registro/"
const MIN_NOMBRE_LENGTH = 3
const MAX_NOMBRE_LENGTH = 150
const MIN_PASSWORD_LENGTH = 8
const MAX_PASSWORD_LENGTH = 128

# ========== INSTANCIA DE HTTP REQUEST ==========
var http_request: HTTPRequest

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	_setup_http_request()
	_setup_ui()
	_connect_signals()

func _setup_http_request() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func _setup_ui() -> void:
	nombre_input.placeholder_text = "Nombre completo"
	email_input.placeholder_text = "Email"
	password_input.placeholder_text = "Contraseña (mínimo 8 caracteres)"
	password_confirm_input.placeholder_text = "Confirmar contraseña"
	password_input.secret = true
	password_confirm_input.secret = true
	validation_label.text = ""
	validation_label.modulate = Color.WHITE
	
	# Configurar límites de caracteres
	nombre_input.max_length = MAX_NOMBRE_LENGTH
	password_input.max_length = MAX_PASSWORD_LENGTH
	password_confirm_input.max_length = MAX_PASSWORD_LENGTH

func _connect_signals() -> void:
	# Conectar eventos de UI
	register_button.pressed.connect(_on_register_button_pressed)
	nombre_input.text_submitted.connect(_on_nombre_submitted)
	email_input.text_submitted.connect(_on_email_submitted)
	password_input.text_submitted.connect(_on_password_submitted)
	password_confirm_input.text_submitted.connect(_on_password_confirm_submitted)
	
	# Conectar cambios de texto para validación en tiempo real (opcional)
	nombre_input.text_changed.connect(_on_text_changed)
	email_input.text_changed.connect(_on_text_changed)
	password_input.text_changed.connect(_on_text_changed)
	password_confirm_input.text_changed.connect(_on_text_changed)

# ========== EVENTOS DE UI ==========

func _on_register_button_pressed() -> void:
	_attempt_register()

func _on_nombre_submitted(_text: String) -> void:
	email_input.grab_focus()

func _on_email_submitted(_text: String) -> void:
	password_input.grab_focus()

func _on_password_submitted(_text: String) -> void:
	password_confirm_input.grab_focus()

func _on_password_confirm_submitted(_text: String) -> void:
	_attempt_register()

func _on_text_changed(_new_text: String) -> void:
	# Limpiar mensaje de error cuando el usuario empiece a escribir
	if validation_label.modulate == Color.RED:
		validation_label.text = ""

# ========== LÓGICA DE REGISTRO ==========

func _attempt_register() -> void:
	var nombre = nombre_input.text.strip_edges()
	var email = email_input.text.strip_edges()
	var password = password_input.text
	var password_confirm = password_confirm_input.text
	
	if not _validate_all_fields(nombre, email, password, password_confirm):
		return
	
	_show_message("Registrando usuario...")
	register_button.disabled = true
	
	# Preparar datos para enviar
	var body = JSON.stringify({
		"username": email,  # Usar email como username
		"email": email,
		"password": password,
		"password2": password_confirm,
		"nombre_completo": nombre,
		"institucion": "",
		"carrera": ""
	})
	
	# Realizar petición HTTP
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json"
	]
	
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		_show_error("Error al conectar con el servidor")
		register_button.disabled = false

# ========== VALIDACIONES COMPLETAS ==========

func _validate_all_fields(nombre: String, email: String, password: String, password_confirm: String) -> bool:
	# Validar nombre
	if not _validate_nombre(nombre):
		return false
	
	# Validar email
	if not _validate_email(email):
		return false
	
	# Validar contraseña
	if not _validate_password(password):
		return false
	
	# Validar confirmación de contraseña
	if not _validate_password_confirmation(password, password_confirm):
		return false
	
	return true

func _validate_password_confirmation(password: String, password_confirm: String) -> bool:
	# Campo vacío
	if password_confirm.is_empty():
		_show_error("Debes confirmar tu contraseña")
		password_confirm_input.grab_focus()
		return false
	
	# Las contraseñas no coinciden
	if password != password_confirm:
		_show_error("Las contraseñas no coinciden")
		password_confirm_input.grab_focus()
		password_confirm_input.text = ""
		return false
	
	return true

func _validate_nombre(nombre: String) -> bool:
	# Campo vacío
	if nombre.is_empty():
		_show_error("El nombre es obligatorio")
		nombre_input.grab_focus()
		return false
	
	# Solo espacios en blanco
	if nombre.strip_edges().is_empty():
		_show_error("El nombre no puede contener solo espacios")
		nombre_input.grab_focus()
		return false
	
	# Longitud mínima
	if nombre.length() < MIN_NOMBRE_LENGTH:
		_show_error("El nombre debe tener al menos " + str(MIN_NOMBRE_LENGTH) + " caracteres")
		nombre_input.grab_focus()
		return false
	
	# Longitud máxima
	if nombre.length() > MAX_NOMBRE_LENGTH:
		_show_error("El nombre no puede exceder " + str(MAX_NOMBRE_LENGTH) + " caracteres")
		nombre_input.grab_focus()
		return false
	
	# Solo contiene números
	if nombre.is_valid_int() or nombre.is_valid_float():
		_show_error("El nombre no puede contener solo números")
		nombre_input.grab_focus()
		return false
	
	# Contiene caracteres especiales no permitidos
	if not _is_valid_nombre(nombre):
		_show_error("El nombre contiene caracteres no permitidos")
		nombre_input.grab_focus()
		return false
	
	return true

func _validate_email(email: String) -> bool:
	# Campo vacío
	if email.is_empty():
		_show_error("El email es obligatorio")
		email_input.grab_focus()
		return false
	
	# Solo espacios en blanco
	if email.strip_edges().is_empty():
		_show_error("El email no puede contener solo espacios")
		email_input.grab_focus()
		return false
	
	# Formato inválido
	if not _is_valid_email_format(email):
		_show_error("Formato de email inválido")
		email_input.grab_focus()
		return false
	
	# Email demasiado largo
	if email.length() > 254:  # RFC 5321
		_show_error("El email es demasiado largo")
		email_input.grab_focus()
		return false
	
	# Contiene espacios
	if email.contains(" "):
		_show_error("El email no puede contener espacios")
		email_input.grab_focus()
		return false
	
	return true

func _validate_password(password: String) -> bool:
	# Campo vacío
	if password.is_empty():
		_show_error("La contraseña es obligatoria")
		password_input.grab_focus()
		return false
	
	# Solo espacios en blanco
	if password.strip_edges().is_empty():
		_show_error("La contraseña no puede contener solo espacios")
		password_input.grab_focus()
		return false
	
	# Longitud mínima
	if password.length() < MIN_PASSWORD_LENGTH:
		_show_error("La contraseña debe tener al menos " + str(MIN_PASSWORD_LENGTH) + " caracteres")
		password_input.grab_focus()
		return false
	
	# Longitud máxima
	if password.length() > MAX_PASSWORD_LENGTH:
		_show_error("La contraseña no puede exceder " + str(MAX_PASSWORD_LENGTH) + " caracteres")
		password_input.grab_focus()
		return false
	
	# Validar complejidad de contraseña
	if not _is_strong_password(password):
		return false
	
	return true

# ========== VALIDADORES AUXILIARES ==========

func _is_valid_nombre(nombre: String) -> bool:
	# Permitir letras (incluidas acentuadas), espacios, guiones y apóstrofes
	var regex = RegEx.new()
	regex.compile("^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\\s\\-']+$")
	return regex.search(nombre) != null

func _is_valid_email_format(email: String) -> bool:
	# Validación completa de formato de email según RFC 5322 (simplificado)
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
	
	if regex.search(email) == null:
		return false
	
	# Validar que tenga al menos un punto después del @
	var parts = email.split("@")
	if parts.size() != 2:
		return false
	
	var domain = parts[1]
	if not domain.contains("."):
		return false
	
	# Validar que el dominio no empiece o termine con punto
	if domain.begins_with(".") or domain.ends_with("."):
		return false
	
	return true

func _is_strong_password(password: String) -> bool:
	var has_uppercase = false
	var has_lowercase = false
	var has_digit = false
	var has_special = false
	
	# Caracteres especiales comunes
	var special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
	
	for i in range(password.length()):
		var char = password[i]
		
		if char >= 'A' and char <= 'Z':
			has_uppercase = true
		elif char >= 'a' and char <= 'z':
			has_lowercase = true
		elif char >= '0' and char <= '9':
			has_digit = true
		elif special_chars.contains(char):
			has_special = true
	
	# Verificar requisitos
	var missing_requirements = []
	
	if not has_uppercase:
		missing_requirements.append("una letra mayúscula")
	if not has_lowercase:
		missing_requirements.append("una letra minúscula")
	if not has_digit:
		missing_requirements.append("un número")
	if not has_special:
		missing_requirements.append("un carácter especial (!@#$%^&*...)")
	
	if missing_requirements.size() > 0:
		var error_msg = "La contraseña debe contener: " + ", ".join(missing_requirements)
		_show_error(error_msg)
		password_input.grab_focus()
		return false
	
	# Validar que no sea una contraseña común
	if _is_common_password(password):
		_show_error("Esta contraseña es demasiado común. Elige una más segura")
		password_input.grab_focus()
		return false
	
	return true

func _is_common_password(password: String) -> bool:
	# Lista de contraseñas comunes a evitar
	var common_passwords = [
		"password", "12345678", "password1", "qwerty123", "abc123456",
		"Password1", "password123", "12345678a", "123456789",
		"password1!", "Qwerty123", "Welcome1", "Admin123"
	]
	
	var lower_password = password.to_lower()
	
	for common in common_passwords:
		if lower_password == common.to_lower():
			return true
	
	return false

# ========== CALLBACKS DE HTTP ==========

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	register_button.disabled = false
	
	if result != HTTPRequest.RESULT_SUCCESS:
		_show_error("Error de conexión con el servidor")
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error != OK:
		_show_error("Error al procesar la respuesta del servidor")
		return
	
	var response = json.get_data()
	
	match response_code:
		201:  # Created
			_on_registro_success(response)
		400:  # Bad Request
			_on_registro_failed(response)
		409:  # Conflict (usuario ya existe)
			_show_error("Este email ya está registrado")
		422:  # Unprocessable Entity
			_on_registro_failed(response)
		500:  # Internal Server Error
			_show_error("Error interno del servidor. Intenta nuevamente")
		_:
			_show_error("Error desconocido: " + str(response_code))

func _on_registro_success(response: Dictionary) -> void:
	_show_message("¡Registro exitoso! Redirigiendo al login...")
	
	# Emitir señal con datos del usuario
	registro_completado.emit(response)
	
	# Limpiar campos
	_clear_fields()
	
	# Esperar un momento y volver al login
	await get_tree().create_timer(1.5).timeout
	volver_a_login.emit()

func _on_registro_failed(response: Dictionary) -> void:
	# Manejar diferentes tipos de errores del servidor
	if response.has("email"):
		var error_msg = response["email"]
		if error_msg is Array and error_msg.size() > 0:
			_show_error("Email: " + str(error_msg[0]))
		else:
			_show_error("Email: " + str(error_msg))
	elif response.has("username"):
		var error_msg = response["username"]
		if error_msg is Array and error_msg.size() > 0:
			_show_error("Usuario: " + str(error_msg[0]))
		else:
			_show_error("Usuario: " + str(error_msg))
	elif response.has("password"):
		var error_msg = response["password"]
		if error_msg is Array and error_msg.size() > 0:
			_show_error("Contraseña: " + str(error_msg[0]))
		else:
			_show_error("Contraseña: " + str(error_msg))
	elif response.has("nombre"):
		var error_msg = response["nombre"]
		if error_msg is Array and error_msg.size() > 0:
			_show_error("Nombre: " + str(error_msg[0]))
		else:
			_show_error("Nombre: " + str(error_msg))
	elif response.has("error"):
		_show_error(str(response["error"]))
	elif response.has("detail"):
		_show_error(str(response["detail"]))
	elif response.has("message"):
		_show_error(str(response["message"]))
	else:
		_show_error("Error en el registro. Verifica los datos.")

# ========== UTILIDADES DE UI ==========

func _show_error(message: String) -> void:
	validation_label.text = message
	validation_label.modulate = Color.RED

func _show_message(message: String) -> void:
	validation_label.text = message
	validation_label.modulate = Color.GREEN

func _clear_fields() -> void:
	nombre_input.text = ""
	email_input.text = ""
	password_input.text = ""
	password_confirm_input.text = ""
	validation_label.text = ""

# ========== CLEANUP ==========

func _exit_tree() -> void:
	if http_request:
		http_request.queue_free()


func _on_register_pressed() -> void:
	pass # Replace with function body.
