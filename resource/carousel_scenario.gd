class_name CarouselScenarioRes extends Resource

@export var main_photo: CompressedTexture2D
@export var scenario_name: String = "Placeholder"
@export_file("*.txt") var description: String
@export var timeline_name: String = "Placeholder"
@export var scene: PackedScene

func get_text() -> String:
	var file = FileAccess.open(description, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return content
	return ""
