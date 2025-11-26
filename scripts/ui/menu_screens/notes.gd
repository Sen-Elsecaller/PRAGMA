extends ScreenState

@onready var feedback_label: RichTextLabel = %FeedbackLabel
@onready var carousel_container: FeedbackCarouselContainer = %CarouselContainer

func Enter(enter_vector: Vector2):
	Utils.tween_slide_in(self, Vector2.LEFT)
	visible = true

func Exit():
	var tween = Utils.tween_slide_out(self, Vector2.LEFT)
	tween.tween_callback(hide)

func _ready() -> void:
	carousel_container.choice_changed.connect(_on_choice_changed)
	
func _on_choice_changed(choice: PlayerChoice) -> void:
	feedback_label.text = choice.feedback.replace(";", ",")

func _on_back_to_menu_pressed() -> void:
	change_screen.emit(ScreenStateMachine.SCREENS.MAIN)
