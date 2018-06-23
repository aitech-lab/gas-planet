uniform sampler2D bufA; // backbuff
uniform sampler2D bufB; // velocity
uniform sampler2D bufC; // textture
uniform float time;

varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float rand2(vec2 n) {
    return 1.0-step(rand(n),0.9);
}

float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}
vec3 overlay(vec3 c1, vec3 c2) {
    return mix(1.0 - 2.0 * (1.0 - c1) * (1.0 - c2), 2.0 * c1 * c2, step(c1, vec3(0.5)));
}

void main() {

    vec4 c = texture2D(bufC, vUv);
    vec4 b = texture2D(bufB, vUv);
    float m = .001;
    b-=0.5;
    b*=m;
    vec2 vel = b.gr*vec2(-1.0, 1.0);

    //vec4 a = texture2D(bufA, vUv);
    //for(float i=-2.0; i<2.0;i+=0.2) a += (texture2D(bufA, vUv+vel*i)-a)/2.0;
    vec4 a = texture2D(bufA, vUv+vel);
    //vec4 a = vec4(overlay(a1.rgb,a2.rgb),1.0);
    float i = floor(time*0.1);
    float f = fract(time*0.1);
    float k = mix(rand2(vUv+i), rand2(vUv+i+1.0), smoothstep(0.0, 1.0, f));
    float noise =(rand(vUv+time)-rand(vUv+time+1.0))*0.05;
    // a*=0.999;
    gl_FragColor = a*(1.0-k)+c*k+noise;
    
    // gl_FragColor = c;
    // gl_FragColor = vec4(k);
    // if(time <0.5) {
    //     gl_FragColor = vec4(c.rgb, 1.0);
    // }
}

