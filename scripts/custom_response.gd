class_name CustomResponse extends MarginContainer

var response: DialogueResponse
var response_index: int
var disabled: bool = false

@onready var label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var texture_button: TextureButton = $TextureButton


func _ready() -> void:
	if response != null:
		texture_button.disabled = disabled
		label.text = response.text
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
