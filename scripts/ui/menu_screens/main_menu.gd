class_name MainMenu extends ScreenState

const ONBOARD = preload("uid://dsn4a4jobam56")

var target_screen: ScreenStateMachine.SCREENS

@onready var buttons_container: MarginContainer = %ButtonsContainer

func _ready() -> void:
	Utils.onboard_exited.connect(_show_buttons)
	
	if ConfigFileHandler.load_config_settings("settings").get("useralias") == "default":
		buttons_container.hide()
		Utils.onboard_created = true
		
		var onboard = ONBOARD.instantiate()
		await get_tree().create_timer(0.3).timeout
		add_child(onboard)
		Utils.tween_scale_bounce_out(onboard)
		
func Enter(enter_vector: Vector2):
	print(enter_vector)
	if enter_vector == Vector2.ZERO:
		show()
	Utils.tween_slide_in(self, enter_vector)
	visible = true

func Exit():
	if _get_target_direction() == Vector2.ZERO:
		return
	var tween = Utils.tween_slide_out(self, _get_target_direction())
	tween.tween_callback(hide)

func _show_buttons():
	buttons_container.show()

func _on_select_scene_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	target_screen= ScreenStateMachine.SCREENS.SCENARIOSELECTOR
	change_screen.emit(target_screen)

func _on_social_dict_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	target_screen = ScreenStateMachine.SCREENS.NOTES
	change_screen.emit(target_screen)

func _get_target_direction() -> Vector2:
	match target_screen:
		ScreenStateMachine.SCREENS.SCENARIOSELECTOR:
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


func _on_leave_pressed() -> void:
	get_tree().quit()
