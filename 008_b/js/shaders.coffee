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

# ../shaders/fbm_03.frag
frag_fbm_03= """
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// See here for a tutorial on how to make this: http://www.iquilezles.org/www/articles/warp/warp.htm

varying vec2 vUv;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_scale;
uniform float u_speed;

uniform vec3 u_col1;
uniform vec3 u_col2;
uniform vec3 u_col3;
uniform vec3 u_col4;
uniform vec3 u_col5;
uniform vec3 u_col6;
uniform vec3 u_col7;

uniform float u_fbm4_1; // 0.500000
uniform float u_fbm4_2; // 0.250000
uniform float u_fbm4_3; // 0.125000
uniform float u_fbm4_4; // 0.062500

uniform float u_fbm6_1; // 0.500000
uniform float u_fbm6_2; // 0.250000
uniform float u_fbm6_3; // 0.125000
uniform float u_fbm6_4; // 0.062500
uniform float u_fbm6_5; // 0.031250
uniform float u_fbm6_6; // 0.015625

const mat2 m = mat2( 0.80,  0.60, -0.60,  0.80 );

float noise( in vec2 x ) {
	return sin(1.5*x.x)*sin(1.5*x.y);
}

float fbm4( vec2 p ) {
    float f = 0.0;
    f += u_fbm4_1*noise( p ); p = m*p*2.02;
    f += u_fbm4_2*noise( p ); p = m*p*2.03;
    f += u_fbm4_3*noise( p+u_time*u_speed ); p = m*p*2.01;
    f += u_fbm4_4*noise( p+u_time*u_speed );
    return f/0.9375;
}

float fbm6( vec2 p ) {
    float f = 0.0;
    f += u_fbm6_1*(0.5+0.5*noise( p )); p = m*p*2.02;
    f += u_fbm6_2*(0.5+0.5*noise( p )); p = m*p*2.03;
    f += u_fbm6_3*(0.5+0.5*noise( p )); p = m*p*2.01;
    f += u_fbm6_4*(0.5+0.5*noise( p )); p = m*p*2.04;
    f += u_fbm6_5*(0.5+0.5*noise( p+u_time*u_speed )); p = m*p*2.01;
    f += u_fbm6_6*(0.5+0.5*noise( p+u_time*u_speed ));
    return f/0.96875;
}

float func( vec2 q, out vec4 ron ) {
    float ql = length( q );
    q.x += 0.05*sin(0.27+ql*4.1)+u_time*0.1;
    q.y += 0.05*sin(0.23+ql*4.3);
    q *= 0.5;

	vec2 o = vec2(0.0);
    o.x = 0.5 + 0.5*fbm4( vec2(2.0*q          )  );
    o.y = 0.5 + 0.5*fbm4( vec2(2.0*q+vec2(5.2))  );

	float ol = length( o );
    o.x += 0.02*sin(0.12+ol)/ol;
    o.y += 0.02*sin(0.14+ol)/ol;

    vec2 n;
    n.x = fbm6( vec2(4.0*o+vec2(9.2))  );
    n.y = fbm6( vec2(4.0*o+vec2(5.7))  );

    vec2 p = 4.0*q + 4.0*n;

    float f = 0.5 + 0.5*fbm4( p );

    f = mix( f, f*f*f*3.5, f*abs(n.x) );

    float g = 0.5 + 0.5*sin(4.0*p.x)*sin(4.0*p.y);
    f *= 1.0-0.5*pow( g, 8.0 );

	ron = vec4( o, n );
	
    return f;
}



vec3 doMagic(vec2 p) {

    vec2 resolution = vec2(512);
	vec2 q = p*0.6;

    vec4 on = vec4(0.0);
    float f = func(q, on);

	vec3 col = vec3(0.0);
    col = mix( u_col1, u_col2, f );
    col = mix( col, u_col3, dot(on.zw,on.zw) );
    col = mix( col, u_col4, 0.5*on.y*on.y );
    col = mix( col, u_col5, 0.5*smoothstep(1.2,1.3,abs(on.z)+abs(on.w)) );
    col = clamp( col*f*2.0, 0.0, 1.0 );
    
	vec3 nor = normalize( vec3( dFdx(f)*resolution.x, 6.0, dFdy(f)*resolution.y ) );

    vec3 lig = normalize( vec3( 0.9, -0.2, -0.4 ) );
    float dif = clamp( 0.3+0.7*dot( nor, lig ), 0.0, 1.0 );
    vec3 bdrf;
    bdrf  = u_col6*(nor.y*0.5+0.5);
    bdrf += u_col7*dif;
    col *= 1.2*bdrf;
	col = 1.0-col;
	return 1.1*col*col;
}

void main() {

    vec2 q = vUv*u_scale;
    q*=2.0;
    vec2 p = -1.0 + 2.0 * q;

    gl_FragColor = vec4( doMagic( p ), 1.0 );
}
"""

