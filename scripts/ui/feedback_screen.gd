extends Control

@onready var carousel_container: FeedbackCarouselContainer = %CarouselContainer
@onready var feedback_label: RichTextLabel = %FeedbackLabel
@onready var carousel_node: Control = %CarouselNode

func _ready() -> void:
	print(Utils.game_controller.current_feedback)
	carousel_container.choice_changed.connect(_on_choice_changed)
	
func _on_choice_changed(choice: PlayerChoice) -> void:
	feedback_label.text = choice.feedback.replace(";", ",")


func _on_back_to_menu_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_BACK)
	Utils.game_controller.return_to_main_menu()

func _on_add_to_pressed() -> void:
	feedback_label.text
