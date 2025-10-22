extends Node

var carousel_scenes_array: Array[CarouselSceneRes]

func _ready() -> void:
	for scene in Carousel_Scenes:
		carousel_scenes_array.append(load(Carousel_Scenes[scene]))

const CAROUSEL_SCENES_PATH = "res://resource/CarouselScenes/"

const Carousel_Scenes := {
	"Classroom1": CAROUSEL_SCENES_PATH + "classroom1.tres",
	"Library1": CAROUSEL_SCENES_PATH + "library1.tres"
}
