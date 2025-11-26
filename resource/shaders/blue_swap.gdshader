shader_type canvas_item;

uniform vec4 color_to_replace : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 new_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float threshold : hint_range(0.0, 1.0) = 0.01;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);

	// Calcula la diferencia entre el color del pixel y el color a reemplazar
	float diff = distance(pixel_color.rgb, color_to_replace.rgb);

	// Si está dentro del threshold, reemplaza
	if (diff < threshold) {
		COLOR = new_color;
	} else {
		COLOR = pixel_color;
	}
}