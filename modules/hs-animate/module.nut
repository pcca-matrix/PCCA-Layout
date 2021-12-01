////////////////////////////////////
//  Animate v2 -> HS Animate
//
// This program comes with ABSOLUTELY NO WARRANTY.  It is licensed under
// the terms of the GNU General Public License, version 3 or later.
//
//  About:
//  Provides AttractMode with animation capabilities
//
//  Description:
//  See animate2/README for a detailed explanation of use
//  See animate2/CHANGELOG for changes from v1
//
// Base Code is work of liquid8d -> https://github.com/liquid8d/attract-extra
//
////////////////////////////////////

Screen <- {
    center = { x = fe.layout.width / 2, y = fe.layout.height / 2 }
}

OFFSET <- fe.layout.width * 0.10;

POSITIONS <- {
    top = function(o) { return  { y = -(o.height + OFFSET), x=o.x } },
    bottom = function(o) { return { y=fe.layout.height + OFFSET, x=o.x } },
    left = function(o) { return  { x=-(o.width + OFFSET), y=o.y } },
    right = function(o) { return { x=fe.layout.width + OFFSET, y=o.y } },
    none = function(o) {return {x=o.x, y=o.y} }
}

class Interpolator {
    constructor(arg = null) {

    }

    function interpolate( from, to, progress ) {

    }
}

fe.do_nut(FeConfigDirectory + "modules/hs-animate/interpolators/cubicbezier.nut");
fe.do_nut(FeConfigDirectory + "modules/hs-animate/interpolators/penner.nut");

class Animation {

    Panimations = [];              //array for on-demand animations
    resting = false;               //resting animation
    resting_progress = 0;          //resting progress, 0 to 1
    running = false;               //is the animation running
    last_update = 0;               //time of last update
    elapsed = 0;                   //time elapsed since animation started
    tick = 0;                      //time since last update
    progress = 0;                  //current animation progress, 0 to 1
    play_count = 0;                //number of times animation has played
    opts = null;                   //the current animation options
    _from = null;                  //values we are animating from
    _to = null;                    //values we are animating to

    states = null;                 //predefined states
    callbacks = null;              //registered callbacks for animation events
    yoyoing = false;               //is animation yoyoing
    key_interpolator = null;       //interpolator by key

    default_config = {
        name = "",
        target = null,              //target object to animate
        from = null,                //state (values) we will animate from
        to = null,                  //state (values) we will animate to
        triggers = [],              //array of transitions that will trigger the animation
        trigger_restart = true,     //when a trigger occurs, the animation is restarted
        default_state = "current"   //default state if no 'from' or 'to' is specified
        then = null,                //a function or state that is applied at the end of the animation
        duration = 0,               //duration of animation (if timed)
        speed = 1,                  //speed multiplier of animation
        smoothing = 0.033,          //smoothing ( magnifies speed )
        delay = 0,                  //delay before animation begins
        delay_from = true,          //delay setting the 'from' values until the animation begins
        loops = 0,                  //loop count (-1 is infinite)
        loops_delay = 0,            //separate delay that is applied only to a looped playback
        loops_delay_from = true,    //delay setting 'from' values until the loop delay finishes
        yoyo = false,               //bounce back and forth the 'from' and 'to' states
        reverse = false,            //reverse the animation
        interpolator = CubicBezierInterpolator("linear"),
        auto = true                // use internal ticks on external
    }

    constructor(...) {
        callbacks = [];
        states = {};
        key_interpolator = {};
        defaults(vargv);
        init();
    }

    //reset animation options to defaults
    function defaults(params) {
        opts = clone( default_config );
        //if opts are provided, merge them
        if ( params.len() > 0 ) {
            if ( typeof(params[0]) == "table" ) {
                opts = merge_opts(opts, params[0]);
                //set the target if its in the config
                if ( "target" in opts && opts.target != null )
                    target(opts.target);
                //sanitize - initialize some option values
                foreach( key, val in opts ) {
                    if ( key == "duration" || key == "delay" || key == "loopsDelay" )
                        opts[key] <- val.tofloat();
                    if ( key == "speed" )
                        opts[key] <- val.tofloat();
                }
            } else if ( typeof(params[0]) != "array" && typeof(params[0]) != "string" ) {
                //assume this is a target object instance
                target(params[0]);
            }
        }
        return this;
    }

    //listen to AM ticks
    function on_tick(ttime) {
        if ( running ) {
            if ( progress == 1 ) {
                stop();
            } else {
                tick = ::clock() * 1000 - last_update;
                elapsed += tick;
                last_update = ::clock() * 1000;
                if ( elapsed > opts.delay ) {
                    //increase progress
                    if ( opts.duration <= 0 ) {
                         progress = clamp( progress + ( opts.smoothing * opts.speed ), 0, 1);
                    } else {
                        //use time
                        progress =  clamp( progress + (tick / opts.duration) ,0 ,1);
                    }
                    update();
                } else {
                    //delay
                    update();
                }
            }
        }else if( resting && progress == 1 ){
            anim_rest();
        }
    }

    //listen to AM transitions
    function on_transition( ttype, var, ttime ) {
        if( opts.triggers ){
            foreach( t in opts.triggers ) {
                if ( t == ttype ){
                    if ( opts.trigger_restart ){
                        restart();
                    }else{
                        play();
                    }
                }
            }
        }
        return false;
    }

    //*** CHAINABLE METHODS ***
    function name( str ) { opts.name = str; return this; }
    function target( ref ) { opts.target <- ref; return this; }
    function from( val ) { opts.from = val; return this; }
    function to( val ) { opts.to = val; return this; }
    function loops( count ) { opts.loops = count; return this; }
    function reverse( bool = null ) { opts.reverse = ( bool == null ) ? !opts.reverse : bool; if ( running ) do_reverse(); return this; }
    function yoyo( bool = true ) { opts.yoyo = bool; return this; }
    function interpolator( i ) { opts.interpolator = i; return this; }
    function triggers( triggers ) { opts.triggers = triggers; return this; }
    function then( then ) { opts.then = then; return this; }
    function speed( s ) { opts.speed = s; return this; }
    function smoothing( s ) { opts.smoothing = s; return this; }
    function delay( length ) { opts.delay = length; return this; }
    function duration( d ) { opts.duration = d; return this; }
    function state( name, state ) { states[name] <- state; return this }
    function default_state( state ) { opts.default_state = state; return this; }
    function easing( e ) { if ( e.find("elastic") != null || e.find("bounce") != null ) return interpolator( PennerInterpolator(e) ); else return interpolator( CubicBezierInterpolator(e) ); }
    function auto( bool = false ){
        if(bool){
            //add callbacks
            fe.add_ticks_callback( this, "on_tick" );
            fe.add_transition_callback( this, "on_transition" );
        }else{
            Panimations.push(this);
        }
        opts.auto = bool
        return this;
    }

    function key_interpolator( key, interpolator ) { key_interpolator[key] <- interpolator; return this }
    function loops_delay( delay ) { opts.loops_delay = delay; return this; }

    //NOT VERIFIED/WORKING YET!
    function delay_from( bool ) { opts.delay_from = bool; return this; }
    function loops_delay_from( bool ) { opts.loops_delay_from = bool; return this; }
    function trigger_restart( restart ) { opts.trigger_restart = restart; return this; }

    //add an event handler
    function on( event, param1, param2 = null ) {
        callbacks.push({
            event = event,
            env = ( param2 == null ) ? null : param1,
            func = ( param2 == null ) ? param1 : param2
        });
        return this;
    }

    //remove an event handler
    function off( event, param1, param2 = null ) {
        for( local i = 0; i < callbacks.len(); i++ )
            if ( param2 == null && callbacks[i].func == param1 )
                callbacks.remove(i);
            else
                if ( callbacks[i].env == param1 && callbacks[i].func == param2 )
                    callbacks.remove(i);
        return this;
    }

    //copy another animation
    function copy( anim ) {
        opts = clone( anim.opts );
        //will need to copy other values too (interpolator, etc )
        return this;
    }

    function init() {
        run_callback( "init", this );
    }

    function anim_rest() {
        run_callback( "resting", this );
    }

    //play the animation
    function play() {
        start();
    }

    //start the animation
    function start() {
        _from = ( "from" in states ) ? states["from"] : opts.from;
        _to = ( "to" in states ) ? states["to"] : opts.to;

        //reverse from and to if reverse is enabled
        do_reverse();
        //update times
        last_update = ::clock() * 1000;
        elapsed = 0;
        tick = 0;
        progress = 0;
        running = true;
        run_callback( "start", this );
    }

    //update the animation
    function update() {
        if ( _from == null || _to == null ) return;
        run_callback( "update", this );
    }

    //update the from and to values when reversed
    function do_reverse() {
        if ( opts.reverse ) {
            _from = ( "to" in states ) ? states["to"] : opts.to;
            _to = ( "from" in states ) ? states["from"] : opts.from;
        } else {
            _from = ( "from" in states ) ? states["from"] : opts.from;
            _to = ( "to" in states ) ? states["to"] : opts.to;
        }
        run_callback( "reverse", this );
    }

    //pause animation at specified step (progress)
    function step(progress) {
        if ( running ) pause();
        this.progress = clamp(progress, 0, 1);
        update();
    }

    //pause the animation
    function pause() {
        running = false;
        run_callback( "pause", this );
    }

    //unpause the animation
    function unpause() {
        running = true;
        run_callback( "unpause", this );
    }

    //restart the animation
    function restart() {
        run_callback( "restart", this );
        play();
    }

    //stop animation (depending on options)
    function stop() {
        if ( opts.yoyo ) {

            if( opts.loops_delay && (elapsed - opts.delay - opts.duration - tick ) < opts.loops_delay ){
                elapsed += tick;
                update();
                return;
            }
            //flip yoyoing, reverse animation
            yoyoing = !yoyoing;
            opts.reverse = !opts.reverse;
        }

        if ( yoyoing ) {
            //first half of 'yoyo' finished, restart to play second half
            run_callback( "yoyo", this );
            restart();
        } else {
            if ( opts.loops == -1 || ( opts.loops > 0 && play_count < opts.loops ) ) {
                //play loop
                play_count++;
                run_callback( "loop", this );
                restart();
            } else {
                //finished animation
                running = false;
                run_callback( "stop", this );
                play_count = 0;
                //run then function or set state if either exist
                if ( "then" in opts && opts.then != null ) {
                    local t = opts.then;
                    //don't keep running .then() on loops or replayed anim.play() from then references
                    opts.then = null;
                    if ( typeof(t) == "function" ) {
                        t(this);
                    } else if ( typeof(t) == "table" ) {
                        set_state(t);
                    } else if ( typeof(t) == "string" && t in states ) {
                        set_state(states[t]);
                    }
                }
            }
        }
    }

    //cancel animation, set key to specified state (origin, start, from or to, current)
    function cancel( state = "current" ) {
        //print("\nAnimation canceled" + this + "\n");
        running = false;
        progress = 1.0;
        if(state == "origin" ){
            yoyoing = false;
            opts.reverse = false;
        }
        set_state(state);
        run_callback( "cancel", this );
    }

    //*****  Helper Functions  *****

    //set the target state
    function set_state( state ) {
        if ( "target" in opts && opts.target != null ) {
            if ( typeof(state) == "string" && state in states ) state = states[state]; else return this;
            foreach( key, val in state )
                try {
                    if ( key == "rgb" ) {
                        opts.target.set_rgb( val[0], val[1], val[2] );
                        if ( val.len() > 3 ) opts.target.alpha = val[3];
                    } else {
                        opts.target[ key ] = val;
                    }
                } catch (err) { /*print("error settings state: " + err);*/ }
        }
        return this;
    }

    //run callbacks for an event
    function run_callback( event, params = {} ) {
        foreach( cb in callbacks )
            if ( cb.event == event )
                if ( cb.env != null )
                    cb.env[ cb.func ]( params );
                else
                    cb.func( params );
    }

    //clamp a value from min to max
    function clamp(value, min, max) {
        if (value < min) value = min; if (value > max) value = max; return value
    }

    //values in table b will be inserted into table a, overwriting existing values
    static function merge_opts(a, b) {
        foreach( key, value in b ) {
            if ( typeof(b[key]) == "table" )
                a[key] <- merge_opts(a[key], b[key]);
            else
                a[key] <- b[key];
        }
        return a;
    }

    //convert a squirrel table to a string
    static function table_as_string( table )
    {
        if ( table == null ) return ""
        local str = ""
        foreach ( name, value in table )
            if ( typeof(value) == "table" )
                str += "[" + name + "] -> " + table_as_string( value ) +"\n"
            else
                str += name + ": " + value + " \n"

        //logs.write_line(str);
        return str
    }
}

local Panimations = Animation().Panimations;

fe.add_ticks_callback( "animate_tick" );
function animate_tick( ttime )
{
    // Animation ticks_callback
    foreach(anim in Panimations){

        if ( anim.running ) {
            if ( anim.progress == 1 ) {
                anim.stop();
            } else {
                anim.tick = ::clock() * 1000 - anim.last_update;
                anim.elapsed += anim.tick;
                anim.last_update = ::clock() * 1000;
                //anim.update();
                if ( anim.elapsed >=anim.opts.delay ) {
                    //increase progress
                    if ( anim.opts.duration <= 0 ) {
                        anim.progress = anim.clamp( anim.progress + ( anim.opts.smoothing * anim.opts.speed ), 0, 1);
                    } else {
                        //use time
                        anim.progress = anim.clamp( anim.progress + (anim.tick / (anim.opts.duration) ) ,0 ,1);
                    }
                   anim.update();
                }else{
                   anim.update();
                }

            }
        }
    }
}



fe.do_nut(FeConfigDirectory + "modules/hs-animate/animations/shader.nut");
fe.do_nut(FeConfigDirectory + "modules/hs-animate/animations/presets.nut");