shader_type spatial;

render_mode unshaded, wireframe, cull_disabled;

uniform vec4 albedo: source_color = vec4(0.0,0.0,0.0,1.0);

void vertex() {
}


void fragment() {
	ALBEDO = albedo.rgb;
}