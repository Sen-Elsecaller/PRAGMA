# login_controller.gd
# Controlador que SOLO maneja la lógica, NO accede directamente a los nodos UI
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

# ========== INSTANCIA LOCAL DE CLIENT ==========
var client = null

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	_setup_client()
	_connect_controller_signals()

func _setup_client() -> void:
	var ClientClass = load("res://scripts/login/client.gd")
	client = ClientClass.new()
	add_child(client)
	
	# Conectar señales del client
	client.login_success.connect(_on_login_success)
	client.login_failed.connect(_on_login_failed)


# ========== CONECTAR SEÑALES DEL LABEL ==========
func _connect_controller_signals() -> void:
	validation_error.connect(_update_validation_label_error)
	validation_success.connect(_update_validation_label_success)

# ========== EVENTOS DE LOS NODOS UI ==========
func _on_user_text_submitted(_text: String) -> void:
	password_input.grab_focus()

# Cuando el usuario está escribiendo en "User"
func _on_user_text_changed(new_text: String) -> void:
	# Opcional: Validación en tiempo real
	if new_text.length() > 0:
		validation_label.text = ""

# Cuando el usuario termina de escribir en "Password" (presiona Enter)
func _on_password_text_submitted(_text: String) -> void:
	_attempt_login()

# Cuando el usuario está escribiendo en "Password"
func _on_password_text_changed(new_text: String) -> void:
	# Opcional: Validación en tiempo real
	if new_text.length() > 0:
		validation_label.text = ""

# Cuando presiona el botón Login
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
	
	# Llamar al cliente para hacer login
	client.login(email, password)

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

# ========== CALLBACKS DEL CLIENT ==========
func _on_login_success(user_data: Dictionary) -> void:
	validation_success.emit("¡Login exitoso!")
	login_button.disabled = false
	await get_tree().create_timer(0.5).timeout
	
	# Emitir señal para login_nav.gd
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

# ========== ACCESO A TOKENS ==========
func get_access_token() -> String:
	return client.get_access_token() if client else ""

func get_refresh_token() -> String:
	return client.get_refresh_token() if client else ""

func has_active_session() -> bool:
	return client.has_active_session() if client else false
