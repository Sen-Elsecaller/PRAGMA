class_name CarouselScene extends MarginContainer

@onready var photo = %Photo
@onready var scene_name = %SceneName
var scene_resource: CarouselSceneRes


func _ready() -> void:
	photo.texture = scene_resource.main_photo
	scene_name.text = scene_resource.scene_name
