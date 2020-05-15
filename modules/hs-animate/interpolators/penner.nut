class PennerInterpolator extends Interpolator {
    easing = null;
    //Penner easings
    easings = {
        "linear": function (t, b, c, d) { return c * t / d + b },
        "ease-in-cubic": function (t, b, c, d) { return c * pow(t / d, 3) + b; },
        "ease-in-quad": function (t, b, c, d) { return c * pow(t / d, 2) + b; },
        "ease-in-quart": function (t, b, c, d) { return c * pow(t / d, 4) + b; },
        "ease-in-quint": function (t, b, c, d) { return c * pow(t / d, 5) + b; },
        "ease-in-sine": function (t, b, c, d) { return -c * cos(t / d * (PI / 2)) + c + b; },
        "ease-in-expo": function (t, b, c, d) { if ( t == 0) return b; return c * pow(2, 10 * ( t / d - 1)) + b; },
        "ease-in-circle": function (t, b, c, d) { return -c * (sqrt(1 - pow(t / d, 2)) - 1) + b; },
        "ease-in-elastic": function (t, b, c, d, a = null, p = null) { if (t == 0) return b; t /= d; if (t == 1) return b + c; if (p == null) p = d * 0.37; local s; if (a == null || a < abs(c)) { a = c; s = p / 4; } else { s = p / (PI * 2) * asin(c / a); } t = t - 1; return -(a * pow(2, 10 * t) * sin((t * d - s) * (PI * 2) / p)) + b; },
        "ease-in-back": function (t, b, c, d, s = null) { if (s == null) s = 1.70158; t /= d; return c * t * t * ((s + 1) * t - s) + b; },
        "ease-in-bounce": function (t, b, c, d) { return c - PennerInterpolator.easings["ease-out-bounce"](d - t, 0, c, d) + b; },
        "ease-out-cubic": function (t, b, c, d) { t /= d; t -= 1; return c * (pow(t, 3) + 1) + b; },
        "ease-out-quad": function (t, b, c, d) { t /= d; return -c * t * (t - 2) + b; },
        "ease-out-quart": function (t, b, c, d) { t /= d; t -= 1; return -c * (pow(t, 4) - 1) + b; },
        "ease-out-quint": function (t, b, c, d) { t /= d; t -= 1; return c * (pow(t, 5) + 1) + b; },
        "ease-out-sine": function (t, b, c, d) { return c * sin(t / d * (PI / 2)) + b; },
        "ease-out-expo": function (t, b, c, d) { if (t == d) return b + c; return c * (-pow(2, -10 * (t / d)) + 1) + b;},
        "ease-out-circle": function (t, b, c, d) { t /= d; t -= 1; return (c * sqrt(1 - pow(t, 2)) + b); },
        "ease-out-elastic": function (t, b, c, d, a = null, p = null) { if (t == 0) return b; t = t / d; if (t == 1) return b + c; if (p == null) p = d * 0.37; local s; if (a == null || a < abs(c)) { a = c; s = p / 4; } else { s = p / (PI * 2) * asin(c / a); } return (a * pow(2, -10 * t) * sin((t * d - s) * (PI * 2) / p) + c + b).tofloat(); },
        "ease-out-back": function (t, b, c, d, s = null) { if (s == null) s = 1.70158; t /= d; t -= 1; return c * (t * t * ((s + 1) * t + s) + 1) + b; },
        "ease-out-bounce": function (t, b, c, d) { t /= d; if (t < 1 / 2.75) { return c * (7.5625 * t * t) + b; } else if ( t < 2 / 2.75) { return c * (7.5625 * (t -= (1.5/2.75)) * t + 0.75) + b; } else if ( t < 2.5 / 2.75 ) { return c * (7.5625 * (t -= (2.25/2.75)) * t + 0.9375) + b; } else { return c * (7.5625 * (t -= (2.625/2.75)) * t + 0.984375) + b;} },
        "ease-in-out-cubic": function (t, b, c, d) { t /= d; t *= 2; if (t < 1) return c / 2 * t * t * t + b; t = t - 2; return c / 2 * (t * t * t + 2) + b; },
        "ease-in-out-quad": function (t, b, c, d) { t /= d; t *= 2; if (t < 1) return c / 2 * pow(t, 2) + b; return -c / 2 * ((t - 1) * (t - 3) - 1) + b; },
        "ease-in-out-quart": function (t, b, c, d) {  t /= d; t *= 2; if (t < 1) return c / 2 * pow(t, 4) + b; t = t - 2; return -c / 2 * (pow(t, 4) - 2) + b; },
        "ease-in-out-quint": function (t, b, c, d) { t /= d; t *= 2; if (t < 1) return c / 2 * pow(t, 5) + b; t = t - 2; return c / 2 * (pow(t, 5) + 2) + b; },
        "ease-in-out-sine": function (t, b, c, d) { return -c / 2 * (cos(PI * t / d) - 1) + b; },
        "ease-in-out-expo": function (t, b, c, d) { if (t == 0) return b; if (t == d) return b + c; t /= d; t *= 2; if (t < 1) return c / 2 * pow(2, 10 * (t - 1)) + b; t = t - 1; return c / 2 * (-pow(2, -10 * t) + 2) + b; },
        "ease-in-out-circle": function (t, b, c, d) { t /= d; t *= 2; if (t < 1) return -c / 2 * (sqrt(1 - t * t) - 1) + b; t = t - 2; return c / 2 * (sqrt(1 - t * t) + 1) + b; },
        "ease-in-out-elastic": function (t, b, c, d, a = null, p = null) { if (t == 0) return b; t /= d; t *= 2; if (t == 2) return b + c; if (p == null) p = d * (0.3 * 1.5); local s; if (a == null || a < abs(c)) { a = c;  s = p / 4; } else { s = p / (PI * 2) * asin(c / a); } if (t < 1) return -0.5 * (a * pow(2, 10 * (t - 1)) * sin((t * d - s) * (PI * 2) / p)) + b; return a * pow(2, -10 * (t - 1)) * sin((t * d - s) * (PI * 2) / p) * 0.5 + c + b; },
        "ease-in-out-back": function (t, b, c, d, s = null) { if (s == null) s = 1.70158; s = s * 1.525; t /= d; t *= 2; if (t < 1) return c / 2 * (t * t * ((s + 1) * t - s)) + b; t = t - 2; return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b; },
        "ease-in-out-bounce": function (t, b, c, d) { if (t < d / 2) return PennerInterpolator.easings["ease-in-bounce"](t * 2, 0, c, d) * 0.5 + b; return PennerInterpolator.easings["ease-out-bounce"](t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b; },
    }

    constructor(easing = "linear") {
        this.easing = easing;
    }

    function interpolate(from, to, progress)
    {
        return easings[easing]( progress, from, to - from, 1.0 );
    }
}
