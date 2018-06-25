// created by florian berger (flockaroo) - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// single pass CFD
// ---------------
// this is some "computational flockarooid dynamics" ;)
// the self-advection is done purely rotational on all scales. 
// therefore i dont need any divergence-free velocity field. 
// with stochastic sampling i get the proper "mean values" of rotations 
// over time for higher order scales.
//
// try changing "RotNum" for different accuracies of rotation calculation
//
// "angRnd" is the rotational randomness of the rotation-samples
// "posRnd" is an additional error to the position of the samples (not really needed)
// for higher numbers of "RotNum" "angRnd" can also be set to 0

#define RotNum 5
#define angRnd 0.0
#define posRnd 0.0

#define Res  iChannelResolution[0]
#define Res1 iChannelResolution[1]



const float ang = 2.0*3.1415926535/float(RotNum);
mat2 m = mat2(cos(ang),sin(ang),-sin(ang),cos(ang));

float hash(float seed) { return fract(sin(seed)*158.5453 ); }
vec4 getRand4(float seed) { return vec4(hash(seed),hash(seed+123.21),hash(seed+234.32),hash(seed+453.54)); }

vec4 randS(vec2 uv){
    return texture(iChannel1,uv*Res.xy/Res1.xy)-vec4(0.5);
}

float getRot(vec2 uv, float sc) {
    float ang2 = angRnd*randS(uv).x*ang;
    vec2 p = vec2(cos(ang2),sin(ang2));
    float rot=0.0;
    for(int i=0;i<RotNum;i++) {
        vec2 p2 = (p+posRnd*randS(uv+p*sc).xy)*sc;
        vec2 v = texture(iChannel0,fract(uv+p2)).xy-vec2(0.5);
        rot+=cross(vec3(v,0.0),vec3(p2,0.0)).z/dot(p2,p2);
        p = m*p;
    }
    rot/=float(RotNum);
    return rot;
}

void init( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / Res.xy;
    fragColor = texture(iChannel2,uv);
}

#define keyTex iChannel3
#define KEY_I texture(keyTex,vec2((105.5-32.0)/256.0,(0.5+0.0)/3.0)).x

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    
    vec2 uv = fragCoord.xy / Res.xy;
    vec2 scr=uv*2.0-vec2(1.0);
    
    float sc=1.0/max(Res.x,Res.y);
    vec4 btr = butterfly(uv, iTime);
    vec2 v = -vec2(btr.x,btr.y)*10.;
    for(int level=0;level<20;level++) {
        if ( sc > 0.7 ) break;
        float ang2 = angRnd*ang*randS(uv).y;
        vec2 p = vec2(cos(ang2),sin(ang2));
        for(int i=0;i<RotNum;i++) {
            vec2 p2=p*sc;
            float rot=getRot(uv+p2,sc);
            v+=p2.yx*rot*vec2(-1,1);
            p = m*p;
        }
      	sc*=2.0;
    }
    
    v.y+=scr.y*0.1;
    
    fragColor=texture(iChannel0,fract(uv+v*1.0/Res.x));
    vec4 tex = texture(iChannel2, uv);
    float k = 0.0001;
    fragColor= fragColor*(1.0-k)+tex*k;
    fragColor.xy-=btr.xy*0.02;
    //fragColor = btr;
    if(iFrame<=4 || KEY_I>0.5) init(fragColor,fragCoord);
}


