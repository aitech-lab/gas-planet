// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

	vec2 p = fragCoord.xy / iResolution.xy;	
	vec2 uv = p*0.15 + 0.25;
	vec2 e = 1.0/iChannelResolution[0].xy; // (1/512,1/512)
	
	float am1 = 0.5 + 0.5*sin( iTime );
	float am2 = 0.5 + 0.5*cos( iTime );

	// iterate uv through map, find point of convergence
	
	for( int i=0; i<50; i++ ){
	
	        // calculate gradient and isoline of color surface
		float h  = dot( texture2D(iChannel0, uv,              ).xyz, vec3(0.333) );
		float h1 = dot( texture2D(iChannel0, uv+vec2(e.x, 0.0)).xyz, vec3(0.333) );
		float h2 = dot( texture2D(iChannel0, uv+vec2(0.0, e.y)).xyz, vec3(0.333) );
		// gradiente
		vec2 g = 0.001*vec2( (h1-h), (h2-h) )/e;
		// isoline - perpendicular to isoline
		vec2 f = g.yx*vec2(-1.0,1.0);

		// waving between g and f  
		g = mix( g, f, am1 );
		
		// waving by amplitude
		uv -= 0.01*g*am2;
	}
	
	// color from end poit
	vec3 col = texture(iChannel0, uv).xyz;
	
        col *= 2.0;
		
	fragColor = vec4(col, 1.0);
}

