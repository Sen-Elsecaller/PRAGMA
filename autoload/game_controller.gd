class_name GameController extends Node

@onready var gui: Control = $GUI
@export var fade_duration: float = 0.6

@onready var current_gui_scene: Control = $GUI/MainScreen
@onready var fade_rect: ColorRect = $SceneTransition/FadeEffect

var main_screen_scene = preload("res://scenes/ui/main_screen.tscn")





func change_gui_scene(new_scene: PackedScene, delete: bool = true, keep_running: bool = false) -> void:
	await _fade_out()
	
	if current_gui_scene:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)

	var new_instance = new_scene.instantiate()
	gui.add_child(new_instance)
	current_gui_scene = new_instance

	await _fade_in()

func return_to_main_menu():
	change_gui_scene(main_screen_scene)
# --------------------------
#   EFECTOS DE TRANSICIÓN
# --------------------------

func _fade_out() -> void:
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 1, fade_duration / 2.0)
	await tween.finished

func _fade_in() -> void:
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 0, fade_duration / 2.0)
	await tween.finished
