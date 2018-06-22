if ( ! Detector.webgl ) Detector.addGetWebGLMessage();
var container, stats;
var camera, scene, renderer, clock;


var planet;
var planet_radius     = 0.8;
var planet_details    = 50;
var planet_resolution = 256;
var pr_w = planet_resolution;
var pr_h = planet_resolution;
var cvs, ctx;
var velocities;

var materials = []
var materials_cnt = 8;
var current_material;
var time = {value:1.0};

String.prototype.hashCode = function() {
  return this.split("").reduce(function(a,b){a=((a<<5)-a)+b.charCodeAt(0);return a&a},0);
};
var seed = 1;
function rnd(r) {
    var x = Math.sin(seed++) * 10000;
    return (x - Math.floor(x)) * r;
}


var params = {
   brightness: 0.0,
   octaves   : 5,
   equator   : 2.0,
   turbulence: 1.0,
   contrast  : 1.2,
   cnt_width : 1.0,
   cnt_alpha : 0.5,
   cnt_col1  : [220,200,100],
   cnt_col2  : [ 70, 90,180],
   cnt_col3  : [250,250,180],
   spec_col  : [100, 80, 60],
   amb_col   : [ 20, 40, 20],

};

function p2u(p) {
   return new THREE.Vector3( params[p][0]/255.0, params[p][1]/255.0, params[p][2]/255.0);
}

function init_gui() {
    var gui = new dat.GUI();

    var octaves = function (val) { current_material.uniforms.octaves.value = val};
    gui.add(params, "octaves", 1, 8, 1).onChange(octaves);

    var equator = function (val) { current_material.uniforms.equator.value = val};
    gui.add(params, "equator", 0.0, 10.0).onChange(equator);

    var turbulence = function (val) { current_material.uniforms.turbulence.value = val};
    gui.add(params, "turbulence", 0.0, 4.0).onChange(turbulence);

    var contrast = function (val) { current_material.uniforms.contrast.value = val};
    gui.add(params, "contrast", 0.1, 2.0).onChange(contrast);
    
    var brightness = function (val) { current_material.uniforms.brightness.value = val};
    gui.add(params, "brightness", -2.0, 2.0).onChange(brightness);

    var cnt_width = function (val) { current_material.uniforms.cnt_width.value = val};
    gui.add(params, "cnt_width", 0.1, 8.0).onChange(cnt_width);

    var cnt_alpha = function (val) { current_material.uniforms.cnt_alpha.value = val};
    gui.add(params, "cnt_alpha", 0.1, 2.0).onChange(cnt_alpha);

    var cnt_col1 = function (val) { current_material.uniforms.cnt_col1.value = p2u("cnt_col1") };
    gui.addColor(params, "cnt_col1").onChange(cnt_col1);
    
    var cnt_col2 = function (val) { current_material.uniforms.cnt_col2.value = p2u("cnt_col2") };
    gui.addColor(params, "cnt_col2").onChange(cnt_col2);
    
    var cnt_col3 = function (val) { current_material.uniforms.cnt_col3.value = p2u("cnt_col3") };
    gui.addColor(params, "cnt_col3").onChange(cnt_col3);

    var spec_col = function (val) { current_material.uniforms.spec_col.value = p2u("spec_col") };
    gui.addColor(params, "spec_col").onChange(spec_col);
    
    var amb_col = function (val) { current_material.uniforms.amb_col.value = p2u("amb_col") };
    gui.addColor(params, "amb_col").onChange(amb_col);
    
    
}


function init() {

    init_planet_texture();
    generate_planet_texture();

	container = document.getElementById( 'container' );
	camera = new THREE.PerspectiveCamera( 40, window.innerWidth / window.innerHeight, 1, 3000 );
	camera.position.z = 4;
	scene = new THREE.Scene();
	clock = new THREE.Clock();

	var geometry = new THREE.SphereBufferGeometry(planet_radius, planet_details, planet_details );
    velocities = {type: "t", value: new THREE.Texture(cvs) };
    velocities.value.wrapS = velocities.value.wrapT = THREE.RepeatWrapping;
    velocities.value.needsUpdate = true;

	for(var i=1; i<=materials_cnt; i++) {

    	var texture  = { value: new THREE.TextureLoader().load('palettes/pal_0'+i+'.png' )}
    	texture.value.wrapS = texture.value.wrapT = THREE.RepeatWrapping;

        
        // Переменные шейдера
        var uniforms = {
    	    id:         { value: 1.0},

    	    octaves:    { type: "i" , value: params.octaves    },
    	    equator:    { type: "f" , value: params.equator    },
    	    turbulence: { type: "f" , value: params.turbulence },
    	    contrast:   { type: "f" , value: params.contrast   },
    	    brightness: { type: "f" , value: params.brightness },
    	    cnt_width:  { type: "f" , value: params.cnt_width  },
    	    cnt_alpha:  { type: "f" , value: params.cnt_alpha  },
    	    cnt_col1 :  { type: "v3", value: p2u("cnt_col1")   },
    	    cnt_col2 :  { type: "v3", value: p2u("cnt_col2")   },
    	    cnt_col3 :  { type: "v3", value: p2u("cnt_col3")   },
    	    spec_col :  { type: "v3", value: p2u("spec_col")   },
    	    amb_col  :  { type: "v3", value: p2u("amb_col" )   },

            time:       time,
    		texture:    texture,
    		velocities: velocities
    	};
    	var material = new THREE.ShaderMaterial( {
    		uniforms: uniforms,
    		vertexShader  : document.getElementById( 'planet.vert' ).textContent,
    		fragmentShader: document.getElementById( 'planet.frag' ).textContent
    	} );
        materials.push(material);
    }
    current_material = materials[0]
    	planet = new THREE.Mesh( geometry, current_material );
    planet.rotation.x = 3.141/8.0;
	scene.add( planet );

	renderer = new THREE.WebGLRenderer();
	renderer.setPixelRatio( window.devicePixelRatio );
	container.appendChild( renderer.domElement );

	stats = new Stats();
	container.appendChild( stats.dom );

	onWindowResize();

	window.addEventListener( 'resize', onWindowResize, false );

}

// Градиент скоростей
function init_planet_texture() {
    cvs = document.createElement('canvas');
    cvs.id = "planet_texture";
    ctx = cvs.getContext('2d')
    cvs.width  = ctx.width  = pr_w;
    cvs.height = ctx.height = pr_h;
    //document.body.prepend(cvs);
}


function generate_planet_texture() {

    // Основной фон
    ctx.globalCompositeOperation = "normal";
    var grd=ctx.createLinearGradient(0, 0, 0, pr_h);
    grd.addColorStop(0.0,"#000000");
    grd.addColorStop(0.5,"#202020");
    grd.addColorStop(1.0,"#000000");
    ctx.fillStyle = grd;
    ctx.fillRect(0,0,pr_w,pr_h);

    // Пятна

    for(var i=0; i<100; i++) {
       var x = rnd(pr_w);
       var y = pr_h/2.0-rnd(pr_h/3.0) + rnd(pr_h/3.0);
       var r = 5+rnd(20);
       var c = 50;
       draw_spot(x, y, r, c);
       if(x+r>pr_w) draw_spot(x-pr_w, y, r, c);
       if(x-r<0   ) draw_spot(x+pr_w, y, r, c);
    }
    
    for(var i=0; i<4; i++) {
       var x = rnd(pr_w);
       var y = pr_h/2.0-rnd(pr_h/4.0) + rnd(pr_h/4.0);
       var r = 5+rnd(40);
       var c = 255;
       draw_spot(x, y, r, c);
       if(x+r>pr_w) draw_spot(x-pr_w, y, r, c);
       if(x-r<0   ) draw_spot(x+pr_w, y, r, c);
    }
    
}

function draw_spot(x, y, r, c) {

    var grd=ctx.createRadialGradient(
        x, y, 0,
        x, y, r);

    grd.addColorStop(0.0,"rgba("+c+","+c+","+c+",1.0)");
    grd.addColorStop(0.1,"rgba("+c+","+c+","+c+",0.8)");  
    grd.addColorStop(0.4,"rgba("+c+","+c+","+c+",0.2)");
    grd.addColorStop(0.6,"rgba("+c+","+c+","+c+",0.01)");
    grd.addColorStop(1.0,"rgba("+c+","+c+","+c+",0.0)");
    
    ctx.globalCompositeOperation = "screen";
    // Fill with gradient
    ctx.fillStyle=grd;
    ctx.fillRect(0,0,pr_w,pr_h);
}


function onWindowResize( event ) {
	camera.aspect = window.innerWidth / window.innerHeight;
	camera.updateProjectionMatrix();
	renderer.setSize( window.innerWidth, window.innerHeight );
}

//

function animate() {
	requestAnimationFrame( animate );
	render();
	stats.update();
}

function render() {
	var delta = clock.getDelta();
	time.value = clock.elapsedTime;
	for ( var i = 0; i < scene.children.length; i ++ ) {
		var object = scene.children[ i ];
		object.rotation.y += delta * 0.1;
		//object.rotation.x += delta * 0.5 * ( i % 2 ? -1 : 1 );
	}
	renderer.render( scene, camera );
}


function input(val) {
    hash = Math.abs(val.hashCode());
    seed = hash;

    current_material = materials[hash%materials_cnt];
    current_material.uniforms.id.value = hash;

    generate_planet_texture();
    velocities.value.needsUpdate = true;
    planet.material = current_material;
}

init();
init_gui(i);
animate();
