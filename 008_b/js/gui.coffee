params =
    background:  false
    u_col1: [255*0.2 |0, 255*0.1  |0, 255*0.4 |0]
    u_col2: [255*0.3 |0, 255*0.05 |0, 255*0.05|0]
    u_col3: [255*0.9 |0, 255*0.9  |0, 255*0.9 |0]
    u_col4: [255*0.4 |0, 255*0.3  |0, 255*0.3 |0]
    u_col5: [255*0.0 |0, 255*0.2  |0, 255*0.4 |0]
    u_col6: [255*0.70|0, 255*0.90 |0, 255*0.95|0]
    u_col7: [255*0.15|0, 255*0.10 |0, 255*0.05|0]
    u_scale: 2.0
    u_speed: 2.0

    u_fbm4_1: 0.500000
    u_fbm4_2: 0.250000
    u_fbm4_3: 0.125000
    u_fbm4_4: 0.062500

    u_fbm6_1: 0.500000
    u_fbm6_2: 0.250000
    u_fbm6_3: 0.125000
    u_fbm6_4: 0.062500
    u_fbm6_5: 0.031250
    u_fbm6_6: 0.015625


p2u = (p) ->
    new (THREE.Vector3)(params[p][0] / 255.0, params[p][1] / 255.0, params[p][2] / 255.0)

init_gui = ->
    color_changer = (c)-> (v)->c.set v

    gui = new (dat.GUI)
    gui.add(params, 'background').onChange ->background.visible = params.background

    gui.add(params, 'u_scale', 0.1, 5.0, 0.1).onChange (v)->material.uniforms.u_scale.value = v
    gui.add(params, 'u_speed',-5.0, 5.0, 0.1).onChange (v)->material.uniforms.u_speed.value = v

    u_col = (name)->
        (val)->
            material.uniforms[name].value = p2u(name)
    for c in [1..7]
        gui.addColor(params, "u_col#{c}").onChange u_col("u_col#{c}")

    
    t = gui.addFolder "FBM4"
    t.add(params, 'u_fbm4_1',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm4_1.value = v
    t.add(params, 'u_fbm4_2',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm4_2.value = v
    t.add(params, 'u_fbm4_3',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm4_3.value = v
    t.add(params, 'u_fbm4_4',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm4_4.value = v

    t = gui.addFolder "FBM6"
    t.add(params, 'u_fbm6_1',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm6_1.value = v
    t.add(params, 'u_fbm6_2',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm6_2.value = v
    t.add(params, 'u_fbm6_3',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm6_3.value = v
    t.add(params, 'u_fbm6_4',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm6_4.value = v
    t.add(params, 'u_fbm6_5',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm6_5.value = v
    t.add(params, 'u_fbm6_6',-1.0, 1.0, 0.0001).onChange (v)->material.uniforms.u_fbm6_6.value = v
   
    t = gui.addFolder "Shadow mat"
    shadows_mat_data = color: shadows_mat.color.getHex()
    t.addColor(shadows_mat_data, "color").onChange color_changer shadows_mat.color
    t.add shadows_mat, "metalness", 0.0, 1.0, 0.1  # : 0.0
    t.add shadows_mat, "roughness", 0.0, 1.0, 0.1  # : 1.0
    t.add shadows_mat, "opacity"  , 0.0, 1.0, 0.1  # : 0.61
    t.add shadows_mat, "transparent"          # : true
    t.add shadows_mat, "premultipliedAlpha"   # : true

    t = gui.addFolder "Light mat"
    light_mat_data = color: light_mat.color.getHex()
    t.addColor(light_mat_data, "color").onChange color_changer light_mat.color
    t.add light_mat, "metalness", 0.0, 1.0, 0.1  # : 0.0
    t.add light_mat, "roughness", 0.0, 1.0, 0.1  # : 1.0
    t.add light_mat, "opacity"  , 0.0, 1.0, 0.1  # : 0.61
    t.add light_mat, "transparent"          # : true
    t.add light_mat, "premultipliedAlpha"   # : true

    lights_data = {}
    for l, i in [1..3].map (i)->this["light_#{i}"]
        n = "#{l.type} #{i}"
        t = gui.addFolder n
        t.add l, "intensity", 0.0, 10.0, 0.1
        lights_data[n] = color: l.color.getHex()
        t.addColor(lights_data[n], "color").onChange color_changer l.color
