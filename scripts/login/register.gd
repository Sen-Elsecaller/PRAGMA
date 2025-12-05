# register_controller.gd
# Controlador de la interfaz de Registro
class_name RegisterControl extends MarginContainer

# ========== SEÑALES ==========
signal registro_completado(user_data: Dictionary)
signal register_completed
# ========== REFERENCIAS A NODOS ==========
@onready var user_input_r: LineEdit = %UserInputR
@onready var email_input_r: LineEdit = %EmailInputR
@onready var password_input_r: LineEdit = %PasswordInputR
@onready var password_confirm_input: LineEdit = %PasswordInputR2
@onready var register_button_r: BaseButton = %RegisterButtonR
@onready var validation_label_r: Label = %ValidationLabelR

# ========== CONFIGURACIÓN ==========
const API_URL = "https://pragmabackend-production.up.railway.app/api/v1/dashboard/auth/register/"
const MIN_NOMBRE_LENGTH = 3
const MAX_NOMBRE_LENGTH = 150
const MIN_PASSWORD_LENGTH = 8
const MAX_PASSWORD_LENGTH = 128

# ========== INSTANCIA DE HTTP REQUEST ==========
var http_request: HTTPRequest
var nuevo_nombre: String
# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	_setup_http_request()

func _setup_http_request() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)


	# Configurar límites de caracteres
	user_input_r.max_length = MAX_NOMBRE_LENGTH
	password_input_r.max_length = MAX_PASSWORD_LENGTH
	password_confirm_input.max_length = MAX_PASSWORD_LENGTH

# ========== EVENTOS DE UI ==========

func _on_register_button_pressed() -> void:
	_attempt_register()

func _on_nombre_submitted(_text: String) -> void:
	email_input_r.grab_focus()

func _on_email_submitted(_text: String) -> void:
	password_input_r.grab_focus()

func _on_password_submitted(_text: String) -> void:
	password_confirm_input.grab_focus()

func _on_password_confirm_submitted(_text: String) -> void:
	_attempt_register()

func _on_text_changed(_new_text: String) -> void:
	# Limpiar mensaje de error cuando el usuario empiece a escribir
	if validation_label_r.modulate == Color.RED:
		validation_label_r.text = ""

# ========== LÓGICA DE REGISTRO ==========

func _attempt_register() -> void:
	var nombre = user_input_r.text.strip_edges()
	nuevo_nombre = user_input_r.text.strip_edges()
	var email = email_input_r.text.strip_edges()
	var password = password_input_r.text
	var password_confirm = password_confirm_input.text
	
	if not _validate_all_fields(nombre, email, password, password_confirm):
		return
	
	_show_message("Registrando usuario...")
	register_button_r.disabled = true
	
	# Preparar datos para enviar
	var body = JSON.stringify({
		"nombre": nombre,
		"email": email,
		"password": password,
		"password_confirm": password_confirm
	})
	
	# Realizar petición HTTP
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json"
	]
	
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		_show_error("Error al conectar con el servidor")
		register_button_r.disabled = false

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
		user_input_r.grab_focus()
		return false
	
	# Solo espacios en blanco
	if nombre.strip_edges().is_empty():
		_show_error("El nombre no puede contener solo espacios")
		user_input_r.grab_focus()
		return false
	
	# Longitud máxima
	if nombre.length() > MAX_NOMBRE_LENGTH:
		_show_error("El nombre no puede exceder " + str(MAX_NOMBRE_LENGTH) + " caracteres")
		user_input_r.grab_focus()
		return false
	
	# Solo contiene números
	if nombre.is_valid_int() or nombre.is_valid_float():
		_show_error("El nombre no puede contener solo números")
		user_input_r.grab_focus()
		return false
	
	# Contiene caracteres especiales no permitidos
	if not _is_valid_nombre(nombre):
		_show_error("El nombre contiene caracteres no permitidos")
		user_input_r.grab_focus()
		return false
	
	return true

func _validate_email(email: String) -> bool:
	# Campo vacío
	if email.is_empty():
		_show_error("El email es obligatorio")
		email_input_r.grab_focus()
		return false
	
	# Solo espacios en blanco
	if email.strip_edges().is_empty():
		_show_error("El email no puede contener solo espacios")
		email_input_r.grab_focus()
		return false
	
	# Formato inválido
	if not _is_valid_email_format(email):
		_show_error("Formato de email inválido")
		email_input_r.grab_focus()
		return false
	
	# Email demasiado largo
	if email.length() > 254:  # RFC 5321
		_show_error("El email es demasiado largo")
		email_input_r.grab_focus()
		return false
	
	# Contiene espacios
	if email.contains(" "):
		_show_error("El email no puede contener espacios")
		email_input_r.grab_focus()
		return false
	
	return true

func _validate_password(password: String) -> bool:
	# Campo vacío
	if password.is_empty():
		_show_error("La contraseña es obligatoria")
		password_input_r.grab_focus()
		return false
	
	# Solo espacios en blanco
	if password.strip_edges().is_empty():
		_show_error("La contraseña no puede contener solo espacios")
		password_input_r.grab_focus()
		return false
	
	# Longitud mínima
	if password.length() < MIN_PASSWORD_LENGTH:
		_show_error("La contraseña debe tener al menos " + str(MIN_PASSWORD_LENGTH) + " caracteres")
		password_input_r.grab_focus()
		return false
	
	# Longitud máxima
	if password.length() > MAX_PASSWORD_LENGTH:
		_show_error("La contraseña no puede exceder " + str(MAX_PASSWORD_LENGTH) + " caracteres")
		password_input_r.grab_focus()
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
		var chara = password[i]
		
		if chara >= 'A' and chara <= 'Z':
			has_uppercase = true
		elif chara >= 'a' and chara <= 'z':
			has_lowercase = true
		elif chara >= '0' and chara <= '9':
			has_digit = true
		elif special_chars.contains(chara):
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
		password_input_r.grab_focus()
		return false
	
	# Validar que no sea una contraseña común
	if _is_common_password(password):
		_show_error("Esta contraseña es demasiado común. Elige una más segura")
		password_input_r.grab_focus()
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
	register_button_r.disabled = false
	print("Result: " + str(result))
	print("Response Code: " + str(response_code))
	if result != HTTPRequest.RESULT_SUCCESS:
		_show_error("Error de conexión con el servidor")
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	print("Error: " + str(error))
	if error != OK:
		_show_error("Error al procesar la respuesta del servidor")
		return
	
	var response = json.get_data()
	print("Response: " + str(response))
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
	ConfigFileHandler.save_config_settings("settings", "useralias", nuevo_nombre)
	Database.player_name_changed.emit()
	# Emitir señal con datos del usuario
	registro_completado.emit(response)
	
	# Limpiar campos
	_clear_fields()
	
	# Esperar un momento y volver al login
	await get_tree().create_timer(0.5).timeout
	register_completed.emit()

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
	validation_label_r.text = message
	validation_label_r.modulate = Color.RED

func _show_message(message: String) -> void:
	validation_label_r.text = message
	validation_label_r.modulate = Color.GREEN

func _clear_fields() -> void:
	user_input_r.text = ""
	email_input_r.text = ""
	password_input_r.text = ""
	password_confirm_input.text = ""
	validation_label_r.text = ""

# ========== CLEANUP ==========

func _exit_tree() -> void:
	if http_request:
		http_request.queue_free()
