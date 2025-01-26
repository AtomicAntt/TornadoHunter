shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float grayness : hint_range(0.0, 1.0); // Control variable for grayscale intensity

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    float avg = (color.r + color.g + color.b) / 3.0;
    vec3 grayscale = vec3(avg);
    color.rgb = mix(color.rgb, grayscale, grayness); // Blend between original color and grayscale
    COLOR = color;
}