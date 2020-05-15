// Thanks, ArcadeBliss!
class ShaderAnimation extends Animation {

    _param = null;
    // custom methods
    function param( param ) { _param = param; return this;}

    function defaults(params) {
        base.defaults(params);
        opts = merge_opts( {
            param = null
        }, opts);
        _param = opts.param;
        return this;
    }

    function start() {
        base.start()
    }

    function update() {
        if ( _param == null || typeof(_from) != "array" || typeof(_to) != "array" || _from.len() != _to.len() ) return;
        local vals = array(4);
        for ( local i = 0; i < _from.len(); i++ )
            vals[i] = opts.interpolator.interpolate(_from[i], _to[i], progress);
        if ( _from.len() == 1 )
            opts.target.set_param( _param, vals[0] );
        else if ( _from.len() == 2 )
            opts.target.set_param( _param, vals[0], vals[1] );
        else if ( _from.len() == 3 )
            opts.target.set_param( _param, vals[0], vals[1], vals[2] );
        else if ( _from.len() == 4 )
            opts.target.set_param( _param, vals[0], vals[1], vals[2], vals[3] );
        base.update();
    }
}