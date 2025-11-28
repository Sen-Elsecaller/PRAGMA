class_name MainMenu extends ScreenState

const ONBOARD = preload("uid://dsn4a4jobam56")

var target_screen: ScreenStateMachine.SCREENS

@onready var buttons_container: MarginContainer = %ButtonsContainer
@onready var press_any_key: Label = %PressAnyKey
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var press_timer: Timer = %PressTimer

var press_any_key_tween: Tween
var did_press_any_button: bool = false
var animation_started: bool = false

func _ready() -> void:
	
	Utils.onboard_exited.connect(_on_onboard_exited)
	
	if ConfigFileHandler.load_config_settings("settings").get("useralias") == "default":
		Utils.onboard_created = true
		var onboard = ONBOARD.instantiate()
		await get_tree().create_timer(0.2).timeout
		Utils.onboard_present = true
		add_child(onboard)
		Utils.tween_scale_bounce_out(onboard)
	else:
		_on_onboard_exited()

func Enter(enter_vector: Vector2):
	if enter_vector == Vector2.ZERO:
		show()
	Utils.tween_slide_in(self, enter_vector)
	visible = true

func Exit():
	if _get_target_direction() == Vector2.ZERO:
		return
	var tween = Utils.tween_slide_out(self, _get_target_direction())
	tween.tween_callback(hide)

func _on_onboard_exited():
	press_timer.start(3)
	await press_timer.timeout
	if not did_press_any_button:
		animation_started = true
		_start_press_any_key_animation()

func _start_press_any_key_animation():
	press_any_key_tween = get_tree().create_tween().set_loops()
	press_any_key_tween.tween_property(press_any_key, "modulate:a", 0.0, 1.0)
	press_any_key_tween.tween_property(press_any_key, "modulate:a", 1.0, 1.0)
	
func _input(event: InputEvent) -> void:
	if !Utils.onboard_present:
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
			if event.is_pressed() and not did_press_any_button:
				did_press_any_button = true
				_hide_press_any_key()

func _hide_press_any_key():
	if press_any_key_tween:
		press_any_key_tween.kill()
	
	if animation_started:
		var fade_out_tween = get_tree().create_tween()
		fade_out_tween.tween_property(press_any_key, "modulate:a", 0.0, 0.5)
	
	animation_player.play("show_buttons")

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
