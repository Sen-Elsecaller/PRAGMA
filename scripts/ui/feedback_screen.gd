extends Control

@onready var carousel_container: FeedbackCarouselContainer = %CarouselContainer
@onready var feedback_label: RichTextLabel = %FeedbackLabel
@onready var carousel_node: Control = %CarouselNode

func _ready() -> void:
	ConfigFileHandler.repeated_note.connect(_on_repeated_note)
	ConfigFileHandler.note_saved.connect(_on_note_saved)
	carousel_container.choice_changed.connect(_on_choice_changed)
	
func _on_choice_changed(choice: PlayerChoice) -> void:
	feedback_label.text = choice.feedback.replace(";", ",")

func _on_back_to_menu_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_BACK)
	Utils.game_controller.return_to_main_menu()
	AudioManager.toggle_bgm_music()

func _on_add_to_pressed() -> void:
	ConfigFileHandler.add_note(carousel_container._get_current_player_choice().to_dict())

func _on_repeated_note():
	Utils.show_notification("Nota previamente guardada", NotificationText.NotificationType.WARNING, NotificationText.Position.BOTTOM)

func _on_note_saved():
	Utils.show_notification("Nota guardada", NotificationText.NotificationType.SUCCESS, NotificationText.Position.BOTTOM)
