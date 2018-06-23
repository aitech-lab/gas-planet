// Generated by CoffeeScript 2.3.1
var RTT, animate, background, camera, clock, container, ctx, current_material, cvs, draw_spot, frag_fbm_05, frag_screen, generate_planet_texture, init, init_gui, init_materilas, init_planet_texture, init_renderers, init_scene, input, light_1, light_2, light_3, light_mat, material, materials, materials_cnt, onLoad, onWindowResize, p2u, params, planet, planet_details, planet_radius, planet_resolution, pr_h, pr_w, render, renderer, rnd, rtt, scene, seed, shader_load, shadows_mat, stats, text_load, time, velocities, vert_simple;

onWindowResize = function(event) {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  return renderer.setSize(window.innerWidth, window.innerHeight);
};

onLoad = function() {
  init();
  init_gui();
  return animate();
};

input = function(val) {
  var current_material, hash, seed;
  hash = Math.abs(val.hashCode());
  seed = hash;
  current_material = materials[hash % materials_cnt];
  current_material.uniforms.id.value = hash;
  generate_planet_texture();
  velocities.value.needsUpdate = true;
  return planet.material = current_material;
};

window.addEventListener("resize", onWindowResize, false);

window.addEventListener("load", onLoad);

params = {
  background: false,
  u_col1: [0x80, 0xFF, 0xFF],
  u_col2: [0xFF, 0x80, 0xFF],
  u_col3: [0xFF, 0xFF, 0x80],
  u_col4: [0xFF, 0x80, 0x80],
  u_scale: 4.0,
  u_speed: 1.0
};

p2u = function(p) {
  return new THREE.Vector3(params[p][0] / 255.0, params[p][1] / 255.0, params[p][2] / 255.0);
};

init_gui = function() {
  var color_changer, gui, i, j, l, len, light_mat_data, lights_data, n, ref, results, shadows_mat_data, t, u_col1, u_col2, u_col3, u_col4;
  color_changer = function(c) {
    return function(v) {
      return c.set(v);
    };
  };
  gui = new dat.GUI;
  gui.add(params, 'background').onChange(function() {
    return background.visible = params.background;
  });
  gui.add(params, 'u_scale', 0.1, 20.0, 0.1).onChange(function(v) {
    return material.uniforms.u_scale.value = v;
  });
  gui.add(params, 'u_speed', 0.1, 5.0, 0.1).onChange(function(v) {
    return material.uniforms.u_speed.value = v;
  });
  u_col1 = function(val) {
    return material.uniforms.u_col1.value = p2u('u_col1');
  };
  u_col2 = function(val) {
    return material.uniforms.u_col2.value = p2u('u_col2');
  };
  u_col3 = function(val) {
    return material.uniforms.u_col3.value = p2u('u_col3');
  };
  u_col4 = function(val) {
    return material.uniforms.u_col4.value = p2u('u_col4');
  };
  gui.addColor(params, 'u_col1').onChange(u_col1);
  gui.addColor(params, 'u_col2').onChange(u_col2);
  gui.addColor(params, 'u_col3').onChange(u_col3);
  gui.addColor(params, 'u_col4').onChange(u_col4);
  t = gui.addFolder("Shadow mat");
  shadows_mat_data = {
    color: shadows_mat.color.getHex()
  };
  t.addColor(shadows_mat_data, "color").onChange(color_changer(shadows_mat.color));
  t.add(shadows_mat, "metalness", 0.0, 1.0, 0.1); // : 0.0
  t.add(shadows_mat, "roughness", 0.0, 1.0, 0.1); // : 1.0
  t.add(shadows_mat, "opacity", 0.0, 1.0, 0.1); // : 0.61
  t.add(shadows_mat, "transparent"); // : true
  t.add(shadows_mat, "premultipliedAlpha"); // : true
  t = gui.addFolder("Light mat");
  light_mat_data = {
    color: light_mat.color.getHex()
  };
  t.addColor(light_mat_data, "color").onChange(color_changer(light_mat.color));
  t.add(light_mat, "metalness", 0.0, 1.0, 0.1); // : 0.0
  t.add(light_mat, "roughness", 0.0, 1.0, 0.1); // : 1.0
  t.add(light_mat, "opacity", 0.0, 1.0, 0.1); // : 0.61
  t.add(light_mat, "transparent"); // : true
  t.add(light_mat, "premultipliedAlpha"); // : true
  lights_data = {};
  ref = [1, 2, 3].map(function(i) {
    return this[`light_${i}`];
  });
  results = [];
  for (i = j = 0, len = ref.length; j < len; i = ++j) {
    l = ref[i];
    n = `${l.type} ${i}`;
    t = gui.addFolder(n);
    t.add(l, "intensity", 0.0, 10.0, 0.1);
    lights_data[n] = {
      color: l.color.getHex()
    };
    results.push(t.addColor(lights_data[n], "color").onChange(color_changer(l.color)));
  }
  return results;
};

container = void 0;

stats = void 0;

camera = void 0;

scene = void 0;

renderer = void 0;

clock = void 0;

planet = void 0;

background = void 0;

rtt = void 0;

material = void 0;

shadows_mat = void 0;

light_mat = void 0;

light_1 = void 0;

light_2 = void 0;

light_3 = void 0;

planet_radius = 1.2;

planet_details = 50;

planet_resolution = 256;

pr_w = planet_resolution;

pr_h = planet_resolution;

cvs = void 0;

ctx = void 0;

velocities = void 0;

materials = [];

materials_cnt = 8;

current_material = void 0;

time = {
  value: 1.0
};

seed = 1;

init_materilas = function(vert, frag) {};

animate = function() {
  requestAnimationFrame(animate);
  render();
  return stats.update();
};

render = function() {
  var delta;
  delta = clock.getDelta();
  material.uniforms.u_time.value = clock.elapsedTime;
  // renderer.setPixelRatio( 1 );
  // renderer.setSize( 256,256 );
  // renderer.autoClear = false;
  // renderer.render rtt.scene, rtt.camera, rtt.texture
  // rtt.render(renderer)

  // if planet?
  //     planet.rotation.y += delta * 0.25

  // renderer.setPixelRatio( window.devicePixelRatio );
  // renderer.setSize( window.innerWidth, window.innerHeight );
  // renderer.autoClear = false;
  return renderer.render(scene, camera);
};

init_renderers = function() {
  renderer = new THREE.WebGLRenderer({
    alpha: true,
    autoClear: false
  });
  renderer.setPixelRatio(window.devicePixelRatio);
  // rtt = new RTT
  container = document.getElementById('container');
  return container.appendChild(renderer.domElement);
};

init_scene = function() {
  var g, light, shadows, uniforms;
  camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 3000);
  camera.position.z = 4;
  scene = new THREE.Scene;
  clock = new THREE.Clock;
  uniforms = {
    u_col1: {
      type: 'v3',
      value: p2u('u_col1')
    },
    u_col2: {
      type: 'v3',
      value: p2u('u_col2')
    },
    u_col3: {
      type: 'v3',
      value: p2u('u_col3')
    },
    u_col4: {
      type: 'v3',
      value: p2u('u_col4')
    },
    u_time: {
      type: 'f',
      value: 0.0
    },
    u_scale: {
      type: 'f',
      value: 4.0
    },
    u_speed: {
      type: 'f',
      value: 1.0
    }
  };
  material = new THREE.ShaderMaterial({
    uniforms: uniforms,
    vertexShader: vert_simple,
    fragmentShader: frag_fbm_05
  });
  g = new THREE.PlaneBufferGeometry(5, 2.5, 10);
  background = new THREE.Mesh(g, material);
  background.visible = params.background;
  scene.add(background);
  g = new THREE.SphereBufferGeometry(planet_radius, planet_details, planet_details);
  planet = new THREE.Mesh(g, material);
  planet.rotation.x = 3.141 / 8.0;
  scene.add(planet);
  g = new THREE.SphereBufferGeometry(planet_radius * 1.001, planet_details, planet_details);
  shadows_mat = new THREE.MeshPhysicalMaterial({
    map: null,
    color: 0xFFFFFF,
    metalness: 0.0,
    roughness: 1.0,
    opacity: 1.0,
    side: THREE.FrontSide,
    transparent: true,
    premultipliedAlpha: true,
    depthTest: false,
    blending: THREE.MultiplyBlending
  });
  shadows = new THREE.Mesh(g, shadows_mat);
  scene.add(shadows);
  light_mat = new THREE.MeshPhysicalMaterial({
    color: 0x202020,
    metalness: 0.5,
    roughness: 0.6,
    opacity: 0.5,
    side: THREE.FrontSide,
    transparent: true,
    premultipliedAlpha: true,
    depthTest: false,
    blending: THREE.AdditiveBlending
  });
  light = new THREE.Mesh(g, light_mat);
  scene.add(light);
  light_1 = new THREE.PointLight(0xffffD0, 2);
  light_1.position.set(-50, 50, 50);
  scene.add(light_1);
  light_2 = new THREE.PointLight(0x404080, 2);
  light_2.position.set(50, -50, -50);
  scene.add(light_2);
  light_3 = new THREE.PointLight(0x808040, 0.5);
  light_3.position.set(0, -100, 0);
  return scene.add(light_3);
};

init = function() {
  console.log("Init");
  if (!Detector.webgl) {
    Detector.addGetWebGLMessage();
  }
  init_renderers();
  init_scene();
  stats = new Stats;
  container.appendChild(stats.dom);
  return onWindowResize();
};

RTT = class RTT {
  constructor() {
    
    // g = new THREE.SphereBufferGeometry 0.1
    // s = new THREE.Mesh g, new THREE.MeshBasicMaterial({color: 0x808080})
    // @scene.add s

    // @renderer = new THREE.WebGLRenderer
    // @renderer.setSize(@resolution, @resolution);
    // @renderer.setPixelRatio 1.0
    // @renderer.autoClear = false
    this.render = this.render.bind(this);
    this.resolution = 1024;
    this.iteration = 0;
    this.camera = new THREE.OrthographicCamera(-0.5, 0.5, 0.5, -0.5, -10000, 10000);
    this.camera.position.z = 100;
    this.scene = new THREE.Scene;
    this.textureA = new THREE.WebGLRenderTarget(this.resolution, this.resolution, {
      minFilter: THREE.LinearFilter,
      magFilter: THREE.LinearFilter,
      format: THREE.RGBAFormat
    });
    this.textureB = new THREE.WebGLRenderTarget(this.resolution, this.resolution, {
      minFilter: THREE.LinearFilter,
      magFilter: THREE.LinearFilter,
      format: THREE.RGBAFormat
    });
    this.bufB = new THREE.TextureLoader().load("textures/jupiter_1024_n.png");
    this.bufB.wrapS = this.bufB.wrapT = THREE.RepeatWrapping;
    this.bufC = new THREE.TextureLoader().load("textures/jupiter_1024.png");
    this.bufC.wrapS = this.bufC.wrapT = THREE.RepeatWrapping;
    this.mat = new THREE.ShaderMaterial({
      uniforms: {
        bufA: {
          type: 't',
          value: this.textureA
        },
        bufB: {
          type: 't',
          value: this.bufB
        },
        bufC: {
          type: 't',
          value: this.bufC
        },
        time: {
          type: 'f',
          value: 0.0
        }
      },
      vertexShader: vert_simple,
      fragmentShader: frag_fbm_05,
      depthWrite: false
    });
    this.mat_screen = new THREE.ShaderMaterial({
      uniforms: {
        texture: {
          type: "t",
          value: this.textureA
        }
      },
      vertexShader: vert_simple,
      fragmentShader: frag_screen
    });
    this.plane = new THREE.PlaneBufferGeometry(1.0, 1.0);
    this.quad = new THREE.Mesh(this.plane, this.mat);
    this.quad.position.z = -100;
    this.scene.add(this.quad);
  }

  render(renderer) {
    this.mat.uniforms.time.value += 0.1;
    renderer.preserveDrawingBuffer = true;
    renderer.autoClear = false;
    renderer.setPixelRatio(1);
    renderer.setSize(this.resolution, this.resolution);
    if (this.iteration % 2 === 0) {
      this.mat.uniforms.bufA.value = this.textureB.texture;
      this.render_target = this.textureA;
    } else {
      this.mat.uniforms.bufA.value = this.textureA.texture;
      this.render_target = this.textureB;
    }
    renderer.render(this.scene, this.camera, this.render_target, false);
    return this.iteration++;
  }

};

// ../shaders/simple.vert
vert_simple = "varying vec2 vUv;\nvarying vec3 vPos;\nvarying vec3 vNormal;\nvoid main() {\n    vUv = uv;\n    vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );\n    gl_Position     = projectionMatrix * mvPosition; \n    gl_Position     = projectionMatrix * mvPosition;\n    vPos            = vec3(mvPosition)/mvPosition.w;\n    vNormal         = vec3(normalMatrix * normal);\n}";

// ../shaders/screen.frag
frag_screen = "varying vec2 vUv;\nvarying vec3 vPos;\nvarying vec3 vNormal;\nuniform sampler2D texture;\nvoid main() {\n    gl_FragColor = texture2D(texture, vUv)*vNormal.z*vNormal.z;\n    gl_FragColor.a = 1.0;\n}";

// ../shaders/fbm_05.frag
frag_fbm_05 = "// Author @patriciogv - 2015\n// http://patriciogonzalezvivo.com\n\n\n#ifdef GL_ES\nprecision mediump float;\n#endif\n\nvarying vec2 vUv;\n\nuniform vec2 u_mouse;\nuniform float u_time;\nuniform float u_scale;\nuniform float u_speed;\n\nuniform vec3 u_col1;\nuniform vec3 u_col2;\nuniform vec3 u_col3;\nuniform vec3 u_col4;\n\n\nfloat random (in vec2 _st) {\n    return fract(sin(dot(_st.xy,\n                         vec2(12.9898,78.233)))*\n        43758.5453123);\n}\n\n// Based on Morgan McGuire @morgan3d\n// https://www.shadertoy.com/view/4dS3Wd\nfloat noise (in vec2 _st) {\n    vec2 i = floor(_st);\n    vec2 f = fract(_st);\n\n    // Four corners in 2D of a tile\n    float a = random(i);\n    float b = random(i + vec2(1.0, 0.0));\n    float c = random(i + vec2(0.0, 1.0));\n    float d = random(i + vec2(1.0, 1.0));\n\n    vec2 u = f * f * (3.0 - 2.0 * f);\n\n    return mix(a, b, u.x) +\n            (c - a)* u.y * (1.0 - u.x) +\n            (d - b) * u.x * u.y;\n}\n\n#define NUM_OCTAVES 5\n\nfloat fbm ( in vec2 _st) {\n    float v = 0.0;\n    float a = 0.5;\n    vec2 shift = vec2(100.0);\n    // Rotate to reduce axial bias\n    mat2 rot = mat2(cos(0.5), sin(0.5),\n                    -sin(0.5), cos(0.50));\n    for (int i = 0; i < NUM_OCTAVES; ++i) {\n        v += a * noise(_st);\n        _st = rot * _st * 2.0 + shift;\n        a *= 0.5;\n    }\n    return v;\n}\n\nvoid main() {\n    float time = u_time*u_speed;\n    vec2 st = vUv*u_scale; // gl_FragCoord.xy/u_resolution.xy*3.;\n    st.x+=time*0.1;\n    // st += st * abs(sin(time*0.1)*3.0);\n    vec3 color = vec3(0.0);\n\n    vec2 q = vec2(0.);\n    q.x = fbm( st + 0.00*time);\n    q.y = fbm( st + vec2(1.0));\n\n    vec2 r = vec2(0.);\n    r.x = fbm( st + 1.0*q + vec2(1.7,9.2)+ 0.150*time);\n    r.y = fbm( st + 1.0*q + vec2(8.3,2.8)+ 0.126*time);\n\n    float f = fbm(st+r);\n\n    color = mix(u_col1,\n                u_col2,\n                clamp((f*f)*4.0,0.0,1.0));\n\n    color = mix(color,\n                u_col3,\n                clamp(length(q),0.0,1.0));\n\n    color = mix(color,\n                u_col4,\n                clamp(length(r.x),0.0,1.0));\n\n    gl_FragColor = vec4((f*f*f+.6*f*f+.5*f)*color,1.);\n}";

rnd = function(r) {
  var x;
  x = Math.sin(seed++) * 10000;
  return (x - Math.floor(x)) * r;
};

text_load = function(url) {
  return new Promise(function(resolve, reject) {
    var loader;
    loader = new THREE.XHRLoader(THREE.DefaultLoadingManager);
    loader.setResponseType('text');
    return loader.load(url, resolve, null, reject);
  });
};

shader_load = function(name) {
  console.log(`Load shader ${name}`);
  return Promise.all([text_load(`shaders/${name}.vert`), text_load(`shaders/${name}.frag`)]);
};

String.prototype.hashCode = function() {
  return this.split('').reduce((function(a, b) {
    a = (a << 5) - a + b.charCodeAt(0);
    return a & a;
  }), 0);
};

// Градиент скоростей
init_planet_texture = function() {
  cvs = document.createElement('canvas');
  cvs.id = 'planet_texture';
  ctx = cvs.getContext('2d');
  cvs.width = ctx.width = pr_w;
  return cvs.height = ctx.height = pr_h;
};

// document.body.prepend(cvs);
generate_planet_texture = function() {
  var i;
  var x;
  var y;
  var r;
  var c;
  var c, grd, i, r, results, x, y;
  // Основной фон
  ctx.globalCompositeOperation = 'normal';
  grd = ctx.createLinearGradient(0, 0, 0, pr_h);
  grd.addColorStop(0.0, '#000000');
  grd.addColorStop(0.5, '#202020');
  grd.addColorStop(1.0, '#000000');
  ctx.fillStyle = grd;
  ctx.fillRect(0, 0, pr_w, pr_h);
  // Пятна
  i = 0;
  while (i < 100) {
    x = rnd(pr_w);
    y = pr_h / 2.0 - rnd(pr_h / 3.0) + rnd(pr_h / 3.0);
    r = 5 + rnd(20);
    c = 50;
    draw_spot(x, y, r, c);
    if (x + r > pr_w) {
      draw_spot(x - pr_w, y, r, c);
    }
    if (x - r < 0) {
      draw_spot(x + pr_w, y, r, c);
    }
    i++;
  }
  i = 0;
  results = [];
  while (i < 4) {
    x = rnd(pr_w);
    y = pr_h / 2.0 - rnd(pr_h / 4.0) + rnd(pr_h / 4.0);
    r = 5 + rnd(40);
    c = 255;
    draw_spot(x, y, r, c);
    if (x + r > pr_w) {
      draw_spot(x - pr_w, y, r, c);
    }
    if (x - r < 0) {
      draw_spot(x + pr_w, y, r, c);
    }
    results.push(i++);
  }
  return results;
};

draw_spot = function(x, y, r, c) {
  var grd;
  grd = ctx.createRadialGradient(x, y, 0, x, y, r);
  grd.addColorStop(0.0, `rgba(${c},${c},${c},1.0 )`);
  grd.addColorStop(0.1, `rgba(${c},${c},${c},0.8 )`);
  grd.addColorStop(0.4, `rgba(${c},${c},${c},0.2 )`);
  grd.addColorStop(0.6, `rgba(${c},${c},${c},0.01)`);
  grd.addColorStop(1.0, `rgba(${c},${c},${c},0.0 )`);
  ctx.globalCompositeOperation = 'screen';
  // Fill with gradient
  ctx.fillStyle = grd;
  return ctx.fillRect(0, 0, pr_w, pr_h);
};
