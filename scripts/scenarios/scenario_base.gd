class_name ScenarioBase extends Control

@onready var background: TextureRect = %Background
@onready var dialogue_box: DialogueBox = %DialogueBox
@onready var last_dialogue: DialogueBox = %DialogueBox
@onready var content: VBoxContainer = %Content
@onready var responses_container: MarginContainer = %ResponsesContainer
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var game_ui: GameUI = $GameUICanvas/GameUI
@onready var characters_node: Characters = $Characters
@onready var outcome_text_node: OutcomeText = $OutcomeText
@onready var fade_rect: ColorRect = %FadeEffect
@onready var frame_blue: TextureRect = $Images/FrameBlue
@onready var frame_purple: TextureRect = $Images/FramePurple

var DIALOGUE_RESOURCE: DialogueResource
var responses_menu_visible: bool = false
var is_processing_line: bool = false
var current_feedback: FeedbackData
var current_choice: PlayerChoice
var dialogue_history: Array[Dictionary] = []
var response_timer: float

signal update_history(character: String, text: String)

func _process(delta: float) -> void:
	response_timer += delta
	
func setup_signals() -> void:
	current_feedback = FeedbackData.new()
	EffectsManager.post_fx.toggle_fx("VignetteFX", true)
	update_history.connect(game_ui._on_update_dialogue_history)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	game_ui.returned_to_main_menu.connect(_on_dialogue_ended)
	game_ui.dialogue_history_pressed.connect(_on_dialogue_history_pressed)
	DialogueManager.got_dialogue.connect(_use_tags)
	gui_input.connect(_on_gui_input)
	dialogue_box.dialogue_line = await DIALOGUE_RESOURCE.get_next_dialogue_line("start", [self])

func _on_dialogue_started(_dialogue):
	pass

func _on_dialogue_ended(_dialogue):
	EffectsManager.post_fx.toggle_fx("VignetteFX", false)
	current_feedback.finalizar_sesion()
	Utils.game_controller.current_feedback = current_feedback
	Utils.game_controller.scenario_ended.emit()
	Utils.game_controller.change_gui_scene(load("uid://bk0ok7dhbcruf"))

func _on_dialogue_history_pressed():
	game_ui.update_dialogue_history(dialogue_history)

func _use_tags(line: Variant) -> void:
	var sound_tag = line.get_tag_value("sound")
	var emotion_tag = line.get_tag_value("emotion")
	var effect_tag = line.get_tag_value("effect")
	var effect_duration_tag = line.get_tag_value("effect_duration")
	var outcome_text_tag = line.get_tag_value("outcome_text")
	var feedback_tag = line.get_tag_value("feedback")
	var background_tag = line.get_tag_value("background")
	var character_enter_tag = line.get_tag_value("character_enter")
	var character_exit_tag = line.get_tag_value("character_exit")
	var character_emotion_tag = line.get_tag_value("character_emotion")
	
	# Sonidos
	if sound_tag != "" and SoundEffect.SOUND_EFFECT_TYPE.has(sound_tag): 
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.get(sound_tag))
	
	# Efectos visuales
	if effect_tag != "" and effect_duration_tag != "":
		if line.get_tag_value("effect_overall") == "true":
			$DialogueCanvas.layer = 0
		var tween = EffectsManager.animate_fx(effect_tag, "strength", effect_duration_tag.to_int(), Tween.EaseType.EASE_IN_OUT)
		tween.tween_callback(func(): $DialogueCanvas.layer = 1)
	
	if background_tag != "":
		if Database.SCENARIOS_BACKGROUNDS.has(background_tag):
			change_background(Database.SCENARIOS_BACKGROUNDS.get(background_tag))
	# Emociones
	if emotion_tag != "":
		if current_choice:
			current_choice.emotion = emotion_tag
	
	# Outcome text
	if outcome_text_tag != "":
		outcome_text_node.enter.emit(outcome_text_tag.replace(";", ","), emotion_tag, false)
		if current_choice:
			current_choice.outcome_text = outcome_text_tag.replace(";", ",")
	
	# Feedback
	if feedback_tag != "":
		current_choice.feedback = feedback_tag.replace(";", ",")
		current_choice.response_time = response_timer
		current_choice.scenario_name = Utils.game_controller.current_scenario_name
		current_feedback.elecciones.append(current_choice)
	
	# Personajes
	if character_exit_tag != "":
		characters_node.hide_character(character_exit_tag.to_pascal_case())
	
	if character_enter_tag != "":
		characters_node.show_character(character_enter_tag.to_pascal_case(), character_emotion_tag)

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
		current_choice = PlayerChoice.new()
		current_choice.question = last_dialogue.dialogue_line.text
		current_choice.character = last_dialogue.dialogue_line.character
		Utils.tween_scale_bounce_out(responses_container)
		response_timer = 0
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
	
	# Guardar en historial
	dialogue_history.append({
		"character": next_dialogue_line.character if next_dialogue_line.character != "" else "Narrador",
		"text": next_dialogue_line.text
	})
	update_history.emit(next_dialogue_line.character if next_dialogue_line.character != "" else "Narrador", next_dialogue_line.text)
	
	await get_tree().create_timer(0.3).timeout
	last_dialogue = copy
	copy.grab_focus()
	is_processing_line = false

func _on_gui_input(event: InputEvent) -> void:
	handle_click(event)

func _on_responses_menu_response_selected(response: Variant) -> void:
	current_choice.selected_response = response.text
	_use_tags(response)

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
		
		# Guardar respuesta del jugador en historial
		dialogue_history.append({
			"character": Database.player_name,
			"text": response.text
		})
		update_history.emit(Database.player_name, response.text)
		await copy.dialogue_label.finished_typing
		await get_tree().create_timer(0.3).timeout
	
	responses_menu_visible = false
	next_line(response.next_id)

func change_background(texture: Texture):
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1, 0.5 / 2.0)
	await tween.finished
	background.texture = texture
	tween.kill()
	tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0, 0.5 / 2.0)

func increase_blue():
	var value = 1
	var tween = create_tween()
	tween.tween_property(frame_purple, "modulate:a", value, 1)
