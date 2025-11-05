class_name DialogueBox extends MarginContainer


signal finished_typing()


const CHARACTERS = {
	nathan = {
		portrait = preload("res://assets/portraits/nathan.svg"),
		side = "left",
		color = Color(1, 0.869, 0.776)
	},
	coco = {
		portrait = preload("res://assets/portraits/coco.svg"),
		side = "right",
		color = Color(0.755, 0.908, 1)
	}
}


var dialogue_line: DialogueLine:
	set(value):
		dialogue_line = value
		update_dialogue()
	get:
		return dialogue_line

var is_typing:
	get:
		return dialogue_label.is_typing

@onready var dialogue: HBoxContainer = %Dialogue
@onready var background: TextureRect = %Background
@onready var character_name: Label = %CharacterName
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var action_label: Label = %ActionLabel

func _ready() -> void:
	pass

func _tween_entrance():
	var tween = get_tree().create_tween()
	var tween_time = 2
	
	var target_size = size.y
	
	custom_minimum_size.y = 0
	modulate.a = 0
	dialogue_label.modulate.a = 0
	
	# Primera fase: contenedor (en paralelo)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "custom_minimum_size:y", target_size, tween_time)
	tween.tween_property(self, "modulate:a", 1.0, tween_time)
	
	# Segunda fase: label (secuencial)
	tween.set_parallel(false)
	tween.tween_property(dialogue_label, "modulate:a", 1.0, tween_time * 0.5)

## Finish typing instantly
func skip_typing() -> void:
	dialogue_label.skip_typing()


func update_dialogue() -> void:
	dialogue.show()
	if dialogue_line.character != "Narrador":
		character_name.text = dialogue_line.character
		
	dialogue_label.dialogue_line = dialogue_line

	if not dialogue_line.character.is_empty():
		dialogue_label.type_out()

#region Signals


func _on_dialogue_label_finished_typing() -> void:
	if is_inside_tree():
		finished_typing.emit()


#endregion
