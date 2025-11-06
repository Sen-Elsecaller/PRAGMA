extends Node

var carousel_scenarios_array: Array[CarouselScenarioRes]
var game_controller: GameController = null
var rng: RandomNumberGenerator = null
var balloon_instance: CanvasLayer

enum PivotPosition {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT
}

const CAROUSEL_SCENARIOS_PATH = "res://resource/carousel_scenarios/"
const Carousel_Scenarios := {
	"Classroom1": preload(CAROUSEL_SCENARIOS_PATH + "classroom1.tres"),
	"Library1": preload(CAROUSEL_SCENARIOS_PATH + "library1.tres")
}

var game_variables_dict: Dictionary = {}

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_set_balloon_instance)
	game_controller = get_node("/root/GameController")
	rng = RandomNumberGenerator.new()
	
	for scenario in Carousel_Scenarios:
		carousel_scenarios_array.append(Carousel_Scenarios[scenario])

# Función helper para configurar el pivot
static func set_pivot(node: Control, pivot_pos: PivotPosition) -> void:
	match pivot_pos:
		PivotPosition.TOP_LEFT:
			node.pivot_offset = Vector2.ZERO
		PivotPosition.TOP_CENTER:
			node.pivot_offset = Vector2(node.size.x / 2, 0)
		PivotPosition.TOP_RIGHT:
			node.pivot_offset = Vector2(node.size.x, 0)
		PivotPosition.CENTER_LEFT:
			node.pivot_offset = Vector2(0, node.size.y / 2)
		PivotPosition.CENTER:
			node.pivot_offset = Vector2(node.size.x / 2, node.size.y / 2)
		PivotPosition.CENTER_RIGHT:
			node.pivot_offset = Vector2(node.size.x, node.size.y / 2)
		PivotPosition.BOTTOM_LEFT:
			node.pivot_offset = Vector2(0, node.size.y)
		PivotPosition.BOTTOM_CENTER:
			node.pivot_offset = Vector2(node.size.x / 2, node.size.y)
		PivotPosition.BOTTOM_RIGHT:
			node.pivot_offset = Vector2(node.size.x, node.size.y)


static func tween_fade_in_with_children(
	main_node: Control, 
	children: Array[Node] = [], 
	pivot_position: PivotPosition = PivotPosition.CENTER,
	duration: float = 0.2,
	children_delay: float = 0.0  # Retraso opcional para los hijos
	) -> Tween:

	# Configuras el pivot ANTES de animar
	if main_node is Control:
		set_pivot(main_node, pivot_position)
	var tween = main_node.get_tree().create_tween()

	var target_size = main_node.custom_minimum_size.y

	main_node.custom_minimum_size.y = 0
	main_node.modulate.a = 0

	# Preparas los hijos
	for child in children:
		if child is CanvasItem:
			child.modulate.a = 0
	
	# Primera fase: nodo principal
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	tween.tween_property(main_node, "custom_minimum_size:y", target_size, duration)
	tween.tween_property(main_node, "modulate:a", 1.0, duration)
	
	# Segunda fase: hijos (si hay delay)
	if children.size() > 0:
		if children_delay > 0:
			tween.set_parallel(false)
			tween.tween_interval(children_delay)
			tween.set_parallel(true)
		
		for child in children:
			if child is CanvasItem:
				tween.tween_property(child, "modulate:a", 1.0, duration * 0.5)

	return tween

static func tween_scale_bounce_out(
	node: Node,
	pivot_pos: PivotPosition = PivotPosition.CENTER,
	duration: float = 0.2,
	overshoot: float = 1.2  # Escala máxima antes de volver a 1
	) -> Tween:
	
	var tween = node.get_tree().create_tween()
	if node is Control:
		set_pivot(node, pivot_pos)
	node.scale = Vector2.ZERO

	# Primera fase: crece más de lo normal
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(node, "scale", Vector2.ONE * overshoot, duration * 0.6)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.4)

	return tween

static func tween_scale_bounce_in(
	node: Node,
	pivot_pos: PivotPosition = PivotPosition.CENTER,
	duration: float = 0.2,
	) -> Tween:
	
	var tween = node.get_tree().create_tween()
	if node is Control:
		set_pivot(node, pivot_pos)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "scale", Vector2.ZERO, duration)

	
	return tween
func _set_balloon_instance(_dialogue):
	balloon_instance = game_controller.find_child("ExampleBalloon", true, false)
	print(balloon_instance)
