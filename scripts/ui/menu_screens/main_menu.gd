class_name MainMenu extends ScreenState

var target_screen: ScreenStateMachine.SCREENS

func Enter():
	Utils.tween_slide_in(self, Vector2.DOWN)
	visible = true

func Exit():
	var tween = Utils.tween_slide_out(self, _get_target_direction())
	tween.tween_callback(hide)

func _on_select_scene_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	target_screen= ScreenStateMachine.SCREENS.SCENARIOSELECTOR
	change_screen.emit(target_screen)

func _on_login_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	target_screen = ScreenStateMachine.SCREENS.LOGIN
	change_screen.emit(target_screen)

func _on_social_dict_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	target_screen = ScreenStateMachine.SCREENS.NOTES
	change_screen.emit(target_screen)

func _get_target_direction() -> Vector2:
	match target_screen:
		ScreenStateMachine.SCREENS.SCENARIOSELECTOR:
			return Vector2.DOWN
		ScreenStateMachine.SCREENS.LOGIN:
			return Vector2.DOWN
		ScreenStateMachine.SCREENS.NOTES:
			return Vector2.RIGHT
		ScreenStateMachine.SCREENS.SETTINGS:
			return Vector2.UP
		_:
			return Vector2.UP


func _on_settings_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	target_screen = ScreenStateMachine.SCREENS.SETTINGS
	change_screen.emit(target_screen)
