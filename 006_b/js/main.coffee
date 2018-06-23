container         = undefined
stats             = undefined
camera            = undefined
scene             = undefined
renderer          = undefined
clock             = undefined
planet            = undefined
background        = undefined
rtt               = undefined
material          = undefined
shadows_mat       = undefined
light_mat         = undefined
light_1           = undefined
light_2           = undefined
light_3           = undefined

planet_radius     = 1.2
planet_details    = 50
planet_resolution = 256
pr_w              = planet_resolution
pr_h              = planet_resolution
cvs               = undefined
ctx               = undefined
velocities        = undefined
materials         = []
materials_cnt     = 8
current_material  = undefined
time              = value: 1.0
seed = 1
     
init_materilas = (vert, frag)->

animate = ->
    requestAnimationFrame animate
    render()
    stats.update()


render = ->
    delta = clock.getDelta()
    material.uniforms.u_time.value = clock.elapsedTime
    # renderer.setPixelRatio( 1 );
    # renderer.setSize( 256,256 );
    # renderer.autoClear = false;
    # renderer.render rtt.scene, rtt.camera, rtt.texture
    # rtt.render(renderer)

    # if planet?
    #     planet.rotation.y += delta * 0.25
        
    # renderer.setPixelRatio( window.devicePixelRatio );
    # renderer.setSize( window.innerWidth, window.innerHeight );
    # renderer.autoClear = false;
    renderer.render scene, camera

init_renderers = ->
    
    renderer = new THREE.WebGLRenderer
        alpha    : true
        autoClear: false

    renderer.setPixelRatio window.devicePixelRatio

    # rtt = new RTT

    container = document.getElementById 'container'
    container.appendChild renderer.domElement

init_scene = ->
    
    camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 3000)
    camera.position.z = 4
    
    scene = new THREE.Scene
    clock = new THREE.Clock
    noise = new THREE.TextureLoader().load('textures/noise_256.png')
    noise.wrapS = noise.wrapT = THREE.RepeatWrapping
    uniforms =
        u_bufA:  type: 't' , value: noise 
        u_time:  type: 'f' , value: 0.0
        u_scale: type: 'f' , value: 4.0
        u_speed: type: 'f' , value: 1.0
    for c in [1..9]
        uniforms["u_col#{c}"] = type: 'v3', value: p2u("u_col#{c}")

    material = new THREE.ShaderMaterial
        uniforms: uniforms
        vertexShader:   vert_simple
        fragmentShader: frag_fbm_01
        extensions: 
            shaderTextureLOD: true  # set to use shader texture LOD
 
    g = new THREE.PlaneBufferGeometry 5, 2.5, 10
    background = new THREE.Mesh g, material
    background.visible = params.background
    scene.add background
        
    g = new THREE.SphereBufferGeometry(planet_radius, planet_details, planet_details)
    planet = new THREE.Mesh g, material
    planet.rotation.x = 3.141 / 8.0
    scene.add planet

    g = new THREE.SphereBufferGeometry(planet_radius*1.001, planet_details, planet_details)
    shadows_mat = new THREE.MeshPhysicalMaterial
        map: null
        color: 0xFFFFFF
        metalness: 0.0
        roughness: 1.0
        opacity:   1.0
        side: THREE.FrontSide
        transparent: true
        premultipliedAlpha: true
        depthTest: false
        blending: THREE.MultiplyBlending
    shadows = new THREE.Mesh g, shadows_mat
    scene.add shadows
    
    light_mat = new THREE.MeshPhysicalMaterial
        color: 0x202020
        metalness: 0.5
        roughness: 0.6
        opacity:   0.5
        side: THREE.FrontSide
        transparent: true
        premultipliedAlpha: true
        depthTest: false
        blending: THREE.AdditiveBlending
    light = new THREE.Mesh g, light_mat
    scene.add light
    
    light_1 = new THREE.PointLight 0xffffD0, 2
    light_1.position.set(-50, 50, 50)
    scene.add light_1

    light_2 = new THREE.PointLight 0x404080, 2
    light_2.position.set(50, -50, -50)
    scene.add light_2
    
    light_3 = new THREE.PointLight 0x808040, 0.5
    light_3.position.set(0, -100, 0)
    scene.add light_3

init = ->

    console.log "Init"

    if !Detector.webgl
        Detector.addGetWebGLMessage()
    
    init_renderers()
    init_scene()

    stats = new Stats
    container.appendChild stats.dom
    onWindowResize()
