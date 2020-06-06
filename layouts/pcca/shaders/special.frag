#version 130

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform float progress;
uniform float alpha;

void FragOut(vec4 col){
    gl_FragColor = col * alpha;
}

/* Main */
void main(){
    vec2 uv = vec2(gl_TexCoord[0]);
    FragOut( texture2D(texture, uv) );
}