class_name MainMenu extends ScreenState

func Enter():
	Utils.tween_slide_in(self, Vector2.DOWN)
	visible = true

func Exit():
	var tween = Utils.tween_slide_out(self, Vector2.DOWN)
	tween.tween_callback(hide)

func _on_select_scene_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	change_screen.emit(ScreenStateMachine.SCREENS.SCENARIOSELECTOR)

func _on_login_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	change_screen.emit(ScreenStateMachine.SCREENS.LOGIN)
