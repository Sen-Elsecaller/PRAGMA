class_name Settings extends ScreenState

@onready var useralias: LineEdit = %Useralias
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
const LOGIN_CONTROLLER = preload("uid://ddevs601qf8c1")
const ABOUT = preload("uid://880mdok80m4r")

func _ready() -> void:
	sfx_slider.set_value_no_signal(ConfigFileHandler.load_config_settings("settings").get("sfx_volume"))
	music_slider.set_value_no_signal(ConfigFileHandler.load_config_settings("settings").get("music_volume"))
	useralias.placeholder_text = ConfigFileHandler.load_config_settings("settings").get("useralias")
	
func Enter(_enter_vector: Vector2):
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
	var login = LOGIN_CONTROLLER.instantiate()
	add_child(login)
	
func _on_texture_button_3_pressed() -> void:
	Utils.toggle_color_main_screen()

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value)
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_ITEM1)
	ConfigFileHandler.save_config_settings("settings", "sfx_volume", value)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value)
	ConfigFileHandler.save_config_settings("settings", "music_volume", value)


func _on_about_button_pressed() -> void:
	var about = ABOUT.instantiate()
	add_child(about)
