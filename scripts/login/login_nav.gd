# login_nav.gd
# SOLO maneja la navegación entre Login y Register
extends ScreenState

# ========== REFERENCIAS A NODOS ==========
@onready var login_node: LoginControl = $Login
@onready var register_node: RegisterControl = $Register

# ========== INICIALIZACIÓN ==========

func _ready() -> void:
	login_node.login_completed.connect(_on_close_menu_pressed)
	register_node.register_completed.connect(_on_close_menu_pressed)
	visible = true
	Utils.tween_scale_bounce_out(self)
	register_node.visible = true
	login_node.visible = false
	

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
	register_node.visible = true
	login_node.visible = false
	var tween = Utils.tween_scale_bounce_in(self)
	tween.tween_callback(queue_free)
	Utils.onboard_present = false
	if Utils.onboard_created:
		Utils.onboard_exited.emit()
