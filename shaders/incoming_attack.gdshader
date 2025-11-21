shader_type spatial;
render_mode unshaded, depth_test_disabled, cull_disabled, blend_mix;

uniform vec4 color : source_color = vec4(1.0, 0.2, 0.2, 1.0);
uniform float thickness = 0.05;

void vertex() {
	//MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	float radius = 1.0;
    vec2 uv = UV * 2.0 - 1.0;     // center UV at (0,0)
    float dist = length(uv);

	float in_circle = 1.0 - step(radius, dist);
    //float outer = step(radius, dist);                 // 1 outside, 0 inside
    //float inner = step(radius - thickness, dist);     // 1 outside inner radius
    //float ring = inner - outer;   // produces 1 only between radii

    ALBEDO = color.rgb;
	ALPHA = in_circle * color.a;
	//ALPHA = ring * color.a;
}