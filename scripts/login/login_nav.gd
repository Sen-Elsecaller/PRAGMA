# login_nav.gd
# SOLO maneja la navegación entre Login y Register
extends ScreenState

# ========== REFERENCIAS A NODOS ==========
@onready var login_node: MarginContainer = $Login
@onready var register_node: MarginContainer = $Register

# ========== INICIALIZACIÓN ==========

func Enter():
	Utils.tween_slide_in(self, Vector2.DOWN)
	visible = true

func Exit():
	var tween = Utils.tween_slide_out(self, Vector2.DOWN)
	tween.tween_callback(hide)


func _ready() -> void:
	register_node.visible = false
	login_node.visible = true
	
	await get_tree().process_frame
	_setup_navigation()

func _setup_navigation() -> void:
	# Conectar señales de navegación desde Login
	if login_node.has_signal("go_to_register"):
		login_node.go_to_register.connect(_on_show_register)
	
	# Conectar señales de navegación desde Register
	if register_node.has_signal("volver_a_login"):
		register_node.volver_a_login.connect(_on_show_login)

# ========== NAVEGACIÓN ==========
func _on_show_register() -> void:
	login_node.hide()
	login_node.set_process_input(false)
	login_node.set_process_unhandled_input(false)
	
	register_node.show()
	register_node.set_process_input(true)
	register_node.set_process_unhandled_input(true)

func _on_show_login() -> void:
	register_node.hide()
	register_node.set_process_input(false)
	register_node.set_process_unhandled_input(false)
	
	login_node.show()
	login_node.set_process_input(true)
	login_node.set_process_unhandled_input(true)


func _on_close_menu_pressed() -> void:
	change_screen.emit(ScreenStateMachine.SCREENS.SETTINGS)
