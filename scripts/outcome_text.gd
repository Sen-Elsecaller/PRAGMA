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

		
func _on_enter(text: String, emotion: String, keep: bool):
	label.text = text
	if emotion == "good":
		texture_rect.texture = BLOQUE_DECISION_VERDE
		if !keep: AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.GOOD_EMOTION)
	elif emotion == "bad":
		texture_rect.texture = BLOQUE_DECISION_ROJO
		if !keep: AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BAD_EMOTION)
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
