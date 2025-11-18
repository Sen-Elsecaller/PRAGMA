class_name DialogueRecord extends MarginContainer
@onready var character_label: Label = $VBoxContainer/CharacterLabel
@onready var text_label: RichTextLabel = $VBoxContainer/TextLabel

var character: String
var text: String

func _ready() -> void:
	character_label.text = character
	text_label.text = text
