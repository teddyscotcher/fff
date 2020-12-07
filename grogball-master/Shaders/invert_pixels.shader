shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	c.r = 1.0 - c.r;
	c.g = 1.0 - c.g;
	c.b = 1.0 - c.b;
	float avg = (c.r + c.g + c.b) / 3.0;
	COLOR.rgb = vec3(avg + 0.2);
}