class_name MainMenu extends ScreenState

func _on_select_scene_pressed() -> void:
	change_screen.emit(ScreenStateMachine.SCREENS.SCENESELECTOR)
