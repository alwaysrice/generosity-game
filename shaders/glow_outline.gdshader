shader_type canvas_item;

uniform float outline_thickness = 1.0;
uniform float brightness = 4.0; // For glow (must be >1 to trigger HDR glow)

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = tex_color.a;

    // If pixel is visible, draw it as-is
    if (alpha > 0.0) {
        COLOR = tex_color;
    } else {
        // Look around for alpha > 0.0 — edge detection
        float max_alpha = 0.0;
        for (float x = -outline_thickness; x <= outline_thickness; x++) {
            for (float y = -outline_thickness; y <= outline_thickness; y++) {
                vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
                float neighbor_alpha = texture(TEXTURE, UV + offset).a;
                max_alpha = max(max_alpha, neighbor_alpha);
            }
        }

        // If neighboring pixel is visible, we are at the outline edge
        if (max_alpha > 0.0) {
            COLOR = vec4(vec3(brightness), 1.0); // bright white for glow
        } else {
            discard;
        }
    }
}