extends TextureButton

var response: DialogueResponse
var response_index: int

@onready var label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	if response != null:
		label.text = response.text
		texture_normal = Database.responses_textures_normal[response_index]
		texture_pressed = Database.responses_textures_pressed[response_index]
	
	else:
		return
