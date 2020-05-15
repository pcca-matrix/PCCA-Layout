Animate2 AttractMode Module
-
***This is a WIP. Some functions may not yet be implemented or working properly. Continue at your own risk :)***

For real world use, see the [Sample Animate2 layout](https://github.com/liquid8d/attract-extra/tree/master/layouts/sample_animate2).

About
-
The Animate modules provides Attract Mode with an animation engine to animate various objects in your layouts. The module is based partially on the work in [Tweene](http:tweene.com/html/docs) and has a similar structure to setting up
animations for your objects.

Usage
-
To use Animate, add the animate module in your layout:

`fe.load_module("animate2");`

Next, create an animation by specifying options. You can append multiple options using chained methods:

`PropertyAnimation(obj).key("x").from(100).to(200).play()`

Unless otherwise specified, Animations will accept an object, and an optional options table of values, or you can use methods to set values.

|Method|Default|Desc|
|:-|:-:|:-|
|`.name(string)`||name for the animation, useful for debugging multiple animations|
|`.debug(bool)`|false|if true, enable debug console output|
|`.target(obj)`||target object to animate, if required by animation (can be specified as animations 1st argument instead)|
|`.key(string)`||key value to animate|
|`.from(int/float/table/string)`||start value(s) - an integer/float, table of key-value pairs or a state name|
|`.to(val)`||ending value(s) - an integer/float, a table of key-value pairs or a state name|
|`.yoyo(bool)`|false|if true, play animation forward, then backwards
|`.reverse(bool)`|false|play animation in reverse|
|`.loops(int), .repeat(int)`|0|number of times to loop/repeat animation, -1 = infinite|
|`.delay(int/string)`|0|delay in ms, a time string ( "1s" or "250ms" ), or time aliases "slow" (750ms), "normal" (500ms), "fast" = (250ms)|
|`.duration(int/string)`|| optional duration in ms, a time string ( "1.5s" or "500ms" ), or time aliases "slow" (750ms), "normal" (500ms), "fast" = (250ms)|
|`.speed(int/float/string)`|1|speed factor integer/float (1.0 being normal speed) or aliases "half" (0.5), "normal" (1.0), "double" (2.0)|
|`.triggers( array )`||array of any Transition. values|
|`.easing( string )`|"linear"|string name of easing to use (see [CubicBezierInterpolator](interpolators/cubicbezier.nut) or [PennerInterpolator](interpolators/penner.nut) for available values)|
|`.interpolator( class )`|CubicBezierInterpolator|specify a custom interpolator|
|`.smoothing(float)`|0.033|tick update frequency, multiples speed
|`.step(float)`||pause an animation and jump to a specified progress (0-1)
|`.set_time_unit(string)`|"ms"|set the default time unit - ms or s - used for delays or duration|
|`.default_state(string)`|"current"|default state used if 'from' or 'to' are not specified. This must be a state stored using the `state()` method. You can use the builtin "origin", "start" or "current" states|
|`state(string, table)`||save a state by name. This state can later be used by referencing its name using `from()`, `to()` or `default_state()`|
|`.set_state( table )`||immediately set state values for a target (if target is specified )|
|`.play()`||play animation immediately, triggers still apply|
|`.pause()`||pause animation - if already paused, has no affect|
|`.unpause()`||unpause animation - if not running, the animation will start running|
|`.restart()`||restart an animation|
|`.stop()`||stop an animation|
|`.cancel(*string)`|"current"|cancel animation. Specify an optional state name to specify what state to put the target in - "origin", "start", "from" or "to"|
|`.then( func )`||Run a function after animation completes (one-shot after), function is passed anim as param|
|`.on( string, function )`||hook a callback to your own function, one of AnimationEvents, function is passed anim as param|
|`.off( string, function )`||remove a callback that was hooked to an event, function is passed anim as param|

**Not yet implemented**

|Method|Default|Desc|
|:---|:---:|:---|
|`trigger_restart(bool)`|true|if true, restart animation when specified triggers occur|
|`.delayFrom(bool)`||if true, animation will wait for a delay to finish to set the 'from' state|
|`.loops_delay(int/float/string)`||delay before loop - a number (default time unit), a time string ( "1s" or "250ms" ), or time aliases "slow" (750ms), "normal" (500ms), "fast" = (250ms)|
|`.loops_delay_from(bool)`|false|if true, animation will wait for a loop delay to finish to set the 'from' state|
|`.exec( table )`||execute a macro|
|`.copy( anim )`||copy another anims properties|


Notes
-
* Only required values are the target (for animations that need it, like PropertyAnimation) the from/to values and for PropertyAnimation, the key that will be animated.

* Animations start when the .play() function is called, or one of the provided trigger events occurs.

* Additional options may be available, depending on the animation you are creating.

* The Animation class provided by animate can be extended for custom animations or interpolations.

Params for the instantiation can optionally be the target and/or the default config.

* Animation options are passed using chainable functions, but you can also use config tables, which is nice if you reuse animations for multiple objects.
Animations that act on a target (i.e. PropertyAnimation) require a target object.

Available Animations
=
There are currently three supported animations:

PropertyAnimation
-
Animate the properties of a target object.

* In addition to the typical object properties in AM, you can also use 'scale', and specify center scaling and center rotation.

**Example**

`PropertyAnimation(obj).from( { x = 0 } ).to( { x = 100 } ).play();`

SpriteAnimation
-
Animate a spritesheet where the target is an image you added that uses a spritesheet image.

* SpriteAnimate will automatically set the subimg_width and subimg_height to the size of your object, but you can set a specific size using sprite_width() and sprite_height()

* You can specify the order of frames:
`SpriteAnimation(obj).order( [ 0, 2, 1 ] ).play();`

**Example**
`SpriteAnimation(obj).sprite_width(64).sprite_height(64).order([ 0, 1, 2]).loop(-1).play()`

ParticleAnimation
-
An implementation of a Particle engine which allows you to create particles using emitters.

**Example**
```
local anim = ParticleAnimation()
local emitter = anim.addEmitter({ x = 0, y = 0 })
      emitter
        .addModifier(RateModifier( 1, 3 ))
        .addModifier(ScaleModifier( 1, 2 ))
        .addModifier(ColorModifier( "random"))
```

Animation Triggers
-
Triggers are events that occur that trigger your animation to play. A trigger is an array, so you can specify multiple values if you so choose.

Triggers are specified for an animation using .triggers(array) function.

The typical triggers are the Transition.* values. Additional trigger events may be available in the future.

**Example**
`PropertyAnimation(obj).from(0).to(100).triggers([Transition.ToNewSelection])`

Timeline Animations
-
You can create a timeline of animations to run in a queued order using the TimeLineAnimation class:

**Example**
```
local scaleAnim = PropertyAnimation(text).fromTo({ scale = 1 }, { scale = 2 })
local rotateAnim = PropertyAnimation(text).fromTo({ rotation = 0 }, { rotation = 180 })

TimelineAnimation()
    .add(scaleAnim)
    .add(rotateAnim)
    .play()
```

Animation States
-
**Not yet implemented**

An animation state is just a squirrel table of key/value pairs.

We can use a state table to set multiple values, or use two state tables (from and to) to animate values over time.

Using states simplifies the process of positining objects or animating objects from one place to another. Though states can be more than just positions.

You can define your own 'states' for objects, and then run an animation that transitions from one state to another.

* PropertyAnimation automatically attempts to save states for "origin", "start", "from", "to" and "current".

* If the 'from' or 'to' states aren't specified, the *default_state* is used.

**Example**
```
local middle = {
    x = fe.layout.width,
    y = fe.layout.height,
    alpha = 255
}

local bottom = {
    x = fe.layout.width / 2,
    y = fe.layout.height, alpha = 50
}

PropertyAnimation(obj).from(middle).to(bottom).play()
```

Animation Macros
-

**Not yet implemented**

Macros are predefined animations (or more specifically, the properties for an animation).

You can register a macro by calling `Animation.registerMacro( "my_macro", val )`

You can initialize it by calling `.exec( macro )` and play it immediately with `.exec(macro).play()`;

At first, the difference between macros and states may seem confusing, since both are tables of keys/values. The difference is that a macro contains the complete options for an animation, whereas a state is just properties.

***A macro might contain states, but states can't contain macros.***

**Example**
```
 local macros = {
     fade = {
         duration = "0.5s",
         from = { alpha = 0 },
         to = { alpha = 255 }
     },
     visible = {
         to = { alpha = 255 }
     },
     invisible = {
         to = { alpha = 0 }
     }
 }
```

Extending Animation
-
The Animation class is a base class which can be extended by developers to create new animations. It provides basic required information for timing, starting, updating and stopping animations. Custom animations can be created to extend this functionality.

**Example**
```
class MyAnimation extends Animation
{
    function start() {
        base.start();
    }

    function update() {
        base.update();
        //update animation here
    }

    function pause() {
        base.pause();
    }

    function unpause() {
        base.unpause;
    }

    function stop() {
        base.stop();
    }

    function restart() {
        base.restart();
    }

}
```

* By default, 'progress' is automatically determined based on many factors such as user options like duration, delay, speed and direction. You can override this by not including the base.update() method, and setting 'progress' manually.

Extending Interpolators
///////////////////////////////

The Interpolator class is what determines values based on the progress of the animation. Some default interpolators are already provided ( Penner and CubicBezier ), but developers can create their own.

* Interpolators take a from and to value and are given the current progress of the animation. It then returns what the current value should be.

**Example**
```
class MyInterpolator extends Interpolator
{
    function interpolate( from, to, progress )
    {
        return from + ( ( to - from ) * progres );
    }
}
```

Tweene Differences
-
Animate v2 is based on [Tweene](http://tweene.com/html/docs/).

You can reference its documentation, but there are some differences:
 - ignore references to drivers (jquery, gsap and velocity) - there is only one default driver here

Basic Animation
* use AnimationName() instead of Tweene ( i.e. SpriteAnimation() )
* table values in squirrel must be "propname": value or propname = value ( not propname: value ) quotes with colon, or no quotes with equals
* resume() is a reserved word, use unpause() instead
* don't pass a target to each method - pass it to the PropertyAnimation constructor, or use target(obj)
* don't pass callback functions into the from and to methods - use on(event)
* don't pass duration to from/to - use duration(time)
* relative values are not supported yet ( +=50 )
* easing strings need to be passed to the class for  .interpolator() and are formatted differently ( easeOutQuad = ease-out-quad )
* options() not supported - use individual setters for now
* no 'complete' callback - use 'stop' instead
* doesn't support property translations ( myProperty = my-property )
* no defaultDuration option
* no defaultEasing option
* doesn't support timeScale
* no aliases for callbacks ( start = begin, complete = end, etc)

PropertyAnimation
* use PropertyAnimation() instead of Tweene
* properties are of course based on AM object properties, not css properties
* sets scheduled? or run immediately

Macros
* registerMacro doesn't use a function, just a state value
* exec doesn't use a function, so it does not support custom parameters

States

Timeline
* this might be a bit different
* doesn't support labels
* doesn't support directional callbacks

Presets
 - Tween