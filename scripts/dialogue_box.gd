class_name DialogueBox extends MarginContainer

signal finished_typing()

const ACTORS = {
	character = {
		texture_type = preload("res://assets/interfaz/Texto-2.png"),
		pivot_side = Utils.PivotPosition.CENTER_LEFT,
	},
	narrator = {
		texture_type = preload("res://assets/interfaz/Fondo-Ajustes.png"),
		pivot_side = Utils.PivotPosition.CENTER_LEFT,
	},
	player = {
		texture_type = preload("res://assets/interfaz/Texto-1.png"),
		pivot_side = Utils.PivotPosition.CENTER_LEFT,
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
	
## Finish typing instantly
func skip_typing() -> void:
	dialogue_label.skip_typing()


func update_dialogue() -> void:
	dialogue.show()
	
	if dialogue_line.character != "Narrador":
		character_name.text = dialogue_line.character
		if dialogue_line.character != "Player":
			background.texture = ACTORS["character"]["texture_type"]
			Utils.tween_scale_bounce_out(self, ACTORS["character"]["pivot_side"], 0.2)
	else:
		character_name.text = ""
		background.texture = ACTORS["narrator"]["texture_type"]
		Utils.tween_scale_bounce_out(self, ACTORS["narrator"]["pivot_side"], 0.2)
		
	dialogue_label.dialogue_line = dialogue_line

	if not dialogue_line.character.is_empty():
		dialogue_label.type_out()

#region Signals

func _on_dialogue_label_finished_typing() -> void:
	if is_inside_tree():
		finished_typing.emit()

#endregion

#region Animations

func burn_card_out():
	if material and material is ShaderMaterial:
		background.material = background.material.duplicate()
		var tween: Tween = get_tree().create_tween()
		# set burning direction in degrees
		background.material.set_shader_parameter("direction", 270.0)
		# use tweens to animate the progress value
		tween.tween_method(
			func(val): background.material.set_shader_parameter("progress", val),
			-1.5, 1.5, 0.2
		)
		tween.tween_callback(queue_free)

func burn_card_in():
	if material and material is ShaderMaterial:
		background.material = background.material.duplicate()
		var tween: Tween = get_tree().create_tween()
		background.material.set_shader_parameter("direction", 90.0)
		
		tween.tween_method(
			func(val): background.material.set_shader_parameter("progress", val),
			1.5, -1.5, 0.2
		)
#endregion
