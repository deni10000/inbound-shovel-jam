shader_type canvas_item;

uniform bool swap_channels = false;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    if (swap_channels) {
        COLOR = vec4(color.b, color.g, color.r, color.a);
    }
}

