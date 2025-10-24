extends CanvasLayer

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var visual_effect: Control = $Control

func play_sound(_name: String):
	update_audio_effect(_name)

func update_audio_effect(audio_name: String):
	if audio_name == "none":
		audio_player.stop()
	if audio_name != audio_player["parameters/switch_to_clip"]:
		audio_player.play()
		audio_player["parameters/switch_to_clip"] = audio_name
