class CubicBezierInterpolator extends Interpolator {
    // Usage:
    // anim.interpolator(CubicBezierInterpolator("ease-out"))
    // or
    // use http://cubic-bezier.com to create your own (but makes sure to prefix 0. !)
    // anim.interpolator(CubicBezierInterpolator([ 0.72, -0.56, 0.33, 1.56 ]))
    easings = {
        "linear": [0.25, 0.25, 0.75, 0.75],
        "snap": [0.0, 1.0, 0.5, 1.0],
        "ease": [0.25, 0.1, 0.25, 1.0],
        "ease-in": [0.42, 0, 1.0, 1.0],
        "ease-out": [0.0, 0.0, 0.58, 1.0],
        "ease-in-out": [0.42, 0.0, 0.58, 1.0],
        "ease-in-cubic": [0.550,0.055,0.675,0.190],
        "ease-out-cubic": [0.215,0.61,0.355,1.0],
        "ease-in-out-cubic": [0.645,0.045,0.355,1.0],
        "ease-in-circle": [0.6,0.04,0.98,0.335],
        "ease-out-circle": [0.075,0.82,0.165,1.0],
        "ease-in-out-circle": [0.785,0.135,0.15,0.86],
        "ease-in-expo": [0.95,0.05,0.795,0.035],
        "ease-out-expo": [0.19,1.0,0.22,1.0],
        "ease-in-out-expo": [1.0,0.0,0.0,1.0],
        "ease-in-quad": [0.55,0.085,0.68,0.53],
        "ease-out-quad": [0.25,0.46,0.45,0.94],
        "ease-in-out-quad": [0.455,0.03,0.515,0.955],
        "ease-in-quart": [0.895,0.03,0.685,0.22],
        "ease-out-quart": [0.165,0.84,0.44,1.0],
        "ease-in-out-quart": [0.77,0.0,0.175,1.0],
        "ease-in-quint": [0.755,0.05,0.855,0.06],
        "ease-out-quint": [0.23,1.0,0.32,1.0],
        "ease-in-out-quint": [0.86,0.0,0.07,1.0],
        "ease-in-sine": [0.47,0.0,0.745,0.715],
        "ease-out-sine": [0.39,0.575,0.565,1.0],
        "ease-in-out-sine": [0.445,0.05,0.55,0.95],
        "ease-in-back": [0.6,-0.28,0.735,0.045],
        "ease-out-back": [0.175, 0.885,0.32,1.275],
        "ease-in-out-back": [0.68,-0.55,0.265,1.55],
        "slow-fast": [1.0,0.02,0,0.99],
        "elastic-back":[0.38,0.58,0.51,1.46]
    }
    bezier = null;

    constructor(easing = null) {
        if ( typeof(easing) == "array" ) {
            bezier = easing;
        } else if ( typeof(easing) == "string" ) {
            bezier = easings[easing];
        } else {
            bezier = easings["linear"];
        }
    }

    function interpolate( from, to, progress ) {
        //::print( from + " - " + to + " ->"+from + ( to - from )+"\n")
        return from + ( to - from ) * cubicBezier( progress, bezier[0], bezier[1], bezier[2], bezier[3] );
    }

    function cubicBezier (x, a, b, c, d)
    {
        local y0a = 0.00; // initial y
        local x0a = 0.00; // initial x
        local y1a = b;    // 1st influence y
        local x1a = a;    // 1st influence x
        local y2a = d;    // 2nd influence y
        local x2a = c;    // 2nd influence x
        local y3a = 1.00; // final y
        local x3a = 1.00; // final x

        local A = x3a - 3*x2a + 3*x1a - x0a;
        local B = 3*x2a - 6*x1a + 3*x0a;
        local C = 3*x1a - 3*x0a;
        local D = x0a;

        local E =   y3a - 3*y2a + 3*y1a - y0a;
        local F = 3*y2a - 6*y1a + 3*y0a;
        local G = 3*y1a - 3*y0a;
        local H =   y0a;

        // Solve for t given x (using Newton-Raphelson), then solve for y given t.
        // Assume for the first guess that t = x.
        local currentt = x.tofloat();
        local nRefinementIterations = 5;
        for (local i = 0; i < nRefinementIterations; i++)
        {
            local currentx = xFromT (currentt, A,B,C,D);
            local currentslope = slopeFromT (currentt, A,B,C);
            currentt -= (currentx - x)*(currentslope);
            currentt = clamp(currentt, 0,1);
        }
        local y = yFromT (currentt,  E,F,G,H);
        return y;
    }

    // Helper functions:
    function slopeFromT (t, A, B, C)
    {
        local dtdx = 1.0/(3.0*A*t*t + 2.0*B*t + C);
        return dtdx;
    }

    function xFromT (t, A, B, C, D)
    {
        local x = A*(t*t*t) + B*(t*t) + C*t + D;
        return x * 1.0;
    }

    function yFromT (t, E, F, G, H)
    {
        local y = E*(t*t*t) + F*(t*t) + G*t + H;
        return y;
    }

    function clamp(value, min, max) {
        if (value < min) value = min; if (value > max) value = max; return value
    }

}