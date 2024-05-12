#pragma language glsl3

// extern float time;


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // if (int(screen_coords.y) % 2 == 0)
    // {
    //     color = color * 0.5 * cos(time * 0.5);
    // }
    return color;
}