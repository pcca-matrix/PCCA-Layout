#version 130

uniform sampler2D back1;
uniform sampler2D back2;
uniform sampler2D bezel;
uniform float progress;
uniform float alpha;
uniform vec4 datas; //preset number, reverse 0:1 , fromIsSWF, toIsSWF
uniform vec4 back_res; // bw, bh, offset_x, offset_y
uniform vec4 prev_res; // previous bw, bh, offset_x, offset_y

float S_progress = progress;
const float PI = 3.14159265358;

vec4 Bez;

float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 get_coord(vec2 uv){
    uv.x = (uv.x - back_res.x ) / back_res.z;
    uv.y = (uv.y + back_res.y) / back_res.w;
    return uv;
}

vec2 get_coord_prev(vec2 uv){
    uv.x = (uv.x - prev_res.x ) / prev_res.z;
    uv.y = (uv.y + prev_res.y ) / prev_res.w;
    return uv;
}

vec4 getFromColor(vec2 uv){
    vec2 Muv = uv;

    Muv.y = abs(int(datas.z) - uv.y); // swf reverse fix !!!

    vec4 color;
    Muv = get_coord_prev(Muv);
    Bez = texture(bezel, uv) * step(0.001, prev_res.x); // hide bezel if offset_x = 0

    vec4 b1 = texture(back1, Muv);
    vec4 b2 = texture(back2, Muv);

    color = mix(b2 , b1  , datas.y);

    return mix(  color , Bez, Bez.a);

}

vec4 getToColor(vec2 uv){
    vec2 Muv = uv;

    Muv.y = abs(int(datas.w) - uv.y); // swf reverse fix !!!

    vec4 color;
    Muv = get_coord(Muv);
    Bez = texture(bezel, uv) * step(0.001, back_res.x); // hide bezel if offset_x = 0

    vec4 b1 = texture(back1, Muv);
    vec4 b2 = texture(back2, Muv);

    color = mix(b1, b2, datas.y);

    return mix( color , Bez, Bez.a);
}


vec4 displacement(vec2 uv){ // displacement
    // Author: Travis Fischer
    // License: MIT
    float strength = 0.5; // = 0.5
    float displacement = texture2D(back1, uv).r * strength;
    vec2 uvFrom = vec2(uv.x + S_progress * displacement, uv.y);
    vec2 uvTo = vec2(uv.x - (1.0 - S_progress) * displacement, uv.y);
    return mix(
        getFromColor(uvFrom),
        getToColor(uvTo),
        S_progress
    );
}

vec4 directional(vec2 uv){ // curtain vertical (Directional)
    // Author: Gaëtan Renaudeau
    // License: MIT
    vec2 direction = vec2(0.0, 1.0);
    vec2 p = uv + S_progress * sign(direction);
    vec2 f = fract(p);
    return mix(
        getToColor(f),
        getFromColor(f),
        step(0.0, p.y) * step(p.y, 1.0) * step(0.0, p.x) * step(p.x, 1.0)
    );
}

// -- SimpleZoom
vec2 zoom(vec2 uv, float amount) {
  return 0.5 + ((uv - 0.5) * (1.0-amount));	
}
vec4 simplezoom(vec2 uv){
    // Author: 0gust1
    // License: MIT
    float zoom_quickness = 0.8; // = 0.8
    float nQuick = clamp(zoom_quickness,0.2,1.0);
    return mix(
        getFromColor( zoom(uv, smoothstep(0.0, nQuick, S_progress)) ),
        getToColor(uv),
       smoothstep(nQuick-0.2, 1.0, S_progress)
    );
}



vec4 linearblur(vec2 uv){
    // author: gre
    // license: MIT
    float intensity = 0.1; // = 0.1
    const int passes = 4; //6
    vec4 c1 = vec4(0.0);
    vec4 c2 = vec4(0.0);

    float disp = intensity*(0.5-distance(0.5, S_progress));
    for (int xi=0; xi<passes; xi++)
    {
        float x = float(xi) / float(passes) - 0.5;
        for (int yi=0; yi<passes; yi++)
        {
            float y = float(yi) / float(passes) - 0.5;
            vec2 v = vec2(x,y);
            float d = disp;
            c1 += getFromColor( uv + d*v);
            c2 += getToColor( uv + d*v);
        }
    }
    c1 /= float(passes*passes);
    c2 /= float(passes*passes);
    return  mix(c1, c2, S_progress);

}

vec4 waterdrop(vec2 uv){
    // author: Paweł Płóciennik
    // license: MIT
    float amplitude = 30.0; // = 30
    float speed = 30.0; // = 30
    vec2 dir = uv - vec2(0.5);
    float dist = length(dir);
    if (dist > S_progress) {
        return mix(getFromColor(uv), getToColor(uv), S_progress);
    } else {
        vec2 offset = dir * sin(dist * amplitude - S_progress * speed);
        return mix(getFromColor( uv + offset), getToColor(uv), S_progress);
    }

}

vec4 glitchmemories(vec2 uv){
    // author: Gunnar Roth
    // license: MIT
    vec2 block = floor(uv.xy / vec2(16));
    vec2 uv_noise = block / vec2(64);
    uv_noise += floor(vec2(S_progress) * vec2(1200.0, 3500.0)) / vec2(64);
    vec2 dist = S_progress > 0.0 ? (fract(uv_noise) - 0.5) * 0.3 *(1.0 -S_progress) : vec2(0.0);
    vec2 red = uv + dist * 0.2;
    vec2 green = uv + dist * 0.3;
    vec2 blue = uv + dist * 0.5;
    return vec4(mix(getFromColor(red), getToColor(red), S_progress).r, mix(getFromColor(green), getToColor(green), S_progress).g,mix(getFromColor(blue), getToColor(blue), S_progress).b, 1.0);
    //return vec4(mix(getFromColor(red), getToColor(red), S_progress).r, mix(getFromColor(green), getToColor(green), S_progress).g,mix(getFromColor(blue), getToColor(blue), S_progress).b,1.0);
}

vec4 directionalwarp(vec2 uv){
    // Author: pschroen
    // License: MIT
    vec2 direction = vec2(-1.0, 1.0); // = vec2(-1.0, 1.0)

    const float smoothness = 0.5;
    const vec2 center = vec2(0.5, 0.5);
    vec2 v = normalize(direction);
    v /= abs(v.x) + abs(v.y);
    float d = v.x * center.x + v.y * center.y;
    float m = 1.0 - smoothstep(-smoothness, 0.0, v.x * uv.x + v.y * uv.y - (d - 0.5 + S_progress * (1.0 + smoothness)));
    return mix(getFromColor((uv - 0.5) * (1.0 - m) + 0.5), getToColor((uv - 0.5) * m + 0.5), m);
}

vec4 bounce(vec2 uv){
    // Author: Adrian Purser
    // License: MIT
    vec4 shadow_colour = vec4(0.0,0.0,0.0,0.6); // = vec4(0.,0.,0.,.6)
    float shadow_height = 0.01; // = 0.075
    float bounces = 2.5; // = 3.0
    float time = S_progress;
    float stime = sin(time * PI / 2.);
    float phase = time * PI * bounces;
    float y = (abs(cos(phase))) * (1.0 - stime);
    float d = uv.y - y;
    return mix(
    mix(
      getToColor(uv),
      shadow_colour,
      step(d, shadow_height) * (1. - mix(
        ((d / shadow_height) * shadow_colour.a) + (1.0 - shadow_colour.a),
        1.0,
        smoothstep(0.95, 1., S_progress) // fade-out the shadow at the end
      ))
    ),
    getFromColor(vec2(uv.x, uv.y + (1.0 - y))),
    step(d, 0.0)
    );
}

vec4 morph(vec2 uv){
    // Author: paniq
    // License: MIT
    float strength = 0.1; // = 0.1
    vec4 ca = getFromColor(uv);
    vec4 cb = getToColor(uv);
    vec2 oa = (((ca.rg+ca.b)*0.5)*2.0-1.0);
    vec2 ob = (((cb.rg+cb.b)*0.5)*2.0-1.0);
    vec2 oc = mix(oa,ob,0.5)*strength;
    float w0 = S_progress;
    float w1 = 1.0-w0;
    return mix(getFromColor(uv+oc*w0), getToColor(uv-oc*w1), S_progress);

}

vec4 circlecrop(vec2 uv){
    // License: MIT
    // Author: fkuteken
    vec4 bgcolor = vec4(0.0, 0.0, 0.0, 1.0); // = vec4(0.0, 0.0, 0.0, 1.0)
    //vec2 ratio2 = vec2(1.0, 1.0 / ratio);
    float s = pow(2.0 * abs(S_progress - 0.5), 3.0);
    //float dist = length((vec2(uv) - 0.5));
    float dist = length((vec2(uv) - 0.5) * 0.2);
    return mix(
        S_progress < 0.5 ? getFromColor(uv) : getToColor(uv), // branching is ok here as we statically depend on S_progress uniform (branching won't change over pixels)
        bgcolor,
        step(s, dist)
    );
}

vec4 swirl(vec2 UV){
    // License: MIT
    // Author: Sergey Kosarevsky
    float Radius = 1.0;
    float T = S_progress;
    UV -= vec2( 0.5, 0.5 );
    float Dist = length(UV);
    if ( Dist < Radius )
    {
        float Percent = (Radius - Dist) / Radius;
        float A = ( T <= 0.5 ) ? mix( 0.0, 1.0, T/0.5 ) : mix( 1.0, 0.0, (T-0.5)/0.5 );
        float Theta = Percent * Percent * A * 8.0 * 3.14159;
        float S = sin( Theta );
        float C = cos( Theta );
        UV = vec2( dot(UV, vec2(C, -S)), dot(UV, vec2(S, C)) );
    }
    UV += vec2( 0.5, 0.5 );
    vec4 C0 = getFromColor(UV);
    vec4 C1 = getToColor(UV);

    return mix( C0, C1, T );
}


//----- Dreamy - Flag effect
vec2 offset(float S_progress, float x, float theta) {
  float phase = S_progress*S_progress + S_progress + theta;
  float shifty = 0.03*S_progress*cos(10.0*(S_progress+x));
  return vec2(0, shifty);
}

vec4 dreamy(vec2 uv){
    return mix(getFromColor(uv + offset(S_progress, uv.x, 0.0)), getToColor(uv + offset(1.0-S_progress, uv.x, PI)), S_progress);
}


//------ Grid flip

float getDelta(vec2 p) {
  ivec2 size = ivec2(4); // = ivec2(4)
  vec2 rectanglePos = floor(vec2(size) * p);
  vec2 rectangleSize = vec2(1.0 / vec2(size).x, 1.0 / vec2(size).y);
  float top = rectangleSize.y * (rectanglePos.y + 1.0);
  float bottom = rectangleSize.y * rectanglePos.y;
  float left = rectangleSize.x * rectanglePos.x;
  float right = rectangleSize.x * (rectanglePos.x + 1.0);
  float minX = min(abs(p.x - left), abs(p.x - right));
  float minY = min(abs(p.y - top), abs(p.y - bottom));
  return min(minX, minY);
}

float getDividerSize() {
  ivec2 size = ivec2(4); // = ivec2(4)
  float dividerWidth = 0.04; // = 0.05
  vec2 rectangleSize = vec2(1.0 / vec2(size).x, 1.0 / vec2(size).y);
  return min(rectangleSize.x, rectangleSize.y) * dividerWidth;
}

vec4 gridflip(vec2 uv){
    ivec2 size = ivec2(4); // = ivec2(4)
    float pause = 0.1; // = 0.1
    vec4 bgcolor = vec4(0.0, 0.0, 0.0, 1.0) ; // = vec4(0.0, 0.0, 0.0, 1.0)
    float randomness = 0.1; // = 0.1
    if(S_progress < pause) {
    float currentProg = S_progress / pause;
    float a = 1.0;
    if(getDelta(uv) < getDividerSize()) {
      a = 1.0 - currentProg;
    }
    return mix(bgcolor, getFromColor(uv), a);
    }
    else if(S_progress < 1.0 - pause){
        if(getDelta(uv) < getDividerSize()) {
          return  bgcolor;
        } else {
          float currentProg = (S_progress - pause) / (1.0 - pause * 2.0);
          vec2 q = uv;
          vec2 rectanglePos = floor(vec2(size) * q);

          float r = rand(rectanglePos) - randomness;
          float cp = smoothstep(0.0, 1.0 - r, currentProg);

          float rectangleSize = 1.0 / vec2(size).x;
          float delta = rectanglePos.x * rectangleSize;
          float offset = rectangleSize / 2.0 + delta;

          uv.x = (uv.x - offset)/abs(cp - 0.5)*0.5 + offset;
          vec4 a = getFromColor(uv);
          vec4 b = getToColor(uv);

          float s = step(abs(vec2(size).x * (q.x - delta) - 0.5), abs(cp - 0.5));
          return mix(bgcolor, mix(b, a, step(cp, 0.5)), s);
        }
    }
    else {
        float currentProg = (S_progress - 1.0 + pause) / pause;
        float a = 1.0;
        if(getDelta(uv) < getDividerSize()) {
          a = currentProg;
        }
        return mix(bgcolor, getToColor(uv), a);
    }

}


// ----- Waves
// License: MIT
// Author: pthrasher

float quadraticInOut(float t) {
  float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float getGradient(float r, float dist) {
  float smoothness = 0.03; // = 0.03
  float d = r - dist;
  return mix(
    smoothstep(-smoothness, 0.0, r - dist * (1.0 + smoothness)),
    -1.0 - step(0.005, d),
    step(-0.005, d) * step(d, 0.01)
  );
}

float getWave(vec2 p){
  vec2 center = vec2(0.5); // = vec2(0.5)
  vec2 _p = p - center; // offset from center
  float rads = atan(_p.y, _p.x);
  float degs = degrees(rads) + 180.0;
  vec2 range = vec2(0.0, PI * 30.0);
  vec2 domain = vec2(0.0, 360.0);
  float ratio = (PI * 30.0) / 360.0;
  degs = degs * ratio;
  float x = S_progress;
  float magnitude = mix(0.02, 0.09, smoothstep(0.0, 1.0, x));
  float offset = mix(40.0, 30.0, smoothstep(0.0, 1.0, x));
  float ease_degs = quadraticInOut(sin(degs));
  float deg_wave_pos = (ease_degs * magnitude) * sin(x * offset);
  return x + deg_wave_pos;
}

vec4 crazyparametricfun(vec2 uv){
    // Author: mandubian
    // License: MIT
    float a = 4.0; // = 4
    float b = 1.0; // = 1
    float amplitude = 120.0; // = 120
    float smoothness = 0.1; // = 0.1
    vec2 p = uv.xy / vec2(1.0).xy;
    vec2 dir = p - vec2(.5);
    float dist = length(dir);
    float x = (a - b) * cos(S_progress) + b * cos(S_progress * ((a / b) - 1.) );
    float y = (a - b) * sin(S_progress) - b * sin(S_progress * ((a / b) - 1.));
    vec2 offset = dir * vec2(sin(S_progress  * dist * amplitude * x), sin(S_progress * dist * amplitude * y)) / smoothness;
    return mix(getFromColor(p + offset), getToColor(p), smoothstep(0.2, 1.0, S_progress));
}

vec4 kaleidoscope(vec2 uv){
    // Author: nwoeanhinnogaehr
    // License: MIT
    float speed = 1.0; // = 1.0;
    float angle = 1.0; // = 1.0;
    float power = 1.5; // = 1.5;
    vec2 p = uv.xy / vec2(1.0).xy;
    vec2 q = p;
    float t = pow(S_progress, power)*speed;
    p = p -0.5;
    for (int i = 0; i < 7; i++) {
    p = vec2(sin(t)*p.x + cos(t)*p.y, sin(t)*p.y - cos(t)*p.x);
    t += angle;
    p = abs(mod(p, 2.0) - 1.0);
    }
    abs(mod(p, 1.0));
    return mix(
    mix(getFromColor(q), getToColor(q), S_progress),
    mix(getFromColor(p), getToColor(p), S_progress), 1.0 - 2.0*abs(S_progress - 0.5));

}

vec4 burn(vec2 uv){
    // author: gre
    // License: MIT
    vec3 color = vec3(0.9, 0.4, 0.2); /* = vec3(0.9, 0.4, 0.2) */
    return mix(
        getFromColor(uv) + vec4(S_progress*color, 1.0),
        getToColor(uv) + vec4((1.0-S_progress)*color, 1.0),
        S_progress
    );
}

vec4 crosswarp(vec2 uv){
    // Author: Eke Péter <peterekepeter@gmail.com>
    // License: MIT
    float x = S_progress;
    x=smoothstep(.0,1.0,(x*2.0+uv.x-1.0));
    return mix(getFromColor((uv-.5)*(1.-x)+.5), getToColor((uv-.5)*x+.5), x);
}

vec4 flyeye(vec2 uv){
    // Author: gre
    // License: MIT
    float size = 0.04; // = 0.04
    float zoom = 50.0; // = 50.0
    float colorSeparation = 0.3; // = 0.3
    float inv = 1. - S_progress;
    vec2 disp = size*vec2(cos(zoom*uv.x), sin(zoom*uv.y));
    vec4 texTo = getToColor(uv + inv*disp);
    vec4 texFrom = vec4(
    getFromColor(uv + S_progress*disp*(1.0 - colorSeparation)).r,
    getFromColor(uv + S_progress*disp).g,
    getFromColor(uv + S_progress*disp*(1.0 + colorSeparation)).b,
    1.0);
    return texTo*S_progress + texFrom*inv;
}

vec4 rotate_scale_fade(vec2 uv){
    // Author: Fernando Kuteken
    // License: MIT
    vec2 center = vec2(0.5, 0.5); // = vec2(0.5, 0.5);
    float rotations = 1.0; // = 1;
    float scale = 8.0; // = 8;
    vec4 backColor = vec4(0.15, 0.15, 0.15, 1.0); // = vec4(0.15, 0.15, 0.15, 1.0);
    vec2 difference = uv - center;
    vec2 dir = normalize(difference);
    float dist = length(difference);

    float angle = 2.0 * PI * rotations * S_progress;

    float c = cos(angle);
    float s = sin(angle);

    float currentScale = mix(scale, 1.0, 2.0 * abs(S_progress - 0.5));

    vec2 rotatedDir = vec2(dir.x  * c - dir.y * s, dir.x * s + dir.y * c);
    vec2 rotatedUv = center + rotatedDir * dist / currentScale;

    if (rotatedUv.x < 0.0 || rotatedUv.x > 1.0 ||
      rotatedUv.y < 0.0 || rotatedUv.y > 1.0)
            return backColor;
    else
            return mix(getFromColor(rotatedUv), getToColor(rotatedUv), S_progress);
}

vec4 squeeze(vec2 uv){
    // Author: gre
    // License: MIT
    if(S_progress == 1.0) return getToColor(uv);
    float colorSeparation = 0.04; // = 0.04
    float y = 0.5 + (uv.y-0.5) / (1.0-S_progress);
    if (y < 0.0 || y > 1.0) {
        return getToColor(uv);
    }
    else {
        vec2 fp = vec2(uv.x, y);
        vec2 off = S_progress * vec2(0.0, colorSeparation);
        vec4 c = getFromColor(fp);
        vec4 cn = getFromColor(fp - off);
        vec4 cp = getFromColor(fp + off);
        return vec4(cn.r, c.g, cp.b, c.a);
    }
}

vec4 canaleaf (vec2 uv) {
  //if(S_progress == 0.0) return getFromColor(uv);
  vec2 leaf_uv = (uv - vec2(0.5))/10./pow(S_progress,3.5);
  leaf_uv.y -= 0.35;
  float r = 0.18;
  float o = -atan(leaf_uv.y , leaf_uv.x);
  return mix(getFromColor(uv), getToColor(uv),
  1.0-step(1. - length(leaf_uv)+r*(1.+sin(o))*(1.+0.9 * cos(8.*o))*(1.+0.1*cos(24.*o))*(0.9+0.05*cos(200.*o)), 1.));
}

void FragOut(vec4 color) {
    gl_FragColor = color * alpha;
}

void main() {
    vec2 uv = vec2(gl_TexCoord[0]);
    if(datas.y == 1) S_progress = 1.0 - progress;
    switch ( int(datas.x) ) {
        case 0:
            FragOut(displacement(uv));
        break;

        case 1:
           FragOut(directional(uv));
        break;

        case 2:
        case 3:
           FragOut(simplezoom(uv));

        break;

        case 4:
            FragOut(linearblur(uv));
        break;

        case 5:
            FragOut(waterdrop(uv));
        break;

        case 6:
        case 7:
            FragOut(glitchmemories(uv));
        break;

        case 8:
            FragOut(directionalwarp(uv));
        break;

        case 9:
            FragOut(bounce(uv));
        break;

        case 10:
        case 11:
        case 12:
            FragOut(morph(uv));
        break;

        case 13:
        case 14:
            FragOut(circlecrop(uv));
        break;

        case 15:
            FragOut(swirl(uv));
        break;

        case 16:
            FragOut(dreamy(uv));
        break;

        case 17:
        case 18:
        case 19:
        case 20:
            FragOut(gridflip(uv));
        break;

        case 21:
            FragOut(crazyparametricfun(uv));
        break;

        case 22:
        case 23:
            FragOut(kaleidoscope(uv));
        break;

        case 24:
        case 25:
        case 26:
        case 27:
            FragOut(burn(uv));
        break;

        case 28:
        case 29:
        case 30:
        case 31:
            FragOut(crosswarp(uv));
        break;

        case 32:
        case 33:
        case 34:
            FragOut(flyeye(uv));
        break;

        case 35:
        case 36:
        case 37:
            FragOut(rotate_scale_fade(uv));
        break;

        case 38:
        case 39:
        case 40:
        case 41:
            FragOut(squeeze(uv));
        break;

        case 42:
            FragOut(canaleaf(uv));
        break;

        case 99: // no transition
            gl_FragColor = getToColor(uv);
        break;
    }
}
