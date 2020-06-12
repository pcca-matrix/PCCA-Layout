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


    /*int test = int(datas.z);
    float a[2] = float[]( uv.y, 1.0 - uv.y );
    Muv.y = a[test];
    */
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

    // swf reverse fix !!!
    /*int test = int(datas.w);
    float a[2] = float[]( uv.y, 1.0 - uv.y );
    Muv.y = a[test];
    */

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

vec4 windowslice(vec2 uv){
  // Author: gre
  // License: MIT
  float count = 10.0;
  float smoothness = 0.5;
  float pr = smoothstep(-smoothness, 0.0, uv.x - S_progress * (1.0 + smoothness));
  float s = step(pr, fract(count * uv.x));
  return mix(getFromColor(uv), getToColor(uv), s);
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

vec4 PolkaDotsCurtain(vec2 uv){
    // author: bobylito
    // license: MIT
    const float SQRT_2 = 1.414213562373;
    float dots = 20.0;// = 20.0;
    vec2 center = vec2(0,0);// = vec2(0, 0);
    bool nextImage = distance(fract(uv * dots), vec2(0.5, 0.5)) < ( S_progress / distance(uv, center));
    return nextImage ? getToColor(uv) : getFromColor(uv);
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

vec4 wiperight(vec2 uv){
    // Author: Jake Nelson
    // License: MIT
  vec2 p=uv.xy/vec2(1.0).xy;
  vec4 a=getFromColor(p);
  vec4 b=getToColor(p);
  return mix(a, b, step(0.0+p.x,S_progress));
}

vec4 wipedown(vec2 uv){
    // Author: Jake Nelson
    // License: MIT
  vec2 p=uv.xy/vec2(1.0).xy;
  vec4 a=getFromColor(p);
  vec4 b=getToColor(p);
  return mix(a, b, step(1.0-p.y,S_progress));
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

vec4 colourdistance(vec2 uv){
    // License: MIT
    // Author: P-Seebauer
  float power = 5.0; // = 5.0
  vec4 fTex = getFromColor(uv);
  vec4 tTex = getToColor(uv);
  float m = step(distance(fTex, tTex), S_progress);
  return mix(
    mix(fTex, tTex, m),
    tTex,
    pow(S_progress, power)
  );
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

vec4 radial(vec2 uv){
    // License: MIT
    // Author: Xaychru
    float smoothness; // = 1.0
    vec2 rp = uv*2.-1.;
    return mix(
        getToColor(uv),
        getFromColor(uv),
        smoothstep(0., smoothness, atan(rp.y,rp.x) - (S_progress-.5) * PI * 2.5)
    );
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

vec4 undulatingburnout(vec2 uv) {
  vec2 center = vec2(0.5); // = vec2(0.5)
  vec3 color = vec3(0.0); // = vec3(0.0)
  float dist = distance(center, uv);
  float m = getGradient(getWave(uv), dist);
  vec4 cfrom = getFromColor(uv);
  vec4 cto = getToColor(uv);
  return mix(mix(cfrom, cto, m), mix(cfrom, vec4(color, 1.0), 0.75), step(m, -2.0));
}


vec4 crosshatch(vec2 uv){
    // License: MIT
    // Author: pthrasher
    vec2 center = vec2(0.5); // = vec2(0.5)
    float threshold = 3.0; // = 3.0
    float fadeEdge = 0.1; // = 0.1
    float dist = distance(center, uv) / threshold;
    float r = S_progress - min(rand(vec2(uv.y, 0.0)), rand(vec2(0.0, uv.x)));
    return mix(getFromColor(uv), getToColor(uv), mix(0.0, mix(step(dist, r), 1.0, smoothstep(1.0-fadeEdge, 1.0, S_progress)), smoothstep(0.0, fadeEdge, S_progress)));

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


vec4 windowblinds(vec2 uv){
    // Author: Fabien Benetou
    // License: MIT
  float t = S_progress;
  if (mod(floor(uv.y*100.*S_progress),2.)==0.)
    t*=2.-.5;
    return mix(
    getFromColor(uv),
    getToColor(uv),
    mix(t, S_progress, smoothstep(0.8, 1.0, S_progress))
  );
}


vec4 pinwheel(vec2 uv){
    // Author: Mr Speaker
    // License: MIT
    float speed = 2.0; // = 2.0;
    vec2 p = uv.xy / vec2(1.0).xy;
    float circPos = atan(p.y - 0.5, p.x - 0.5) + S_progress * speed;
    float modPos = mod(circPos, 3.1415 / 4.);
    float signed = sign(S_progress - modPos);
    return mix(getToColor(p), getFromColor(p), step(signed, 0.5));
}


vec4 angular(vec2 uv){
    // Author: Fernando Kuteken
    // License: MIT
    float startingAngle = 90.0; // = 90;
    float offset = startingAngle * PI / 180.0;
    float angle = atan(uv.y - 0.5, uv.x - 0.5) + offset;
    float normalizedAngle = (angle + PI) / (2.0 * PI);
    normalizedAngle = normalizedAngle - floor(normalizedAngle);
   return mix(
        getFromColor(uv),
        getToColor(uv),
        step(normalizedAngle, S_progress)
    );
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


vec4 circleopen(vec2 uv){
    // author: gre
    // License: MIT
    float smoothness = 0.3; // = 0.3
    bool opening = true; // = true
    const vec2 center = vec2(0.5, 0.5);
    const float SQRT_2 = 1.414213562373;
    float x = opening ? S_progress : 1.-S_progress;
    float m = smoothstep(-smoothness, 0.0, SQRT_2*distance(center, uv) - x*(1.+smoothness));
    return mix(getFromColor(uv), getToColor(uv), opening ? 1.-m : m);
}

vec4 colorphase(vec2 uv){
    // Author: gre
    // License: MIT
    // Usage: fromStep and toStep must be in [0.0, 1.0] range
    // and all(fromStep) must be < all(toStep)
    vec4 fromStep = vec4(0.0, 0.2, 0.4, 0.0); // = vec4(0.0, 0.2, 0.4, 0.0)
    vec4 toStep = vec4(0.6, 0.8, 1.0, 1.0); // = vec4(0.6, 0.8, 1.0, 1.0)
    vec4 a = getFromColor(uv);
    vec4 b = getToColor(uv);
    return mix(a, b, smoothstep(fromStep, toStep, vec4(S_progress)));
}


vec4 crosswarp(vec2 uv){
    // Author: Eke Péter <peterekepeter@gmail.com>
    // License: MIT
    float x = S_progress;
    x=smoothstep(.0,1.0,(x*2.0+uv.x-1.0));
    return mix(getFromColor((uv-.5)*(1.-x)+.5), getToColor((uv-.5)*x+.5), x);
}

vec4 directionalwipe(vec2 uv){
    // Author: gre
    // License: MIT
    vec2 direction = vec2(1.0, -1.0); // = vec2(1.0, -1.0)
    float smoothness = 0.5; // = 0.5
    const vec2 center = vec2(0.5, 0.5);
    vec2 v = normalize(direction);
    v /= abs(v.x)+abs(v.y);
    float d = v.x * center.x + v.y * center.y;
    float m =
    (1.0-step(S_progress, 0.0)) * // there is something wrong with our formula that makes m not equals 0.0 with S_progress is 0.0
    (1.0 - smoothstep(-smoothness, 0.0, v.x * uv.x + v.y * uv.y - (d-0.5+S_progress*(1.+smoothness))));
    return mix(getFromColor(uv), getToColor(uv), m);

}

vec4 fade(vec2 uv){
  return mix(
    getFromColor(uv),
    getToColor(uv),
    S_progress
  );
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


vec4 polar(vec2 uv){
    // Author: Fernando Kuteken
    // License: MIT
    int segments = 5; // = 5;
    float angle = atan(uv.y - 0.5, uv.x - 0.5) - 0.5 * PI;
    float normalized = (angle + 1.5 * PI) * (2.0 * PI);

    float radius = (cos(float(segments) * angle) + 4.0) / 4.0;
    float difference = length(uv - vec2(0.5, 0.5));

    if (difference > radius * S_progress)
        return getFromColor(uv);
    else
        return getToColor(uv);
}

vec4 randomsquare(vec2 uv){
    // Author: gre
    // License: MIT
    ivec2 size = ivec2(10, 10); // = ivec2(10, 10)
    float smoothness = 0.5; // = 0.5
    float r = rand(floor(vec2(size) * uv));
    float m = smoothstep(0.0, -smoothness, r - (S_progress * (1.0 + smoothness)));
    return mix(getFromColor(uv), getToColor(uv), m);
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

vec4 squarewire(vec2 uv){
    // Author: gre
    // License: MIT
    ivec2 squares = ivec2(10,10) ;// = ivec2(10,10)
    vec2 direction = vec2(1.0, -0.5);// = vec2(1.0, -0.5)
    float smoothness = 1.6; // = 1.6
    const vec2 center = vec2(0.5, 0.5);
    vec2 v = normalize(direction);
    v /= abs(v.x)+abs(v.y);
    float d = v.x * center.x + v.y * center.y;
    float offset = smoothness;
    float pr = smoothstep(-offset, 0.0, v.x * uv.x + v.y * uv.y - (d-0.5+S_progress*(1.+offset)));
    vec2 squarep = fract(uv*vec2(squares));
    vec2 squaremin = vec2(pr/2.0);
    vec2 squaremax = vec2(1.0 - pr/2.0);
    float a = (1.0 - step(S_progress, 0.0)) * step(squaremin.x, squarep.x) * step(squaremin.y, squarep.y) * step(squarep.x, squaremax.x) * step(squarep.y, squaremax.y);
    return mix(getFromColor(uv), getToColor(uv), a);
}


vec4 wind(vec2 uv){
    // Author: gre
    // License: MIT
    float size = 0.2; // = 0.2
    float r = rand(vec2(0, uv.y));
    float m = smoothstep(0.0, -size, uv.x*(1.0-size) + size*r - (S_progress * (1.0 + size)));
    return mix(
        getFromColor(uv),
        getToColor(uv),
        m
    );
}


vec4 squeeze(vec2 uv){
    // Author: gre
    // License: MIT
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

/* Doom Sctreen Transitions */
// Author: Zeh Fernando
// License: MIT

float wave(int num, int bars){
  float frequency = 0.5; // = 0.5 // Speed variation horizontally. the bigger the value, the shorter the waves
  float fn = float(num) * frequency * 0.1 * float(bars);
  return cos(fn * 0.5) * cos(fn * 0.13) * sin((fn+10.0) * 0.3) / 2.0 + 0.5;
}

float drip(int num, int bars) {
  return sin(float(num) / float(bars - 1) * 3.141592);
}

vec4 doomscreentransition(vec2 uv) {
    int bars = 30; // = 30 Number of total bars/columns
    float amplitude = 2.0; // = 2 // Multiplier for speed ratio. 0 = no variation when going down, higher = some elements go much faster
    float noise = 0.1; // = 0.1 // Further variations in speed. 0 = no noise, 1 = super noisy (ignore frequency)
    float dripScale = 0.5; // = 0.5 // How much the bars seem to "run" from the middle of the screen first (sticking to the sides). 0 = no drip, 1 = curved drip
    int bar = int(uv.x * (float(bars)));
    float scale = 1.0 + ( (noise == 0.0 ? wave(bar, bars) : mix(wave(bar, bars), rand( vec2(0.0, bar) ), noise)) + (dripScale == 0.0 ? 0.0 : drip(bar, bars)  * dripScale ) ) * amplitude;
    //float scale = 1.0 + pos(bar) * amplitude;
    float phase = S_progress * scale;
    float posY = uv.y / vec2(1.0).y;
    vec2 p;
    vec4 c;
    if (phase + posY < 1.0) {
        p = vec2(uv.x, uv.y + mix(0.0, vec2(1.0).y, phase)) / vec2(1.0).xy;
        c = getFromColor(p);
    } else {
        p = uv.xy / vec2(1.0).xy;
        c = getToColor(p);
    }
    return c;
}


/*swap*/

// Author: gre
// License: MIT

bool inBounds (vec2 p) {
  const vec2 boundMin = vec2(0.0, 0.0);
  const vec2 boundMax = vec2(1.0, 1.0);
  return all(lessThan(boundMin, p)) && all(lessThan(p, boundMax));
}

vec2 project (vec2 p) {
  return p * vec2(1.0, -1.2) + vec2(0.0, -0.02);
}

vec4 bgColor (vec2 p, vec2 pfr, vec2 pto) {
  float reflection = 0.4; // = 0.4
  const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
  vec4 c = black;
  pfr = project(pfr);
  if (inBounds(pfr)) {
    c += mix(black, getFromColor(pfr), reflection * mix(1.0, 0.0, pfr.y));
  }
  pto = project(pto);
  if (inBounds(pto)) {
    c += mix(black, getToColor(pto), reflection * mix(1.0, 0.0, pto.y));
  }
  return c;
}

vec4 swap(vec2 uv) {
    float perspective = 0.2; // = 0.2
    float depth = 3.0; // = 3.0
    vec2 pfr, pto = vec2(-1.);
    float size = mix(1.0, depth, S_progress);
    float persp = perspective * S_progress;
    pfr = (uv + vec2(-0.0, -0.5)) * vec2(size/(1.0-perspective*S_progress), size/(1.0-size*persp*uv.x)) + vec2(0.0, 0.5);

    size = mix(1.0, depth, 1.-S_progress);
    persp = perspective * (1.-S_progress);
    pto = (uv + vec2(-1.0, -0.5)) * vec2(size/(1.0-perspective*(1.0-S_progress)), size/(1.0-size*persp*(0.5-uv.x))) + vec2(1.0, 0.5);

    if (S_progress < 0.5) {
    if (inBounds(pfr)) {
      return getFromColor(pfr);
    }else
    if (inBounds(pto)) {
      return getToColor(pto);
    }
    }else{
      if (inBounds(pto)) {
        return getToColor(pto);
      }else
      if (inBounds(pfr)) {
        return getFromColor(pfr);
      }else{
        return bgColor(uv, pfr, pto);
     }
    }
}

// Pseudo-random noise function
// http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
float noise(vec2 co)
{
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy * S_progress, vec2(a, b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

/* HP PAGE Corner */
float amount = S_progress * (1.5 - -0.16) + -0.16;
float cylinderCenter = amount;
float cylinderAngle = 2.0 * PI * amount; // 360 degrees * amount
const float cylinderRadius = 1.0 / PI / 2.0;

vec3 hitPoint(float hitAngle, float yc, vec3 point, mat3 rrotation)
{
        float hitPoint = hitAngle / (2.0 * PI);
        point.y = hitPoint;
        return rrotation * point;
}

vec4 antiAlias(vec4 color1, vec4 color2, float distanc)
{
        const float scale = 512.0; // = 512.0
        const float sharpness = 3.0; // = 3.0
        distanc *= scale;
        if (distanc < 0.0) return color2;
        if (distanc > 2.0) return color1;
        float dd = pow(1.0 - distanc / 2.0, sharpness);
        return ((color2 - color1) * dd) + color1;
}

float distanceToEdge(vec3 point)
{
        float dx = abs(point.x > 0.5 ? 1.0 - point.x : point.x);
        float dy = abs(point.y > 0.5 ? 1.0 - point.y : point.y);
        if (point.x < 0.0) dx = -point.x;
        if (point.x > 1.0) dx = point.x - 1.0;
        if (point.y < 0.0) dy = -point.y;
        if (point.y > 1.0) dy = point.y - 1.0;
        if ((point.x < 0.0 || point.x > 1.0) && (point.y < 0.0 || point.y > 1.0)) return sqrt(dx * dx + dy * dy);
        return min(dx, dy);
}

vec4 seeThrough(float yc, vec2 p, mat3 rotation, mat3 rrotation)
{
        float hitAngle = PI - (acos(yc / cylinderRadius) - cylinderAngle);
        vec3 point = hitPoint(hitAngle, yc, rotation * vec3(p, 1.0), rrotation);
        if (yc <= 0.0 && (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0))
        {
            return getToColor(p);
        }

        if (yc > 0.0) return getFromColor(p);

        vec4 color = getFromColor(point.xy);
        vec4 tcolor = vec4(0.0);

        return antiAlias(color, tcolor, distanceToEdge(point));
}

vec4 seeThroughWithShadow(float yc, vec2 p, vec3 point, mat3 rotation, mat3 rrotation)
{
        float shadow = distanceToEdge(point) * 30.0;
        shadow = (1.0 - shadow) / 3.0;

        if (shadow < 0.0) shadow = 0.0; else shadow *= amount;

        vec4 shadowColor = seeThrough(yc, p, rotation, rrotation);
        shadowColor.r -= shadow;
        shadowColor.g -= shadow;
        shadowColor.b -= shadow;

        return shadowColor;
}

vec4 backside(float yc, vec3 point)
{
        vec4 color = getFromColor(point.xy);
        float gray = (color.r + color.b + color.g) / 15.0;
        gray += (8.0 / 10.0) * (pow(1.0 - abs(yc / cylinderRadius), 2.0 / 10.0) / 2.0 + (5.0 / 10.0));
        color.rgb = vec3(gray);
        return color;
}

vec4 behindSurface(vec2 p, float yc, vec3 point, mat3 rrotation)
{
        float shado = (1.0 - ((-cylinderRadius - yc) / amount * 7.0)) / 6.0;
        shado *= 1.0 - abs(point.x - 0.5);

        yc = (-cylinderRadius - cylinderRadius - yc);

        float hitAngle = (acos(yc / cylinderRadius) + cylinderAngle) - PI;
        point = hitPoint(hitAngle, yc, point, rrotation);

        if (yc < 0.0 && point.x >= 0.0 && point.y >= 0.0 && point.x <= 1.0 && point.y <= 1.0 && (hitAngle < PI || amount > 0.5))
        {
                shado = 1.0 - (sqrt(pow(point.x - 0.5, 2.0) + pow(point.y - 0.5, 2.0)) / (71.0 / 100.0));
                shado *= pow(-yc / cylinderRadius, 3.0);
                shado *= 0.5;
        }
        else
        {
                shado = 0.0;
        }
        return vec4(getToColor(p).rgb - shado, 1.0);
}

vec4 main_hpcorner(vec2 p) {

  const float angle = 100.0 * PI / 180.0;
        float c = cos(-angle);
        float s = sin(-angle);

        mat3 rotation = mat3( c, s, 0,
                                                                -s, c, 0,
                                                                -0.801, 0.8900, 1
                                                                );
        c = cos(angle);
        s = sin(angle);

        mat3 rrotation = mat3(	c, s, 0,
                                                                        -s, c, 0,
                                                                        0.98500, 0.985, 1
                                                                );

        vec3 point = rotation * vec3(p, 1.0);

        float yc = point.y - cylinderCenter;

        if (yc < -cylinderRadius)
        {
                // Behind surface
                return behindSurface(p,yc, point, rrotation);
        }

        if (yc > cylinderRadius)
        {
                // Flat surface
                return getFromColor(p);
        }

        float hitAngle = (acos(yc / cylinderRadius) + cylinderAngle) - PI;

        float hitAngleMod = mod(hitAngle, 2.0 * PI);
        if ((hitAngleMod > PI && amount < 0.5) || (hitAngleMod > PI/2.0 && amount < 0.0))
        {
                return seeThrough(yc, p, rotation, rrotation);
        }

        point = hitPoint(hitAngle, yc, point, rrotation);

        if (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0)
        {
                return seeThroughWithShadow(yc, p, point, rotation, rrotation);
        }

        vec4 color = backside(yc, point);

        vec4 otherColor;
        if (yc < 0.0)
        {
                float shado = 1.0 - (sqrt(pow(point.x - 0.5, 2.0) + pow(point.y - 0.5, 2.0)) / 0.71);
                shado *= pow(-yc / cylinderRadius, 3.0);
                shado *= 0.5;
                otherColor = vec4(0.0, 0.0, 0.0, shado);
        }
        else
        {
                otherColor = getFromColor(p);
        }

        color = antiAlias(color, otherColor, cylinderRadius - abs(yc));

        vec4 cl = seeThroughWithShadow(yc, p, point, rotation, rrotation);
        float dist = distanceToEdge(point);

        return antiAlias(color, cl, dist);
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

// Miss : Unzoom , corner out

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
           FragOut(simplezoom(uv));

        break;

        case 3:
            FragOut(windowslice(uv));
        break;

        case 4:
            FragOut(linearblur(uv));
        break;

        case 5:
            FragOut(waterdrop(uv));
        break;

        case 6:
            FragOut(glitchmemories(uv));
        break;

        case 7:
            FragOut(PolkaDotsCurtain(uv));
        break;

        case 8:
            FragOut(directionalwarp(uv));
        break;

        case 9:
            FragOut(bounce(uv));
        break;

        case 10:
            FragOut(wiperight(uv));
        break;

        case 11:
            FragOut(wipedown(uv));
        break;

        case 12:
            FragOut(morph(uv));
        break;

        case 13:
            FragOut(colourdistance(uv));
        break;

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
            FragOut(gridflip(uv));
        break;

        case 18:
            FragOut(radial(uv));
        break;

        case 19:
            FragOut(undulatingburnout(uv));
        break;

        case 20:
            FragOut(crosshatch(uv));
        break;

        case 21:
            FragOut(crazyparametricfun(uv));
        break;

        case 22:
            FragOut(kaleidoscope(uv));
        break;

        case 23:
            FragOut(windowblinds(uv));
        break;

        case 24:
            FragOut(pinwheel(uv));
        break;

        case 25:
            FragOut(angular(uv));
        break;

        case 26:
            FragOut(burn(uv));
        break;

        case 27:
            FragOut(circleopen(uv));
        break;

        case 28:
            FragOut(colorphase(uv));
        break;

        case 29:
            FragOut(crosswarp(uv));
        break;

        case 30:
            FragOut(directionalwipe(uv));
        break;

        case 31:
            FragOut(fade(uv));
        break;

        case 32:
            FragOut(flyeye(uv));
        break;

        case 33:
            FragOut(polar(uv));
        break;

        case 34:
            FragOut(randomsquare(uv));
        break;

        case 35:
            FragOut(rotate_scale_fade(uv));
        break;

        case 36:
            FragOut(squarewire(uv));
        break;

        case 37:
            FragOut(wind(uv));
        break;

        case 38:
            FragOut(squeeze(uv));
        break;

        case 39:
            FragOut(doomscreentransition(uv));
        break;

        case 40:
            FragOut(swap(uv));
        break;

        case 41:
            FragOut(main_hpcorner(uv)); // hp corner can only be used right to left
        break;

        case 42:
            FragOut(canaleaf(uv));
        break;

        case 99: // no transition
            gl_FragColor = getToColor(uv);
        break;

    }
}
