params =
    background:  false


init_gui = ->
    color_changer = (c)-> (v)->c.set v

    data =
        palette: 1
    gui = new (dat.GUI)
    gui.add(params, 'background').onChange -> background.visible = params.background
    gui.add(data, "palette", [1..8]).onChange (v)-> rtt.set_palette v
    
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
