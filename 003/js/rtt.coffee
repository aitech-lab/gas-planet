redefines = """
#define iChannel0 bufA
#define iChannel1 bufB
#define iChannel2 bufC
#define texture texture2D

#define Res  vec3(512.0)
#define Res1 vec3(512.0)

uniform sampler2D bufA;
uniform sampler2D bufB;
uniform sampler2D bufC;
uniform float time;

"""

frag_fluid = """

#{redefines}

#define RotNum 3
#define angRnd 1.0
#define posRnd 0.0

const float ang = 2.0*3.1415926535/float(RotNum);
mat2 m = mat2(cos(ang),sin(ang),-sin(ang),cos(ang));

float hash(float seed) { return fract(sin(seed)*158.5453 ); }
vec4 getRand4(float seed) { return vec4(hash(seed),hash(seed+123.21),hash(seed+234.32),hash(seed+453.54)); }
vec4 randS(vec2 uv) {
    //return getRand4(uv.y+uv.x*1234.567)-vec4(0.5);
    return texture(iChannel1,uv*Res.xy/Res1.xy)-vec4(0.5);
}

float getRot(vec2 uv, float sc)
{
    float ang2 = angRnd*randS(uv).x*ang;
    vec2 p = vec2(cos(ang2),sin(ang2));
    float rot=0.0;
    for(int i=0;i<RotNum;i++)
    {
        vec2 p2 = (p+posRnd*randS(uv+p*sc).xy)*sc;
        vec2 v = texture(iChannel0,fract(uv+p2)).xy-vec2(0.5);
        rot+=cross(vec3(v,0.0),vec3(p2,0.0)).z/dot(p2,p2);
        p = m*p;
    }
    rot/=float(RotNum);
    return rot;
}

void init( out vec4 fragColor, in vec4 fragCoord ) {
    vec2 uv = fragCoord.xy / Res.xy;
    fragColor = texture(iChannel2,uv);
}

void main() {
    vec2 uv = gl_FragCoord.xy / Res.xy;
    vec2 scr=uv*2.0-vec2(1.0);
    
    float sc=1.0/max(Res.x,Res.y);
    vec2 v=vec2(0);
    for(int level=0;level<20;level++)
    {
        if ( sc > 0.7 ) break;
        float ang2 = angRnd*ang*randS(uv).y;
        vec2 p = vec2(cos(ang2),sin(ang2));
        for(int i=0;i<RotNum;i++)
        {
            vec2 p2=p*sc;
            float rot=getRot(uv+p2,sc);
            //v+=cross(vec3(0,0,rot),vec3(p2,0.0)).xy;
            v+=p2.yx*rot*vec2(-1,1); //maybe faster than above
            p = m*p;
        }
          sc*=2.0;
    }
       
    gl_FragColor=texture(iChannel0, fract(uv+v*3.0/Res.x));
    
    // add a little "motor" in the center
    gl_FragColor.xy += (0.01*scr.xy / (dot(scr,scr)/0.1+0.3));
    
    if(time<=1.0) init(gl_FragColor, gl_FragCoord);
}
"""

noise_frag = """
float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
        mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
        mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
    return res*res;
}"""

class RTT

    @vert: """
        varying vec2 vUv;
        varying vec3 vPos;
        varying vec3 vNormal;
        void main() {
            vUv = uv;
            vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
            gl_Position = projectionMatrix * mvPosition; 
        	gl_Position     = projectionMatrix * mvPosition;
        	vPos            = vec3(mvPosition)/mvPosition.w;
        	vNormal         = vec3(normalMatrix * normal);
        }"""
        
    @frag: frag_fluid

    @frag_screen: """
        varying vec2 vUv;
        varying vec3 vPos;
        varying vec3 vNormal;
        uniform sampler2D texture;
        uniform sampler2D palette;
        void main() {
            vec4 col = texture2D(texture, vUv);
            gl_FragColor = texture2D(palette, col.rg*4.0)*vNormal.z*vNormal.z;
            
            gl_FragColor.a = 1.0;
        }"""
        
    constructor: ->

        @resolution = 512;
        @iteration  = 0

        @camera = new THREE.OrthographicCamera(
            -0.5, 0.5, 0.5,-0.5,
            -10000, 10000)
            
        @camera.position.z = 100
        @scene = new THREE.Scene

        @textureA = new THREE.WebGLRenderTarget(@resolution, @resolution,
            minFilter: THREE.LinearFilter
            magFilter: THREE.NearestFilter
            format: THREE.RGBAFormat)

        @textureB = new THREE.WebGLRenderTarget(@resolution, @resolution,
            minFilter: THREE.LinearFilter
            magFilter: THREE.NearestFilter
            format: THREE.RGBAFormat)

        noise = new THREE.TextureLoader().load("palettes/jupiter_512.jpg")
        noise.wrapS = noise.wrapT = THREE.RepeatWrapping
        
        @palettes = []
        for p in [1..8]
            palette = new THREE.TextureLoader().load("palettes/pal_0#{p}.png")
            palette.wrapS = palette.wrapT = THREE.RepeatWrapping
            @palettes.push palette
            
        @mat = new THREE.ShaderMaterial
            uniforms:
                bufA: type: 't',value: @textureA.texture
                bufB: type: 't',value: noise
                bufC: type: 't',value: noise
                time: type: 'f',value: 0.0
            vertexShader  : RTT.vert
            fragmentShader: RTT.frag
            depthWrite    : false

        @mat_screen = new THREE.ShaderMaterial
            uniforms:
                texture:
                    type : "t"
                    value: @textureA.texture
                palette:
                    type : "t"
                    value: @palettes[0]
                    
            vertexShader  : RTT.vert
            fragmentShader: RTT.frag_screen

        @plane = new THREE.PlaneBufferGeometry 1.0, 1.0
        @quad  = new THREE.Mesh @plane, @mat
        
        @quad.position.z = -100
        @scene.add @quad
        
        # g = new THREE.SphereBufferGeometry 0.1
        # s = new THREE.Mesh g, new THREE.MeshBasicMaterial({color: 0x808080})
        # @scene.add s
        
        # @renderer = new THREE.WebGLRenderer
        # @renderer.setSize(@resolution, @resolution);
        # @renderer.setPixelRatio 1.0
        # @renderer.autoClear = false
        
    render:(renderer) =>
        @mat.uniforms.time.value += 0.1
       
        if @iteration%2 is 0
            @mat.uniforms.bufA.value = @textureB.texture
            renderer.render @scene, @camera, @textureA, true
        else
            @mat.uniforms.bufA.value = @textureA.texture
            renderer.render @scene, @camera, @textureB, true
        @iteration++
    set_palette: (p)=> @mat_screen.uniforms.palette.value = @palettes[p]
