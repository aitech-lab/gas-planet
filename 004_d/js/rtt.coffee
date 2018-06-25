frag_fluid = """
uniform sampler2D bufA; // backbuff
uniform sampler2D bufB; // velocity
uniform sampler2D bufC; // texture
uniform float time;

uniform float u_noise;
uniform float u_noise_frq;
uniform float u_noise_dns;
uniform float u_flow_spd;
uniform float u_sharp;

varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

vec4 sharp(in sampler2D txt, in vec2 pos) {
    float d = 1.0/1024.0;
    vec4 sum = texture2D(txt, pos+vec2(-d, -d)) * -1.
             + texture2D(txt, pos+vec2(-d,  0)) * -1.
             + texture2D(txt, pos+vec2(-d,  d)) * -1.
             + texture2D(txt, pos+vec2( 0, -d)) * -1.
             + texture2D(txt, pos+vec2( 0,  0)) *  8.
             + texture2D(txt, pos+vec2( 0,  d)) * -1.
             + texture2D(txt, pos+vec2( d, -d)) * -1.
             + texture2D(txt, pos+vec2( d,  0)) * -1.
             + texture2D(txt, pos+vec2( d,  d)) * -1.; 
    return sum;
}

void main() {

    vec4 c = texture2D(bufC, vUv);

    vec2 uv = vUv;
    for(int i=0; i<20; i++) {
        vec4 b = texture2D(bufB, uv);
        float m = .00001*u_flow_spd;
        b*=(b-0.5)*m;
        vec2 vel = b.gr*vec2(-1.0, 1.0);
        uv+= vel;
    }
    vec4 a = texture2D(bufA, uv);
    vec4 d = sharp(bufA, uv);
    float i = floor(time);
    float f = fract(time);
    float n = rand(vUv*1024.0)+time/u_noise_frq;
    n = fract(n)*2.0-1.0;
    n = abs(n)*2.0-1.0;
    float s = sign(n);
    n = pow(n, u_noise_dns);
    gl_FragColor = mix(a+d*u_sharp, c-s*n*u_noise, n);
}
"""

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
        void main() {
            gl_FragColor = texture2D(texture, vUv)*vNormal.z*vNormal.z;
            gl_FragColor.a = 1.0;
        }"""
        
    constructor: ->

        @resolution = 1024;
        @iteration  = 0

        @camera = new THREE.OrthographicCamera(
            -0.5, 0.5, 0.5,-0.5,
            -10000, 10000)
            
        @camera.position.z = 100
        @scene = new THREE.Scene

        @textureA = new THREE.WebGLRenderTarget(@resolution, @resolution,
            minFilter: THREE.LinearFilter
            magFilter: THREE.LinearFilter
            format: THREE.RGBAFormat)

        @textureB = new THREE.WebGLRenderTarget(@resolution, @resolution,
            minFilter: THREE.LinearFilter
            magFilter: THREE.LinearFilter
            format: THREE.RGBAFormat)

        @bufB = new THREE.TextureLoader().load("textures/jupiter_1024_n.png")
        @bufB.wrapS = @bufB.wrapT = THREE.RepeatWrapping
        @bufC = new THREE.TextureLoader().load("textures/jupiter_1024.png")
        @bufC.wrapS = @bufC.wrapT = THREE.RepeatWrapping
        
        @mat = new THREE.ShaderMaterial
            uniforms:
                bufA: type: 't',value: @textureA.texture
                bufB: type: 't',value: @bufB
                bufC: type: 't',value: @bufC
                time: type: 'f',value: 0.0
                u_noise:     type: 'f', value:  0.15
                u_noise_frq: type: 'f', value:  5.00
                u_noise_dns: type: 'f', value:  7.00
                u_flow_spd:  type: 'f', value: 10.00
                u_sharp:     type: 'f', value:  0.005
            vertexShader  : RTT.vert
            fragmentShader: RTT.frag
            depthWrite    : false

        @mat_screen = new THREE.ShaderMaterial
            uniforms:
                texture:
                    type : "t"
                    value: @textureA.texture
            vertexShader  : RTT.vert
            fragmentShader: RTT.frag_screen

        @plane = new THREE.PlaneBufferGeometry 1.0, 1.0
        @quad  = new THREE.Mesh @plane, @mat
        
        @quad.position.z = -100
        @scene.add @quad        
        
    render:(renderer) =>
        @mat.uniforms.time.value += 0.1
       
        if @iteration%2 is 0
            @mat.uniforms.bufA.value = @textureB.texture
            renderer.render @scene, @camera, @textureA, true
        else
            @mat.uniforms.bufA.value = @textureA.texture
            renderer.render @scene, @camera, @textureB, true
        @iteration++
