shader_type spatial;
render_mode blend_mix, depth_test_disabled, unshaded;

uniform sampler2D depth_texture : source_color, hint_depth_texture;

void fragment () {
	float z = FRAGCOORD.z;
	float depth = texture(depth_texture, SCREEN_UV).x;
	if (z <= depth + 0.00001 ) discard;
	ALBEDO = vec3(1.0, 1.0, 0.0);
}