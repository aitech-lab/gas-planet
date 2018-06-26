params =
    background:  false
    u_col1: [255*0.50|0, 255*0.00|0, 255*0.00|0]
    u_col2: [255*1.00|0, 255*0.75|0, 255*0.35|0]
    u_col3: [255*0.00|0, 255*0.00|0, 255*0.02|0]
    u_col4: [255*1.0 |0, 255*0.7 |0, 255*0.6 |0]
    u_scale: 4.0
    u_speed: 1.0
    u_fbm1: 0.0
    u_fbm2: 0.5000
    u_fbm3: 2.02
    u_fbm4: 0.2500
    u_fbm5: 2.03
    u_fbm6: 0.1250
    u_fbm7: 2.01
    u_fbm8: 0.0625
    u_fbm9: 0.9375

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
    for c in [1..4]
        gui.addColor(params, "u_col#{c}").onChange u_col("u_col#{c}")


    set_u =(u)-> (v)->material.uniforms[u].value = v
    t = gui.addFolder "FBM"
    for i in [1..9]
        name = "u_fbm#{i}"
        t.add(params, name, -2.0, 2.0, 0.001)
        .onChange set_u name
       
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
    for l, i in [1..3].map ((i)->this["light_#{i}"])
        n = "#{l.type} #{i}"
        t = gui.addFolder n
        t.add l, "intensity", 0.0, 10.0, 0.1
        lights_data[n] = color: l.color.getHex()
        t.addColor(lights_data[n], "color").onChange color_changer l.color
