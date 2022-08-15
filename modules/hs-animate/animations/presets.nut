///////////////////////////////////////////////////
//
// HyperSpin Animations for pcca layout
// PCCA-Matrix 2022
//
///////////////////////////////////////////////////

class PresetAnimation extends Animation {
    supported = ["x", "y", "width", "height", "origin_x", "origin_y", "rotation", "rgb", "red", "green", "blue", "bg_red", "bg_green", "bg_blue", "sel_red", "sel_green", "sel_blue", "sel_alpha", "selbg_red", "selbg_green", "selbg_blue", "selbg_alpha", "alpha", "skew_x", "skew_y", "pinch_x", "pinch_y", "subimg_x", "subimg_y", "charsize", "zorder" ];
    unique_keys = null;
    pr_opt = null;
    ParticlesArray = null; // Particles medias clones Array
    function defaults(params){
        base.defaults(params);
        opts = merge_opts({
            key = null,
            preset = null,
            preset_load = false,
            starting = "none",
            rest = null,
            rest_speed = 1.0,
            rotation = null,
            datas = {},
            bck_opts = {},
            rest_vars = {}
        }, opts);

        ParticlesArray = []
        return this;
    }

    function target(ref){
        base.target(ref);
        state( "origin", collect_state(ref) );
        return this;
    }

    function reset(){
        resting = false;
        running = false;
        last_update = 0;
        elapsed = 0;
        tick = 0;
        progress = 0;
        resting_progress = 0;
        play_count = 0;
        yoyoing = false;
        states.clear();
        callbacks.clear();
        pr_opt = null;
        opts.triggers.clear();
        opts.loops = 0
        opts.loops_delay = 0
        opts.loops_delay_from = true;
        opts.key = null
        opts.starting = "none"
        opts.rest = null
        opts.rest_speed = 1.0
        opts.rest_vars.clear();
        opts.from = null
        opts.to = null
        opts.preset = null
        opts.rotation = null
        opts.datas.clear()
        opts.bck_opts.clear()
        opts.then = null;
        opts.reverse = false;
        opts.yoyo = false;
        opts.delay = 0;
        opts.trigger_restart = true;
        key_interpolator.clear();
        opts.speed = 1.0;
        opts.delay_from = 0;
        opts.interpolator = CubicBezierInterpolator("linear");
        hide_particles();
        return;
    }

    function hide_particles(){
        foreach(a,b in ParticlesArray) ParticlesArray[a].file_name = "";
    }

    function preset( str , opt = false){
        reset();
        unset_rotation(opts.target.rotation, opts.target);
        //if(opts.target.rotation) unset_rotation(opts.target.rotation, opts.target);
        state( "origin", collect_state(opts.target) );
        pr_opt = opt;
        (str != "none"  ? opts.preset <- str : opts.preset <- "linear");
        opts.preset_load = true;
        return this;
    }

    function key( key ) { opts.key <- key; return this; }
    function rotation( val ) { opts.rotation = (abs(val) > 0 ? val.tofloat() : null ); return this; }
    function starting( str ) { opts.starting <- str; return this; }
    function datas( val ) { opts.datas <- val; return this; }
    function rest( str ) { opts.rest = ( str != "none" ?  str : null ); return this; }

    function stop(){
        state( "finish", collect_state(opts.target) ); // maybe just clone state origin
        if(!states.rawin("finish") && states.to){
            foreach(k,v in states.to){
               states["finish"][k] = v;
            }
        }
        base.stop();
    }

    function anim_rest(){
        local speed = 1.0;
        local obj = opts.target;
        unset_rotation(obj.rotation , obj);
        switch(opts.rest){
            case "shake": // must be redone !!
                set_rotation(obj.rotation , obj);
                speed = 1.5
                local itr = CubicBezierInterpolator("ease-out-back");
                if(resting_progress <= 0.5){
                    obj.x = itr.interpolate(states["finish"].x, states["finish"].x+(flw * 0.02), normalize(resting_progress, 0.0, 0.50) );
                    obj.y = itr.interpolate(states["finish"].y, states["finish"].y-(flw * 0.02), normalize(resting_progress, 0.0, 0.50) );
                }else{
                    obj.x = itr.interpolate(states["finish"].x+(flw * 0.02), states["finish"].x, normalize(resting_progress, 0.50, 1.0) );
                    obj.y = itr.interpolate(states["finish"].y-(flw * 0.02), states["finish"].y, normalize(resting_progress, 0.50, 1.0) );
                }
                if(resting_progress == 1.0) resting = false;
                unset_rotation(obj.rotation , obj);
            break;

            case "rock":
            case "rock fast": // must be redone !!
                if( !("cnt" in opts.datas) ){
                    opts.datas.cnt <- 0;
                    opts.datas.r <- obj.rotation;
                }
                if(opts.rest == "rock fast") speed = 0.80; else speed = 0.45;
                local itr = "ease-in-quart";
                local rt = 0;
                local angle = 25;
                switch(opts.datas.cnt){
                    case 0:
                        speed*=2
                        rt = PennerInterpolator(itr).interpolate(opts.datas.r, opts.datas.r - angle, resting_progress);
                    break;

                    case 1:
                        rt = PennerInterpolator(itr).interpolate(opts.datas.r - angle, opts.datas.r + angle, resting_progress);
                    break;

                    case 2:
                        rt = PennerInterpolator(itr).interpolate(opts.datas.r + angle, opts.datas.r - angle, resting_progress);
                    break;
                }

                if(rt) obj.rotation = rt

                if(resting_progress >= 1.0){
                    opts.datas.cnt = (opts.datas.cnt > 1 ? 1 : opts.datas.cnt+=1);
                    resting_progress = 0.0
                }
            break;

            case "squeeze": // OK
                speed = 2.4;
                local nw,nh;
                local ow = states["finish"].width;
                local oh = states["finish"].height;
                if(resting_progress <= 0.3){
                    nw = CubicBezierInterpolator("linear").interpolate(ow, ow * 1.2 ,normalize(resting_progress, 0, 0.3) );
                    nh = CubicBezierInterpolator("linear").interpolate(oh, oh * 0.2 ,normalize(resting_progress, 0, 0.3) );
                    obj.x-= (nw-obj.width) * 0.5
                    obj.y+= (obj.height-nh) * 0.5
                    obj.height -= (obj.height-nh)
                    obj.width += (nw-obj.width)
                }else if(resting_progress <= 0.7){
                    nw = CubicBezierInterpolator("linear").interpolate(ow * 1.2, ow * 0.6 ,normalize(resting_progress, 0.3, 0.7) );
                    nh = CubicBezierInterpolator("linear").interpolate(oh * 0.2, oh * 1.7 ,normalize(resting_progress, 0.3, 0.7) );
                    obj.x+= (obj.width-nw) * 0.5
                    obj.y-= (nh-obj.height) * 0.5
                    obj.height += (nh-obj.height)
                    obj.width -= (obj.width-nw)
                }else{
                    nw = CubicBezierInterpolator("elastic-back").interpolate(ow * 0.6, ow ,normalize(resting_progress, 0.7, 1.0) );
                    nh = CubicBezierInterpolator("elastic-back").interpolate(oh * 1.7, oh ,normalize(resting_progress, 0.7, 1.0) );
                    obj.x-= (nw-obj.width) * 0.5
                    obj.y+= (obj.height-nh) * 0.5
                    obj.height -= (obj.height-nh)
                    obj.width += (nw-obj.width)
                }
                if(resting_progress == 1.0) resting = false;
            break;

            case "pulse":
            case "pulse fast": // OK check easing
                (opts.rest == "pulse fast" ? speed = 0.85 : speed = 0.40);
                local zoom = 1.24;
                local nw,nh;
                local itr = CubicBezierInterpolator("ease-in-out-circle");
                if(resting_progress <= 0.5){
                    nw = itr.interpolate(states["finish"].width, states["finish"].width * zoom, resting_progress);
                    nh = itr.interpolate(states["finish"].height, states["finish"].height * zoom , resting_progress);
                    obj.x-= (nw-obj.width) * 0.5
                    obj.y+= (obj.height-nh) * 0.5
                    obj.height -= (obj.height-nh)
                    obj.width += (nw-obj.width)
                }else{
                    nw = itr.interpolate(states["finish"].width * zoom, states["finish"].width , resting_progress);
                    nh = itr.interpolate(states["finish"].height * zoom, states["finish"].height , resting_progress);
                    obj.x-= (nw-obj.width) * 0.5
                    obj.y+= (obj.height-nh) * 0.5
                    obj.height -= (obj.height-nh)
                    obj.width += (nw-obj.width)
                }
                if(resting_progress == 1.0) resting_progress = 0.0;
            break;

           case "spin":
           case "spin slow":
           case "spin fast":
                switch(opts.rest){
                    case "spin fast":
                        speed = 50.0;
                    break;
                    case "spin slow":
                        speed = 20.0;
                    break;
                    default:
                        speed = 30.00;
                    break;
                }

                local r = obj.rotation + opts.smoothing * speed;
                if( r >= 360 ) r = 0.0;
                obj.rotation = r
            break;

            case "hover":
            case "hover vertical":
            case "hover horizontal":
                resting_hover(obj, opts.rest);
            break;

            case "horizontal panning":
            case "vertical panning":
            case "random panning":
                resting_bck(obj, opts.rest);
            break;
        }

        resting_progress = clamp( resting_progress + ( opts.smoothing * speed ), 0.0, 1.0);
        set_rotation(obj.rotation , obj);
        base.anim_rest();
    }

    function start() {
        //save target states
        states["current"] <- collect_state( opts.target );
        state( "start", clone(states["current"]) );

        if(opts.preset == "random"){
            local rnd = ["linear","ease","elastic","elastic bounce","flip","fade","bounce","blur","pixelate","zoom out","pixelate zoom out","strobe",
            "grow","grow bounce","grow blur","grow x","grow y","grow center shrink","flag","stripes","stripes 2"];
            opts.preset = rnd[rnd_num(0,rnd.len()-1,"int")];
        }

        if(opts.preset == "fade" && opts.name == "video") opts.preset = "video_fade";
        if (  opts.preset && opts.preset_load ) {
            try {
                local t = PresetA[opts.preset];
                local res = t(opts.target, pr_opt);
                set_rotation(opts.target.rotation, opts.target)
                opts.preset_load = false;
            }catch(e) {
                return false;
            }
        }
        if(opts.rest){
            on("stop", function(anim){
                anim.resting = true;
            });
        }

        if(opts.rotation){
            if(typeof( opts.to ) == "table"){
               opts.to.rotation <- opts.rotation;
            }else{
                switch(opts.preset){
                    case "sweep left":
                    case "sweep right":
                        states["D"].rotation <- opts.rotation;
                    break;
                    default:
                        if(states.rawin("B")) states["B"].rotation <- opts.rotation; // fort states anim , anime on first part
                    break;
                }
            }
        }

        //evaluate states["from"] and states["to"] from opts.from and opts.to
        foreach( i, val in [ "from", "to" ]) {
            if ( opts[val] == null ) {
                //use default state
                states[val] <- states[opts.default_state];
            } else if ( typeof( opts[val] ) == "string" && opts[val] in states ) {
                //use requested state
                states[val] <- states[ opts[val] ];
            } else if ( typeof( opts[val] ) == "table" ) {
                //use provided table
                states[val] <- opts[val];
            } else {
                //generate a table using opts.key as key, opts.from/to as val
                states[val] <- {}
                states[val][opts.key] <- opts[val];
            }
        }

        //ensure all keys are accounted for
        foreach( key, val in states["to"] )
            if ( supported.find(key) != null )
                states["from"][key] <- ( key in states["from"] ) ? states["from"][key] : ( opts.default_state in states ) ? states[opts.default_state][key] : states["current"][key];
        foreach( key, val in states["from"] )
            if ( supported.find(key) != null )
                states["to"][key] <- ( key in states["to"] ) ? states["to"][key] : ( opts.default_state in states ) ? states[opts.default_state][key] : states["current"][key];

        //store a table of unique keys we are animating
        unique_keys = {}
        foreach ( key, val in states["from"] )
            if ( supported.find(key) != null ){
                if ( states["from"][key] != states["to"][key] ) unique_keys[key] <- "";
            }
        base.start();
    }

    function update() {
        switch(opts.preset){
            case "rain float":
                local x=0; local y=0; local v=0;
                if( progress == 0.0 ) return;
                progress = 0.1;
                for ( local i=0; i < ParticlesArray.len(); i++ ){
                    y = ParticlesArray[i].y + opts.datas.s[i];
                    opts.datas.t[i] += opts.datas.x[i];
                    v = cos(opts.datas.t[i] / 100) * 8;
                    if(ParticlesArray[i].rotation > 0)
                        x = ParticlesArray[i].x - v;
                    else
                        x = ParticlesArray[i].x + v;

                    if( ParticlesArray[i].y >= flh ){
                        y = - (ParticlesArray[i].height + rnd_num(0,flh * 0.10,"int"));
                        x = rnd_num(0,flw,"int");
                        opts.datas.x[i] = rnd_num(0.0,2.0,"float");
                    }

                    ParticlesArray[i].rotation = v;
                    ParticlesArray[i].y = y;
                    ParticlesArray[i].x = x;
                }
            break;

            case "arc grow":
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                local arc;

                if( opts.starting == "right"){
                    arc = quadbezier(

                        flw , flh * 0.5 - opts.target.height * 0.5,

                        flw * 0.5 , -(flh * 0.25) + opts.target.height * 0.5 ,

                        -opts.target.width * 0.5, flh + opts.target.height * 0.5,

                        progress);

                }else{

                    arc = quadbezier(

                        0 , flh * 0.5,

                        flw * 0.5 , -(flh * 0.25) + opts.target.height * 0.5 ,

                        flw + opts.target.width * 0.5 , flh + opts.target.height * 0.5 ,

                        progress);
                }
                opts.target.width = states["origin"].width * 2.4 * progress + 0.1;
                opts.target.height = states["origin"].height * 2.4 * progress + 0.1;
                opts.target.x = arc.x - opts.target.width * 0.5;
                opts.target.y = arc.y - opts.target.height * 0.5;
                if(opts.rotation) opts.target["rotation"] = opts.interpolator.interpolate(0, opts.rotation, progress); // animated rotation ( only if > 180 )
                set_rotation(opts.target["rotation"], opts.target);
                if(progress == 1.0) restart();
            break;

            case "arc shrink":
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                local arc;
                // HS left/right is inverted !!!!
                if( opts.starting == "right"){

                    arc = quadbezier(
                        flw, flh

                        flw * 0.5 , -(flh * 0.50) - opts.target.height * 0.5,

                        -opts.target.width  , flh * 0.5 - opts.target.height * 0.5,

                        progress
                    );


                }else{
                    arc = quadbezier( //hs =  right , bottom, top, none

                        -opts.target.width * 2, flh,

                        flw * 0.5 , -(flh * 0.50) - opts.target.height * 0.5,

                        flw , flh * 0.5 ,

                        progress
                    );
                }

                opts.target.width  = states["origin"].width * 2.4  - (states["origin"].width * 2.4 * progress) + 0.1;
                opts.target.height = states["origin"].height * 2.4 - (states["origin"].height * 2.4 * progress) + 0.1;
                opts.target.x = arc.x + opts.target.width * 0.5;
                opts.target.y = arc.y + opts.target.height * 0.5;
                if(opts.rotation) opts.target["rotation"] = opts.interpolator.interpolate(0, opts.rotation, progress); // animated rotation ( only if > 180 )
                set_rotation(opts.target["rotation"], opts.target);
                if(progress == 1.0) restart();
            break;

            case "pendulum":
                //starting : top left , bottom = right
                if (elapsed < opts.delay) return true;  // wait delay before start except in HS theme !  hs does not apply the delay
                if( progress == 0.0 ) return;
                if(opts.datas.loops > 0 && opts.datas.nbr >= opts.datas.loops){ progress=1.0; return }
                if(opts.datas.rotation > PI || opts.datas.rotation < 0){
                    opts.datas.nbr++;
                    opts.datas.step=-opts.datas.step;
                }
                opts.datas.rotation+=opts.datas.step;
                local x = (states["origin"].x ) + cos( opts.datas.rotation ) * opts.datas.radius
                local y = (states["origin"].y - opts.datas.radius ) + sin( opts.datas.rotation ) * opts.datas.radius
                if(!opts.datas.hd) y = Screen["center"].y - (opts.target.height * 0.60) - opts.datas.radius  + sin( opts.datas.rotation ) * opts.datas.radius
                local angle = opts.datas.rotation / PI * 180 - 90; // 90 starting angle
                opts.target.rotation = angle;
                opts.target.x = x;
                opts.target.y = y;
                set_rotation(angle, opts.target);
                progress = 0.1;
            break;

            case "bounce random":
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                unset_rotation(opts.target["rotation"], opts.target);
                random_bounce(opts.target)
                if(progress == 1.0) progress = 0.0;
            break;

            case "bounce around 3d":
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                unset_rotation(opts.target["rotation"], opts.target);
                bounce_around(opts.target);
            break;

            default:
                foreach( key, val in states["to"] ){
                    if ( key == "rgb" ) {
                        opts.target.set_rgb(
                            opts.interpolator.interpolate(_from[key][0], _to[key][0], progress),
                            opts.interpolator.interpolate(_from[key][1], _to[key][1], progress),
                            opts.interpolator.interpolate(_from[key][2], _to[key][2], progress)
                        )
                        if ( _from[key].len() > 3 && _to[key].len() > 3 )
                            opts.interpolator.interpolate(_from[key][3], _to[key][3], progress)
                    } else if ( supported.find(key) != null ) {
                        // if from width/height is set to 0.1 unhide object (hidden in layout !)
                        if(key == "width" || key == "height") if( _from[key] <= 0.1 && progress > 0 && !opts.target.visible) opts.target.visible = true;

                        try {
                            if(key_interpolator[key]) opts.target[key] = key_interpolator[key].interpolate(_from[key], _to[key], progress)
                        }
                        catch(e){
                            opts.target[key] = opts.interpolator.interpolate(_from[key], _to[key], progress);
                        }

                        if ( key == "alpha" && opts.name != "" ){
                           ArtObj[opts.name].shader.set_param( "alpha", opts.interpolator.interpolate( _from["alpha"] / 255 , _to["alpha"] / 255, progress) );
                        }
                    }
                }
                //set_rotation(opts.target["rotation"], opts.target);
            break;
        }

        set_rotation(opts.target["rotation"], opts.target);
        states["current"] <- collect_state(opts.target);
        base.update();
    }

    PresetA = {
        "linear": //OK (Default without Preset)
        function(...){
            local obj = vargv[0];
            if(opts.delay > 0 && opts.duration == 0){
                opts.duration = 1
                opts.starting = "top"
            }
            opts.from <- { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to <- { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator <- CubicBezierInterpolator("linear")
        },

        "ease": //OK
        function(...){
            local obj = vargv[0];
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = CubicBezierInterpolator("ease")
        },

        "elastic": // OK (can be better)
        function(...){
            local obj = vargv[0];
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = PennerInterpolator("ease-out-elastic")
        },

        "elastic bounce": // OK (can be better)
        function(...){
            local obj = vargv[0];
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = PennerInterpolator("ease-out-elastic");
        },

        "flip": // OK
        function(...){
            local obj = vargv[0];
            local startx=POSITIONS[opts.starting](obj).x;
            local starty=POSITIONS[opts.starting](obj).y;
            opts.interpolator = CubicBezierInterpolator("ease-in-out-quart")
            if(opts.starting == "bottom" || opts.starting == "top"){
                key_interpolator["y"] <- CubicBezierInterpolator("linear");
                opts.interpolator = CubicBezierInterpolator("ease-in-quart")
            }else if(opts.starting == "left" || opts.starting == "right"){
               key_interpolator["x"] <- CubicBezierInterpolator("linear");
               opts.interpolator = CubicBezierInterpolator("ease-in-quart")
            }

            opts.from = { y=starty, width = 0.1, pinch_y=-states["origin"].height / 6,  x=startx + states["origin"].width * 0.5 };
            opts.to = { y=states["origin"].y, width=states["origin"].width, pinch_y = 0, x=states["origin"].x };

        },

        "fade": // OK
        function (...){
            local obj = vargv[0];
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y, alpha=0 };
            opts.to = { x=states["origin"].x,  y=states["origin"].y, alpha=255 };
            opts.interpolator = CubicBezierInterpolator("ease")
        },

        "bounce": // OK
        function(...){
            local obj = vargv[0];
            opts.interpolator = PennerInterpolator("ease-out-bounce")
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y };
        },

        "blur": // OK (can be better)
        function(...){
            local obj = vargv[0];
            blur(obj);
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y, alpha=0 };
            opts.to = { x=states["origin"].x,  y=states["origin"].y, alpha=255  };
            opts.interpolator = CubicBezierInterpolator("ease-in-out-quart")

        },

        "pixelate": // OK
        function(...){
            local obj = vargv[0];
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",1,0,0,0);
            anims_shader[art-1].duration(opts.duration)
            anims_shader[art-1].delay(opts.delay)
            anims_shader[art-1].play();

            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = CubicBezierInterpolator("ease-out-cubic");
        },

        "zoom out": // OK
        function(...){
            local obj = vargv[0];
            local mtpl = (fe.layout.width + (OFFSET * 2) ) / obj.width * 4.0;
            opts.from = { x=Screen["center"].x  - (obj.width * mtpl * 0.5), y=Screen["center"].y - (obj.height * mtpl * 0.5), height=obj.height * mtpl, width=obj.width * mtpl, alpha=0 };
            opts.to = { x=obj.x, y=obj.y, height=obj.height, width=obj.width, alpha=255  };
            opts.interpolator = PennerInterpolator("ease-out-sine");
        },

        "pixelate zoom out": // OK
        function(...){
            local obj = vargv[0];
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",1,0,0,0);
            anims_shader[art-1].duration(opts.duration)
            anims_shader[art-1].delay(opts.delay)
            anims_shader[art-1].play();
            local mtpl = (fe.layout.width+(OFFSET*2) ) / obj.width;
            opts.from = { x=Screen["center"].x  - (obj.width * mtpl * 0.5), y=Screen["center"].y - (obj.height * mtpl * 0.5), height=obj.height * mtpl, width=obj.width * mtpl, alpha=0 };
            opts.to = { x=obj.x, y=obj.y, height=obj.height, width=obj.width, alpha=255  };
            opts.interpolator = PennerInterpolator("ease-out-sine");
        },

        "chase": // OK
        function(...){
            local obj = vargv[0];
            local startx=POSITIONS["left"](obj).x - obj.width * 1.5;
            local endx=POSITIONS["right"](obj).x + obj.width * 1.5;

            local a= -1;
            local orig_subW = obj.subimg_width;
            local orig_subX = obj.subimg_x;
            if(opts.starting == "right"){
                startx=POSITIONS["right"](obj).x + obj.width*1.5;
                endx=POSITIONS["left"](obj).x - obj.width*1.5;
            }
            opts.from = {y=obj.y, x=startx}
            opts.to = {y=obj.y, x=endx}
            on("restart", function(anim) {
                if(a == -1){
                    orig_subW = obj.subimg_width;
                    orig_subX = obj.subimg_x;
                    flipx(obj)
                    a=0;
                }else{
                    obj.subimg_width = orig_subW;
                    obj.subimg_x = orig_subX;
                    a=-1;
                }
            })
            yoyo(true)
            loops(-1)
        },

        "sweep left": // OK
        function(...){
            local obj = vargv[0];
            state("A", { x=POSITIONS["left"](obj).x, y=obj.y} )
            state("B", { x=POSITIONS["right"](obj).x, y=obj.y } )
            state("C", { y=POSITIONS["top"](obj).y, x=states["origin"].x } )
            state("D", { y=states["origin"].y, x=states["origin"].x } )
            from("A")
            to("B")
            duration(opts.duration * 0.5)
            then(function(anim) {
                anim.from("C").to("D").delay(550).duration(opts.duration * 0.5 ).play()
            })
        },

        "sweep right": // OK
        function(...){
            local obj = vargv[0];
            state("A", { x=POSITIONS["right"](obj).x, y=obj.y } )
            state("B", { x=POSITIONS["left"](obj).x, y=obj.y } )
            state("C", { y=POSITIONS["top"](obj).y, x=states["origin"].x } )
            state("D", { y=states["origin"].y, x=states["origin"].x } )
            from("A")
            to("B")
            duration(opts.duration * 0.5)
            then(function(anim) {
                anim.from("C").to("D").delay(550).duration(opts.duration * 0.5).play()
            })
        },

        "strobe": // OK (mindless need rewrite ...)
        function(...){
            local obj = vargv[0];
            opts.datas.cnt <- 0;
            opts.from = { alpha=0, y=POSITIONS[opts.starting](obj).y, x=POSITIONS[opts.starting](obj).x };
            opts.to = { alpha=255, y=states["origin"].y, x=states["origin"].x };
            opts.interpolator = PennerInterpolator("ease-in-circle")
            delay( (opts.delay > 0 ? opts.delay + 500 : 500  ) )
            on("update",function(anim){
                anim.opts.datas.cnt++;
                anim.opts.datas.prev <- obj.alpha;
                if(anim.opts.datas.cnt > 100){
                    if(anim.opts.datas.cnt % 3 == 0){
                        ArtObj[anim.opts.name].shader.set_param( "alpha", anim.opts.datas.prev / 250 );
                    }
                    if(anim.opts.datas.cnt % 4 == 0){
                        ArtObj[anim.opts.name].shader.set_param( "alpha", 1.0 );
                    }
                }
            })
        },

        "grow": // OK
        function (...){
            local obj = vargv[0];
            opts.from = {width=0.1, height=0.1, x=POSITIONS[opts.starting](obj).x + obj.width * 0.5, y=POSITIONS[opts.starting](obj).y + obj.height * 0.5, alpha=0 };
            opts.to = {width=obj.width, height=obj.height, x=obj.x, y=obj.y, alpha=255};
        },

        "grow bounce": // OK
        function (...){
            local obj = vargv[0];
            opts.from = {width=0.1, height=0.1, x=POSITIONS[opts.starting](obj).x + obj.width * 0.5, y=POSITIONS[opts.starting](obj).y + obj.height * 0.5, alpha=0 };
            opts.to = {width=obj.width, height=obj.height, x=obj.x, y=obj.y, alpha=255};
            opts.interpolator = PennerInterpolator("ease-out-bounce")
        },

        "grow blur": // OK
        function (...){
           local obj = vargv[0];
           blur(obj);
           opts.from = {width=0.1, height=0.1, x=POSITIONS[opts.starting](obj).x + obj.width * 0.5, y=POSITIONS[opts.starting](obj).y + obj.height/2 };
           opts.to = {width=obj.width, height=obj.height, x=obj.x, y=obj.y};
        },

        "grow x": // OK
        function (...){
            local obj = vargv[0];
            opts.from = { width=0.1, x=POSITIONS[opts.starting](obj).x + (states["origin"].width * 0.5), y=POSITIONS[opts.starting](obj).y  };
            opts.to = { width=states["origin"].width, x=states["origin"].x,y=states["origin"].y  };
        },

        "grow y": // OK
        function (...){
            local obj = vargv[0];
            opts.from = { height=0.1, y=POSITIONS[opts.starting](obj).y+(obj.height * 0.5), x=POSITIONS[opts.starting](obj).x  };
            opts.to = { height=states["origin"].height, x=states["origin"].x, y=states["origin"].y };
        },

        "grow center shrink": // OK
        function (...){
            local obj = vargv[0];
            state("A",  { x=Screen["center"].x, y=Screen["center"].y, height=0.1, width=0.1 } )
            state("B",  { x=Screen["center"].x - (obj.width * 3 * 0.5)  , y=Screen["center"].y - (obj.height * 3 * 0.5), height=obj.height * 3, width=obj.width * 3 } )
            state("C",  { x=obj.x,  y=obj.y, height=obj.height, width=obj.width } )

            if (opts.rotation){
                states["A"].rotation <- obj.rotation
                states["B"].rotation <- opts.rotation
                states["C"].rotation <- opts.rotation + 360;
            }

            opts.from = "A";
            opts.to = "B";

            interpolator(PennerInterpolator("ease-in-sine") )
            duration(opts.duration * 0.5)
            then(function(anim) {
                anim.from("B").to("C").duration(opts.duration * 0.5).delay(350).play()
            })
        },

        "scroll":  //OK  (not really like HS)
        function (...){
            local obj = vargv[0];
            if(opts.starting == "left"){
              opts.from = { x=POSITIONS[opts.starting](obj).x, y=obj.y };
              opts.to = { x=POSITIONS["right"](obj).x ,y=obj.y };
            }else if(opts.starting == "right"){
              opts.from = { x=POSITIONS[opts.starting](obj).x, y=obj.y };
              opts.to = { x=POSITIONS["left"](obj).x ,y=obj.y };

            }else if(opts.starting == "top"){
              opts.from = { y=POSITIONS[opts.starting](obj).y, x=obj.x };
              opts.to = { y=POSITIONS["bottom"](obj).y ,x=obj.x};

            }else if(opts.starting == "bottom"){
              opts.from = { y=POSITIONS[opts.starting](obj).y, x=obj.x};
              opts.to = { y=POSITIONS["top"](obj).y, x=obj.x};
            }
            opts.interpolator = CubicBezierInterpolator("linear")
            opts.loops=-1;
        },

        "flag": // OK
        function(...){
            local obj = vargv[0];
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",2,0,0,0);
            anims_shader[art-1].duration(opts.duration);
            anims_shader[art-1].delay(opts.delay);
            anims_shader[art-1].play();
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y, alpha=75 };
            opts.to = { x=states["origin"].x,  y=states["origin"].y, alpha=255  };
        },

        "pendulum": // OK
        function (...){
            local obj = vargv[0];
            local divider = 35;
            opts.target.x = -2500; // hide away before starting animation
            local start = PI;
            if(opts.starting == "right" || opts.starting == "bottom") start = 0;
            opts.datas <- { "loops" : -1, "rotation" : start, "radius" : flw * 1.1  , "nbr" : 0, "hd" : vargv[1]  }
            opts.datas.step <- PI / (opts.duration / divider );
            if( opts.datas.loops > 0 ) opts.datas.loops *= 2;
        },

        "stripes": //OK  (not really like HS)
        function(...){
            local obj = vargv[0];
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",3,0,0,0);
            anims_shader[art-1].duration(opts.duration);
            anims_shader[art-1].delay(opts.delay + 500);
            anims_shader[art-1].play();

            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
        },

        "stripes 2": // OK (not really like HS)
        function(...){
            local obj = vargv[0];
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",4,0,0,0);
            anims_shader[art-1].duration(opts.duration)
            anims_shader[art-1].delay(opts.delay + 500);
            anims_shader[art-1].play();

            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
        },

        "arc grow": // OK
        function(...){
            opts.target.x = -2500; // hide away before starting animation
            return true;
        },

        "arc shrink": // OK
        function(...){
            opts.target.x = -2500; // hide away before starting animation
            return true;
        },

        "bounce random": // OK
        function(...){
            opts.datas <- { "velY" : 10, "velX" : 20, "damping" : 0.8 , "traction" : 0.8, "gravity" : 0.4, "bound" : false, "zoom" : 0 }
            return true;
        },

        "rain float": // OK
        function (...){
            local obj = vargv[0];
            opts.target.zorder-=1000
            local nx = ParticlesArray.len();
            if( nx < 4 ){ // add missings images if needed
                for ( local i=0; i < 4-nx; i++ ){ ParticlesArray.push(fe.add_image("" ,0 , 0 , 0 , 0)) }
            }

            for ( local i=0; i < 4; i++ ){
                local posx = ( i > 0 ? (obj.width * i) + rnd_num(0,obj.width,"int") : flw * 0.01)
                ParticlesArray[i].file_name = obj.file_name;
                ParticlesArray[i].visible = true;
                ParticlesArray[i].set_pos( posx , -( rnd_num(0,flh*0.5,"int") + obj.height ) , obj.width, obj.height);
                ParticlesArray[i].zorder-=1; // fix: hide obj on exit menu
            }
            opts.datas <- { "s": [4.1, 2.8, 3.4, 1.9], "t": [0,0,0,0], "x": [rnd_num(0.0,2.1,"float"), rnd_num(0.0,2.1,"float"), rnd_num(0.0,2.1,"float"), rnd_num(0.0,2.1,"float")] };
        },

        "bounce around 3d": // OK
        function(...){
            local obj = vargv[0];
            opts.datas <- { "velY" : 6, "velX" : 6, "zoom" : 0 ,"tw" : obj.width, "th" : obj.height }
            return true;
        },

        /* Video Only */
        "pump": // OK
        function(...){
            local obj = vargv[0];
            local part = opts.duration - (opts.duration / 3);
            obj.width = obj.width / 6;
            obj.height = obj.height / 6;
            if(opts.starting == "left" || opts.starting == "right"){
                state("A", { x=POSITIONS[opts.starting](obj).x + obj.width,  y=POSITIONS[opts.starting](obj).y + obj.height * 2.5} )
            }else if(opts.starting == "top" || opts.starting == "bottom"){
                state("A", { x=POSITIONS[opts.starting](obj).x + obj.width * 2.5,  y=POSITIONS[opts.starting](obj).y + obj.height} )
            }else{
              state("A", { x=obj.x + obj.width * 2.5  y=obj.y+ obj.height * 2.5} )
            }

            state("B", {  x=obj.x + obj.width * 2.5, y=obj.y + obj.height * 2.5  } )
            state("C", {  x=obj.x + obj.width * 2, y=obj.y + obj.height * 2, width=obj.width * 2, height=obj.height * 2} )
            state("D", {  x=obj.x + obj.width, y=obj.y + obj.height, width=obj.width * 4, height=obj.height * 4} )
            state("E", {  x=states["origin"].x, y=states["origin"].y , width=states["origin"].width, height=states["origin"].height } )
            from("A")
            to("B")
            easing("ease-out-back")
            duration(opts.duration / 3)
            then(function(anim) {
                anim.from("B").to("C").delay(0).duration(part / 3).easing("ease-in-out-back").play()
                then(function(anim) {
                    anim.from("C").to("D").delay(0).duration(part / 3).play()
                        then(function(anim) {
                            anim.from("D").to("E").delay(0).duration(part / 3 ).play()
                        })
                })
            })
        },

        "video_fade": // OK
        function (...){
            local obj = vargv[0];
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y };
            opts.interpolator = CubicBezierInterpolator("ease")

            anim_video_shader.param("alpha")
            anim_video_shader.from([0.0])
            anim_video_shader.to([1.0])
            anim_video_shader.delay(opts.delay)
            anim_video_shader.duration(opts.duration)
            anim_video_shader.interpolator(PennerInterpolator("ease-in-sine"))
            anim_video_shader.play()
        },

        "tv":
        function(...){
            local obj = vargv[0];
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y };
            opts.interpolator = CubicBezierInterpolator("ease")
            anim_video_shader.param("progress")
            anim_video_shader.from([0.0])
            anim_video_shader.to([1.0])
            anim_video_shader.duration(2850)
            anim_video_shader.delay(opts.delay)
            anim_video_shader.interpolator(PennerInterpolator("ease-in-sine"))
            anim_video_shader.play()
        },

        "tv zoom out":
        function(...){
            local obj = vargv[0];
            local mtpl = (fe.layout.width + (OFFSET * 2) ) / obj.width * 4.0;
            opts.from = { x=states["origin"].x  - (obj.width * mtpl * 0.5), y=states["origin"].y - (obj.height * mtpl * 0.5), height=obj.height * mtpl, width=obj.width * mtpl };
            opts.to = { x=states["origin"].x, y=states["origin"].y, height=obj.height, width=obj.width  };
            interpolator(PennerInterpolator("ease-out-sine"))

            anim_video_shader.param("progress")
            anim_video_shader.from([0.0])
            anim_video_shader.to([1.0])
            anim_video_shader.duration(2650)
            anim_video_shader.delay(opts.delay)
            anim_video_shader.interpolator(PennerInterpolator("ease-in-sine"))
            anim_video_shader.play()
        },

        /* Custom */
        "zoom": // OK
        function(...){
            local obj = vargv[0];
            local alpha = obj.alpha;
            local mtpl = vargv[1];
            if(typeof mtpl == "instance" || !mtpl){ // anim with fade and size option
                mtpl = (fe.layout.width+(OFFSET*2) ) / obj.width;
                alpha=0;
            }
            opts.from = {width=obj.width, height=obj.height, x=obj.x, y=obj.y, alpha=obj.alpha};
            opts.to = {width=obj.width * mtpl, height=obj.height * mtpl, x=obj.x + obj.width * 0.5 - (obj.width * mtpl * 0.5), y=obj.y + obj.height * 0.5 - (obj.height * mtpl * 0.5), alpha=alpha};
            interpolator(PennerInterpolator("ease-out-sine"));
        },

        "unzoom": // OK
        function(...){
            local obj = vargv[0];
            opts.from = {width=obj.width, height=obj.height, x=obj.x, y=obj.y, alpha=255 };
            opts.to = {width=0.1, height=0.1, x=obj.x + obj.width * 0.5 , y=obj.y + obj.height * 0.5, alpha=0 };
            interpolator(PennerInterpolator("ease-out-sine"));
        },

        "fade out": // OK
        function (...){
            local obj = vargv[0];
            opts.from <- { alpha=obj.alpha, x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to <- { alpha=0, x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = CubicBezierInterpolator("ease");
        },

        "expl": // OK
        function (...){
            local obj = vargv[0];
            local f={}; local t={};
            if(obj.x <= fe.layout.width  * 0.5){
                if(obj.y <= fe.layout.height * 0.5){
                    f.y <- obj.y;
                    t.y <- -fe.layout.height;
                    f.x <- obj.x
                    t.x <- obj.x
                }else{
                    f.x <- obj.x;
                    t.x <- -fe.layout.width;
                    f.y <- obj.y
                    t.y <- obj.y
                }
            }else{
                if(obj.y <= fe.layout.height * 0.5){
                    f.y <- obj.y;
                    t.y <- fe.layout.height * 2;
                    f.x <- obj.x;
                    t.x <- obj.x;
                }else{
                    f.x <- obj.x;
                    t.x <- fe.layout.width * 2;
                    f.y <- obj.y
                    t.y <- obj.y
                }
            }
            opts.from = f;
            opts.to = t;
        },

        "swirl":
        function (...){
            local obj = vargv[0];
            opts.from = {width=obj.width, height=obj.height, x=obj.x, y=obj.y, alpha=255, rotation=obj.rotation };
            opts.to = {width=0.1, height=0.1, x=obj.x + obj.width * 0.5 , y=obj.y + obj.height * 0.5, alpha=0, rotation=obj.rotation+540 };
            interpolator(PennerInterpolator("linear"));
        },

        "pixelate fadeout":
        function (...){
            local obj = vargv[0];
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",1,0,0,0);
            anims_shader[art-1].duration(opts.duration)
            anims_shader[art-1].delay(opts.delay)
            anims_shader[art-1].play();

            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y, alpha=obj.alpha };
            opts.to = { x=states["origin"].x,  y=states["origin"].y, alpha=100  };
            opts.interpolator = CubicBezierInterpolator("ease-out-cubic");
        }
    }

    function set_rotation(r, obj) {
        local mr = PI * r / 180;
        obj.x += cos( mr ) * (-obj.width * 0.5) - sin( mr ) * (-obj.height * 0.5) + obj.width * 0.5;
        obj.y += sin( mr ) * (-obj.width * 0.5) + cos( mr ) * (-obj.height * 0.5) + obj.height * 0.5;
    }

    function unset_rotation(r, obj) {
        local mr = PI * r / 180;
        obj.x -= cos( mr ) * (-obj.width * 0.5) - sin( mr ) * (-obj.height * 0.5) + obj.width * 0.5;
        obj.y -= sin( mr ) * (-obj.width * 0.5) + cos( mr ) * (-obj.height * 0.5) + obj.height * 0.5;
    }

    function blur(obj){
        local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
        artwork_shader[art-1].set_param("datas",5,0,0,0);
        anims_shader[art-1].duration(opts.duration)
        anims_shader[art-1].delay(opts.delay)
        anims_shader[art-1].play();
    }

    function bounce_around(art){ // OK
        local w = art.width;
        local h = art.height;
        local x = art.x;
        local y = art.y;
        local dw = opts.datas.tw * 3.50 - opts.datas.tw;
        local dh = opts.datas.th * 3.50 - opts.datas.th;
        local itr = CubicBezierInterpolator("ease-in-circle");

        if(!opts.datas.zoom){
            itr = CubicBezierInterpolator("ease-out-circle");
            w += (progress * dw) - (art.width - opts.datas.tw);
            h += (progress * dh) - (art.height - opts.datas.th);
        }else{
            itr = CubicBezierInterpolator("ease-in-circle");
            w -= (progress * dw) - ( (opts.datas.tw + dw) - art.width);
            h -= (progress * dh) - ( (opts.datas.th + dh) - art.height);
        }

        // bottom bound
        if ( y + (h * 0.5) >= flh ){
            opts.datas.velY = -opts.datas.velY;
            y = flh - (h * 0.5);
        }
        // top bound
        if (y  <= -(h * 0.5)) {
            opts.datas.velY = -opts.datas.velY;
            y = -(h * 0.5);
        }
        // left bound
        if (x <= -(w * 0.5)) {
            opts.datas.velX = -opts.datas.velX;
            x = -(w * 0.5);
        }
        // right bound
        if (x + (w * 0.5) >= flw) {
            opts.datas.velX = -opts.datas.velX;
            x = flw - (w * 0.5);
        }

        // update position
        art.x = x + opts.datas.velX;
        art.y = y + opts.datas.velY;
        art.width = itr.interpolate(art.width , w, progress);
        art.height = itr.interpolate(art.height, h, progress);

        if(opts.rotation) opts.target["rotation"] +=opts.duration * 0.001; // animated rotation ( only if > 180 )

        if (progress >= 1.0){
            opts.datas.zoom = 1 - opts.datas.zoom;
            progress = 0.0;
        }
    }

    function random_bounce(art){ // OK
        // bottom bound
        if ( art.y + art.height >= flh){
            opts.datas.velY = -opts.datas.velY * opts.datas.damping;
            if(opts.datas.bound){
                opts.datas.velY = ( rand()%(opts.datas.bound - (opts.datas.bound * 0.5) + 1) + (opts.datas.bound * 0.50) ) * opts.datas.damping
                local jumpX = (rand()%( opts.datas.bound * 0.5 - (opts.datas.bound * 0.25) + 1) + (opts.datas.bound * 0.25));
                if(rnd_num(0,3,"int") < 1) opts.datas.velX += jumpX; else opts.datas.velX -= jumpX;
                opts.datas.bound = false;
            }

            art.y = flh - art.height;
            opts.datas.velX *= opts.datas.traction;
        }
        // top bound
        if (art.y  <= 0) {
            opts.datas.velY = -opts.datas.velY * opts.datas.damping;
            art.y = 0;
        }
        // left bound
        if (art.x <= 0) {
            opts.datas.velX = -opts.datas.velX * opts.datas.damping;
            art.x = 0;
        }
        // right bound
        if (art.x + art.width >= flw) {
            opts.datas.velX = -opts.datas.velX * opts.datas.damping;
            art.x = flw - art.width;
        }
        // add gravity
        opts.datas.velY += opts.datas.gravity;
        if( abs(opts.datas.velY) == 0 && art.y > rand()%(flw * 0.5 - flw * 0.5 + 1) + flw * 0.25){
           opts.datas.bound = (art.y + art.height) * 0.1;
        }

        if(opts.rotation) opts.target["rotation"]+=opts.duration * 0.001;

        // update position
        art.x += opts.datas.velX;
        art.y += opts.datas.velY;
    }


    function quadbezier(p1x, p1y, cx, cy, p2x, p2y, t) {
        local c1x = p1x + (cx - p1x) * t;
        local c1y = p1y + (cy - p1y) * t;
        local c2x = cx + (p2x - cx) * t;
        local c2y = cy + (p2y - cy) * t;
        local tx = c1x + (c2x - c1x) * t;
        local ty = c1y + (c2y - c1y) * t;
        return { x = tx, y = ty };
    }

    function resting_bck(art, animate_type){

        if( !opts.bck_opts.len() ){
            opts.bck_opts.x <- prev_back.ox;
            opts.bck_opts.y <- prev_back.oy;
        }
        local arr_y = ["Up", "Down"];
        local arr_x = ["Left", "Right"];


        if( !("direction_y" in opts.rest_vars)) opts.rest_vars.direction_y <- arr_y[rnd_num(0,1,"int")];
        if( !("direction_x" in opts.rest_vars)) opts.rest_vars.direction_x <- arr_x[rnd_num(0,1,"int")];

        if (animate_type == "horizontal panning" || animate_type == "random panning")
        {
            if ( prev_back.ox >= 0 && opts.rest_vars.direction_x == "Right") opts.rest_vars.direction_x = "Left";

            if ( prev_back.ox < opts.bck_opts.x && opts.rest_vars.direction_x == "Left") opts.rest_vars.direction_x = "Right";

            if (opts.rest_vars.direction_x == "Right"){
                prev_back.ox +=1 * opts.rest_speed;
            }else if (opts.rest_vars.direction_x == "Left"){
                prev_back.ox -=1 * opts.rest_speed;
            }
        }

        if (animate_type == "vertical panning" || animate_type == "random panning")
        {
            if ( prev_back.oy >= opts.bck_opts.y && opts.rest_vars.direction_y == "Up") opts.rest_vars.direction_y = "Down";

            if ( prev_back.oy < 0 && opts.rest_vars.direction_y == "Down") opts.rest_vars.direction_y = "Up";

            if (opts.rest_vars.direction_y == "Down"){
                prev_back.oy -=1 * opts.rest_speed ;
            }else if (opts.rest_vars.direction_y == "Up"){
                prev_back.oy +=1 * opts.rest_speed;
            }
        }

        //Trans_shader.set_param("scroll_progress", prev_back.oy * 0.2)
        Trans_shader.set_param("back_res", prev_back.ox / flw, prev_back.oy / flh, prev_back.bw / flw, prev_back.bh / flh ); // actual background infos stretched
    }

    function resting_hover(art, animate_type, range=35){
        local arr_y = ["Up", "Down"];
        local arr_x = ["Left", "Right"];

        if( !("direction_x" in opts.rest_vars) || !rnd_num(0,24,"int") % 6){
            opts.rest_vars.direction_x <- arr_x[rnd_num(0,1,"int")];
            opts.rest_vars.x <- rnd_num(0.1,0.8,"float"); // speed x
        }
        if( !("direction_y" in opts.rest_vars) || !rnd_num(0,30,"int") % 3){
            opts.rest_vars.direction_y <- arr_y[rnd_num(0,1,"int")];
            opts.rest_vars.y <- rnd_num(0.1,0.8,"float"); // speed y
        }

        if (animate_type == "hover vertical" || animate_type == "hover")
        {
            if(art.y >= states["origin"].y+range && opts.rest_vars.direction_y == "Down") opts.rest_vars.direction_y = "Up";
            if(art.y <= states["origin"].y-range && opts.rest_vars.direction_y == "Up") opts.rest_vars.direction_y = "Down";

            if (opts.rest_vars.direction_y == "Down"){
                art.y += opts.rest_vars.y;
            }else if (opts.rest_vars.direction_y == "Up"){
                art.y -= opts.rest_vars.y;
            }
        }

        if (animate_type == "hover horizontal" || animate_type == "hover")
        {
            if (art.x >= states["origin"].x+range && opts.rest_vars.direction_x == "Right") opts.rest_vars.direction_x = "Left";
            if (art.x <= states["origin"].x-range && opts.rest_vars.direction_x == "Left")  opts.rest_vars.direction_x = "Right";

            if (opts.rest_vars.direction_x == "Right"){
                art.x += opts.rest_vars.x;
            }else if (opts.rest_vars.direction_x == "Left"){
                art.x -= opts.rest_vars.x;
            }
        }
    }


    //collect supported key values in a state from target
    function collect_state(target) {
        if ( target == null ) return;
        local state = {}
        for ( local i = 0; i < supported.len(); i++)
            try {
                if ( supported[i] == "rgb" ) {
                    state[supported[i]] <- [ target.red, target.green, target.blue, target.alpha ];
                } else {
                    state[supported[i]] <- target[supported[i]];
                }
            } catch(e) {}
        return state;
    }

    // normalize 0.0 - 1.0
    static function normalize(value, min, max) {
        return (value - min) / (max - min);
    }
}