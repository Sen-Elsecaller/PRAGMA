# login_controller.gd
# Controlador de la interfaz de Login
extends Control

# ========== SEÑALES ==========
signal go_to_register
signal login_completed(user_data: Dictionary)

# ========== REFERENCIAS A NODOS ==========
@onready var user_input: LineEdit = $TextureRect/VBoxContainer/User
@onready var password_input: LineEdit = $TextureRect/VBoxContainer/Password
@onready var login_button: Button = $"TextureRect/VBoxContainer/Iniciar sesión"
@onready var register_button: Button = $TextureRect/MarginContainer/HBoxContainer/Register
@onready var validation_label: Label = $TextureRect/VBoxContainer/ValidationLabel

# ========== INSTANCIA LOCAL DE CLIENT ==========
var client = null

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	_setup_client()
	_setup_ui()
	_connect_signals()

func _setup_client() -> void:
	# Cargar e instanciar client.gd localmente
	var ClientClass = load("res://scripts/login/client.gd")
	client = ClientClass.new()
	add_child(client)

func _setup_ui() -> void:
	password_input.secret = true
	password_input.placeholder_text = "Contraseña"
	user_input.placeholder_text = "Email"
	validation_label.text = ""
	validation_label.modulate = Color.WHITE

func _connect_signals() -> void:
	# Conectar señales del client local
	client.login_success.connect(_on_login_success)
	client.login_failed.connect(_on_login_failed)
	
	# Conectar eventos de UI
	login_button.pressed.connect(_on_login_button_pressed)
	register_button.pressed.connect(_on_register_button_pressed)  # ← AGREGADO
	user_input.text_submitted.connect(_on_user_submitted)
	password_input.text_submitted.connect(_on_password_submitted)

# ========== EVENTOS DE UI ==========

func _on_login_button_pressed() -> void:
	_attempt_login()

func _on_register_button_pressed() -> void:
	print("🔘 Botón Register presionado, emitiendo señal")
	go_to_register.emit()

func _on_user_submitted(_text: String) -> void:
	password_input.grab_focus()

func _on_password_submitted(_text: String) -> void:
	_attempt_login()

# ========== LÓGICA DE LOGIN ==========

func _attempt_login() -> void:
	var email = user_input.text.strip_edges()
	var password = password_input.text
	
	if not _validate_fields(email, password):
		return
	
	_show_message("Iniciando sesión...")
	login_button.disabled = true
	
	# Usar la instancia local de client
	client.login(email, password)

func _validate_fields(email: String, password: String) -> bool:
	if email.is_empty():
		_show_error("El email es obligatorio")
		return false
	
	if password.is_empty():
		_show_error("La contraseña es obligatoria")
		return false
	
	if not _is_valid_email(email):
		_show_error("Formato de email inválido")
		return false
	
	return true

func _is_valid_email(email: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email) != null

# ========== CALLBACKS DEL CLIENT ==========

func _on_login_success(user_data: Dictionary) -> void:
	_show_message("¡Login exitoso!")
	login_button.disabled = false
	
	# Emitir señal para otros nodos si es necesario
	login_completed.emit(user_data)
	
	# Cambiar a escena principal
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_login_failed(error_message: String) -> void:
	_show_error(error_message)
	login_button.disabled = false
	password_input.text = ""

# ========== UTILIDADES DE UI ==========

func _show_error(message: String) -> void:
	validation_label.text = message
	validation_label.modulate = Color.RED

func _show_message(message: String) -> void:
	validation_label.text = message
	validation_label.modulate = Color.WHITE

func _clear_fields() -> void:
	user_input.text = ""
	password_input.text = ""
	validation_label.text = ""

# ========== ACCESO A TOKENS ==========

func get_access_token() -> String:
	if client:
		return client.get_access_token()
	return ""

func get_refresh_token() -> String:
	if client:
		return client.get_refresh_token()
	return ""

func has_active_session() -> bool:
	if client:
		return client.has_active_session()
	return false
