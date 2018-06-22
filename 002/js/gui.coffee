params =
    background:  false

init_gui = ->
    gui = new (dat.GUI)
    gui.add(params, 'background').onChange ->background.visible = params.background
    t = gui.addFolder "Shadow mat"
    #t.add shadows_mat, "color"                # : 0xFFFFFF
    t.add shadows_mat, "metalness", 0.0, 1.0, 0.1  # : 0.0
    t.add shadows_mat, "roughness", 0.0, 1.0, 0.1  # : 1.0
    t.add shadows_mat, "opacity"  , 0.0, 1.0, 0.1  # : 0.61
    t.add shadows_mat, "transparent"          # : true
    t.add shadows_mat, "premultipliedAlpha"   # : true
