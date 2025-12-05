# AuthManager.gd
# Autoload global para gestionar autenticación en toda la aplicación
extends Node

# ========== CONFIGURACIÓN ==========
const BASE_URL = "https://pragmabackend-production.up.railway.app"
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
signal session_restored()
signal authentication_required()

# ========== INICIALIZACIÓN ==========
func _ready() -> void:
	# Intentar restaurar sesión guardada al iniciar la aplicación
	_try_restore_saved_session()

# ========== RESTAURACIÓN DE SESIÓN ==========
func _try_restore_saved_session() -> void:
	if ConfigFileHandler.has_saved_session():
		var auth_data = ConfigFileHandler.load_auth_session()
		
		if auth_data["access_token"] != "" and auth_data["refresh_token"] != "":
			access_token = auth_data["access_token"]
			refresh_token = auth_data["refresh_token"]
			user_email = auth_data["user_email"]
			is_authenticated = true
			
			print("[AuthManager] Sesión restaurada para: ", user_email)
			
			# Verificar si el token sigue siendo válido
			verify_token()
			session_restored.emit()
		else:
			print("[AuthManager] No hay tokens válidos guardados")
	else:
		print("[AuthManager] No hay sesión guardada")

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
				
				# Guardar sesión en disco
				ConfigFileHandler.save_auth_session(access_token, refresh_token, email)
				
				print("[AuthManager] Login exitoso: ", email)
				
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
		var error_msg = "Error de autenticación"
		var json = JSON.new()
		if json.parse(response_text) == OK:
			var error_data = json.data
			if error_data.has("detail"):
				error_msg = error_data["detail"]
			elif error_data.has("error"):
				error_msg = error_data["error"]
		
		print("[AuthManager] Login fallido: ", error_msg)
		login_failed.emit(error_msg)

# Refrescar el access token
func refresh_access_token() -> void:
	if refresh_token == "":
		print("[AuthManager] No hay refresh token disponible")
		token_refresh_failed.emit()
		return
	
	print("[AuthManager] Intentando refrescar token...")
	
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

func _handle_refresh_response(result: int, response_code: int, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(response_text) == OK:
			var response_data = json.data
			if response_data.has("access"):
				access_token = response_data["access"]
				
				# Actualizar token en disco
				ConfigFileHandler.update_access_token(access_token)
				
				print("[AuthManager] Token refrescado exitosamente")
				token_refreshed.emit()
			else:
				print("[AuthManager] Respuesta de refresh inválida")
				token_refresh_failed.emit()
		else:
			print("[AuthManager] Error parseando respuesta de refresh")
			token_refresh_failed.emit()
	else:
		print("[AuthManager] Refresh fallido con código: ", response_code)
		token_refresh_failed.emit()
		logout()

# Verificar si el token actual es válido
func verify_token() -> void:
	if access_token == "":
		print("[AuthManager] No hay token para verificar")
		return
	
	print("[AuthManager] Verificando token...")
	
	var url = BASE_URL + VERIFY_ENDPOINT
	var data = { "token": access_token }
	var headers = ["Content-Type: application/json"]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(result, response_code, response_headers, body):
		if response_code == 200:
			print("[AuthManager] Token válido")
		else:
			print("[AuthManager] Token inválido, intentando refrescar...")
			refresh_access_token()
		http.queue_free()
	)
	
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))

# Cerrar sesión
func logout() -> void:
	print("[AuthManager] Cerrando sesión de: ", user_email)
	
	access_token = ""
	refresh_token = ""
	user_email = ""
	is_authenticated = false
	
	# Limpiar sesión guardada
	ConfigFileHandler.clear_auth_session()
	
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

# Obtener información del usuario
func get_user_info() -> Dictionary:
	return {
		"email": user_email,
		"is_authenticated": is_authenticated,
		"has_access_token": access_token != "",
		"has_refresh_token": refresh_token != ""
	}

# Realizar petición HTTP autenticada
func make_authenticated_request(
	endpoint: String, 
	method: HTTPClient.Method, 
	data: Dictionary = {},
	callback: Callable = Callable()
) -> HTTPRequest:
	
	if not has_active_session():
		print("[AuthManager] Intento de petición sin sesión activa")
		authentication_required.emit()
		return null
	
	var url = BASE_URL + endpoint
	var headers = get_auth_headers()
	
	var http := HTTPRequest.new()
	add_child(http)
	
	if callback.is_valid():
		http.request_completed.connect(callback)
	
	var body = JSON.stringify(data) if not data.is_empty() else ""
	
	var error = http.request(url, headers, method, body)
	if error != OK:
		print("[AuthManager] Error en petición HTTP: ", error)
		http.queue_free()
		return null
	
	return http

# ========== HELPERS PARA DEBUGGING ==========
func print_auth_status() -> void:
	print("========== AUTH STATUS ==========")
	print("Authenticated: ", is_authenticated)
	print("Email: ", user_email)
	print("Has Access Token: ", access_token != "")
	print("Has Refresh Token: ", refresh_token != "")
	print("================================")
