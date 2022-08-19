#version 130
uniform sampler2D Tex1;
uniform sampler2D Tex0;
uniform vec4 datas; // x, y offsets, scale_x, scale_y
uniform bool enable;

/* Main */
void main(){
    vec2 uv = vec2(gl_TexCoord[0]);
    vec2 snap_uv = uv;
    vec4 t1 = texture2D(Tex1, uv);
    if(enable == true){
        // center snap with offset
        snap_uv.x = (uv.x - 0.5 + datas.x)  / datas.z + 0.50;
        snap_uv.y = (uv.y - 0.5 + datas.y)  / datas.w + 0.50;
        vec4 t0 = texture2D(Tex0, snap_uv);
        if ( snap_uv.y < 0.0 || snap_uv.y > 1.0 || snap_uv.x < 0.0 || snap_uv.x > 1.0 ) t0 = vec4(0.0);
        gl_FragColor = mix(t0, t1, t1.a);
    }else{
        vec4 t0 = texture2D(Tex0, snap_uv);
        gl_FragColor = t0;
    }
}