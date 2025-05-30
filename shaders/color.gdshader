shader_type canvas_item;

uniform vec4 modulate_color : source_color;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (tex_color.a >=0.01) {
        // Make invisible pixels white
        COLOR = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        COLOR = tex_color;
    }
}