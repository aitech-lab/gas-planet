//// [2TC 15] Mystery Mountains.
// David Hoskins.

// Add layers of the texture of differing frequencies and magnitudes...
#define F +texture(iChannel0,.3+p.xz*s/3e3)/(s+=s) 
void mainImage( out vec4 c, vec2 w )
{
    vec4 p=vec4(w/iResolution.xy,1,1)-.5,d=p,t;
    p.z += iTime*20.;d.y-=.4;
    for(float i=1.5;i>0.;i-=.002)
    {
        float s=.5;
        t = F F F F F F;
        c = vec4(1,1.,.9,9)+d.x-t*i;
        if(t.x>p.y*.007+1.3)break;
        p += d;
    }
}
