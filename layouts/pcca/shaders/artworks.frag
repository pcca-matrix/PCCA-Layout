#version 130

uniform sampler2D Tex0;
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
    float normalize = 25.0 - (progress * 25.00);
    float dx = normalize * (1.0 / 150.0);
    float dy = normalize * (1.0 / 60.0);
    vec2 coord = vec2(dx * floor(uv.x / dx), dy * floor(uv.y / dy));
    FragOut( texture(Tex0, coord) * step(0.01, progress) );
}

//-- Flag
void flag(vec2 uv){ 
    FragOut(texture(Tex0, uv + vec2( 0.0, 0.18 * (1.0 - progress) * cos(10.0 * ((1.0 - progress) + uv.x)))));
}

//-- Stripes
void stripes(vec2 uv){
  float count = 10.0; // = 10.0
  float smoothness = 0.5; // = 0.5
  float pr = smoothstep(-smoothness, 0.0, uv.x - progress * (1.0 + smoothness));
  float s = step(pr, fract(count * uv.x));
  FragOut( mix(vec4(0.0), texture(Tex0, uv), s) );
}

//-- Stripes 2
void stripes2(vec2 uv){
  float count = 12.0; // = 10.0
  float smoothness = 0.5; // = 0.5
  float pr = smoothstep(-smoothness, 0.1, uv.x - progress * (1.0 + smoothness));
  float s = step(pr, fract(count * uv.x * PI));
  FragOut( mix(vec4(0.0), texture(Tex0, uv), s) );
}

//-- Blur
void blur(vec2 uv){
    float intensity = 0.115; // = 0.1
    int passes = 4;
    vec4 c1 = vec4(0.0);
    float disp = intensity * (0.5 - distance(0.5, progress));
    float revpass = 1.0 / float(passes);
    for (int xi=0; xi < passes; xi++)
    {
        float x = float(xi) * revpass - 0.5;
        for (int yi = 0; yi < passes; yi++)
        {
            float y = float(yi) * revpass - 0.5;
            vec2 v = vec2(x, y);
            c1 += texture(Tex0, uv + disp * v);
        }
    }
    c1 *= float(revpass * revpass);
    FragOut(c1 * progress);
}

void main(){
    vec2 uv = vec2(gl_TexCoord[0]);
    if(progress == 1.0){
        FragOut( texture(Tex0, uv) );
        return;
    }
    switch ( int(datas.x) ) {
        case 0:
            FragOut( texture(Tex0, uv) );
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
    }
}