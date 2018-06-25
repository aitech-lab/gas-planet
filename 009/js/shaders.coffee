# ../shaders/simple.vert
vert_simple= """
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
void main() {
    vUv = uv;
    vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
    gl_Position     = projectionMatrix * mvPosition; 
    gl_Position     = projectionMatrix * mvPosition;
    vPos            = vec3(mvPosition)/mvPosition.w;
    vNormal         = vec3(normalMatrix * normal);
}
"""

# ../shaders/screen.frag
frag_screen= """
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
uniform sampler2D texture;
void main() {
    gl_FragColor = texture2D(texture, vUv)*vNormal.z*vNormal.z;
    gl_FragColor.a = 1.0;
}
"""

# ../shaders/smoking.frag
frag_smoking= """
//Smokin' by nimitz (@stormoid) (Looks better in fullscreen)

/*
	The Two tweets challenge 2015 is over.

	The results are in, thanks to everyone who contributed, judged and
	spread the word about the contest. I had a good time and hope you
	guys had too.


	We had a total of 16 judges who voted for 31 different shaders.
	
	Here is the top 10:

	#1  "Mystery Mountains" by Dave_Hoskins (https://www.shadertoy.com/view/llsGW7)
	#2  "old skool 3d driving" by mattz (https://www.shadertoy.com/view/XtlGW4)
	#3  "Supernova" by guil (https://www.shadertoy.com/view/MtfGWN)
	#4  "Venus" by Trisomie21 (https://www.shadertoy.com/view/llsGWM)
	#5  "Hall of Kings" by Trisomie21 (https://www.shadertoy.com/view/4tfGRB)
	#6  "Flying" by iq (https://www.shadertoy.com/view/4ts3DH)
	#7  "2 Tweets Challenge" by nimitz (https://www.shadertoy.com/view/4tl3W8)
	#8  "Night Forest" by fizzer (https://www.shadertoy.com/view/4lfGDM)
	#9  "Cave" by iq (https://www.shadertoy.com/view/ltlGDN)
	#10 "Minecraft" by reinder (https://www.shadertoy.com/view/4tsGD7)



	More info about the contest: https://www.shadertoy.com/view/4tl3W8
	

	More info about the Judging: https://www.shadertoy.com/view/llXGzB
*/

uniform float u_time;
uniform sampler2D u_texture;
varying vec2 vUv;

void main(){
    // f fragcolor
    // w fragcoord
    vec4 p = vec4(vUv,0.0,1.0).xyxx*6.-3.,z = p-p, c, d=z;
	float t = u_time;
    p.x -= t*0.4;
    for(float i=0.;i<8.;i+=.3)
        c = texture2D(u_texture, p.xy*.0029)*11.,
        d.x = cos(c.x+t), d.y = sin(c.y+t),
        z += (2.-abs(p.y))*vec4(.1*i, .3, .2, 9),
        //z += (2.-abs(p.y))*vec4(.2,.4,.1*i,1), // Alt palette
        z *= dot(d,d-d+.03)+.98,
        p -= d*.022;
    
	gl_FragColor = z/25.;
}

"""

