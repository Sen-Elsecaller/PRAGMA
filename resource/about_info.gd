class_name AboutInfo extends Resource

@export var section_name: String
@export_file("*.txt") var description: String

func get_text() -> String:
	var file = FileAccess.open(description, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return content
	return ""
