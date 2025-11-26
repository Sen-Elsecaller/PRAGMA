extends Control

@onready var title: Label = %Title
@onready var text: RichTextLabel = %Text

var about_data: AboutInfo

func _ready() -> void:
	Utils.tween_scale_bounce_out(self)
	about_data = Database.ABOUT_INFO.get("Credits")
	title.text = about_data.section_name
	text.text = about_data.get_text()
	
func _on_about_pressed() -> void:
	about_data = Database.ABOUT_INFO.get("Credits")
	title.text = about_data.section_name
	text.text = about_data.get_text()

func _on_privacy_pressed() -> void:
	about_data = Database.ABOUT_INFO.get("Privacy")
	title.text = about_data.section_name
	text.text = about_data.get_text()

func _on_use_pressed() -> void:
	about_data = Database.ABOUT_INFO.get("Use")
	title.text = about_data.section_name
	text.text = about_data.get_text()

func _on_close_menu_pressed() -> void:
	var tween = Utils.tween_scale_bounce_in(self)
	tween.tween_callback(queue_free)

func _on_text_meta_clicked(meta: Variant) -> void:
	print(typeof(meta))
	OS.shell_open(meta)
