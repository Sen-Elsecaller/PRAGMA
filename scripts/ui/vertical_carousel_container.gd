@tool
class_name FeedbackCarouselContainer extends Node2D

signal choice_changed(choice: PlayerChoice)

@export var spacing: float = 10.0
@export var opacity_strength: float = 0.35
@export_range(0.0, 1.0) var scale_strength: float = 0.25
@export_range(0.01, 0.99, 0.01) var scale_min: float = 0.1
@export var smoothing_speed: float = 6.5
@export var selected_index: int = 0
@onready var position_offset_node: Control = $CarouselNode
@onready var choices_bg: TextureRect = %ChoicesBG

var _previous_index: int = -1
var is_dragging: bool = false
var drag_start_y: float = 0.0
var drag_velocity: float = 0.0
var last_drag_y: float = 0.0
var drag_accumulator: float = 0.0
var drag_threshold: float = 100.0  # Ajusta según necesites

func _ready() -> void:
	choices_bg.gui_input.connect(_on_gui_input)
	
func _process(delta: float) -> void:
	if !position_offset_node or position_offset_node.get_child_count() == 0:
		return
	
	selected_index = clamp(selected_index, 0, position_offset_node.get_child_count() - 1)
	
	if _previous_index != selected_index:
		_previous_index = selected_index
		var current_node = position_offset_node.get_child(selected_index)
		if current_node is ChoiceScene:
			choice_changed.emit(current_node.player_choice)
	
	for i in position_offset_node.get_children():
		# Posicionamiento vertical
		var position_y = 0
		if i.get_index() > 0:
			position_y = position_offset_node.get_child(i.get_index() - 1).position.y + position_offset_node.get_child(i.get_index() - 1).size.y + spacing
		i.position = Vector2(-i.size.x / 2.0, position_y)
		
		i.pivot_offset = i.size / 2.0
		
		# Escala
		var target_scale = 1.0 - (scale_strength * abs(i.get_index() - selected_index))
		target_scale = clamp(target_scale, scale_min, 1.0)
		i.scale = lerp(i.scale, Vector2.ONE * target_scale, smoothing_speed * delta)
		
		# Opacidad
		var target_opacity = 1.0 - (opacity_strength * abs(i.get_index() - selected_index))
		target_opacity = clamp(target_opacity, 0.0, 1.0)
		i.modulate.a = lerp(i.modulate.a, target_opacity, smoothing_speed * delta)
	
	# Centrar verticalmente en el item seleccionado
	position_offset_node.position.y = lerp(
		position_offset_node.position.y,
		-(position_offset_node.get_child(selected_index).position.y + position_offset_node.get_child(selected_index).size.y / 2.0),
		smoothing_speed * delta
	)


# Función para manejar input:
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_accumulator = 0.0
		else:
			is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		drag_accumulator += event.relative.y
		
		if drag_accumulator > drag_threshold:
			_up()
			is_dragging = false
		elif drag_accumulator < -drag_threshold:
			_down()
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		var delta_y = event.position.y - last_drag_y
		position_offset_node.position.y += delta_y
		drag_velocity = delta_y
		last_drag_y = event.position.y
		
func _up():
	selected_index -= 1
	if selected_index < 0:
		selected_index = 0

func _down():
	selected_index += 1
	if selected_index > position_offset_node.get_child_count() - 1:
		selected_index = position_offset_node.get_child_count() - 1
