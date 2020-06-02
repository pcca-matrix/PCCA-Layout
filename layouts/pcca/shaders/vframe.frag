#version 130

#ifdef GL_ES
precision mediump float;
#endif

uniform float progress;
uniform float alpha;
uniform vec2 datas;
uniform sampler2D tex_s;
uniform sampler2D tex_f;
uniform vec4 snap_coord;
uniform vec3 border1;
uniform vec3 border2;
uniform vec3 border3;

float roundCorners(vec2 p, vec2 b, float r)
{
    return length(max(abs(p)-b+r,0.0))-r;
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 tv(vec3 color, vec2 pos){
      pos *= sin(progress);
      float r = rand(pos);
      vec3 noise = vec3(r);
      float noise_intensity = 1.0 - progress;
      float a = 1.0 * progress + 1.0;
      return vec4( mix(color, noise, noise_intensity), a);
}


vec3 htmtcolor(int html) {
    float rValue = float(html / 256 / 256);
    float gValue = float(html / 256 - int(rValue * 256.0));
    float bValue = float(html - int(rValue * 256.0 * 256.0) - int(gValue * 256.0));
    return vec3(rValue / 255.0, gValue / 255.0, bValue / 255.0);
}

vec4 frame_border(vec2 uv){
    float bmax = ( max(max(border1[1]/2, border2[1]), border3[1] ) );
    vec2 snap_res = vec2(snap_coord.z, snap_coord.w);
    vec2 full_size = vec2( snap_res.x + (bmax * 2), snap_res.y + (bmax * 2) );
    vec2 scale = vec2(snap_res / full_size);
    vec2 snap_uv = (uv - 0.5) / scale + 0.5; // scaled and centered video snap
    vec4 color = texture2D(tex_s, snap_uv);

	vec3 Brd1Col = ( border1[0] > 0 ? vec3( htmtcolor( int(border1[0]) ) ) : vec3(0,0,0) );
	vec3 Brd2Col = ( border2[0] > 0 ? vec3( htmtcolor( int(border2[0]) ) ) : vec3(0,0,0) );
	vec3 Brd3Col = ( border3[0] > 0 ? vec3( htmtcolor( int(border3[0]) ) ) : vec3(0,0,0) );
	bool rounded = false ;
	if(border1[2] + border2[2] + border3[2] > 0.0 ) rounded = true;
    float b = 1.0;
    if(progress != 1.0) color = tv(color.xyz, uv);
    vec2 bn1 = (1.0 / snap_res) * (border1[1] * 0.5); // border 1
    vec2 bn2 = (1.0 / snap_res) * (border2[1]); // border2
    vec2 bn3 = (1.0 / snap_res) * (border3[1]); // border3

    if(border1[1] > 0.0){
        if(snap_uv.x <= bn1.x || snap_uv.x >= 1.0 - bn1.x) color = vec4(Brd1Col, 1.0 );
        if(snap_uv.y <= bn1.y || snap_uv.y >= 1.0 - bn1.y) color = vec4(Brd1Col, 1.0 );
    }

    if( border2[1] > 0.0 ){
        if(snap_uv.x <=-bn1.x || snap_uv.x >=1.0 + bn1.x) color = vec4(Brd2Col, 1.0);
        if(snap_uv.y <=-bn1.y || snap_uv.y >=1.0 + bn1.y) color = vec4(Brd2Col, 1.0);
    }

    if( border3[1] > 0.0 ){
        if(snap_uv.x < -max(bn2.x,bn1.x) || snap_uv.x >=1.0 + max(bn2.x,bn1.x) ) color = vec4(Brd3Col, 1.0);
        if(snap_uv.y < -max(bn2.y,bn1.y) || snap_uv.y >= 1.0 + max(bn2.y,bn1.y) ) color = vec4(Brd3Col, 1.0);
    }


    if(rounded){
        if(border1[1] > 0.0){
            if(border1[1] <=20){ // inner corner if it's less than 20
                b = 1.0 - roundCorners( snap_uv * snap_res - (0.5 * snap_res) , (0.5 - bn1 ) * snap_res,  border1[1] * 1.20 );
                if(b <= 0.0 ) color = vec4( Brd1Col, 1.0 );
            }

            b = 1.0 - roundCorners( snap_uv * snap_res - (0.5 * snap_res) , (0.5 + bn1 ) * snap_res,  border1[1] * 1.20 );
            if(b <= 0.0 ){
                color = vec4( Brd2Col, 1.0 );
                if(border1[1]* 0.5 == bmax)color = vec4(0.0);  // transparent if it's the bigger or single
            }
        }

        if(border2[1] > 0.0){
            b = 1.0 - roundCorners( snap_uv * snap_res - (0.5 * snap_res) , (0.5 + bn2 -0.003) * snap_res, border2[1] * 1.20 );
            if(b <= 0.0 ){
                color = vec4( Brd3Col, 1.0 );
                if(border2[1] == bmax)color = vec4(0.0);
            }
        }

        if(border3[1] > 0.0){ // > bmax always transparent
            b = 1.0 - roundCorners( snap_uv * snap_res - (0.5 * snap_res) , ( 0.5 + ( (1.0 / snap_res) * bmax ) )  * snap_res, border3[1] * 1.20 );
            if(b <= 0.0)color = vec4(0.0);
        }
    }
    return color;
}


vec4 frame(vec2 uv){
    vec4 color;
    if( bool(datas[0]) ){ // if frame overlay

        vec2 OverlaySize = textureSize(tex_f, 0);
        vec2 FrameSize = OverlaySize;
        vec2 scale_frame;
        vec2 scale_snap;
        vec2 uv_frame;
        vec2 uv_snap;
        vec4 snap;
        vec4 frame;

        if(snap_coord.z > OverlaySize.x) FrameSize.x = snap_coord.z;
        if(snap_coord.w > OverlaySize.y) FrameSize.y = snap_coord.w;

        scale_frame = vec2(OverlaySize / FrameSize);
        uv_frame = (uv - 0.5) / scale_frame + 0.5; // center frame

        scale_snap.x = snap_coord.z / FrameSize.x;
        scale_snap.y = snap_coord.w / FrameSize.y;
        float ox = snap_coord.x * (1.0 / FrameSize.x);
        float oy = snap_coord.y * (1.0 / FrameSize.y);
        uv_snap.x = (uv.x - (0.50 - ox) ) / scale_snap.x + 0.50; // center snap with offset
        uv_snap.y = (uv.y - (0.50 - oy) ) / scale_snap.y + 0.50;

        frame = texture2D( tex_f, uv_frame );
        snap = frame_border(uv_snap);

        if ( uv_snap.y < 0.0 || uv_snap.y > 1.0 || uv_snap.x < 0.0 || uv_snap.x > 1.0 ) snap = vec4(0.0);
        if ( uv_frame.y < 0.0 || uv_frame.y > 1.0 || uv_frame.x < 0.0 || uv_frame.x > 1.0 ) frame = vec4(0.0);

        if(frame.a < 1.00 && frame.a > 0.001) snap.a = frame.a + snap.a;

        if( bool(datas[1]) ){
            color = mix(frame, snap, snap.a);
        }else{
            color = mix(snap, frame, frame.a);
        }

    }else{ // no frame overlay
        vec4 snap = frame_border(uv);
        color = snap;
    }

    return color;
}



void main(){
    vec2 uv = vec2(gl_TexCoord[0]);
    vec4 color = frame(uv);
    if(progress == 0.0){
        gl_FragColor = vec4(0.0);
    }else{
        gl_FragColor = color * alpha;
    }
}
