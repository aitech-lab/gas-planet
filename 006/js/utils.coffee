rnd = (r) ->
    x = Math.sin(seed++) * 10000
    (x - Math.floor(x)) * r

p2u = (p) ->
    new (THREE.Vector3)(params[p][0] / 255.0, params[p][1] / 255.0, params[p][2] / 255.0)

text_load = (url) ->
    new Promise (resolve, reject)->
        loader = new THREE.XHRLoader THREE.DefaultLoadingManager
        loader.setResponseType 'text'
        loader.load url, resolve, null, reject

shader_load = (name)->
    console.log "Load shader #{name}"
    Promise.all [text_load("shaders/#{name}.vert"), text_load("shaders/#{name}.frag")]

String::hashCode = ->
    @split('').reduce ((a, b) ->
        a = (a << 5) - a + b.charCodeAt(0)
        a & a
    ), 0
