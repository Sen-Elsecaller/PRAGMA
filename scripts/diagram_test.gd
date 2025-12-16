extends Control
@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(delta: float) -> void:
	if sprite_2d.position.y < -1700:
		return
	await get_tree().create_timer(1).timeout
	sprite_2d.position.y -= delta * 300
