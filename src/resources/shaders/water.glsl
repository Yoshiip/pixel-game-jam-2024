#pragma language glsl3

uniform vec4 mask_color = vec4(1.0, 0.0, 1.0, 1.0); // purple
uniform vec4 water_color = vec4(0.255, 0.651, 0.965, 1.0); // blue
uniform vec4 dirt_color = vec4(0.937, 0.49, 0.341, 1.0); // brown

bool isClose(vec4 col1, vec4 col2, float tolerance) {
    return length(col1 - col2) < tolerance;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (isClose(texturecolor, mask_color, 0.1))
    {
        vec2 coords_above = texture_coords + vec2(0.0, -1.0/textureSize(tex, 0).y);
        vec4 texturecolor_above = Texel(tex, coords_above);
        if (!isClose(texturecolor_above, mask_color, 0.1))
        {
            texturecolor = dirt_color;
        }
        else
        {
            texturecolor = water_color;
        }
    }
    return texturecolor * color;
}
