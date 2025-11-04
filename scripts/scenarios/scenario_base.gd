class_name ScenarioBase extends Control

@onready var dialogue_box: DialogueBox = %DialogueBox
@onready var scroll: ScrollContainer = %Scroll
#@onready var v_scroll_bar: VScrollBar = %VScrollBar
@onready var content: VBoxContainer = %Content
#@onready var answer_overlay: ColorRect = %AnswerOverlay
#@onready var answer_edit: LineEdit = %AnswerEdit
#@onready var submit_button: Button = %SubmitButton
@onready var responses_container: MarginContainer = %ResponsesContainer
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var game_ui: GameUI = $GameUICanvas/GameUI
@onready var animation_player: AnimationPlayer = $DialogueCanvas/AnimationPlayer
const SCENARIO_SELECTOR = preload("uid://btrw7gm53yrcs")
var DIALOGUE_RESOURCE: DialogueResource
var ballon_instance: CanvasLayer


func setup_signals() -> void:
	EffectsManager.post_fx.toggle_fx("VignetteFX", true)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.got_dialogue.connect(_on_line_emited)

	gui_input.connect(_on_gui_input)

	dialogue_box.dialogue_line = await DIALOGUE_RESOURCE.get_next_dialogue_line("start", [self])

func _on_dialogue_started(_dialogue):
	pass

func _on_dialogue_ended(_dialogue):
	print(Database.game_variables_dict)
	Utils.game_controller.change_gui_scene(SCENARIO_SELECTOR, false, false)

func _on_line_emited(line: DialogueLine):
	var sound_tag = line.get_tag_value("sound")
	var emotion_tag = line.get_tag_value("emotion")
	var effect_tag = line.get_tag_value("effect")
	var effect_duration_tag = line.get_tag_value("effect_duration")
	var outcome_text_tag = line.get_tag_value("outcome_text")
	if sound_tag != "" and SoundEffect.SOUND_EFFECT_TYPE.has(sound_tag): 
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.get(sound_tag))
	
	if effect_tag != "" and effect_duration_tag != "":
		EffectsManager.animate_fx(effect_tag, "strength", 8, effect_duration_tag.to_int(), Tween.EaseType.EASE_OUT)
		
	if emotion_tag != "":
		print(emotion_tag)

	if outcome_text_tag != "":
		print(outcome_text_tag)

func handle_click(event: InputEvent) -> void:
	var is_left_click: bool = event.is_pressed() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	var is_accept_key: bool = event.is_action_pressed("ui_accept")
	if is_left_click or is_accept_key:
		get_viewport().set_input_as_handled()
		if dialogue_box.is_typing:
			dialogue_box.skip_typing()
		else:
			next_line(dialogue_box.dialogue_line.next_id)

func next_line(next_id: String) -> void:
	var next_dialogue_line: DialogueLine = await DIALOGUE_RESOURCE.get_next_dialogue_line(next_id, [self])
	if not is_instance_valid(next_dialogue_line): return

	if next_dialogue_line.type == DMConstants.TYPE_RESPONSE:
		animation_player.play("open_responses_menu")
		responses_menu.responses = next_dialogue_line.responses
		await get_tree().create_timer(0.5).timeout
		scroll.set_deferred("scroll_vertical", 10000)
		responses_menu.get_menu_items()[0].grab_focus()
		
	elif next_dialogue_line.text == "":
		print(next_dialogue_line)
		dialogue_box.dialogue_line = next_dialogue_line
		
	else:
		var copy: DialogueBox = dialogue_box.duplicate()
		content.add_child(copy)
		content.move_child(copy, dialogue_box.get_index())
		dialogue_box.dialogue_line = next_dialogue_line

		await get_tree().create_timer(0.2).timeout
		scroll.set_deferred("scroll_vertical", 10000)

		dialogue_box.grab_focus()

func _on_gui_input(event: InputEvent) -> void:
	handle_click(event)

func _on_responses_menu_response_selected(response: Variant) -> void:
	animation_player.play("close_responses_menu")
	next_line(response.next_id)
