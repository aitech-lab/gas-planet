// Author @patriciogv - 2015
// Title: Ikeda Data Stream

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texcoord;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random (in float x) {
    return fract(sin(x)*1e4);
}

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(22.7898,78.233)))* 43758.5453123);
}

float pattern(vec2 st, vec2 v, float t) {
    vec2 p = floor(st+v);
    return 
        random(p)*2.0;
    // return step(t, random(100.0 + p*0.0000001)+random(p.x)*0.5 );
}

#define pices 200.0
void main() {

    vec2 st = v_texcoord;
    vec2 grid = vec2(pices*.5, pices);
    st *= grid;

    vec2 ipos = floor(st);  // integer

    vec2 v = vec2( u_time * 0.2 * grid.x); // time
    v *= vec2(-1.,0.0) *  random(1.0+ipos.y);            // direction

    vec3 rgb = vec3(pattern(st, v, 0.5));
    vec2 p = floor(st+v)/pices/2.0;
    rgb = vec3(step(0.2,random(fract(p))));
    //rgb = step(0.5, rgb);
    gl_FragColor = vec4(1.2-rgb,1.0);
}

