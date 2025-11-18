class_name Characters extends Node2D

@onready var left_marker: Marker2D = $LeftMarker
@onready var center_marker: Marker2D = $CenterMarker
@onready var right_marker: Marker2D = $RightMarker

var visible_chars: Array[AnimatedSprite2D] = []  # Máximo 2 elementos
var animations_nodes: Dictionary
var char_animations: Dictionary

func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			# Usas el nombre como clave en lugar del nodo
			var char_name = child.name.to_pascal_case()
			animations_nodes[char_name] = child
			child.hide()
	
	char_animations = _build_animations_dict()
	
func show_character(char_name: String, char_emotion: String):
	var anim: AnimatedSprite2D = animations_nodes.get(char_name)
	if not anim:
		return
	
	# Si ya está visible, solo actualiza emoción
	if anim in visible_chars:
		anim.play(char_emotion if char_emotion in char_animations[char_name] else str(anim.animation))
		return
	
	# Máximo 2 personajes
	if visible_chars.size() >= 2:
		return
	
	# Posicionamiento
	var marker = center_marker if visible_chars.size() == 0 else right_marker
	if visible_chars.size() == 1:
		visible_chars[0].global_position = left_marker.global_position
	
	anim.global_position = marker.global_position
	Utils.tween_fade_in_simple(anim)
	visible_chars.append(anim)
	anim.play(char_emotion if char_emotion in char_animations[char_name] else "neutro")
	
func hide_character(char_name: String):
	if animations_nodes.has(char_name):
		var anim: AnimatedSprite2D = animations_nodes[char_name]
		
		if anim in visible_chars:
			var tween = Utils.tween_fade_out_simple(anim)
			tween.tween_callback(anim.hide)
			visible_chars.erase(anim)
			
			# Reorganizar posiciones si queda uno solo
			if visible_chars.size() == 1:
				# El que queda vuelve al centro
				visible_chars[0].global_position = center_marker.global_position

func _build_animations_dict() -> Dictionary:
	var dict = {}
	
	for char_name in animations_nodes:
		@warning_ignore("shadowed_global_identifier")
		var char = animations_nodes[char_name]
		if char.sprite_frames != null:
			var anim_names: Array = char.sprite_frames.get_animation_names()
			dict[char_name] = anim_names.map(func(anim): return anim.to_snake_case())
	
	return dict
