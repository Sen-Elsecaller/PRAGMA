@tool
class_name AutoSizeLabel extends Label

@export var min_font_size: int = 10
@export var max_font_size: int = 50

func _ready() -> void:
	if not Engine.is_editor_hint():
		await get_tree().process_frame
	update_font_size()
	
	var parent = get_parent()
	if parent:
		parent.item_rect_changed.connect(_on_item_rect_changed)

func _set(property: StringName, _value: Variant) -> bool:
	if property == "text":
		update_font_size()
	return false

func update_font_size() -> void:
	if text.is_empty():
		return
	
	var parent = get_parent()
	if not parent:
		return
	
	var font = get_theme_default_font()
	var target_size = parent.size
	
	# Buscar el font_size más grande que quepa
	for font_size in range(max_font_size, min_font_size - 1, -1):
		var string_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		
		if string_size.x <= target_size.x and string_size.y <= target_size.y:
			add_theme_font_size_override("font_size", font_size - 6)
			return
	
	# Si nada cabe, usar el mínimo
	add_theme_font_size_override("font_size", min_font_size)

func _on_item_rect_changed() -> void:
	update_font_size()
