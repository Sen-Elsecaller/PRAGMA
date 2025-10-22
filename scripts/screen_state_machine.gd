class_name ScreenStateMachine extends Node


# Enumeración que define los identificadores de las pestañas principales.
enum SCREENS {MAIN, SCENARIOSELECTOR, SETTINGS}

# Diccionario que asocia cada tipo de screen con su nodo correspondiente dentro del árbol de la escena.
@onready var screens: Dictionary = {
	SCREENS.MAIN: $MainMenu,
	SCREENS.SCENARIOSELECTOR: $ScenarioSelector
}

# Referencia al screen actualmente activo.
var current_screen: ScreenState

# Tab inicial que se mostrará al cargar la escena.
@export var initial_screen: SCREENS = SCREENS.MAIN

# Referencias a las animaciones de apertura y cierre que se aplican a las transiciones de .
@onready var close_animations = $CloseAnimations
@onready var open_animations = $OpenAnimations

func _ready():
	# Configura los  al iniciar: conecta sus señales y asigna referencias a las animaciones compartidas.
	for screen in screens.values():
		if screen is ScreenState:
			
			# Conecta las señales de cada screen a las funciones locales de control.
			screen.push_screen.connect(push_screen)
			screen.pop_screen.connect(pop_screen)
			screen.close_all_screens.connect(close_all_screens)
			
			# Asigna las animaciones comunes a cada screen.
			screen.close_animations = close_animations
			screen.open_animations = open_animations
			screen.change_screen.connect(change_screen)
	
	# Activa el screen inicial al iniciar la escena.
	screens[initial_screen].Enter()
	current_screen = screens[initial_screen]
	
# Función destinada a apilar un nuevo screen sobre el actual (no implementada).
func push_screen(_screen: SCREENS) -> void:
	pass
	
# Cierra el screen superior actual, si existe.
func pop_screen() -> void:
	get_topmost_screen().Exit()

# Probablemente no se utilice; diseñada para reiniciar el sistema eliminando todas las  secundarias.
# Actualmente incompatible con el modelo actual que no instancia nuevas escenas dinámicamente.
func reset_to_first_screen() -> void:
	for n in range(get_child_count() - 1, 0, -1):
		get_child(n).queue_free()

# Cierra todas las  presentes en el nodo.
func close_all_screens() -> void:
	if get_children().size() > 0:
		for child in get_children():
			child.queue_free()

# Devuelve la screen superior en la jerarquía (la última agregada).
func get_topmost_screen() -> ScreenState:
	if get_child_count() == 0:
		return null
	return get_child(-1)
	
# Cambia de una screen a otra, ejecutando la animación de salida de la actual y la de entrada de la nueva.
func change_screen(screen: SCREENS):
	current_screen.Exit()
	screens[screen].Enter()
