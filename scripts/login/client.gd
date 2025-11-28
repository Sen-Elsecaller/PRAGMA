# client.gd
# Clase singleton encargada de gestionar la autenticación con JWT
extends Node

# ========== CONFIGURACIÓN ==========
const BASE_URL = "http://98.87.220.175:8000"
const LOGIN_ENDPOINT = "/api/v1/dashboard/auth/login/"
const REFRESH_ENDPOINT = "/api/v1/dashboard/auth/refresh/"
const VERIFY_ENDPOINT = "/api/v1/dashboard/auth/verify/"

# ========== VARIABLES DE AUTENTICACIÓN ==========
var access_token: String = ""
var refresh_token: String = ""
var user_email: String = ""
var is_authenticated: bool = false

# ========== SEÑALES ==========
signal login_success(user_data: Dictionary)
signal login_failed(error_message: String)
signal token_refreshed()
signal token_refresh_failed()
signal logout_completed()

# ========== MÉTODOS DE AUTENTICACIÓN ==========

# Realizar login con email y contraseña
func login(email: String, password: String) -> void:
	var url = BASE_URL + LOGIN_ENDPOINT
	var data = {
		"email": email,
		"password": password
	}
	var headers = ["Content-Type: application/json"]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(result, response_code, response_headers, body):
		_handle_login_response(result, response_code, body, email)
		http.queue_free()
	)
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	if error != OK:
		login_failed.emit("Error de conexión")
		http.queue_free()

# Manejar respuesta del login
func _handle_login_response(result: int, response_code: int, body: PackedByteArray, email: String) -> void:
	var response_text = body.get_string_from_utf8()
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(response_text) == OK:
			var response_data = json.data
			
			if response_data.has("access") and response_data.has("refresh"):
				access_token = response_data["access"]
				refresh_token = response_data["refresh"]
				user_email = email
				is_authenticated = true
				
				var user_data = {
					"email": email,
					"access_token": access_token,
					"refresh_token": refresh_token
				}
				login_success.emit(user_data)
			else:
				login_failed.emit("Respuesta del servidor inválida")
		else:
			login_failed.emit("Error al procesar respuesta del servidor")
	else:
		print(response_code)
		var error_msg = "Error de autenticación"
		var json = JSON.new()
		if json.parse(response_text) == OK:
			var error_data = json.data
			if error_data.has("detail"):
				error_msg = error_data["detail"]
			elif error_data.has("error"):
				error_msg = error_data["error"]
		
		login_failed.emit(error_msg)

# Refrescar el access token usando el refresh token
func refresh_access_token() -> void:
	if refresh_token == "":
		token_refresh_failed.emit()
		return
	
	var url = BASE_URL + REFRESH_ENDPOINT
	var data = { "refresh": refresh_token }
	var headers = ["Content-Type: application/json"]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(result, response_code, response_headers, body):
		_handle_refresh_response(result, response_code, body)
		http.queue_free()
	)
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	if error != OK:
		token_refresh_failed.emit()
		http.queue_free()

# Manejar respuesta del refresh
func _handle_refresh_response(result: int, response_code: int, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(response_text) == OK:
			var response_data = json.data
			if response_data.has("access"):
				access_token = response_data["access"]
				token_refreshed.emit()
			else:
				token_refresh_failed.emit()
		else:
			token_refresh_failed.emit()
	else:
		token_refresh_failed.emit()
		logout()

# Verificar si el token actual es válido
func verify_token() -> void:
	if access_token == "":
		return
	
	var url = BASE_URL + VERIFY_ENDPOINT
	var data = { "token": access_token }
	var headers = ["Content-Type: application/json"]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(result, response_code, response_headers, body):
		if response_code != 200:
			refresh_access_token()
		http.queue_free()
	)
	
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))

# Cerrar sesión
func logout() -> void:
	access_token = ""
	refresh_token = ""
	user_email = ""
	is_authenticated = false
	logout_completed.emit()

# ========== MÉTODOS DE UTILIDAD ==========

# Obtener headers autenticados para peticiones HTTP
func get_auth_headers() -> Array:
	return [
		"Content-Type: application/json",
		"Authorization: Bearer " + access_token
	]

# Verificar si hay una sesión activa
func has_active_session() -> bool:
	return is_authenticated and access_token != ""

# Obtener el token de acceso actual
func get_access_token() -> String:
	return access_token

# Obtener el token de refresh
func get_refresh_token() -> String:
	return refresh_token

# Obtener el email del usuario
func get_user_email() -> String:
	return user_email

# Realizar petición HTTP autenticada (helper genérico)
func make_authenticated_request(endpoint: String, method: HTTPClient.Method, data: Dictionary = {}) -> HTTPRequest:
	var url = BASE_URL + endpoint
	var headers = get_auth_headers()
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var body = JSON.stringify(data) if not data.is_empty() else ""
	http.request(url, headers, method, body)
	
	return http
