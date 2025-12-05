# login_controller.gd
# Controlador que usa AuthManager directamente (sin client.gd local)
class_name LoginControl extends MarginContainer

# ========== SEÑALES ==========
signal go_to_register
signal login_completed
signal validation_error(message: String)
signal validation_success(message: String)

# ========== REFERENCIAS A NODOS UI ==========
@onready var user_input: LineEdit = %UserInputLogin
@onready var password_input: LineEdit = %PasswordInputLogin
@onready var validation_label: Label = %ValidationLabelLogin
@onready var login_button: BaseButton = %LoginButtonLogin
@onready var register_button: BaseButton = %RegisterButtonLogin

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	_connect_signals()
	_connect_controller_signals()
	
	# Intentar auto-login si hay sesión guardada
	await get_tree().process_frame
	_try_auto_login()

# ========== CONECTAR SEÑALES ==========
func _connect_signals() -> void:
	# Conectar señales de AuthManager
	AuthManager.login_success.connect(_on_login_success)
	AuthManager.login_failed.connect(_on_login_failed)
	AuthManager.session_restored.connect(_on_session_restored)
	AuthManager.token_refreshed.connect(_on_token_refreshed)
	AuthManager.token_refresh_failed.connect(_on_token_refresh_failed)

func _connect_controller_signals() -> void:
	validation_error.connect(_update_validation_label_error)
	validation_success.connect(_update_validation_label_success)

# ========== AUTO-LOGIN ==========
func _try_auto_login() -> void:
	if AuthManager.has_active_session():
		validation_success.emit("Restaurando sesión...")
		# AuthManager ya restauró la sesión automáticamente
		# Solo esperamos confirmación
		await get_tree().create_timer(0.5).timeout
		login_completed.emit()

func _on_session_restored() -> void:
	validation_success.emit("¡Sesión restaurada!")
	await get_tree().create_timer(0.5).timeout
	login_completed.emit()

func _on_token_refreshed() -> void:
	print("[LoginControl] Token refrescado exitosamente")

func _on_token_refresh_failed() -> void:
	validation_error.emit("Sesión expirada. Inicia sesión nuevamente.")
	clear_fields()

# ========== EVENTOS DE LOS NODOS UI ==========
func _on_user_text_submitted(_text: String) -> void:
	password_input.grab_focus()

func _on_user_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		validation_label.text = ""

func _on_password_text_submitted(_text: String) -> void:
	_attempt_login()

func _on_password_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		validation_label.text = ""

func _on_login_button_pressed() -> void:
	_attempt_login()

# ========== LÓGICA DE LOGIN ==========
func _attempt_login() -> void:
	var email = user_input.text.strip_edges()
	var password = password_input.text
	
	# Validar campos
	if not _validate_fields(email, password):
		return
	
	# Emitir señal de éxito en validación
	validation_success.emit("Iniciando sesión...")
	login_button.disabled = true
	
	# Usar AuthManager para hacer login
	AuthManager.login(email, password)

func _validate_fields(email: String, password: String) -> bool:
	if email.is_empty():
		validation_error.emit("El email es obligatorio")
		return false
	
	if password.is_empty():
		validation_error.emit("La contraseña es obligatoria")
		return false
	
	if not _is_valid_email(email):
		validation_error.emit("Formato de email inválido")
		return false
	
	return true

func _is_valid_email(email: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email) != null

# ========== CALLBACKS DE AUTHMANAGER ==========
func _on_login_success(_user_data: Dictionary) -> void:
	validation_success.emit("¡Login exitoso!")
	login_button.disabled = false
	await get_tree().create_timer(0.5).timeout
	login_completed.emit()

func _on_login_failed(error_message: String) -> void:
	validation_error.emit(error_message)
	login_button.disabled = false
	password_input.text = ""

# ========== ACTUALIZAR VALIDATION LABEL ==========
func _update_validation_label_error(message: String) -> void:
	validation_label.text = message
	validation_label.modulate = Color.RED

func _update_validation_label_success(message: String) -> void:
	validation_label.text = message
	validation_label.modulate = Color.WHITE

# ========== UTILIDADES ==========
func clear_fields() -> void:
	user_input.text = ""
	password_input.text = ""
	validation_label.text = ""

# ========== ACCESO A TOKENS (usando AuthManager) ==========
func get_access_token() -> String:
	return AuthManager.access_token

func get_refresh_token() -> String:
	return AuthManager.refresh_token

func has_active_session() -> bool:
	return AuthManager.has_active_session()

func get_user_email() -> String:
	return AuthManager.user_email

# ========== LOGOUT ==========
func logout() -> void:
	AuthManager.logout()
	clear_fields()
