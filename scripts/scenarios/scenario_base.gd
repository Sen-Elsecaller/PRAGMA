class_name ScenarioBase extends Control

@onready var dialogue_box: DialogueBox = %DialogueBox
#@onready var v_scroll_bar: VScrollBar = %VScrollBar
@onready var content: VBoxContainer = %Content
#@onready var answer_overlay: ColorRect = %AnswerOverlay
#@onready var answer_edit: LineEdit = %AnswerEdit
#@onready var submit_button: Button = %SubmitButton
@onready var responses_container: MarginContainer = %ResponsesContainer
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var game_ui: GameUI = $GameUICanvas/GameUI
var DIALOGUE_RESOURCE: DialogueResource
var ballon_instance: CanvasLayer
var responses_menu_visible: bool = false
@onready var last_dialogue: DialogueBox = %DialogueBox
var is_processing_line: bool = false

func setup_signals() -> void:
	EffectsManager.post_fx.toggle_fx("VignetteFX", true)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	game_ui.returned_to_main_menu.connect(_on_dialogue_ended)
	DialogueManager.got_dialogue.connect(_on_line_emited)

	gui_input.connect(_on_gui_input)

	dialogue_box.dialogue_line = await DIALOGUE_RESOURCE.get_next_dialogue_line("start", [self])

func _on_dialogue_started(_dialogue):
	pass

func _on_dialogue_ended(_dialogue):
	print(Database.game_variables_dict)
	EffectsManager.post_fx.toggle_fx("VignetteFX", false)
	game_ui._on_close_menu_pressed()

func _on_line_emited(line: DialogueLine):
	var sound_tag = line.get_tag_value("sound")
	var emotion_tag = line.get_tag_value("emotion")
	var effect_tag = line.get_tag_value("effect")
	var effect_duration_tag = line.get_tag_value("effect_duration")
	var outcome_text_tag = line.get_tag_value("outcome_text")
	if sound_tag != "" and SoundEffect.SOUND_EFFECT_TYPE.has(sound_tag): 
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.get(sound_tag))
	
	if effect_tag != "" and effect_duration_tag != "":
		if line.get_tag_value("effect_overall") == "true":
			$DialogueCanvas.layer = 0
		var callback = EffectsManager.animate_fx(effect_tag, "strength", 8, effect_duration_tag.to_int(), Tween.EaseType.EASE_IN_OUT)
		callback.tween_callback(func(): $DialogueCanvas.layer = 1)
	if emotion_tag != "":
		print(emotion_tag)

	if outcome_text_tag != "":
		print(outcome_text_tag)

func handle_click(event: InputEvent) -> void:
	var is_left_click: bool = event.is_pressed() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	var is_accept_key: bool = event.is_action_pressed("ui_accept")
	if is_left_click or is_accept_key:
		get_viewport().set_input_as_handled()
		if last_dialogue.is_typing:
			last_dialogue.skip_typing()
		elif responses_menu_visible or is_processing_line:
			return
		else:
			next_line(last_dialogue.dialogue_line.next_id)

func next_line(next_id: String) -> void:
	is_processing_line = true
	var next_dialogue_line: DialogueLine = await DIALOGUE_RESOURCE.get_next_dialogue_line(next_id, [self])
	if not is_instance_valid(next_dialogue_line): 
		is_processing_line = false
		return
	
	if next_dialogue_line.type == DMConstants.TYPE_RESPONSE:
		Utils.tween_scale_bounce_out(responses_container)
		responses_menu.responses = next_dialogue_line.responses
		await get_tree().create_timer(0.3).timeout
		responses_menu.get_menu_items()[0].grab_focus()
		responses_menu_visible = true
		is_processing_line = false
		return
	
	if next_dialogue_line.text == "":
		last_dialogue.dialogue_line = next_dialogue_line
		is_processing_line = false
		return
	
	var copy: DialogueBox = last_dialogue.duplicate()
	copy.scale = Vector2.ONE
	content.add_child(copy)
	
	if content.get_child_count() > 5:
		content.get_child(0).burn_card_out()
	
	copy.dialogue_line = next_dialogue_line
	
	await get_tree().create_timer(0.3).timeout
	last_dialogue = copy
	copy.grab_focus()
	is_processing_line = false
	
func _on_gui_input(event: InputEvent) -> void:
	handle_click(event)

func _on_responses_menu_response_selected(response: Variant) -> void:
	Utils.tween_scale_bounce_in(responses_container)
	if response.character == "Player":
		var copy: DialogueBox = last_dialogue.duplicate()
		copy.scale = Vector2.ZERO
		content.add_child(copy)
		if content.get_child_count() > 5:
			content.get_child(0).burn_card_out()
		
		var response_line: DialogueLine = last_dialogue.dialogue_line
		response_line.character = Database.player_name
		response_line.text = response.text
		copy.dialogue_line = response_line
	
		await copy.dialogue_label.finished_typing
		await get_tree().create_timer(0.3).timeout
		
	responses_menu_visible = false
	next_line(response.next_id)
