extends Control

var base_carousel_scene = preload("res://scenes/ui/carousel_scene.tscn")

func _ready() -> void:
	for scene in Utils.carousel_scenes_array:
		var carousel_scene_instance = base_carousel_scene.instantiate()
		carousel_scene_instance.scene_resource = scene
		add_child(carousel_scene_instance)
