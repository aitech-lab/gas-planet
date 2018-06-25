# ../shaders/simple.vert
vert_simple= """
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
void main() {
    vUv = uv;
    vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
    gl_Position     = projectionMatrix * mvPosition; 
    gl_Position     = projectionMatrix * mvPosition;
    vPos            = vec3(mvPosition)/mvPosition.w;
    vNormal         = vec3(normalMatrix * normal);
}
"""

# ../shaders/screen.frag
frag_screen= """
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
uniform sampler2D texture;
void main() {
    gl_FragColor = texture2D(texture, vUv)*vNormal.z*vNormal.z;
    gl_FragColor.a = 1.0;
}
"""

# ../shaders/fbm_05.frag
frag_fbm_05= """
// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com


#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUv;
varying vec3 vNormal;

uniform vec2 u_mouse;
uniform float u_time;
uniform float u_scale;
uniform float u_speed;

uniform vec3 u_col1;
uniform vec3 u_col2;
uniform vec3 u_col3;
uniform vec3 u_col4;

#define pal1 pal( c.r, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0), vec3(0.0,0.33,0.67) )
#define pal2 pal( c.r, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0), vec3(0.0,0.10,0.20) )
#define pal3 pal( c.r, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0), vec3(0.3,0.20,0.20) )
#define pal4 pal( c.r, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,0.5), vec3(0.8,0.90,0.30) )
#define pal5 pal( c.r, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,0.7,0.4), vec3(0.0,0.15,0.20) )
#define pal6 pal( c.r, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(2.0,1.0,0.0), vec3(0.5,0.20,0.25) )
#define pal7 pal( c.r, vec3(0.8,0.5,0.4), vec3(0.2,0.4,0.2), vec3(2.0,1.0,1.0), vec3(0.0,0.25,0.25) )
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy, vec2(12.9898,78.233)))*
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    float time = u_time*u_speed;
    vec2 st = vUv*u_scale; // gl_FragCoord.xy/u_resolution.xy*3.;
    st.x+=time*0.1;
    // st += st * abs(sin(time*0.1)*3.0);
    vec3 color = vec3(0.0);

    vec2 q = vec2(0.);
    q.x = fbm( st + 0.00*time);
    q.y = fbm( st + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( st + 1.0*q + vec2(1.7,9.2)+ 0.150*time);
    r.y = fbm( st + 1.0*q + vec2(8.3,2.8)+ 0.126*time);

    float f = fbm(st+r);
    vec3 c = pal((f*f*f+.6*f*f+.5*f)*5.0, u_col1, u_col2, u_col3, u_col4);
    gl_FragColor = vec4(c, 1.0);
}
"""

