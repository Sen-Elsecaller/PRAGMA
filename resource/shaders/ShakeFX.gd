@tool
extends FXBase
class_name ShakeFX

@export var strength : float = 0.5:
	set(value):
		strength = value
		notify_change()

func _get_shader_code() -> String:
	return load("res://resource/shaders/shake.gdshader").code

func _update_shader() -> void:
	properties["ShakeStrength"] = strength
