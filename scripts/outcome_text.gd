class_name OutcomeText extends Control

@onready var label: RichTextLabel = %RichTextLabel
@onready var texture_rect: TextureRect = $TextureRect

const BLOQUE_DECISION_AMARILLA = preload("uid://1butysd6xcyy")
const BLOQUE_DECISION_ROJO = preload("uid://qh8qa8207vdr")
const BLOQUE_DECISION_VERDE = preload("uid://fotnuq1ddu0o")


signal enter(text: String, emotion: String)
signal exit

func _ready() -> void:
	hide()
	enter.connect(_on_enter)
	exit.connect(_on_exit)
	await get_tree().process_frame
	var max_height = label.size.y
	var content_height = label.get_content_height()

	if content_height > max_height:
		var ratio = max_height / content_height
		var new_size = int(16 * ratio)
		label.add_theme_font_size_override("normal_font_size", new_size)
		label.add_theme_font_size_override("bold_font_size", new_size)
		label.add_theme_font_size_override("bold_italics_font_size", new_size)
		label.add_theme_font_size_override("italics_font_size", new_size)
		label.add_theme_font_size_override("mono_font_size", new_size)
		
func _on_enter(text: String, emotion: String, keep: bool):
	label.text = text
	if emotion == "good":
		texture_rect.texture = BLOQUE_DECISION_VERDE
	elif emotion == "bad":
		texture_rect.texture = BLOQUE_DECISION_ROJO
	else:
		texture_rect.texture = BLOQUE_DECISION_AMARILLA
	
	show()
	if !keep:
		Utils.tween_scale_bounce_out(self)
		await get_tree().create_timer(3).timeout
		_on_exit()
	
func _on_exit():
	var tween = Utils.tween_scale_bounce_in(self)
	tween.tween_callback(hide)
