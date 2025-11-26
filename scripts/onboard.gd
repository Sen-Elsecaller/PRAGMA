extends Control
const LOGIN_CONTROLLER = preload("uid://ddevs601qf8c1")
@onready var useralias: LineEdit = %Useralias

func _ready() -> void:
	pass
	
func _on_continue_pressed() -> void:
	var login = LOGIN_CONTROLLER.instantiate()
	add_sibling(login)
	var tween = Utils.tween_scale_bounce_in(self)
	tween.tween_callback(queue_free)

func _on_useralias_text_submitted(new_text: String) -> void:
	ConfigFileHandler.save_config_settings("settings", "useralias", new_text)
	useralias.placeholder_text = Database.player_name
	Database.player_name_changed.emit()
