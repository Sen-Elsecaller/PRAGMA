extends ScenarioBase

func _ready() -> void:
	Dialogic.start("classroom1")
	setup_signals()
