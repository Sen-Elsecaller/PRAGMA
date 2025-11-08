class_name CustomResponse extends MarginContainer

var response: DialogueResponse
var response_index: int

@onready var label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var texture_button: TextureButton = $TextureButton

func _ready() -> void:
	if response != null:
		label.text = response.text
		#print(label.get_visible_line_count()) #TODO aqui quedee
		texture_button.texture_normal = Database.responses_textures_normal[response_index]
		texture_button.texture_pressed = Database.responses_textures_pressed[response_index]
	
