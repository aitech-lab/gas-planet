
class RTT

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
            vertexShader  : vert_simple
            fragmentShader: frag_fluid
            depthWrite    : false
            extensions:
                derivatives: true

        @mat_screen = new THREE.ShaderMaterial
            uniforms:
                texture:
                    type : "t"
                    value: @textureA.texture
            vertexShader  : vert_simple
            fragmentShader: frag_screen

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
