# register_controller.gd
# Controlador de la interfaz de Registro (usando AuthManager)
class_name RegisterControl extends MarginContainer

# ========== SEÑALES ==========
signal register_completed

# ========== REFERENCIAS A NODOS ==========
@onready var user_input_r: LineEdit = %UserInputR
@onready var email_input_r: LineEdit = %EmailInputR
@onready var password_input_r: LineEdit = %PasswordInputR
@onready var password_confirm_input: LineEdit = %PasswordInputR2
@onready var register_button_r: BaseButton = %RegisterButtonR
@onready var validation_label_r: Label = %ValidationLabelR

# ========== CONFIGURACIÓN ==========
const MIN_NOMBRE_LENGTH = 3
const MAX_NOMBRE_LENGTH = 150
const MIN_PASSWORD_LENGTH = 8
const MAX_PASSWORD_LENGTH = 128

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	_connect_signals()
	_setup_input_limits()

func _connect_signals() -> void:
	# Conectar señales de AuthManager
	AuthManager.register_success.connect(_on_register_success)
	AuthManager.register_failed.connect(_on_register_failed)

func _setup_input_limits() -> void:
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
	if validation_label_r.modulate == Color.RED:
		validation_label_r.text = ""

# ========== LÓGICA DE REGISTRO ==========

func _attempt_register() -> void:
	var nombre = user_input_r.text.strip_edges()
	var email = email_input_r.text.strip_edges()
	var password = password_input_r.text
	var password_confirm = password_confirm_input.text
	
	if not _validate_all_fields(nombre, email, password, password_confirm):
		return
	
	_show_message("Registrando usuario...")
	register_button_r.disabled = true
	
	# Usar AuthManager para registro
	AuthManager.register(nombre, email, password, password_confirm)

# ========== VALIDACIONES COMPLETAS ==========

func _validate_all_fields(nombre: String, email: String, password: String, password_confirm: String) -> bool:
	if not _validate_nombre(nombre):
		return false
	if not _validate_email(email):
		return false
	if not _validate_password(password):
		return false
	if not _validate_password_confirmation(password, password_confirm):
		return false
	return true

func _validate_password_confirmation(password: String, password_confirm: String) -> bool:
	if password_confirm.is_empty():
		_show_error("Debes confirmar tu contraseña")
		password_confirm_input.grab_focus()
		return false
	
	if password != password_confirm:
		_show_error("Las contraseñas no coinciden")
		password_confirm_input.grab_focus()
		password_confirm_input.text = ""
		return false
	
	return true

func _validate_nombre(nombre: String) -> bool:
	if nombre.is_empty():
		_show_error("El nombre es obligatorio")
		user_input_r.grab_focus()
		return false
	
	if nombre.strip_edges().is_empty():
		_show_error("El nombre no puede contener solo espacios")
		user_input_r.grab_focus()
		return false
	
	if nombre.length() > MAX_NOMBRE_LENGTH:
		_show_error("El nombre no puede exceder " + str(MAX_NOMBRE_LENGTH) + " caracteres")
		user_input_r.grab_focus()
		return false
	
	if nombre.is_valid_int() or nombre.is_valid_float():
		_show_error("El nombre no puede contener solo números")
		user_input_r.grab_focus()
		return false
	
	if not _is_valid_nombre(nombre):
		_show_error("El nombre contiene caracteres no permitidos")
		user_input_r.grab_focus()
		return false
	
	return true

func _validate_email(email: String) -> bool:
	if email.is_empty():
		_show_error("El email es obligatorio")
		email_input_r.grab_focus()
		return false
	
	if email.strip_edges().is_empty():
		_show_error("El email no puede contener solo espacios")
		email_input_r.grab_focus()
		return false
	
	if not _is_valid_email_format(email):
		_show_error("Formato de email inválido")
		email_input_r.grab_focus()
		return false
	
	if email.length() > 254:
		_show_error("El email es demasiado largo")
		email_input_r.grab_focus()
		return false
	
	if email.contains(" "):
		_show_error("El email no puede contener espacios")
		email_input_r.grab_focus()
		return false
	
	return true

func _validate_password(password: String) -> bool:
	if password.is_empty():
		_show_error("La contraseña es obligatoria")
		password_input_r.grab_focus()
		return false
	
	if password.strip_edges().is_empty():
		_show_error("La contraseña no puede contener solo espacios")
		password_input_r.grab_focus()
		return false
	
	if password.length() < MIN_PASSWORD_LENGTH:
		_show_error("La contraseña debe tener al menos " + str(MIN_PASSWORD_LENGTH) + " caracteres")
		password_input_r.grab_focus()
		return false
	
	if password.length() > MAX_PASSWORD_LENGTH:
		_show_error("La contraseña no puede exceder " + str(MAX_PASSWORD_LENGTH) + " caracteres")
		password_input_r.grab_focus()
		return false
	
	if not _is_strong_password(password):
		return false
	
	return true

# ========== VALIDADORES AUXILIARES ==========

func _is_valid_nombre(nombre: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\\s\\-']+$")
	return regex.search(nombre) != null

func _is_valid_email_format(email: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
	
	if regex.search(email) == null:
		return false
	
	var parts = email.split("@")
	if parts.size() != 2:
		return false
	
	var domain = parts[1]
	if not domain.contains("."):
		return false
	
	if domain.begins_with(".") or domain.ends_with("."):
		return false
	
	return true

func _is_strong_password(password: String) -> bool:
	var has_uppercase = false
	var has_lowercase = false
	var has_digit = false
	var has_special = false
	
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
	
	if _is_common_password(password):
		_show_error("Esta contraseña es demasiado común. Elige una más segura")
		password_input_r.grab_focus()
		return false
	
	return true

func _is_common_password(password: String) -> bool:
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

# ========== CALLBACKS DE AUTHMANAGER ==========

func _on_register_success(_user_data: Dictionary) -> void:
	_show_message("¡Registro exitoso! Redirigiendo al login...")
	register_button_r.disabled = false
	Database.player_name_changed.emit()
	
	_clear_fields()
	
	await get_tree().create_timer(0.5).timeout
	register_completed.emit()

func _on_register_failed(error_message: String) -> void:
	_show_error(error_message)
	register_button_r.disabled = false

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
