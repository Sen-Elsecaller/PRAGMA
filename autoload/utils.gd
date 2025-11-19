extends Node

var carousel_scenarios_array: Array[CarouselScenarioRes]
var game_controller: GameController = null
var rng: RandomNumberGenerator = null
var balloon_instance: CanvasLayer
const NOTIFICATION_SCENE = preload("res://scenes/ui/notification.tscn")

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


var game_variables_dict: Dictionary = {}

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_set_balloon_instance)
	game_controller = get_node("/root/GameController")
	rng = RandomNumberGenerator.new()
	
func show_notification(
		message: String,
		type: int = NotificationText.NotificationType.SUCCESS,
		position: int = NotificationText.Position.TOP,
		duration: float = 3.0
	) -> void:
		
	var notification = NOTIFICATION_SCENE.instantiate()
	notification.message = message
	notification.type = type
	notification.notification_position = position
	notification.duration = duration
	
	game_controller.get_current_scene().add_child(notification)

func set_pivot(node: Control, pivot_pos: PivotPosition) -> Vector2:
	match pivot_pos:
		PivotPosition.TOP_LEFT:
			return Vector2.ZERO
		PivotPosition.TOP_CENTER:
			return Vector2(node.size.x / 2, 0)
		PivotPosition.TOP_RIGHT:
			return Vector2(node.size.x, 0)
		PivotPosition.CENTER_LEFT:
			return Vector2(0, node.size.y / 2)
		PivotPosition.CENTER:
			return Vector2(node.size.x / 2, node.size.y / 2)
		PivotPosition.CENTER_RIGHT:
			return Vector2(node.size.x, node.size.y / 2)
		PivotPosition.BOTTOM_LEFT:
			return Vector2(0, node.size.y)
		PivotPosition.BOTTOM_CENTER:
			return Vector2(node.size.x / 2, node.size.y)
		PivotPosition.BOTTOM_RIGHT:
			return Vector2(node.size.x, node.size.y)
		_:
			return Vector2.ZERO

func tween_fade_in_with_children(
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

func tween_scale_bounce_out(
	node: Node,
	duration: float = 0.2,
	overshoot: float = 1.02  # Escala máxima antes de volver a 1
	) -> Tween:
		
	var tween = node.get_tree().create_tween()

	node.scale = Vector2.ZERO

	# Primera fase: crece más de lo normal
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(node, "scale", Vector2.ONE * overshoot, duration * 0.6).from(Vector2.ZERO)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.4)

	return tween

func tween_scale_bounce_in(
	node: Node,
	duration: float = 0.2,
	) -> Tween:
	
	var tween = node.get_tree().create_tween()

	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(node, "scale", Vector2.ZERO, duration)

	return tween

func tween_fade_in_simple(
	node: CanvasItem,
	duration: float = 0.3,
	ease_type: Tween.EaseType = Tween.EASE_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_SINE
) -> Tween:
	var tween = node.get_tree().create_tween()
	if node.visible == false:
		node.show()
		
	node.modulate.a = 0
	
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(node, "modulate:a", 1.0, duration)
	
	return tween

# Fade out simple
func tween_fade_out_simple(
	node: CanvasItem,
	duration: float = 0.2,
	ease_type: Tween.EaseType = Tween.EASE_IN,
	trans_type: Tween.TransitionType = Tween.TRANS_SINE
) -> Tween:
	var tween = node.get_tree().create_tween()
	
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(node, "modulate:a", 0.0, duration)
	
	return tween

# Entra deslizándose (funciona con Node2D y Control)
func tween_slide_in(
	node: Node,
	direction: Vector2,
	duration: float = 0.12,
	distance: float = 650
) -> Tween:
	var tween = node.get_tree().create_tween()
	
	var start_offset = direction * distance
	var target_pos = node.position
	
	tween.set_ease(Tween.EASE_IN)  # ← Mismo ease
	tween.set_trans(Tween.TRANS_SINE)   # ← Misma transición
	tween.tween_property(node, "position", target_pos, duration).from(target_pos + start_offset)
	
	return tween

# Sale deslizándose (funciona con Node2D y Control)
func tween_slide_out(
	node: Node,
	direction: Vector2,
	duration: float = 0.12,
	distance: float = 650
) -> Tween:
	var tween = node.get_tree().create_tween()
	var initial_position = node.position
	var end_position = node.position + (direction * distance)
	
	tween.set_ease(Tween.EASE_IN)  # ← Mismo ease
	tween.set_trans(Tween.TRANS_SINE)   # ← Misma transición
	tween.tween_property(node, "position", end_position, duration)
	
	tween.tween_callback(func(): node.position = initial_position)
	return tween

func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)

func _set_balloon_instance(_dialogue):
	balloon_instance = game_controller.find_child("ExampleBalloon", true, false)
