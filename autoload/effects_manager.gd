extends CanvasLayer

@onready var post_fx: PostFX = $PostFX

func _ready() -> void:
	disable_all_effects()

func disable_all_effects() -> void:
	for fx in post_fx.effects:
		if fx != null:
			fx.enabled = false

func animate_fx(fx_name: String, property: String, duration: float = 2, ease_type: Tween.EaseType = Tween.EASE_OUT, trans_type: Tween.TransitionType = Tween.TRANS_CUBIC) -> Tween:
	var max_value: float
	match fx_name:
		"ChromaticAberrationFX":
			max_value = 8
		"ShakeFX":
			max_value = 0.05
	
	var fx := post_fx.get_fx(fx_name)
	if fx == null:
		push_warning("Efecto %s no encontrado." % fx_name)
		return
	
	if not fx.enabled:
		fx.enabled = true
	
	var initial_value = fx.get(property)
	
	var tween := create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	
	tween.tween_property(fx, property, max_value, duration / 2.0)
	
	tween.tween_property(fx, property, initial_value, duration / 2.0)
	
	return tween
