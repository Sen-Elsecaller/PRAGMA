# login_nav.gd
# SOLO maneja la navegación entre Login y Register
extends Control

# ========== REFERENCIAS A NODOS ==========
@onready var login_node: Control = $Login
@onready var register_node: Control = $Register

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	# IMPORTANTE: No bloquear eventos del mouse
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Configurar estado inicial
	register_node.visible = false
	login_node.visible = true
	
	await get_tree().process_frame
	_setup_navigation()

func _setup_navigation() -> void:
	# Conectar señales
	if login_node.has_signal("go_to_register"):
		login_node.go_to_register.connect(_on_show_register)
		print("✅ Señal go_to_register conectada")
	
	if register_node.has_signal("volver_a_login"):
		register_node.volver_a_login.connect(_on_show_login)
		print("✅ Señal volver_a_login conectada")

# ========== NAVEGACIÓN ==========

func _show_login() -> void:
	register_node.visible = false
	login_node.visible = true

func _show_register() -> void:
	login_node.visible = false
	register_node.visible = true

# ========== CALLBACKS ==========

func _on_show_register() -> void:
	_show_register()

func _on_show_login() -> void:
	_show_login()
