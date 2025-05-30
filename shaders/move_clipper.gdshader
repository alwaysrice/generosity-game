shader_type canvas_item;

uniform vec2 clip_min; // Clipping start in pixels (e.g., Vector2(20, 20))
uniform vec2 clip_max; // Clipping end in pixels (e.g., Vector2(100, 100))

void fragment() {
    // Get the texture size as vec2 to avoid type mismatch
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));

    // Convert UV to local pixel space
    vec2 local_pos = UV * tex_size;

    // Clip if out of bounds
    if (local_pos.x < clip_min.x || local_pos.y < clip_min.y ||
        local_pos.x > clip_max.x || local_pos.y > clip_max.y) {
        discard;
    }
}