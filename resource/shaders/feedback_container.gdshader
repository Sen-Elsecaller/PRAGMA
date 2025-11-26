shader_type canvas_item;

// Controla el progreso del desvanecimiento (0.0 = visible, 1.0 = invisible)
uniform float fade_progress : hint_range(0.0, 1.0) = 0.0;

// Suavidad del borde del desvanecimiento
uniform float edge_softness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
	// Obtiene el color del pixel
	vec4 color = texture(TEXTURE, UV);

	// Calcula la posición vertical (0.0 = arriba, 1.0 = abajo)
	float vertical_pos = UV.y;

	// Invierte para que 1.0 sea arriba y 0.0 sea abajo
	float fade_factor = 1.0 - vertical_pos;

	// Calcula el alpha basado en el progreso
	float alpha = smoothstep(
		fade_progress - edge_softness,
		fade_progress + edge_softness,
		fade_factor
	);

	// Aplica el alpha al color
	COLOR = vec4(color.rgb, color.a * alpha);
}