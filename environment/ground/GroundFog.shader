shader_type spatial;
//render_mode specular_schlick_ggx;

uniform sampler2D NOISE_PATTERN;
uniform float INTENSITY;
uniform float SCALE;


void vertex() {
// Output:0

}

void fragment() {
// Output:0
	vec4 world_vertex = CAMERA_MATRIX * vec4(VERTEX, 1.0);
	float noiseValue = texture(NOISE_PATTERN, world_vertex.zx * 0.05 * SCALE).x;
	ALBEDO = vec3(noiseValue);
	ALPHA = texture(NOISE_PATTERN, world_vertex.xz * 0.1).x * INTENSITY;
}

void light() {
// Output:0

}
