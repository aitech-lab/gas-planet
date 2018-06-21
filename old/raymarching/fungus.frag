// Just a typical space fungus. A result of trying to understand the 
// volumetric / additive color stuff in "Type 2 Supernova" by Duke 
// (https://www.shadertoy.com/view/lsyXDK). Cosine color palettes 
// courtesy IQ: http://www.iquilezles.org/www/articles/palettes/palettes.htm
// Golfed version by FabriceNeyret2: https://www.shadertoy.com/view/ldlyD2

#ifdef GL_ES
precision highp float;
#endif

#define R(p, a) p = p * cos(a) + vec2(-p.y, p.x) * sin(a)

float Sin01(float t) {
    return 0.5 + 0.5 * sin(6.28319 * t);
}

float SineEggCarton(vec3 p) {
    return 1.0 - abs(sin(p.x) + sin(p.y) + sin(p.z)) / 3.0;
}

float Map(vec3 p, float scale) {
    float dSphere = length(p) - 1.0;
    return max(dSphere, (0.95 - SineEggCarton(scale * p)) / scale);
}

vec3 GetColor(vec3 p) {
    float amount = clamp((1.5 - length(p)) / 2.0, 0.0, 1.0);
    vec3 col = 0.5 + 0.5 * cos(6.28319 * (vec3(0.2, 0.0, 0.0) + amount * vec3(1.0, 1.0, 0.5)));
    return col * amount;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec3 rd = normalize(vec3(2.0 * fragCoord.xy - iResolution.xy, -iResolution.y));
    vec3 ro = vec3(0.0, 0.0, mix(1.2, 2.0, Sin01(0.05 * iTime)));
    R(rd.xz, 0.5 * iTime);
    R(ro.xz, 0.5 * iTime);
    R(rd.yz, 0.1 * iTime);
    R(ro.yz, 0.1 * iTime);
    float t = 0.0;
    fragColor.rgb = vec3(0.0);
    float scale = mix(3.5, 9.0, Sin01(0.068 * iTime));
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = Map(p, scale);
        if (t > 5.0 || d < 0.001) {
            break;
        }
        t += 0.8 * d;
        fragColor.rgb += 0.05 * GetColor(p);
    }
}
