shader_type canvas_item;

uniform vec2 tile_factor = vec2(8.0f);
uniform vec2 offset_scale = vec2(0.1, 0.01);
uniform vec2 time_scale = vec2(0.1, 0.2);
uniform vec2 amplitude = vec2(2.0, 0.5);

void fragment() {
	// For some reason it is correct in-game but not in-editor?
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 tiled_uv = UV * tile_factor;
	tiled_uv.y *= aspect_ratio;
	
	vec2 wave_uv_offset;
	wave_uv_offset.x = cos(TIME * time_scale.x + (tiled_uv.x + tiled_uv.y) * offset_scale.x);
	wave_uv_offset.y = sin(TIME * time_scale.y + (tiled_uv.x + tiled_uv.y) * offset_scale.y);
	//vec2 animated_uv = vec2(fract(tiled_uv.x + sin(TIME * 0.1) * -2.0f), fract(tiled_uv.y + cos(TIME * 0.1)));
	COLOR = texture(TEXTURE, fract(tiled_uv + wave_uv_offset * amplitude));
	//COLOR = vec4(fract(UV * 8.0f + TIME), 0.0f, 1.0f);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
