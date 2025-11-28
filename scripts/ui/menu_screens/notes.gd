extends ScreenState

@onready var feedback_label: RichTextLabel = %FeedbackLabel
@onready var carousel_container: FeedbackCarouselContainer = %CarouselContainer
@onready var carousel_node: CarouselNode = %CarouselNode
@onready var notes_label: AutoSizeLabel = %NotesLabel

enum NOTES_TYPES {
	CUSTOM,
	DEFAULT
}

var current_notes_types: NOTES_TYPES = NOTES_TYPES.CUSTOM

func Enter(_enter_vector: Vector2):
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

func _on_change_notes_pressed() -> void:
	if current_notes_types == NOTES_TYPES.CUSTOM:
		current_notes_types = NOTES_TYPES.DEFAULT
		notes_label.text = "Ver notas guardadas"
		carousel_node.load_default_notes()
	else:
		current_notes_types = NOTES_TYPES.CUSTOM
		notes_label.text = "Ver notas de regalo"
		carousel_node.load_default_notes()
