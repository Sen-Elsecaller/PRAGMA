class_name CustomResponseButton extends AnimatedTextureButton

func _ready():
	if disabled:
		mouse_entered.disconnect(_on_focus_entered)
