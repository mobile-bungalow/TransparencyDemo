// NOTE: Shader automatically converted from Godot Engine 4.0.3.stable.mono's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


uniform bool fade_enabled = true;

const mat4 bayerIndex = mat4(
    vec4(00.0/16.0, 12.0/16.0, 03.0/16.0, 15.0/16.0),
    vec4(08.0/16.0, 04.0/16.0, 11.0/16.0, 07.0/16.0),
    vec4(02.0/16.0, 14.0/16.0, 01.0/16.0, 13.0/16.0),
    vec4(10.0/16.0, 06.0/16.0, 09.0/16.0, 05.0/16.0));


uniform float alpha_clip : hint_range(0.001, 1.0, 0.01) = 0.1;
uniform float fade_intensity : hint_range(1.0, 10000.0, 0.1) = 10.0;
// number of world coordinates to actually check
global uniform int run_length;

global uniform int max_actors_on_screen;
global uniform sampler2D screen_fade_coords;


varying vec3 world_pos;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	// off if the object is not in a visible leaf or is 
	// not inside visibility polygon
	// NOTE: this will likely require two groups of shaders to be efficient
	// the in and out group, to avoid position texture copies to disabled 
	// meshes.
	if (fade_enabled) {
		float dist = 0.0;
		// output alpha, defaulting to 1.0, decremented by different processes
		// from the actor position texture.
		float alpha = 1.0;
		
			for (int i = 0; i < run_length; i++) {
				// target texel center
				// max_onscreen is the texture width and max data length
				vec2 pixel_coords = vec2(float(i) + .5, 0.5) / float(max_actors_on_screen);
				vec4 char_coord = texture(screen_fade_coords, pixel_coords);
				if (char_coord.xy == vec2(0)) continue;
				dist = length(char_coord.xy - FRAGCOORD.xy);
			
	
				alpha = smoothstep(0.0, fade_intensity, dist);			
					
				ivec2 uv = ivec2(int(FRAGCOORD.x) %  4, int(FRAGCOORD.y) % 4);
				float bayer = bayerIndex[uv.x][uv.y];
				
				if (alpha < bayer || alpha < alpha_clip ) {
						discard;
				}
					
			}	
			
		
	}
	
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
			

	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}
