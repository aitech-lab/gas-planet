varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;
uniform sampler2D texture;
void main() {
    gl_FragColor = texture2D(texture, vUv)*vNormal.z*vNormal.z;
    gl_FragColor.a = 1.0;
}
