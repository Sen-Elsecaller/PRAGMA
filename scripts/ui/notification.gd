class_name NotificationText extends Control

@onready var label: RichTextLabel = %RichTextLabel
@onready var texture_rect: TextureRect = $TextureRect

const BLOQUE_NOTIFICACION_AMARILLA = preload("uid://1butysd6xcyy")
const BLOQUE_NOTIFICACION_VERDE = preload("uid://fotnuq1ddu0o")
const BLOQUE_NOTIFICACION_ROJO = preload("uid://qh8qa8207vdr")

enum NotificationType { SUCCESS, WARNING, ERROR }
enum Position { TOP, BOTTOM }

var message: String
var type: NotificationType = NotificationType.SUCCESS
var duration: float = 3.0
var notification_position: Position = Position.TOP

signal notification_hidden

func _ready() -> void:
	#No logre hacer funcionar el cambio automatico de posicion
	if notification_position == Position.TOP:
		set_anchors_preset(Control.PRESET_CENTER_TOP)
	else:
		set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	
	label.text = message
	
	match type:
		NotificationType.SUCCESS:
			texture_rect.texture = BLOQUE_NOTIFICACION_VERDE
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.GOOD_EMOTION)
		NotificationType.WARNING:
			texture_rect.texture = BLOQUE_NOTIFICACION_AMARILLA
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BAD_EMOTION)
		NotificationType.ERROR:
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BAD_EMOTION)
			texture_rect.texture = BLOQUE_NOTIFICACION_ROJO
	
	Utils.tween_scale_bounce_out(self)
	
	await get_tree().create_timer(duration).timeout
	hide_notification()

func hide_notification() -> void:
	var tween = Utils.tween_scale_bounce_in(self)
	tween.tween_callback(queue_free)
	notification_hidden.emit()
