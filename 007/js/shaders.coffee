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

# ../shaders/fbm_02.frag
frag_fbm_02= """
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

varying vec2 vUv;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_scale;
uniform float u_speed;

uniform vec3 u_col1;
uniform vec3 u_col2;
uniform vec3 u_col3;
uniform vec3 u_col4;

const mat2 m = mat2( 0.80,  0.60, -0.60,  0.80 );

float hash( vec2 p )
{
	float h = dot(p,vec2(127.1,311.7));
    return -1.0 + 2.0*fract(sin(h)*43758.5453123);
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

float fbm( vec2 p )
{
    float f = 0.0;
    f += 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f/0.9375;
}

vec2 fbm2( in vec2 p )
{
    return vec2( fbm(p.xy), fbm(p.yx) );
}

vec3 map( vec2 p )
{   
    p *= 0.7;

    float f = dot( fbm2( 1.0*(0.05*u_time*u_speed + p + fbm2(-0.05*u_time*u_speed+2.0*(p + fbm2(4.0*p)))) ), vec2(1.0,-1.0) );

    float bl = smoothstep( -0.8, 0.8, f );

    float ti = smoothstep( -1.0, 1.0, fbm(p) );

    return mix( mix( u_col1, 
                     u_col2, ti ), 
                     u_col3, bl );
}

void main() {

    vec2 p = vUv*2.0 - vec2(1.0);
    p*=u_scale;
    p.x-=u_time*0.05;
    float e = 0.0045;

    vec3 colc = map( p               ); float gc = dot(colc,vec3(0.333));
    vec3 cola = map( p + vec2(e,0.0) ); float ga = dot(cola,vec3(0.333));
    vec3 colb = map( p + vec2(0.0,e) ); float gb = dot(colb,vec3(0.333));
    
    vec3 nor = normalize( vec3(ga-gc, e, gb-gc ) );

    vec3 col = colc;
    col += u_col4*8.0*abs(2.0*gc-ga-gb);
    col *= 1.0+0.2*nor.y*nor.y;
    col += 0.05*nor.y*nor.y*nor.y;
    
    
    vec2 q = vUv;
    col *= pow(16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.1);
    
    gl_FragColor = vec4( col, 1.0 );
}
"""

