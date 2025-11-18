class_name ScreenState extends Control

signal push_screen(screen_state: ScreenStateMachine.SCREENS)
signal pop_screen
signal close_all_screens
signal reset_to_first_screen
signal change_screen

@onready var close_animations: AnimationPlayer
@onready var open_animations: AnimationPlayer

func Enter():
	pass
	#open_animations.play("open_" + str(name))

func Exit():
	pass
	#close_animations.play("close_" + str(name))
