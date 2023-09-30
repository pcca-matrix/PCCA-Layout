#version 130
uniform sampler2D Tex1;
uniform sampler2D Tex0;
uniform vec4 datas; // x, y offsets, scale_x, scale_y
uniform bool enable;


void main(){
    vec2 uv = vec2(gl_TexCoord[0]).xy;
    if(!enable){
        gl_FragColor = texture2D(Tex0, uv);
        return;
    }
    // center snap with offset
    vec2 snap_uv = (uv - 0.5 + datas.xy) / datas.zw + 0.5;
    vec4 t0 = texture2D(Tex0, snap_uv);
    vec4 t1 = texture2D(Tex1, uv);
    if (any(lessThan(snap_uv, vec2(0.0))) || any(greaterThan(snap_uv, vec2(1.0)))) t0 = vec4(0.0);
    gl_FragColor = mix(t0, t1, t1.a);
}