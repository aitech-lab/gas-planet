onWindowResize = (event)->
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize window.innerWidth, window.innerHeight

onLoad = ->
    init()
    init_gui()
    animate()

input = (val) ->
    hash = Math.abs(val.hashCode())
    seed = hash
    current_material = materials[hash % materials_cnt]
    current_material.uniforms.id.value = hash
    generate_planet_texture()
    velocities.value.needsUpdate = true
    planet.material = current_material

window.addEventListener "resize", onWindowResize, false
window.addEventListener "load", onLoad
