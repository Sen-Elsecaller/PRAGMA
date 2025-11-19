extends ScreenState

func Enter():
	Utils.tween_slide_in(self, Vector2.UP)
	visible = true

func Exit():
	var tween = Utils.tween_slide_out(self, Vector2.UP)
	tween.tween_callback(hide)
	
func _on_return_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_BACK)
	change_screen.emit(ScreenStateMachine.SCREENS.MAIN)
