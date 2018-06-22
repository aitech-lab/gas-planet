params =
    background:  false
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

init_gui = ->
    gui = new (dat.GUI)
    gui.add(params, 'background').onChange ->background.visible = params.background
    octaves = (val) -> current_material.uniforms.octaves.value = val
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
