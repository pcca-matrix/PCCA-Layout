#version 130

uniform sampler2D Tex0;
uniform float progress;
uniform float alpha;

void FragOut(vec4 col){
    gl_FragColor = col * alpha;
}

/* Main */
void main(){
    vec2 uv = vec2(gl_TexCoord[0]);
    FragOut( texture(Tex0, uv) );
}