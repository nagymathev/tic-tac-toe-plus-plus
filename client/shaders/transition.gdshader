shader_type canvas_item;

uniform float radius = 0.0f;
uniform bool invert = false;

void fragment() {
	vec2 screen = vec2(1.0f / SCREEN_PIXEL_SIZE.x, 1.0f / SCREEN_PIXEL_SIZE.y);
	vec2 st = FRAGCOORD.xy / screen;
	float dist = 0.0f;
	dist = distance(vec2(0.5), st);
	if (invert) {
		COLOR *= step(radius, dist);
	} else {
		COLOR *= step(dist, radius);
	}
}
