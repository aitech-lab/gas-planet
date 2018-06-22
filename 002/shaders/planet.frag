#define PI     3.14159265359
#define TWO_PI 6.28318530718

precision mediump float; 

uniform int   id;
uniform int   octaves;
uniform float time;

uniform float contrast; 
uniform float brightness;
uniform float equator;
uniform float turbulence;

uniform float cnt_width;
uniform float cnt_alpha;

uniform vec3 cnt_col1;
uniform vec3 cnt_col2;
uniform vec3 cnt_col3;
uniform vec3 spec_col;
uniform vec3 amb_col;

uniform sampler2D texture;
uniform sampler2D velocities;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPos;

const vec3 lightPos     = vec3(-100.0, 100.0, 100.0);

const vec3 diffuseColor = vec3(0.3, 0.0, 0.0);

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.54531237);
}

float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3. - 2.0 * f);

    return mix(a, b, u.x) + 
            (c - a)* u.y * (1. - u.x) + 
            (d - b) * u.x * u.y;
}


float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(20.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2( cos(0.5), sin(0.5), 
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < 10; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.2 + shift;
        a *= 0.5;
        if(i>=octaves) break;
    }
    return v;
}


void main( void ) {

    // расчет освещения
    vec3 normal     = normalize(vNormal);
    vec3 lightDir   = normalize(lightPos - vPos);
    vec3 reflectDir = reflect(-lightDir, normal);
    vec3 viewDir    = normalize(-vPos);

    float idf        = 0.5+sin(float(id))/2.0;
    float lambertian = max(dot(lightDir,normal), 0.0);
    float specular = 0.0;

    if(lambertian > 0.0) {
       float specAngle = max(dot(reflectDir, viewDir), 0.0);
       specular = pow(specAngle, 4.0);
    }
    // atmoshpere
    float atm = clamp(pow(1.0-dot(normal,viewDir),0.4*cnt_width)*normal.y*normal.x, 0.0, 1.0);
    vec3 atmosphere = cnt_col1*atm*cnt_alpha;

    atm = clamp(pow(1.0-dot(normal,viewDir),1.0*cnt_width)*(normal.x-normal.y), 0.0, 1.0);
    atmosphere += cnt_col2*atm*cnt_alpha;

    atm = clamp(pow(1.0-dot(normal,viewDir),1.7*cnt_width)*(normal.x+normal.y), 0.0, 1.0);
    atmosphere += cnt_col3*atm*cnt_alpha;

    // turbulences

    float e = sin(vUv.y*PI);
    e = pow(e, equator);
    float vel = texture2D(velocities, vUv).r*turbulence;
    
    vec2 uv = vUv;
    uv.x = 0.5+sin((uv.x-time*0.01+idf)*TWO_PI)/2.0;
    vec2 st = (uv*e +vel*e - 0.5);
    st *= 3.5;
    
    vec3 color = vec3(0.);
    vec2 a = vec2(0.0);
    vec2 b = vec2(0.0);
    vec2 c = vec2(60.,800.);
    
    a.x = fbm( st            );
    a.y = fbm( st + vec2(idf));
    
    b.x = fbm( st + idf*4.0*a);
    b.y = fbm( st       );

    c.x = fbm( st + idf*7.0*b + vec2(10.7, 0.2)+ idf/5.0*time);
    c.y = fbm( st + idf*3.0*b + vec2( 0.3,12.8)+ idf/9.0*time);

    float f = fbm(st*idf*2.0+b+c);

    vec3 rgb1 = texture2D(texture, a.xy*8.0*idf).rgb;
    vec3 rgb2 = texture2D(texture, b.xy*8.0*idf).rgb;
    color = mix(rgb1, rgb2, clamp((f*f), 1.0 - e, 1.0));
    // color = mix(color, vec3(0.413,0.524,0.880), clamp(length(c.x),0.480, 0.92));


    vec3 rgb = vec3(f*2.5*color);
    rgb = amb_col*rgb +
          lambertian*rgb +
          specular*spec_col+
          atmosphere;
    rgb = rgb*contrast-(contrast-1.0)+brightness;
    gl_FragColor = vec4(rgb,1.0);
                        
}
