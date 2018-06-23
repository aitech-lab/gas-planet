params =
    background:  false
    u_col1: [256*0.2 |0, 256*0.1 |0, 256*0.4 |0]
    u_col2: [256*0.3 |0, 256*0.05|0, 256*0.05|0]
    u_col3: [256*0.9 |0, 256*0.9 |0, 256*0.9 |0]
    u_col4: [256*0.5 |0, 256*0.2 |0, 256*0.2 |0]
    u_col5: [256*0.0 |0, 256*0.2 |0, 256*0.4 |0]
    u_col6: [256*0.85|0, 256*0.90|0, 256*0.95|0]
    u_col7: [256*0.15|0, 256*0.10|0, 256*0.05|0]
    u_col8: [256*0.85|0, 256*0.90|0, 256*0.95|0]
    u_col9: [256*0.15|0, 256*0.10|0, 256*0.05|0]
    u_scale: 4.0
    u_speed: 1.0

p2u = (p) ->
    new (THREE.Vector3)(params[p][0] / 255.0, params[p][1] / 255.0, params[p][2] / 255.0)

init_gui = ->
    color_changer = (c)-> (v)->c.set v

    gui = new (dat.GUI)
    gui.add(params, 'background').onChange ->background.visible = params.background

    gui.add(params, 'u_scale', 0.1, 20.0, 0.1).onChange (v)->material.uniforms.u_scale.value = v
    gui.add(params, 'u_speed', 0.1, 20.0, 0.1).onChange (v)->material.uniforms.u_speed.value = v

    u_col = (name)->
        (val)-> material.uniforms[name].value = p2u(name)
    for c in [1..9]
        gui.addColor(params, "u_col#{c}").onChange u_col("u_col#{c}")
    
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
