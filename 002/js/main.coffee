container         = undefined
stats             = undefined
camera            = undefined
scene             = undefined
renderer          = undefined
clock             = undefined
planet            = undefined
background        = undefined
rtt               = undefined
shadows_mat       = undefined
light_1           = undefined
light_2           = undefined
light_3           = undefined

planet_radius     = 0.8
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
    console.log "Init materials"
    for i in [1..materials_cnt]
        texture = value: new THREE.TextureLoader().load("palettes/pal_0#{i}.png")
        texture.value.wrapS = texture.value.wrapT = THREE.RepeatWrapping
        # Переменные шейдера
        uniforms = 
            id: value: 1.0
            octaves:    type: 'i',  value: params.octaves
            equator:    type: 'f',  value: params.equator
            turbulence: type: 'f',  value: params.turbulence
            contrast:   type: 'f',  value: params.contrast
            brightness: type: 'f',  value: params.brightness
            cnt_width:  type: 'f',  value: params.cnt_width
            cnt_alpha:  type: 'f',  value: params.cnt_alpha
            cnt_col1:   type: 'v3', value: p2u('cnt_col1')
            cnt_col2:   type: 'v3', value: p2u('cnt_col2')
            cnt_col3:   type: 'v3', value: p2u('cnt_col3')
            spec_col:   type: 'v3', value: p2u('spec_col')
            amb_col:    type: 'v3', value: p2u('amb_col' )
            time:       time
            texture:    texture
            velocities: velocities
            
        material = new THREE.ShaderMaterial
            uniforms: uniforms
            vertexShader:   vert
            fragmentShader: frag
        materials.push material

    current_material = materials[0]

animate = ->
    requestAnimationFrame animate
    render()
    stats.update()


render = ->
    delta = clock.getDelta()
    time.value = clock.elapsedTime

    # renderer.setPixelRatio( 1 );
    # renderer.setSize( 256,256 );
    # renderer.autoClear = false;
    # renderer.render rtt.scene, rtt.camera, rtt.texture
    rtt.render(renderer)

    if planet?
        planet.rotation.y += delta * 0.25
        
    renderer.setPixelRatio( window.devicePixelRatio );
    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.autoClear = false;
    renderer.render scene, camera

init_renderers = ->
    
    renderer = new THREE.WebGLRenderer
    renderer.setPixelRatio window.devicePixelRatio

    rtt = new RTT

    container = document.getElementById 'container'
    container.appendChild renderer.domElement

init_scene = ->
    
    camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 3000)
    camera.position.z = 4
    
    scene = new THREE.Scene
    clock = new THREE.Clock

    g = new THREE.PlaneBufferGeometry 5, 2.5, 10
    background = new THREE.Mesh g, rtt.mat_screen
    background.visible = params.background
    scene.add background

        
    g = new THREE.SphereBufferGeometry(planet_radius, planet_details, planet_details)
    planet = new THREE.Mesh g, rtt.mat_screen
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
    
    # init_planet_texture()
    # generate_planet_texture()
    # velocities = type: 't', value: new THREE.Texture(cvs)
    # velocities.value.wrapS = velocities.value.wrapT = THREE.RepeatWrapping
    # velocities.value.needsUpdate = true

    init_renderers()
    init_scene()


    
    #    shader_load "planet"
    #    .then (shaders)->
    #
    #        init_materilas shaders[0], shaders[1]
    #
    #        g = new THREE.SphereBufferGeometry(planet_radius, planet_details, planet_details)
    #        planet = new THREE.Mesh g, current_material
    #        planet.rotation.x = 3.141 / 8.0
    #        scene.add planet
    #
    #        g = new THREE.PlaneBufferGeometry(5,2.5,10)
    #        background = new THREE.Mesh g, current_material
    #        scene.add background


    stats = new Stats
    container.appendChild stats.dom
    onWindowResize()
