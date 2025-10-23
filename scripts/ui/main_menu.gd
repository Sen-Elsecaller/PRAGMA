class_name MainMenu extends ScreenState

func _on_select_scene_pressed() -> void:
	change_screen.emit(ScreenStateMachine.SCREENS.SCENARIOSELECTOR)

func _on_login_pressed() -> void:
	change_screen.emit(ScreenStateMachine.SCREENS.LOGIN)
