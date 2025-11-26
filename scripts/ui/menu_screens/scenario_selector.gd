extends ScreenState
@onready var carousel_container: CarouselContainer = $CarouselContainer
@onready var left_button: TextureButton = %Left
@onready var right_button: TextureButton = %Right
@onready var carousel_node: Control = %CarouselNode
@onready var panel_container: MarginContainer = %PanelContainer
@onready var title_scenario: Label = %TitleScenario
@onready var description_scenario: RichTextLabel = %DescriptionScenario
@onready var return_button: AnimatedTextureButton = $MarginContainer/Return

func Enter(enter_vector: Vector2):
	Utils.tween_slide_in(self, Vector2.UP)
	visible = true

func Exit():
	var tween = Utils.tween_slide_out(self, Vector2.UP)
	tween.tween_callback(hide)
	
func _ready() -> void:
	carousel_container.scenario_changed.connect(_on_scenario_changed)
	carousel_node.info_pressed.connect(_show_info)
	panel_container.hide()
	
func _on_scenario_changed():
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT)
	Utils.tween_fade_in_simple(left_button, 0.75, Tween.EaseType.EASE_IN)
	Utils.tween_fade_in_simple(right_button, 0.75, Tween.EaseType.EASE_IN)
	
	
func _show_info(scenario_resource: CarouselScenarioRes):
	panel_container.show()
	left_button.hide()
	right_button.hide()
	return_button.hide()
	carousel_container.hide()
	title_scenario.text = scenario_resource.scenario_name
	description_scenario.text = scenario_resource.get_text()
	
func _hide_info():
	panel_container.hide()
	left_button.show()
	right_button.show()
	return_button.show()
	carousel_container.show()
	
func _on_return_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_BACK)
	change_screen.emit(ScreenStateMachine.SCREENS.MAIN)


func _on_close_menu_pressed() -> void:
	_hide_info()
	
