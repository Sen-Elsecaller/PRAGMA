# Controlador principal del juego. Maneja transiciones entre escenas,
# gestiona el feedback de sesiones, y configura el audio inicial
class_name GameController extends Node

# Referencias a nodos principales
@onready var gui: Control = $GUI
@onready var current_gui_scene: Control = $GUI/MainScreen
@onready var fade_rect: ColorRect = $SceneTransition/FadeEffect

# Configuración de transiciones
@export var fade_duration: float = 0.6

# Escenas precargadas
var main_screen_scene = preload("res://scenes/ui/main_screen.tscn")

# Estado de la sesión actual
var current_feedback: FeedbackData
var current_scenario_name: String

signal scenario_ended

# Inicialización del sistema de audio y señales
func _ready() -> void:
	scenario_ended.connect(_on_scenario_ended)
	AudioServer.set_bus_volume_linear(1, ConfigFileHandler.load_config_settings("settings").get("music_volume"))
	AudioServer.set_bus_volume_linear(2, ConfigFileHandler.load_config_settings("settings").get("sfx_volume"))

# Manejo del fin de escenario: guarda feedback y lo envía al backend
func _on_scenario_ended():
	ConfigFileHandler.save_session(current_feedback)
	ConfigFileHandler.send_session_to_webhook()

# Cambia la escena actual del GUI con transición fade
# delete: destruye la escena anterior
# keep_running: oculta pero mantiene la escena anterior activa
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

func get_current_scene():
	return current_gui_scene

func return_to_main_menu():
	change_gui_scene(main_screen_scene)

# Efectos de transición de pantalla
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
