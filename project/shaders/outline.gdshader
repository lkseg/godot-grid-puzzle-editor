shader_type canvas_item;

uniform float edge_pixel_size = 2.0;
uniform float alpha_cutoff = 0.001;
uniform vec4 edge_color: source_color = vec4(1,0,0,1);
uniform vec4 background_modulate: source_color = vec4(1,1,1,1);

bool is_zero_approx(float alpha) {
	return alpha <= alpha_cutoff;	
}
bool __is_not_zero_approx(float alpha) {
	return alpha > alpha_cutoff;
	// return v.x <= eps && v.y <= eps && v.z <= eps;
}

#define Z __is_not_zero_approx


bool val_is_near_edge(float val, float max_val) {
	return val <= edge_pixel_size || max_val - val <= edge_pixel_size;
}
bool is_near_edge(vec2 val, vec2 max_val) {
	return val_is_near_edge(val.x, max_val.x) || val_is_near_edge(val.y, max_val.y);
}


// if an object doesn't have an inner part that is empty then
// one could check for an outer edge just by checking if alpha approx zero and not near edge
void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE;
	vec2 r = vec2(1, 0)*size*edge_pixel_size;
	vec2 u = vec2(0,-1)*size*edge_pixel_size;
	vec2 d = -u;
	vec2 l = -r;

	vec2 ul = u + l;
	vec2 ur = u + r;
	
	vec2 dl = d + l;
	vec2 dr = d + r;

	float t0 = texture(TEXTURE, UV+u).a;
	float t1 = texture(TEXTURE, UV+ur).a;
	float t2 = texture(TEXTURE, UV+r).a;
	float t3 = texture(TEXTURE, UV+dr).a;
	float t4 = texture(TEXTURE, UV+d).a;
	float t5 = texture(TEXTURE, UV+dl).a;
	float t6 = texture(TEXTURE, UV+l).a;
	float t7 = texture(TEXTURE, UV+ul).a;
	bool is_neighbour_not_zero = Z(t0) || Z(t1) || Z(t2) || Z(t3) || Z(t4) || Z(t5) || Z(t6) || Z(t7);
	//is_neighbour_not_zero = Z(t0) || Z(t2) || Z(t4) || Z(t6);
	//bool is_self_edge = UV.x <= 
	vec2 tsize = vec2(textureSize(TEXTURE, 0));
	vec2 pixel = UV*tsize;
	// sprite that is surrounded by transparent pixels e.g. a shovel
	bool is_colored_edge_pixel = !is_zero_approx(COLOR.a) && is_near_edge(pixel, tsize);
	// sprite that isn't surrounded by transparent pixels e.g. a block	
	bool is_zero_and_edge = is_zero_approx(COLOR.a) && is_neighbour_not_zero;
	if (is_zero_and_edge || is_colored_edge_pixel) {
		COLOR = edge_color;
	} else {
		COLOR = texture(TEXTURE, UV) * background_modulate;
	}
}