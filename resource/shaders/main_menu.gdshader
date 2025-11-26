shader_type canvas_item;
uniform sampler2D gradient;
uniform bool enabled = true;
void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);

	if (enabled) {
		float brightness = (pixelColor.r + pixelColor.b + pixelColor.g) / 3.0;
		vec4 gradientColor = texture(gradient, vec2(brightness));
		COLOR = gradientColor;
	} else {
		COLOR = pixelColor;
	}
}