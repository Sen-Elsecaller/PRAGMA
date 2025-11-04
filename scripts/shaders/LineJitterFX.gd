@tool
extends FXBase
class_name LineJitterFX

@export var amplitude : float = 1.0:
	set(value):
		amplitude = value
		notify_change()

@export var noise_scale : float = 20.0:
	set(value):
		noise_scale = value
		notify_change()

@export var noise_speed : float = 2-.0:
	set(value):
		noise_speed = value
		notify_change()

func _get_shader_code() -> String:
	return load("res://resource/shaders/line_jitter.gdshader").code

func _update_shader() -> void:
	properties["amplitude"] = amplitude
	properties["noise_scale"] = noise_scale
	properties["noise_speed"] = noise_speed
