container         = undefined
stats             = undefined
camera            = undefined
scene             = undefined
renderer          = undefined
clock             = undefined
planet            = undefined
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
params = 
    brightness:  0.0
    octaves:     5
    equator:     2.0
    turbulence:  1.0
    contrast:    1.2
    cnt_width:   1.0
    cnt_alpha:   0.5
    cnt_col1: [ 220, 200, 100 ]
    cnt_col2: [  70,  90, 180 ]
    cnt_col3: [ 250, 250, 180 ]
    spec_col: [ 100,  80,  60 ]
    amb_col:  [  20,  40,  20 ]

rnd = (r) ->
    x = Math.sin(seed++) * 10000
    (x - Math.floor(x)) * r

p2u = (p) ->
    new (THREE.Vector3)(params[p][0] / 255.0, params[p][1] / 255.0, params[p][2] / 255.0)

init_gui = ->

    gui = new (dat.GUI)
    octaves = (val) ->
        current_material.uniforms.octaves.value = val
        return

    gui.add(params, 'octaves', 1, 8, 1).onChange octaves
    equator = (val) -> current_material.uniforms.equator.value = val
    gui.add(params, 'equator', 0.0, 10.0).onChange equator
    turbulence = (val) -> current_material.uniforms.turbulence.value = val
    gui.add(params, 'turbulence', 0.0, 4.0).onChange turbulence
    contrast = (val) -> current_material.uniforms.contrast.value = val
    gui.add(params, 'contrast', 0.1, 2.0).onChange contrast
    brightness = (val) -> current_material.uniforms.brightness.value = val
    gui.add(params, 'brightness', -2.0, 2.0).onChange brightness
    cnt_width = (val) -> current_material.uniforms.cnt_width.value = val
    gui.add(params, 'cnt_width', 0.1, 8.0).onChange cnt_width
    cnt_alpha = (val) -> current_material.uniforms.cnt_alpha.value = val
    gui.add(params, 'cnt_alpha', 0.1, 2.0).onChange cnt_alpha
    cnt_col1 = (val) -> current_material.uniforms.cnt_col1.value = p2u('cnt_col1')
    gui.addColor(params, 'cnt_col1').onChange cnt_col1
    cnt_col2 = (val) -> current_material.uniforms.cnt_col2.value = p2u('cnt_col2')
    gui.addColor(params, 'cnt_col2').onChange cnt_col2
    cnt_col3 = (val) -> current_material.uniforms.cnt_col3.value = p2u('cnt_col3')
    gui.addColor(params, 'cnt_col3').onChange cnt_col3
    spec_col = (val) -> current_material.uniforms.spec_col.value = p2u('spec_col')
    gui.addColor(params, 'spec_col').onChange spec_col
    amb_col = (val) -> current_material.uniforms.amb_col.value = p2u('amb_col')
    gui.addColor(params, 'amb_col').onChange amb_col

text_load = (url) ->
    new Promise (resolve, reject)->
        loader = new THREE.XHRLoader THREE.DefaultLoadingManager
        loader.setResponseType 'text'
        loader.load url, resolve, null, reject

shader_load = (name)->
    console.log "Load shader #{name}"
    Promise.all [text_load("shaders/#{name}.vert"), text_load("shaders/#{name}.frag")]
     
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


onWindowResize = (event)->
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize window.innerWidth, window.innerHeight

# Градиент скоростей

init_planet_texture = ->
    cvs = document.createElement('canvas')
    cvs.id = 'planet_texture'
    ctx = cvs.getContext('2d')
    cvs.width = ctx.width = pr_w
    cvs.height = ctx.height = pr_h
    #document.body.prepend(cvs);

generate_planet_texture = ->

    `var i`
    `var x`
    `var y`
    `var r`
    `var c`

    # Основной фон
    ctx.globalCompositeOperation = 'normal'
    grd = ctx.createLinearGradient(0, 0, 0, pr_h)
    grd.addColorStop 0.0, '#000000'
    grd.addColorStop 0.5, '#202020'
    grd.addColorStop 1.0, '#000000'
    ctx.fillStyle = grd
    ctx.fillRect 0, 0, pr_w, pr_h
    # Пятна
    i = 0
    while i < 100
        x = rnd(pr_w)
        y = pr_h / 2.0 - rnd(pr_h / 3.0) + rnd(pr_h / 3.0)
        r = 5 + rnd(20)
        c = 50
        draw_spot x, y, r, c
        if x + r > pr_w
            draw_spot x - pr_w, y, r, c
        if x - r < 0
            draw_spot x + pr_w, y, r, c
        i++
    i = 0
    while i < 4
        x = rnd(pr_w)
        y = pr_h / 2.0 - rnd(pr_h / 4.0) + rnd(pr_h / 4.0)
        r = 5 + rnd(40)
        c = 255
        draw_spot x, y, r, c
        if x + r > pr_w
            draw_spot x - pr_w, y, r, c
        if x - r < 0
            draw_spot x + pr_w, y, r, c
        i++

draw_spot = (x, y, r, c) ->
    grd = ctx.createRadialGradient(x, y, 0, x, y, r)
    grd.addColorStop 0.0, "rgba(#{c},#{c},#{c},1.0 )"
    grd.addColorStop 0.1, "rgba(#{c},#{c},#{c},0.8 )"
    grd.addColorStop 0.4, "rgba(#{c},#{c},#{c},0.2 )"
    grd.addColorStop 0.6, "rgba(#{c},#{c},#{c},0.01)"
    grd.addColorStop 1.0, "rgba(#{c},#{c},#{c},0.0 )"
    ctx.globalCompositeOperation = 'screen'
    # Fill with gradient
    ctx.fillStyle = grd
    ctx.fillRect 0, 0, pr_w, pr_h


animate = ->
    requestAnimationFrame animate
    render()
    stats.update()


render = ->
    delta = clock.getDelta()
    time.value = clock.elapsedTime
    if planet?
        planet.rotation.y += delta * 0.1
    renderer.render scene, camera


input = (val) ->
    hash = Math.abs(val.hashCode())
    seed = hash
    current_material = materials[hash % materials_cnt]
    current_material.uniforms.id.value = hash
    generate_planet_texture()
    velocities.value.needsUpdate = true
    planet.material = current_material

String::hashCode = ->
    @split('').reduce ((a, b) ->
        a = (a << 5) - a + b.charCodeAt(0)
        a & a
    ), 0

init_scene = ->
    camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 3000)
    camera.position.z = 4
    
    scene    = new THREE.Scene
    clock    = new THREE.Clock

    renderer = new (THREE.WebGLRenderer)
    renderer.setPixelRatio window.devicePixelRatio

    container = document.getElementById 'container'
    container.appendChild renderer.domElement

    stats = new Stats
    container.appendChild stats.dom
    onWindowResize()
    window.addEventListener 'resize', onWindowResize, false

init = ->

    console.log "Init"

    if !Detector.webgl
        Detector.addGetWebGLMessage()
    
    init_planet_texture()
    generate_planet_texture()

    init_scene()
    
    velocities = type: 't', value: new THREE.Texture(cvs)

    velocities.value.wrapS = velocities.value.wrapT = THREE.RepeatWrapping
    velocities.value.needsUpdate = true

    shader_load "planet"
    .then (shaders)->
        init_materilas shaders[0], shaders[1]

        g = new THREE.SphereBufferGeometry(planet_radius, planet_details, planet_details)
        planet = new THREE.Mesh g, current_material
        planet.rotation.x = 3.141 / 8.0
        scene.add planet
        
        g = new THREE.PlaneBufferGeometry(5,2.5,10)
        p = new THREE.Mesh g, current_material

        scene.add p
        

window.addEventListener "load", ->
    init()
    init_gui()
    animate()

