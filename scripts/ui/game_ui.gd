class_name GameUI extends Control

@onready var animations: AnimationPlayer = $AnimationPlayer
signal returned_to_main_menu

func _on_exit_pressed() -> void:
	EffectsManager.post_fx.toggle_fx("VignetteFX", false)
	Utils.game_controller.return_to_main_menu()
	
func _on_menu_button_pressed() -> void:
	animations.play("open_game_menu")

func _on_close_menu_pressed() -> void:
	
	animations.play("close_game_menu")
	
func _on_dialogue_history_pressed() -> void:
	pass # Replace with function body.
