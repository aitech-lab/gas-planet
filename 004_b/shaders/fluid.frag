uniform sampler2D bufA; // backbuff
uniform sampler2D bufB; // velocity
uniform sampler2D bufC; // texture
uniform float time;

varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

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

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float rand2(vec2 n, float k) {
    return step(rand(n), k);
}

float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}
vec3 overlay(vec3 c1, vec3 c2) {
    return mix(1.0 - 2.0 * (1.0 - c1) * (1.0 - c2), 2.0 * c1 * c2, step(c1, vec3(0.5)));
}

vec4 sharp(in sampler2D txt, in vec2 pos) {
    vec4 sum = texture2D(txt, pos+vec2(-1, -1)) * -1.
             + texture2D(txt, pos+vec2(-1,  0)) * -1.
             + texture2D(txt, pos+vec2(-1,  1)) * -1.
             + texture2D(txt, pos+vec2( 0, -1)) * -1.
             + texture2D(txt, pos+vec2( 0,  0)) *  9.
             + texture2D(txt, pos+vec2( 0,  1)) * -1.
             + texture2D(txt, pos+vec2( 1, -1)) * -1.
             + texture2D(txt, pos+vec2( 1,  0)) * -1.
             + texture2D(txt, pos+vec2( 1,  1)) * -1.; 
    return sum;
}

vec4 sharpv(in sampler2D txt, in vec2 pos, vec2 vel) {
    vec4 sum = 
               texture2D(txt, pos                  ) *  1.
             //+ texture2D(txt, pos+vel.xy           ) *  1.
             //+ texture2D(txt, pos-vel.xy           ) *  1.
             //+ texture2D(txt, pos+vel.yx*vec2(-1,1)) * -1.
             //+ texture2D(txt, pos-vel.yx*vec2(-1,1)) * -1.
             ;
    return sum;
}

void main() {

    vec4 c = sharp(bufC, vUv); // original texture
    vec2 uv = vUv;
    vec4 b; // velocity texture
    vec4 a; //  = texture2D(bufA, uv);
    vec2 vel;
    for(int i=0; i<20; i++) {
        b = texture2D(bufB, uv); // velocity texture
        vel = (b.gr-0.5)*vec2(-1.0, 1.0)/10000.0;
        uv += vel;
    }
    a = sharp(bufA, uv);
    a = mix(texture2D(bufA, uv),a,0.001);
    vec4 n = normalize(b*2.0-1.0);
    vec4 l = normalize(vec4(1.0, -1.0, 1.0,0.0));
    float  bump = dot(n, l);
    c = c-bump/3.0;

    // a = mix(a, s, 0.001); 
    a*= 0.99;
    float i = floor(time*1.0);
    float f = fract(time*1.0);
    float k = mix(rand2(vUv+i, 0.2), rand2(vUv+i+1.0, 0.2), smoothstep(0.0, 1.0, f));
    float noise =(rand(vUv*1000.0+time)-rand(vUv*1000.0+time+1.0))*0.05;

    gl_FragColor = mix(a,c,k)+ noise; // mix(a,c+noise,k);
}

