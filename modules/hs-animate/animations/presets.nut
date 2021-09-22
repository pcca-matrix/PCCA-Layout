///////////////////////////////////////////////////
//
// HyperSpin Animations for pcca layout
// PCCA-Matrix 2020
//
///////////////////////////////////////////////////

class PresetAnimation extends Animation {
    supported = ["x", "y", "width", "height", "origin_x", "origin_y", "rotation", "rgb", "red", "green", "blue", "bg_red", "bg_green", "bg_blue", "sel_red", "sel_green", "sel_blue", "sel_alpha", "selbg_red", "selbg_green", "selbg_blue", "selbg_alpha", "alpha", "skew_x", "skew_y", "pinch_x", "pinch_y", "subimg_x", "subimg_y", "charsize", "zorder" ];
    unique_keys = null;
    pr_opt = null;
    _move_direction_x = -1;
    _move_direction_y = -1;
    move_speed_x = 0.4;
    move_speed_y = 0.4;

    function defaults(params){
        base.defaults(params);
        opts = merge_opts({
            key = null,
            preset = null,
            preset_load = false,
            starting = "none",
            rest = null,
            rotation = null,
            datas = {}
        }, opts);

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
        move_speed_y = 0.4;
        move_speed_x = 0.4;
        _move_direction_x = -1;
        _move_direction_y = -1;
        pr_opt = null;
        opts.triggers.clear();
        opts.loops = 0
        opts.loops_delay = 0
        opts.loops_delay_from = true;
        opts.key = null
        opts.starting = "none"
        opts.rest = null
        opts.from = null
        opts.to = null
        opts.preset = null
        opts.rotation = null
        opts.datas.clear()
        opts.preset_load = true;
        opts.then = null;
        opts.reverse = false;
        opts.yoyo = false;
        opts.delay = 0;
        opts.trigger_restart = true;
        opts.speed = 1;
        opts.delay_from = 0;
        opts.interpolator = CubicBezierInterpolator("linear");
        side = 0;
        way = 0;
        return;
    }

    function preset( str , opt = false){
        reset();
        state( "origin", collect_state(opts.target) );
        if(opt) pr_opt = opt;
        (str != "none"  ? opts.preset <- str : opts.preset <- "linear");
        opts.preset_load = true;
        return this;
    }

    function key( key ) { opts.key <- key; return this; }
    function rotation( val ) { opts.rotation = (abs(val) > 0 ? val.tofloat() : null ); return this; }
    function starting( str ) { opts.starting <- str; return this; }
    function datas( val ) { opts.datas <- val; return this; }
    function rest( str ) { opts.rest = ( str != "none" ?  str : null ); return this; }

    side = 0; way = 0;
    function anim_rest(){
        local speed = 1.0;
        local obj = opts.target;
        switch(opts.rest){
            case "shake": // best easing ?
                    speed = 0.9
                    local itr = CubicBezierInterpolator("ease-in-out-back");
                    if(resting_progress < 0.5){
                        obj.x = itr.interpolate(states["origin"].x, states["origin"].x+40, normalize(resting_progress, 0.0, 0.50) );
                        obj.y = itr.interpolate(states["origin"].y, states["origin"].y-40, normalize(resting_progress, 0.0, 0.50) );
                    }else{
                        obj.x = itr.interpolate(states["origin"].x+40, states["origin"].x, normalize(resting_progress, 0.50, 1.0) );
                        obj.y = itr.interpolate(states["origin"].y-40, states["origin"].y, normalize(resting_progress, 0.50, 1.0) );
                    }
                    if(resting_progress == 1.0) resting = false;
            break;

            case "rock":
            case "rock fast":
                if(opts.rest == "rock fast") speed = 1.25; else speed = 0.8;
                if(!way){
                    side+=speed;
                    if(side <= 10){
                        obj.rotation+=speed;
                        set_rotation( side, obj, true );
                    }
                    if(side > 30){
                        side = 10;
                        way = 1;
                    }
                }else{
                    side-=speed;
                    if(side >= -8){
                        obj.rotation-=speed;
                        set_rotation( side, obj, true );
                    }
                    if(side < -28 ){
                        side = -8;
                        way = 0;
                    }
                }

                if(resting_progress == 1.0) resting_progress = 0;
            break;


            case "squeeze": // OK
                speed = 2.0
                local nw,nh;
                local ow = states["origin"].width;
                local oh = states["origin"].height;
                if(resting_progress <= 0.3){
                    nw = CubicBezierInterpolator("linear").interpolate(ow, ow * 1.4 , normalize(resting_progress, 0, 0.3) );
                    nh = CubicBezierInterpolator("linear").interpolate(oh, oh * 0.2, normalize(resting_progress, 0, 0.3) );
                    obj.width = nw;
                    obj.height = nh;
                    obj.x = states["origin"].x + ( (ow - nw) * 0.5 );
                    obj.y = states["origin"].y + ( (oh - nh) * 0.5 );
                }else if(resting_progress <= 0.7){
                    nw = CubicBezierInterpolator("linear").interpolate(ow * 1.4, ow * 0.5 , normalize(resting_progress, 0.3, 0.7) );
                    nh = CubicBezierInterpolator("linear").interpolate(oh * 0.2, oh * 1.4 , normalize(resting_progress, 0.3, 0.7) );
                    obj.width = nw;
                    obj.height = nh;
                    obj.x = states["origin"].x - ( (nw - ow) * 0.5 );
                    obj.y = states["origin"].y - ( (nh - oh) * 0.5 );
                }else{
                    nw = CubicBezierInterpolator("ease-out-back").interpolate(ow * 0.5, ow, normalize(resting_progress, 0.7, 1)  );
                    nh = CubicBezierInterpolator("ease-out-back").interpolate(oh * 1.4, oh, normalize(resting_progress, 0.7, 1)  );
                    obj.width = nw;
                    obj.height = nh;
                    obj.x = states["origin"].x - ( (nw - ow) * 0.5 );
                    obj.y = states["origin"].y - ( (nh - oh) * 0.5 );
                }
                if(resting_progress == 1.0) resting = false;
            break;

           case "pulse":
           case "pulse fast": // OK check easing
                ( opts.rest == "pulse fast" ? speed = 0.85 : speed = 0.40);
                local zoom = 1.21;
                local nw,nh;
                local itr = CubicBezierInterpolator("ease-in-out-circle");
                if(resting_progress <= 0.5){
                    nw = itr.interpolate(states["origin"].width, states["origin"].width * zoom, resting_progress);
                    nh = itr.interpolate(states["origin"].height, states["origin"].height * zoom , resting_progress);
                    obj.width = nw;
                    obj.height = nh;
                    obj.x = states["origin"].x + ( (states["origin"].width - nw) * 0.5 );
                    obj.y = states["origin"].y + ( (states["origin"].height - nh) * 0.5 );

                }else{
                    nw = itr.interpolate(states["origin"].width * zoom, states["origin"].width , resting_progress);
                    nh = itr.interpolate(states["origin"].height * zoom, states["origin"].height , resting_progress);
                    obj.width = nw;
                    obj.height = nh;
                    obj.x = states["origin"].x - ( (nw - states["origin"].width) * 0.5 );
                    obj.y = states["origin"].y - ( (nh - states["origin"].height) * 0.5 );
                }
                if(resting_progress == 1.0) resting_progress = 0;
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
                if( r > 359 ) r = 0;
                obj.rotation=r;
                set_rotation( r, obj, true ); // fixed rotation
            break;

            case "hover":
            case "hover vertical":
            case "hover horizontal":
                resting_hover(obj, opts.rest);
                move_speed_y = clamp(rand()%2.0, 0.05, 0.3);
                move_speed_x = clamp(rand()%2.0, 0.05, 0.3);
            break;
        }

        resting_progress = clamp( resting_progress + ( opts.smoothing * speed ), 0, 1);

        base.anim_rest();
    }

    function start() {
        //save target states
        states["current"] <- collect_state( opts.target );
        state( "start", clone(states["current"]) );

        if (  opts.preset && opts.preset_load ) {
            try {
                local t = PresetA[opts.preset];
                if(pr_opt)
                    local res = t(opts.target, pr_opt);
                else
                   local res = t(opts.target);

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

        if(opts.rotation && opts.preset != "chase"){ // hyerspin animate a rotation only if it's greater than 180 or -180
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
            if ( supported.find(key) != null )
                if ( states["from"][key] != states["to"][key] ) unique_keys[key] <- "";

        base.start();
    }

    function update() {
        switch(opts.preset){
            case "rain float":
                local x=0; local y=0; local v=0;
                if( progress == 0.0 )return;
                progress = 0.1;
                for ( local i=0; i < ArtArray.len(); i++ ){
                    y = ArtArray[i].y + opts.datas.s[i];
                    opts.datas.t[i] += opts.datas.x[i];
                    v = cos(opts.datas.t[i] / 100) * 8;
                    if(ArtArray[i].rotation > 0)
                        x = ArtArray[i].x - v;
                    else
                        x = ArtArray[i].x + v;

                    if( ArtArray[i].y >= flh ){
                        y = - (ArtArray[i].height + rndint(flh * 0.10));
                        x = rndint(flw);
                        opts.datas.x[i] = rndfloat(2.0);
                    }

                    ArtArray[i].rotation = v;
                    ArtArray[i].y = y;
                    ArtArray[i].x = x;
                }

            break;

            case "arc grow":
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                local arc;

                if(opts.starting == "none" || opts.starting == "left" || opts.starting == "bottom"){

                   arc = quadbezier(
                   //0 + offset_x, (flh * 0.5) + states["origin"].height * 0.5,
                   0 , (flh * 0.5) + states["origin"].height * 0.5,

                   flw * 0.5, -(flh * 0.5),

                   flw , flh + opts.target.height * 0.5,

                    progress);

                }else{

                   arc = quadbezier(

                   flw + opts.target.width * 0.5, (flh * 0.5) + states["origin"].height * 0.5,

                   flw  * 0.5, -(flh * 0.5),

                   0, flh + opts.target.height * 0.5,

                   progress);
                }
                opts.target.width = states["origin"].width * 1.5 * progress + 0.1;
                opts.target.height = states["origin"].height* 1.5 * progress + 0.1;
                opts.target.x = arc.x - opts.target.width * 0.5;
                opts.target.y = arc.y - opts.target.height * 0.5;
                if(progress == 1.0) restart();
            break;

            case "arc shrink":
                if ( elapsed < opts.delay ) return true;  // wait delay before start

                local arc;
                // HS left/right is inverted !!!!
                if( opts.starting == "right"){ //hs = left
                    arc = quadbezier(

                        -opts.target.width * 2, flh + opts.target.height,

                        flw * 0.5, -(flh * 0.5),

                        flw + opts.target.width * 0.5  , flh * 0.5 ,

                        progress
                    );


                }else{
                    arc = quadbezier( //hs =  right , bottom, top, none

                        flw, flh + opts.target.height,

                        flw * 0.5, -(flh * 0.5),

                        -opts.target.width * 1.5  , flh * 0.5 ,

                        progress
                    );
                }
                opts.target.width  = states["origin"].width * 1.1  - (states["origin"].width  * progress) + 0.1;
                opts.target.height = states["origin"].height * 1.1 - (states["origin"].height  * progress) + 0.1;
                opts.target.x = arc.x + opts.target.width * 0.5;
                opts.target.y = arc.y + opts.target.height * 0.5;
                if(progress == 1.0) restart();
            break;

            case "pendulum":
                //starting : top left , bottom = right
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                if( progress == 0.0 )return;
                if(opts.datas.loops > 0 && opts.datas.nbr >= opts.datas.loops){ progress=1.0; return }
                progress = 0.1;
                if(opts.datas.rotation > PI || opts.datas.rotation < 0){
                    opts.datas.nbr++;
                    opts.datas.step=-opts.datas.step;
                }
                opts.datas.rotation+=opts.datas.step;
                local x = (states["origin"].x ) + cos( opts.datas.rotation ) * opts.datas.radius
                local y = (states["origin"].y - flw * 1.59 ) + sin( opts.datas.rotation ) * opts.datas.radius
                local angle = opts.datas.rotation / PI * 180 - 90; // 90 starting angle
                opts.target.rotation = angle;
                opts.target.x = x;
                opts.target.y = y;
                set_rotation(angle, opts.target);
            break;

            case "bounce random":
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                random_bounce(opts.target);
                progress = 0.1;
            break;

            case "bounce around 3d":
                if ( elapsed < opts.delay ) return true;  // wait delay before start
                bounce_around(opts.target);
                //progress = 0.1;
            break;

            default:
                foreach( key, val in states["to"] ) {
                    // if from width is set to 0.1 unhide object (hidden in layout !)
                    if(key == "width"){
                        if( _from[key] <= 0.1 && progress > 0 && !opts.target.visible) opts.target.visible = true;
                    }
                    if ( key == "rgb" ) {
                        opts.target.set_rgb(
                            opts.interpolator.interpolate(_from[key][0], _to[key][0], progress),
                            opts.interpolator.interpolate(_from[key][1], _to[key][1], progress),
                            opts.interpolator.interpolate(_from[key][2], _to[key][2], progress)
                        )
                        if ( _from[key].len() > 3 && _to[key].len() > 3 )
                            opts.interpolator.interpolate(_from[key][3], _to[key][3], progress)
                    } else if ( supported.find(key) != null ) {
                        try {
                            if(key_interpolator[key]) opts.target[key] = key_interpolator[key].interpolate(_from[key], _to[key], progress)
                        }
                        catch(e){
                            opts.target[key] = opts.interpolator.interpolate(_from[key], _to[key], progress);
                        }

                        if ( key == "alpha" && opts.name !="" ){
                           ArtObj[opts.name].shader.set_param( "alpha", opts.interpolator.interpolate( _from["alpha"] / 255 , _to["alpha"] / 255, progress) );
                        }
                    }
                }

                if (states["to"].rawin("rotation")) set_rotation(opts.target["rotation"], opts.target);
            break;
        }
        states["current"] <- collect_state(opts.target);
        base.update();
    }

    PresetA = {
        "linear": //OK (Default without Preset)
        function( obj )
        {
            opts.from <- { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to <- { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator <- CubicBezierInterpolator("linear")
        },

        "ease": //OK
        function( obj )
        {
            if(opts.starting == "none") return;
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = CubicBezierInterpolator("ease")
        },

        "elastic": // OK (can be better)
        function( obj )
        {
            if(opts.starting == "none") return;
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = PennerInterpolator("ease-out-elastic")
        },

        "elastic bounce": // OK (can be better)
        function( obj )
        {
            if(opts.starting == "none") return;
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = PennerInterpolator("ease-out-elastic");
        },

        "flip": // OK
        function( obj )
        {
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
        function ( obj )
        {
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y, alpha=0 };
            opts.to = { x=states["origin"].x,  y=states["origin"].y, alpha=255 };
            opts.interpolator = CubicBezierInterpolator("ease")
        },

        "bounce": // OK
        function( obj ){
            if(opts.starting == null) return;
            opts.interpolator = PennerInterpolator("ease-out-bounce")
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y };
        },

        "blur": // OK (can be better)
        function( obj ){
            blur(obj);
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y, alpha=0 };
            opts.to = { x=states["origin"].x,  y=states["origin"].y, alpha=255  };
            opts.interpolator = CubicBezierInterpolator("ease-in-out-quart")

        },

        "pixelate": // OK
        function( obj ){
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",1,0,0,0);
            anims_shader[art-1].duration(opts.duration)
            anims_shader[art-1].delay(opts.delay)
            anims_shader[art-1].play();

            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            opts.interpolator = CubicBezierInterpolator("ease-out-cubic");
        },

        "zoom out": // OK (can be better)
        function( obj ){
            local mtpl = (fe.layout.width+(OFFSET*2) ) / obj.width;
            local f = center_zoom(obj, obj.width*mtpl, obj.height*mtpl, obj.width, obj.height);
            opts.from = {x=f.from_x, y=f.from_y, height=obj.height*mtpl, width=obj.width*mtpl,alpha=0 };
            opts.to = { x=f.to_x, y=f.to_y, height=obj.height,width=obj.width,alpha=255  };
            opts.interpolator = PennerInterpolator("ease-out-sine");

        },

        "pixelate zoom out": // OK
        function( obj ){
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",1,0,0,0);
            anims_shader[art-1].duration(opts.duration)
            anims_shader[art-1].delay(opts.delay)
            anims_shader[art-1].play();

            local f = center_zoom(obj, obj.width*2.8, obj.height*2.8, obj.width, obj.height);
            opts.from = {x=f.from_x, y=f.from_y, height=obj.height*2.8, width=obj.width*2.8,alpha=0 };
            opts.to = { x=f.to_x, y=f.to_y, height=obj.height,width=obj.width,alpha=255  };
            interpolator(PennerInterpolator("ease-out-sine"))
        },

        "chase": // OK
        function( obj ){
            local startx=POSITIONS["left"](obj).x - obj.width*1.5;
            local endx=POSITIONS["right"](obj).x + obj.width*1.5;

            local a= -1;
            local orig_subW = obj.subimg_width;
            local orig_subX = obj.subimg_x;
            if(opts.starting =="right"){
                startx=POSITIONS["right"](obj).x + obj.width*1.5;
                endx=POSITIONS["left"](obj).x - obj.width*1.5;
            }
            opts.from = {x=startx}
            opts.to = {x=endx}
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
        function( obj ){
            state("A", { x=POSITIONS["left"](obj).x } )
            state("B", { x=POSITIONS["right"](obj).x } )
            state("C", { y=POSITIONS["top"](obj).y, x=states["origin"].x } )
            state("D", { y=states["origin"].y, x=states["origin"].x } )
            from("A")
            to("B")
            duration(opts.duration / 2)
            then(function(anim) {
                anim.from("C").to("D").delay(550).duration(opts.duration / 2 ).play()
            })
        },

        "sweep right": // OK
        function( obj ){
            state("A", { x=POSITIONS["right"](obj).x } )
            state("B", { x=POSITIONS["left"](obj).x } )
            state("C", { y=POSITIONS["top"](obj).y, x=states["origin"].x } )
            state("D", { y=states["origin"].y, x=states["origin"].x } )
            from("A")
            to("B")
            duration(opts.duration / 2)
            then(function(anim) {
                anim.from("C").to("D").delay(550).duration(opts.duration / 2).play()
            })
        },

        "strobe": // OK (mindless need rewrite ...)
        function( obj ){
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
        function ( obj ){
            opts.from = {width=0.1, height=0.1, x=POSITIONS[opts.starting](obj).x + obj.width/2, y=POSITIONS[opts.starting](obj).y + obj.height/2, alpha=0 };
            opts.to = {width=obj.width, height=obj.height, x=obj.x, y=obj.y, alpha=255};
        },

        "grow bounce": // OK
        function ( obj ){
            opts.from = {width=0.1, height=0.1, x=POSITIONS[opts.starting](obj).x + obj.width/2, y=POSITIONS[opts.starting](obj).y + obj.height/2, alpha=0 };
            opts.to = {width=obj.width, height=obj.height, x=obj.x, y=obj.y, alpha=255};
            opts.interpolator = PennerInterpolator("ease-out-bounce")
        },

        "grow blur": // OK
        function ( obj ){
            blur(obj);
           opts.from = {width=0.1, height=0.1, x=POSITIONS[opts.starting](obj).x + obj.width/2, y=POSITIONS[opts.starting](obj).y + obj.height/2 };
           opts.to = {width=obj.width, height=obj.height, x=obj.x, y=obj.y};
        },

        "grow x": // OK
        function ( obj ){
            opts.from = { width=0.1, x=POSITIONS[opts.starting](obj).x + (states["origin"].width / 2), y=POSITIONS[opts.starting](obj).y  };
            opts.to = { width=states["origin"].width, x=states["origin"].x,y=states["origin"].y  };
        },

        "grow y": // OK
        function ( obj ){
            opts.from = { height=0.1, y=POSITIONS[opts.starting](obj).y+(obj.height / 2), x=POSITIONS[opts.starting](obj).x  };
            opts.to = { height=states["origin"].height, x=states["origin"].x, y=states["origin"].y };
        },

        "grow center shrink": // OK
        function ( obj ){
            local starty=Screen["center"].y;
            local startx=Screen["center"].x;
            local f = center_zoom(obj, 0.1, 0.1, obj.width*3, obj.height*3, startx, starty);
            state("A",  { x=f.from_x, y=f.from_y, height=0.1, width=0.1 } )
            state("B",  { x=f.to_x,  y=f.to_y, height=obj.height*3, width=obj.width*3 } )
            state("C",  { x=obj.x,  y=obj.y, height=obj.height,width=obj.width } )
            opts.from = "A";
            opts.to = "B";
            interpolator(PennerInterpolator("ease-in-sine") )
            duration(opts.duration / 2)
            then(function(anim) {
                anim.from("B").to("C").duration(opts.duration / 2).delay(350).play()
            })

        },

        "scroll":  // not really like HS
        function ( obj ){
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
        function( obj ){
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",2,0,0,0);
            anims_shader[art-1].duration(opts.duration);
            anims_shader[art-1].delay(opts.delay);
            anims_shader[art-1].play();
            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y, alpha=75 };
            opts.to = { x=states["origin"].x,  y=states["origin"].y, alpha=255  };
        },

        "pendulum": // OK
        function ( obj ){
            local divider = 25;
            opts.target.x = -2500; // hide away before starting animation
            local start = PI;
            if(opts.starting == "right" || opts.starting == "bottom") start = 0;
            opts.datas <- { "loops" : -1, "rotation" : start, "radius" : flw * 2 , "nbr" : 0 }
            opts.datas.step <- PI / (opts.duration / divider );
            if( opts.datas.loops > 0 ) opts.datas.loops *= 2;
        },

        "stripes": // not really like HS
        function( obj ){
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",3,0,0,0);
            anims_shader[art-1].duration(opts.duration);
            anims_shader[art-1].delay(opts.delay + 500);
            anims_shader[art-1].play();

            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            //opts.interpolator = CubicBezierInterpolator("ease-out-cubic");
        },

        "stripes 2": // not really like HS
        function( obj ){
            local art = opts.name.slice( opts.name.len() - 1, opts.name.len() ).tointeger();
            artwork_shader[art-1].set_param("datas",4,0,0,0);
            anims_shader[art-1].duration(opts.duration)
            anims_shader[art-1].delay(opts.delay + 500);
            anims_shader[art-1].play();

            opts.from = { x=POSITIONS[opts.starting](obj).x, y=POSITIONS[opts.starting](obj).y };
            opts.to = { x=states["origin"].x,  y=states["origin"].y  };
            //opts.interpolator = CubicBezierInterpolator("ease-out-cubic");
        },

        "arc grow": // OK
        function( obj ){
            opts.target.x = -2500; // hide away before starting animation
            return true;
        },

        "arc shrink": // OK
        function( obj ){
            opts.target.x = -2500; // hide away before starting animation
            return true;
        },

        "bounce random": // OK
        function( obj ){
            opts.datas <- { "velY" : 10, "velX" : 20, "damping" : 0.8 , "traction" : 0.8, "gravity" : 0.4, "bound" : false, "zoom" : 0 }
            return true;
        },

        "rain float": // OK
        function ( obj ){
            opts.target.zorder-=1000
            local nx = ArtArray.len();
            if( nx < 4 ){ // add missings images if needed
                for ( local i=0; i < 4-nx; i++ ){ ArtArray.push(fe.add_image("",0 , 0 , 0 , 0)) }
            }

            for ( local i=0; i < 4; i++ ){
                local posx = ( i > 0 ? (obj.width * i) + rndint(obj.width) : flw*0.01)
                ArtArray[i].file_name = obj.file_name;
                ArtArray[i].visible = true;
                ArtArray[i].set_pos( posx , -( rndint(flh*0.5) + obj.height ) , obj.width, obj.height);
                ArtArray[i].zorder-=1; // fix: hide obj on exit menu
            }
            opts.datas <- { "s": [4.1, 2.8, 3.4, 1.9], "t": [0,0,0,0], "x": [rndfloat(2.1), rndfloat(2.1), rndfloat(2.1), rndfloat(2.1)] };
        },

        "bounce around 3d": // OK
        function( obj ){
            opts.duration /= 2;
            opts.datas <- { "velY" : 6, "velX" : 6, "zoom" : 0 ,"tw" : obj.width, "th" : obj.height }
            return true;
        },

        /* Video Only */
        "pump": // OK
        function( obj ){
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
        function ( obj )
        {
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
        function( obj ){
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
        function( obj ){
            local mtpl = 3;
            local f = center_zoom(obj, obj.width*mtpl, obj.height*mtpl, obj.width, obj.height);
            opts.from = {x=f.from_x, y=f.from_y, height=obj.height*mtpl, width=obj.width*mtpl };
            opts.to = { x=f.to_x, y=f.to_y, height=obj.height,width=obj.width  };
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
        function( obj , mtpl=false){
            local alpha = 255;
            if(!mtpl){ // out anim with fade
                mtpl = (fe.layout.width+(OFFSET*2) ) / obj.width;
                alpha=0;
            }
            local f = center_zoom(obj, obj.width*mtpl, obj.height*mtpl, obj.width, obj.height);
            opts.from = { x=f.to_x, y=f.to_y, height=obj.height,width=obj.width,alpha=obj.alpha };
            opts.to = {x=f.from_x, y=f.from_y, height=obj.height*mtpl, width=obj.width*mtpl,alpha=alpha };
            interpolator(PennerInterpolator("ease-out-sine"));

        },

        "unzoom": // OK
        function( obj, mtpl=false ){
            local alpha = 255;
            if(!mtpl){ // out anim with fade
                mtpl = (fe.layout.width+(OFFSET*2) ) / obj.width;
                alpha=0;
            }
            local f = center_zoom(obj, obj.width, obj.height, 0.1, 0.1);
            opts.from = {x=f.from_x, y=f.from_y, height=obj.height, width=obj.width, alpha=obj.alpha };
            opts.to = { x=f.to_x, y=f.to_y, height=0.1,width=0.1,alpha=alpha };
            interpolator(PennerInterpolator("ease-out-sine"));

        },

        "fade out": // OK
        function ( obj )
        {
            opts.from = { alpha=obj.alpha };
            opts.to = { alpha=0 };
            opts.interpolator = CubicBezierInterpolator("ease");
        },

        "expl": // OK
        function ( obj )
        {
            local f={}; local t={};
            if(obj.x <= fe.layout.width  / 2){
                if(obj.y <= fe.layout.height / 2){
                    f.y <- obj.y;
                    t.y <- -fe.layout.height;
                }else{
                    f.x <- obj.x;
                    t.x <- -fe.layout.width;
                }
            }else{
                if(obj.y <= fe.layout.height / 2){
                    f.y <- obj.y;
                    t.y <- fe.layout.height * 2;
                }else{
                    f.x <- obj.x;
                    t.x <- fe.layout.width * 2;
                }
            }
            opts.from = f;
            opts.to = t;
        }
    }

    function center_zoom(target, from_w, from_h, to_w, to_h, x=false,y=false){
        local base_x = target.x;
        local base_y = target.y;
        if( x ) base_x = x - (target.width / 2);
        if( y ) base_y = y - (target.height / 2);
        local from_x = base_x + (target.width / 2) - (from_w / 2);
        local to_x = base_x + target.width / 2 - (to_w / 2);
        local from_y = base_y + (target.height/2) - (from_h / 2);
        local to_y = base_y + target.height / 2 - (to_h / 2);
        return { from_x = from_x, to_x = to_x, from_y = from_y, to_y = to_y };
    }

    function set_rotation( r, obj, fixed = false ) {
        local mr = PI * r / 180;
        local w2 = obj.width;
        local h2 = obj.height;
        if(!fixed ) {
            obj.x += cos( mr ) * (-w2/2) - sin( mr ) * (-h2/2) + w2/2;
            obj.y +=  sin( mr ) * (-w2/2) + cos( mr ) * (-h2/2) + h2/2;
        }else{
            obj.x = states["origin"].x + cos( mr ) * (-w2/2) - sin( mr ) * (-h2/2) + w2/2;
            obj.y = states["origin"].y + sin( mr ) * (-w2/2) + cos( mr ) * (-h2/2) + h2/2;
        }
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
        local itr;

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
        if(true){
            art.x = opts.datas.velX + itr.interpolate(art.x, x , progress);
            art.y = opts.datas.velY + itr.interpolate(art.y, y , progress);
            art.width = itr.interpolate(art.width , w, progress);
            art.height = itr.interpolate(art.height, h, progress);
        }else{
            art.width = w;
            art.height = h;
            art.x = x + opts.datas.velX;
            art.y = y + opts.datas.velY;
        }

        if (progress >=1.0){
            opts.datas.zoom = 1 - opts.datas.zoom;
            progress = 0;
        }
    }

    function random_bounce(art){ // OK
        if ( art.y + art.height >= flh){
            opts.datas.velY = -opts.datas.velY * opts.datas.damping;
            if(opts.datas.bound){
                opts.datas.velY = ( rand()%(opts.datas.bound - (opts.datas.bound / 2) + 1) + (opts.datas.bound / 2) ) * opts.datas.damping
                local jumpX = (rand()%( opts.datas.bound / 2 - (opts.datas.bound / 4) + 1) + (opts.datas.bound / 4));
                if(rndint(3) < 1) opts.datas.velX += jumpX; else opts.datas.velX -= jumpX;
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
        if( abs(opts.datas.velY) == 0 && art.y > rand()%(flw / 2 - flw / 4 + 1) + flw / 4){
           opts.datas.bound = (art.y + art.height) / 10;
        }
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


    function resting_hover(art, animate_type, range=30){
        local surface = {};
        surface.x <- states["origin"].x;
        surface.y <- states["origin"].y;
        local arr_y = ["Up", "Down"];
        local arr_x = ["Left", "Right"];
        if(_move_direction_y == -1) _move_direction_y = arr_y[rndint(2)];
        if(_move_direction_x == -1) _move_direction_x = arr_x[rndint(2)];

        if (animate_type == "hover vertical" || animate_type == "hover")
        {
            if ( art.y >= surface.y+range && _move_direction_y == "Down"){
                _move_direction_y = "Up";
            }

            if(art.y <= surface.y-range && _move_direction_y == "Up"){
                _move_direction_y = "Down";
            }

            if (_move_direction_y == "Down"){
                art.y += move_speed_y;
            }else if (_move_direction_y == "Up"){
                art.y -= move_speed_y;
            }
        }

        if (animate_type == "hover horizontal" || animate_type == "hover")
        {
            if (art.x >= surface.x+range && _move_direction_x == "Right"){
                _move_direction_x = "Left";
            }
            if (art.x <= surface.x-range && _move_direction_x == "Left"){
                _move_direction_x = "Right";
            }

            if (_move_direction_x == "Right"){
                art.x += move_speed_x;
            }else if (_move_direction_x == "Left"){
                art.x -= move_speed_x;
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

    // Generate a pseudo-random float between 0 and max - 1, inclusive
    function rndfloat(max) {
        local roll = 1.0 * max * rand() / RAND_MAX;
        return roll;
    }

    //Generate a pseudo-random integer between 0 and max
    function rndint(max) {
        local roll = 1.0 * max * rand() / RAND_MAX;
        return roll.tointeger();
    }

    // normalize 0.0 - 1.0
    static function normalize(value, min, max) {
        return (value - min) / (max - min);
    }

}