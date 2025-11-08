class_name DialogueBox extends MarginContainer

signal finished_typing()

const ACTORS = {
	character = {
		texture_type = preload("res://assets/interfaz/Texto-2.png"),
		pivot_side = Utils.PivotPosition.CENTER_LEFT,
	},
	narrator = {
		texture_type = preload("res://assets/interfaz/Fondo-Ajustes.png"),
		pivot_side = Utils.PivotPosition.CENTER,
	},
	player = {
		texture_type = preload("res://assets/interfaz/Texto-1.png"),
		pivot_side = Utils.PivotPosition.CENTER_RIGHT
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

@onready var dialogue: MarginContainer = %Dialogue
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
	
	# Ajusta el size de DialogueBox a la cantidad de texto
	set_deferred("size", Vector2.ZERO)
	custom_minimum_size = Vector2.ZERO
	
	dialogue_label.dialogue_line = dialogue_line
	var actor_key: String
	if dialogue_line.character == "Narrador":
		character_name.text = ""
		actor_key = "narrator"
		character_name.hide()
		set("theme_override_constants/margin_left", 0)
		set("theme_override_constants/margin_right", 0)
		dialogue_label.set("horizontal_alignment", 1)
	elif dialogue_line.character == "Player" or dialogue_line.character == Database.player_name:
		
		character_name.text = Database.player_name
		actor_key = "player"
		character_name.show()
		set("theme_override_constants/margin_left", 0)
		set("theme_override_constants/margin_right", -15)
		dialogue_label.set("horizontal_alignment", 0)
	else:
		character_name.text = dialogue_line.character
		actor_key = "character"
		set("theme_override_constants/margin_left", -15)
		set("theme_override_constants/margin_right", 0)
		dialogue_label.set("horizontal_alignment", 0)
		character_name.show()
	
	var actor = ACTORS[actor_key]
	background.texture = actor["texture_type"]

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
