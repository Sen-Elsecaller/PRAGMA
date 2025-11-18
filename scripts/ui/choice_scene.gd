class_name ChoiceScene extends MarginContainer

@onready var question_label: RichTextLabel = %QuestionLabel
@onready var choice_label: RichTextLabel = %ChoiceLabel
@onready var outcome_text: OutcomeText = %OutcomeText
@onready var character_name: Label = %CharacterName
@onready var question_texture: TextureRect = %QuestionTexture
@onready var question_margin: MarginContainer = %QuestionMargin

var player_choice: PlayerChoice

func _ready() -> void:
	var actor_key
	if player_choice.character == "Narrador":
		character_name.text = ""
		actor_key = "narrator"
		question_label.set("horizontal_alignment", 1)
		question_margin.set("theme_override_constants/margin_top", 25)
		question_label.set("theme_override_colors/default_color", Color("f8f6cd"))
		character_name.hide()
	else:
		character_name.text = player_choice.character
		actor_key = "character"
		question_label.set("horizontal_alignment", 0)
		character_name.show()
	
	var actor = Database.ACTORS[actor_key]
	question_texture.texture = actor["texture_type"]
	
	question_label.text = player_choice.question
	choice_label.text = player_choice.selected_response
	outcome_text.enter.emit(player_choice.outcome_text, player_choice.emotion, true)
