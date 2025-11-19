class_name Settings extends ScreenState

@onready var useralias: LineEdit = %Useralias

func _ready() -> void:
	
	useralias.placeholder_text = ConfigFileHandler.load_config_settings("settings").get("useralias")
	
func Enter():
	Utils.tween_slide_in(self, Vector2.DOWN)
	visible = true

func Exit():
	var tween = Utils.tween_slide_out(self, Vector2.DOWN)
	tween.tween_callback(hide)

func _on_useralias_text_submitted(new_text: String) -> void:
	ConfigFileHandler.save_config_settings("settings", "useralias", new_text)
	useralias.placeholder_text = Database.player_name
	Database.player_name_changed.emit()

func _on_close_menu_pressed() -> void:
	change_screen.emit(ScreenStateMachine.SCREENS.MAIN)


func _on_confirm_name_pressed() -> void:
	pass


func _on_texture_button_pressed() -> void:
	print(ConfigFileHandler.save_file)


func _on_login_pressed() -> void:
	change_screen.emit(ScreenStateMachine.SCREENS.LOGIN)
