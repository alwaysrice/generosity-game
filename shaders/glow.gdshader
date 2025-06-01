shader_type canvas_item;

uniform vec4 glow_color = vec4(1.0, 1.0, 0.0, 1.0); // yellowish
uniform float glow_strength = 2.0;
uniform float glow_size = 4.0;

void fragment() {
    float dist = length(UV - vec2(0.5));
    float glow = glow_strength * exp(-dist * glow_size);
    COLOR = glow_color * glow;
}
