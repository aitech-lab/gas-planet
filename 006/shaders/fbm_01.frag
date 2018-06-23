// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// See http://www.iquilezles.org/www/articles/warp/warp.htm for details

// undefine these on old/slow computers
#define SLOW_NOISE
#define SLOW_NORMAL

varying vec2 vUv;

uniform sampler2D u_bufA;

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
uniform vec3 u_col8;
uniform vec3 u_col9;

vec2 hash2( float n )
{
    return fract(sin(vec2(n,n+1.0))*vec2(13.5453123,31.1459123));
}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
#ifdef SLOW_NOISE
    float a = texture2DLodEXT(u_bufA,(p+vec2(0.5,0.5))/256.0,0.0).x;
	float b = texture2DLodEXT(u_bufA,(p+vec2(1.5,0.5))/256.0,0.0).x;
	float c = texture2DLodEXT(u_bufA,(p+vec2(0.5,1.5))/256.0,0.0).x;
	float d = texture2DLodEXT(u_bufA,(p+vec2(1.5,1.5))/256.0,0.0).x;
    return mix(mix( a, b,f.x), mix( c, d,f.x),f.y);
#else
	return texture2DLodEXT( u_bufA, (p+0.5+f)/256.0, 0. ).x;
#endif    
}

const mat2 mtx = mat2( 0.80,  0.60, -0.60,  0.80 );

float fbm4( vec2 p )
{
    float f = 0.0;

    f += 0.5000*(-1.0+2.0*noise( p )); p = mtx*p*2.02;
    f += 0.2500*(-1.0+2.0*noise( p )); p = mtx*p*2.03;
    f += 0.1250*(-1.0+2.0*noise( p )); p = mtx*p*2.01;
    f += 0.0625*(-1.0+2.0*noise( p ));

    return f/0.9375;
}

float fbm6( vec2 p )
{
    float f = 0.0;

    f += 0.500000*noise( p ); p = mtx*p*2.02;
    f += 0.250000*noise( p ); p = mtx*p*2.03;
    f += 0.125000*noise( p ); p = mtx*p*2.01;
    f += 0.062500*noise( p ); p = mtx*p*2.04;
    f += 0.031250*noise( p ); p = mtx*p*2.01;
    f += 0.015625*noise( p );

    return f/0.96875;
}

float func( vec2 q, out vec2 o, out vec2 n )
{
    float ql = length( q );
    q.x += 0.05*sin(0.11*u_time*u_speed+ql*4.0);
    q.y += 0.05*sin(0.13*u_time*u_speed+ql*4.0);

    q *= 0.7 + 0.2*cos(0.05*u_time);

    q = (q+1.0)*0.5;

    o.x = 0.5 + 0.5*fbm4( vec2(2.0*q*vec2(1.0,1.0)          )  );
    o.y = 0.5 + 0.5*fbm4( vec2(2.0*q*vec2(1.0,1.0)+vec2(5.2))  );

    float ol = length( o );
    o.x += 0.02*sin(0.11*u_time*u_speed*ol)/ol;
    o.y += 0.02*sin(0.13*u_time*u_speed*ol)/ol;


    n.x = fbm6( vec2(4.0*o*vec2(1.0,1.0)+vec2(9.2))  );
    n.y = fbm6( vec2(4.0*o*vec2(1.0,1.0)+vec2(5.7))  );

    vec2 p = 4.0*q + 4.0*n;

    float f = 0.5 + 0.5*fbm4( p );

    f = mix( f, f*f*f*3.5, f*abs(n.x) );

    float g = 0.5+0.5*sin(4.0*p.x)*sin(4.0*p.y);
    f *= 1.0-0.5*pow( g, 8.0 );

    return f;
}

float funcs( in vec2 q )
{
    vec2 t1, t2;
    return func(q,t1,t2);
}


void main() {
    vec2 resolution = vec2(1024.0);
    vec2 of = vec2(0.0);//hash2( float(u_time)*1113.1 + gl_FragCoord.x + gl_FragCoord.y*119.1 );
    
	vec2 p = vUv;// gl_FragCoord / resolution.xy;
	vec2 q = (p*2.0-vec2(1.0))*u_scale;// (-resolution.xy + 2.0*(gl_FragCoord+of)) /resolution.y;
    q.x-=u_time*0.2;	
    vec2 o, n;
    float f = func(q, o, n);
    vec3 col = vec3(0.0);


    col = mix( u_col1, u_col2, f );
    col = mix( col, u_col3, dot(n,n) );
    col = mix( col, u_col4, 0.5*o.y*o.y );

    col = mix( col, u_col5, 0.5*smoothstep(1.2,1.3,abs(n.y)+abs(n.x)) );

    col *= f*2.0;
    
#ifdef SLOW_NORMAL
    vec2 ex = vec2( 1.0 / resolution.x, 0.0 );
    vec2 ey = vec2( 0.0, 1.0 / resolution.y );
	vec3 nor = normalize( vec3( funcs(q+ex) - f, ex.x, funcs(q+ey) - f ) );
#else
    vec3 nor = normalize( vec3( dFdx(f)*resolution.x, 1.7, dFdy(f)*resolution.y ) );	
#endif
    vec3 lig = normalize( vec3( 0.9, -0.2, -0.4 ) );
    float dif = clamp( 0.3+0.7*dot( nor, lig ), 0.0, 1.0 );

    vec3 bdrf;
    bdrf  = u_col6*(nor.y*0.5+0.5);
    bdrf += u_col7*dif;
    bdrf  = u_col8*(nor.y*0.5+0.5);
    bdrf += u_col9*dif;

    col *= bdrf;

    col = vec3(1.0)-col;

    col = col*col;

    col *= vec3(1.2,1.25,1.2);
	
	col *= 0.5 + 0.5 * sqrt(16.0*p.x*p.y*(1.0-p.x)*(1.0-p.y));
	
	gl_FragColor = vec4( col, 1.0 );
}
