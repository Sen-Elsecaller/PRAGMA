class_name DialogueBox extends MarginContainer

signal finished_typing

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
	dialogue_label.seconds_per_step = 0.02 * 1.5
	dialogue_label.spoke.connect(_on_spoke)
	
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
		dialogue.set("theme_override_constants/margin_top", 15)
		dialogue_label.set("theme_override_colors/default_color", Color("f8f6cd"))
		#set("theme_override_constants/margin_right", 0)
		dialogue_label.set("horizontal_alignment", 1)
	elif dialogue_line.character == "Player" or dialogue_line.character == Database.player_name:
		
		character_name.text = Database.player_name
		actor_key = "player"
		character_name.show()
		#set("theme_override_constants/margin_left", 0)
		#set("theme_override_constants/margin_right", -15)
		dialogue.set("theme_override_constants/margin_top", 0)
		dialogue_label.set("theme_override_colors/default_color", Color.BLACK)
		dialogue_label.set("horizontal_alignment", 0)
	else:
		character_name.text = dialogue_line.character
		actor_key = "character"
		#set("theme_override_constants/margin_left", -15)
		#set("theme_override_constants/margin_right", 0)
		dialogue.set("theme_override_constants/margin_top", 0)
		dialogue_label.set("horizontal_alignment", 0)
		dialogue_label.set("theme_override_colors/default_color", Color.BLACK)
		character_name.show()
	
	var actor = Database.ACTORS[actor_key]
	background.texture = actor["texture_type"]

	if not dialogue_line.character.is_empty():
		
		dialogue_label.type_out()
	
#region Signals

func _on_dialogue_label_finished_typing() -> void:
	if is_inside_tree():
		finished_typing.emit()

func _on_spoke(_letter: String, letter_index: int, speed: float):
	if dialogue_line.character != "Narrador":
		if is_multiple(letter_index, 3) or letter_index == 0 or speed < 0.3:
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.SPEAKING)
			
func is_multiple(number: int, divisor: int) -> bool:
	if divisor == 0:
		return false
	return number % divisor == 0
#endregion

#region Animations

func burn_card_out():
	var tween = Utils.tween_fade_out_simple(self)
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
