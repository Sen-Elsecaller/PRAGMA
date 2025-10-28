class_name GameSessionData extends Resource

var scenario_name: String
var scenario_resource: ScenarioData
var average_response_time: float

func _init() -> void:
	set_scenario_name()
	
func set_scenario_name() -> void:
	scenario_name = scenario_resource.scenario_name
