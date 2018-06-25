# Градиент скоростей
init_planet_texture = ->
    cvs = document.createElement('canvas')
    cvs.id = 'planet_texture'
    ctx = cvs.getContext('2d')
    cvs.width = ctx.width = pr_w
    cvs.height = ctx.height = pr_h
    # document.body.prepend(cvs);

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


