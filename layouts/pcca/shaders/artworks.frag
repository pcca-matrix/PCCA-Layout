#version 130

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform float progress;
uniform float alpha;
uniform vec4 datas;
const float PI = 3.14159265358;

void FragOut(vec4 col){
    gl_FragColor = col * alpha;
}

//-- Pixelate
void pixelate(vec2 uv)
{
    float normalize = ( 25.0 - (progress * 25.00) );
    float dx = normalize * (1./512);
    float dy = normalize * (1./400);
    vec2 coord = vec2(dx*floor(uv.x/dx), dy*floor(uv.y/dy));
    FragOut( texture2D(texture, coord) );
}

//-- Flag
vec2 offset(float progress, float x, float theta) {
  float phase = progress*progress + progress + theta;
  float shifty = 0.05*progress*cos(10*(progress+x));
  return vec2(0, shifty);
}

void flag(vec2 uv){
    if (progress == 0.0){
      FragOut( texture2D(texture, uv) );
    }else{
      FragOut( texture2D(texture, uv + offset(1.0-progress, uv.x, 0.0)) );
    }
}


//-- Stripes
void stripes(vec2 uv){
  float count = 10.0; // = 10.0
  float smoothness = 0.5; // = 0.5
  float pr = smoothstep(-smoothness, 0.0, uv.x - progress * (1.0 + smoothness));
  float s = step(pr, fract(count * uv.x));
  FragOut( mix(vec4(0.0), texture2D(texture, uv), s) );
}

//-- Stripes 2
void stripes2(vec2 uv){
  float count = 12.0; // = 10.0
  float smoothness = 0.5; // = 0.5
  float pr = smoothstep(-smoothness, 0.1, uv.x - progress * (1.0 + smoothness));
  float s = step(pr, fract(count * uv.x * PI));
  FragOut( mix(vec4(0.0), texture2D(texture, uv), s) );
}

//-- Blur
void blur(vec2 uv){
    float intensity = 0.112; // = 0.1
    int passes = 6;
    vec4 c1 = vec4(0.0);
    float disp = intensity*(0.5-distance(0.5, progress));
    for (int xi=0; xi<passes; xi++)
    {
        float x = float(xi) / float(passes) - 0.5;
        for (int yi=0; yi<passes; yi++)
        {
            float y = float(yi) / float(passes) - 0.5;
            vec2 v = vec2(x,y);
            float d = disp;
            c1 += texture2D(texture, uv + d*v);
        }
    }
    c1 /= float(passes*passes);
    FragOut(c1*progress);
}

//-- Rain float
void rainfloat(vec2 uv){
    /* TODO */
}

/* Main */
void main(){
    vec2 uv = vec2(gl_TexCoord[0]);
    if(progress == 1.0){
         FragOut( texture2D(texture, uv) );
        return;
    }
    switch ( int(datas.x) ) {
        case 0:
            FragOut( texture2D(texture, uv) );
        break;

        case 1:
            pixelate(uv);
        break;

        case 2:
            flag(uv);
        break;

        case 3:
            stripes(uv);
        break;

        case 4:
            stripes2(uv);
        break;

        case 5:
            blur(uv);
        break;

        case 6:
            rainfloat(uv);
        break;
    }
}