/*
elem : surface
Tickness: 1.0-5.0
msg: text
data: {x, y, w, font-size}
set : set any of the add_text properties : ("align" , Align.Left)
stroke_rgb : thick_rgb( [0,0,255] )
*/
class OutlinedText
{
    constructor(elem, msg, datas, thick)
    {
        thickness = clamp(thick, 0.5, 5.0) * 0.5;
        x_offset = thickness;
        y_offset = thickness;

        _title_l = elem.add_text(msg,0,0,0,0);
        _title_l.set_pos(datas.x - x_offset, datas.y, datas.w, datas.size);
        _title_l.set_rgb( 0, 0, 0 );

        _title_r = elem.add_text(msg,0,0,0,0);
        _title_r.set_pos(datas.x + x_offset , datas.y, datas.w, datas.size);
        _title_r.set_rgb( 0, 0, 0 );

        _title_d = elem.add_text(msg,0,0,0,0);
        _title_d.set_pos(datas.x, datas.y + y_offset, datas.w, datas.size);
        _title_d.set_rgb( 0, 0, 0 );

        _title_u = elem.add_text(msg,0,0,0,0);
        _title_u.set_pos(datas.x, datas.y - y_offset, datas.w, datas.size);
        _title_u.set_rgb( 0, 0, 0 );

        _title = elem.add_text(msg,0,0,0,0);
        _title.set_pos(datas.x, datas.y, datas.w, datas.size);
        _title.set_rgb( datas.color[0],datas.color[1], datas.color[2]  );
    }

    function set(param, val){
        _title_l[param] = val;
        _title_r[param] = val;
        _title_d[param] = val;
        _title_u[param] = val;
        _title[param] = val;
    }

    function x(val){
      _title_l.x = (val - thickness);
      _title_r.x = (val + thickness);
      _title_u.x = (val);
      _title_d.x = (val);
      _title.x = val;
    }

    function y(val){
      _title_l.y = (val);
      _title_r.y = (val);
      _title_u.y = (val - thickness);
      _title_d.y = (val + thickness);
      _title.y = val;
    }

    function thick_rgb(tbl){
       _title_l.set_rgb( tbl[0], tbl[1], tbl[2] );
       _title_r.set_rgb( tbl[0], tbl[1], tbl[2] );
       _title_d.set_rgb( tbl[0], tbl[1], tbl[2] );
       _title_u.set_rgb( tbl[0], tbl[1], tbl[2] );
    }

    function text_color(tbl){
       _title.set_rgb( tbl[0], tbl[1], tbl[2] );
    }

    function visible(bool){
        _title.visible = bool;
        _title_l.visible = bool;
        _title_r.visible = bool;
        _title_u.visible = bool;
        _title_d.visible = bool;
    }


    thickness = null;
    x_offset = null;
    y_offset = null;

    _title = null;
    _title_u = null;
    _title_d = null;
    _title_l = null;
    _title_r = null;
}

/* Menu Class  */
class SelMenu
{
    constructor(menu, surface , row_space)
    {
        _slot = [];
        for ( local i = 0; i < 38; i++){
          _slot.push(surface.add_text("",0,0,0,0));
          _slot[i].set_pos( flw * 0.006, flh * 0.041 + (row_space * i), flw * 0.17, flh * 0.022);
          _slot[i].align = Align.Left;
          _slot[i].set_bg_rgb(100,100,100);
          _slot[i].bg_alpha=0;
        }
        _list_title = surface.add_text("",0,0,0,0);
        _list_title.set_pos(flw * 0.008, flh * 0.002, flw * 0.24, flw * 0.008);
        _list_title.align = Align.Left;
        _list_info = surface.add_text("",0,0,0,0);
        _list_info.set_pos(flw * 0.008, flh * 0.022, flw * 0.24, flw * 0.0085);
        _list_info.align = Align.Left;
        _list_info.style = Style.Italic
        _list_info.set_rgb( 230, 230, 200 );
        _menus = menu

        fe.add_ticks_callback( this, "on_tick" );
    }

    function get_by_id( str ){
        foreach(k,v in _menus){ if(v.id == str) return clone(v); }
        return false;
    }

    function set_list(value){
        if(typeof(value) == "table" ) _current_list = clone(value); else _current_list = get_by_id( value );
        if(!_current_list) return false;
        if(!_current_list.rawin("slot_pos"))_current_list.slot_pos <- 0 // set the current list position slot

        _current_list.rows = clone(_current_list.rows); // stop delegation
        for (local i = _current_list.rows.len() - 1; i >= 0; i--){ // remove array item if hide
            if(_current_list.rows[i].rawin("hide")){
                if(_current_list.rows[i].hide.slice(0,1) == "!"){
                    if(_current_list.rows[i].hide.slice(1) != curr_sys) _current_list.rows.remove(i);
                }else{
                    if(_current_list.rows[i].hide == curr_sys) _current_list.rows.remove(i);
                }
            }
        }

        for ( local i = 0; i < 38; i++){
            if(i < _current_list.rows.len() ){
                _slot[i].msg = _current_list.rows[i].title;
            }else{
                _slot[i].msg = "";
            }
            _slot[i].set_bg_rgb(150,100,100);
            _slot[i].bg_alpha=0;
        }
        _slot_pos = _current_list.slot_pos;
        _slot[_slot_pos].bg_alpha = 255;
        _list_info.msg = "";
        if(_current_list.rows[_slot_pos].rawin("infos"))  _list_info.msg = _current_list.rows[_slot_pos].infos;

        titles();
    }

    function back(){
        if( !_lists.len()) return false;
        if( _current_list.rawin("onback") && typeof(_current_list.onback) == "function"){
            local onback = _current_list.onback;
            onback(_selected_row , _current_list);
        }

        set_list( _lists.top() );
        _lists.pop();
        titles();
        _selected_row.clear(); // clear the table
        return true;
    }

    function titles(){
        local tmp = "";
        if(!_lists.len()) tmp = "Main";
        foreach(a,v in _lists) tmp+=v.title + "->";
        if(_lists.len() > 0) tmp+=_current_list.title;
        _list_title.msg = tmp;
    }

    function select(){
        local onselect = false;
        if(_selected_row.rawin("type") ){ // save and reload theme if select pressed on rows that have type attr
            save_xml(xml_root, path);
            triggers.theme.start = true;
            if(_current_list.rawin("onselect") ){ // if onselect function exist
                onselect = _current_list.onselect;
                if(typeof(onselect) == "function" ){
                    if( !onselect(_current_list, _selected_row) ) return false;
                }
            }
        }
        // do not continue if we are on these item (prevent changing menu selected_row)
        if( _selected_row.rawin("type") || _edit_type != null ) return false;
        _list_info.msg = "";
        _current_list.slot_pos = _slot_pos; // set the current list position
        local prev_list = _current_list;
        _selected_row = clone(_current_list.rows[_slot_pos]);

        if(_current_list.rawin("onselect") ) onselect = _current_list.onselect;
        if(_selected_row.rawin("onselect") ) onselect = _selected_row.onselect;
        if(typeof(onselect) == "function" ){
            if( !onselect(_current_list, _selected_row) ) return false;
        }

        if(_selected_row.rawin("target")){
            local get_list = get_by_id(_selected_row.target); // check if the list exist in the menu
            if(get_list) _current_list = get_list;
        }

        set_list(_current_list);
        _lists.push(prev_list);
        titles();

        if( _current_list.rawin("afterload") && typeof(_current_list.afterload) == "function"){ // after load the newlist , use this function
            local afterload = _current_list.afterload; // need to be in var to have acces to the class prop (ex _pos)
            afterload(_current_list, _selected_row);
        }
    }

    function up(){
        _slot[_slot_pos].bg_alpha=0;
        if(!_slot_pos) _slot_pos =_current_list.rows.len();
        _list_info.msg = "";
        if(_current_list.rows[_slot_pos-1].rawin("infos")){
          _list_info.msg = _current_list.rows[_slot_pos-1].infos;
        }
        _slot[_slot_pos-1].bg_alpha=255;
        _slot_pos--;
    }

    function down(){
        _slot[_slot_pos].bg_alpha=0;
        if( _slot_pos == _current_list.rows.len()-1 ) _slot_pos=-1;
        _list_info.msg = "";
        if(_current_list.rows[_slot_pos+1].rawin("infos")){
          _list_info.msg = _current_list.rows[_slot_pos+1].infos;
        }
        _slot[_slot_pos+1].bg_alpha=255;
        _slot_pos++;
    }

    function set_text(pos, msg){
        _slot[pos].msg = msg;
        return true;
    }

    function get_input(){ // keys monitoring
        foreach(a,b in controls){
            foreach(k, v in b){
                if(fe.get_input_state(v) != false) return a;
            }
        }
        return false;
    }

    function on_tick(ttime) {
        if(globs.signal == "default_sig"){
            globs.hold = null;
            return true;
        }
        globs.hold = get_input();

        if(globs.hold){
            if(globs.keyhold % 10 == 1 && globs.keyhold > 1){
                fe.signal ( globs.hold.tolower() );
            }
            globs.keyhold = (globs.keyhold > 50 ? globs.keyhold+5 : globs.keyhold+1);
        }else{
            globs.hold = null;
            globs.keyhold = -1;
        }
        switch(_edit_type){
            case "pos/size/rotate":
                // hide special on edit mode
                ArtObj.SpecialA.visible = false;
                ArtObj.SpecialB.visible = false;
                ArtObj.SpecialC.visible = false;
                edit_artworks(_current_list.object);
            break;
            case "pos/size":
                overlay_video();
            break;
            case "edit_obj":
                edit_obj(_current_list.object, _edit_datas);
            break;
        }
    }

    function reset(){
       _edit_type = null;
       _current_list.clear();
       _selected_row.clear();
       _lists.clear();
       _slot_pos = 0;
       _edit_datas.clear();
    }

    _edit_datas = {}; // addoitional datas for edit_obj
    _selected_row = {};
    _edit_type = null;
    _current_list = {};
    _lists = [];
    _slot_pos = 0;

    _slot = null;
    _menus = null;
    _list_title = null;
    _list_info = null;
}

class PCCA_Conveyor {

    progress = null;
    offset = null;
    r_offset = null;
    wheel_elems = null;
    flw = null;
    flh = null;
    ft = null;
    angle = null;
    tjump = 0;
    step = null;
    config_speed = 40; // config speed from attract.cfg
    max_speed = 0;
    fast_start = false;
    spin_start = false;

    // fade
    w_time = 0;
    fade_time = 4000;
    fade_delay = 4000;
    fade_alpha = 0;
    fade_on = false;
    wheel_frame = false;
    frame_img = null;
    timer = 0
    timer2 = 0
    stop = false;
    artwork = "Wheel";

    constructor( init=false )
    {
        flw = ::fe.layout.width.tofloat();
        flh = ::fe.layout.height.tofloat();
        surface = ::fe.add_surface( flw, flh );
        surface.set_pos(0,0);
        if(init) Init(null);
        fe.add_transition_callback( this, "on_transition" );
        fe.add_ticks_callback( this, "on_tick" )
        fe.add_signal_handler(this, "main_signal")
        frame_img = surface.add_image("")
        frame_img.visible = false;
    }

    function set_slots(nbr_slot){
        local wlen = w_slots.len();
        if(wlen < nbr_slot){
            for ( local i=0; i<nbr_slot - wlen; i++ ){
                w_slots.push({
                    art = surface.add_image(""),
                    frame = surface.add_clone(frame_img),
                    origin_x = 0,
                    origin_y = 0,
                    origin_r = 0,
                    origin_a = 0,
                    origin_w = 0,
                    origin_h = 0,
                });
            }
        }else if(wlen > nbr_slot){
            for ( local i=wlen-1; i>0; i-- ){
                w_slots[i].art.file_name = "";
                w_slots[i].art.visible = false;
                w_slots[i].frame.visible = false;
            }
        }
    }

    function Init(opts){
        flh = surface.height
        flw = surface.width
        Rad = flh * 0.5
        reset_fade();
        if(opts){
            try{ speed = (opts.transition_ms < 150 ? 150 :  opts.transition_ms) } catch(err){}
            try{ nbr_slot = opts.slots } catch(err){}
            try{ fade_alpha = opts.alpha } catch(err){}
            try{ fade_time = opts.fade_time * 1000 } catch(err){}
            try{ Rad = opts.curve * flh * 0.5 } catch(err){}
            try{ rounded = (opts.type == "rounded" ? true : false) } catch(err){}
        }

        if(fade_time) fade_on = true;
        max_speed = (speed - config_speed);
        ft = 1.0 / round( speed / (1000.0 / ScreenRefreshRate), 0);
        offset = 0;
        progress = 0.0;
        wheel_elems = { "x":[], "y":[], "w":[], "h":[], "r":[] }

        local ww = flw * 0.15;
        local wh = (flh / nbr_slot);
        local pad = wh * 0.1;
        wh-=pad
        local y = -wh - pad * 0.5;

        if(nbr_slot % 2 == 0 ){ // if slot is even
            nbr_slot+=1;
            y = -wh * 1.5 - pad;
        }

        nbr_slot+=2; // add the 2 offscreen wheel
        wheel_x = flw + Rad - ww * 2
        wheel_y = flh * 0.5 - (wh * 0.5);
        r_offset = floor(nbr_slot * 0.5);

        angle = curve_points(Rad);

        for ( local i=0; i<nbr_slot; i++ ){
            local tot = 1.0 / nbr_slot;
            if(rounded){
                local mr = PI * angle[i] / 180;
                wheel_elems.x.push(wheel_x + Rad * cos( mr ) - (cos( mr ) * (-ww * 0.5) - sin( mr ) * (-wh * 0.5) - ww * 0.5) )
                wheel_elems.y.push(wheel_y + Rad * sin( mr ) - (sin( mr ) * (-ww * 0.5) + cos( mr ) * (-wh * 0.5) - wh * 0.5) )
                wheel_elems.r.push(angle[i] - 180)
            }else{
                wheel_elems.x.push(flw * 0.85);
                wheel_elems.y.push(y)
                wheel_elems.r.push(0)
            }

            wheel_elems.w.push(ww)
            wheel_elems.h.push(wh)

            y+=wh+pad
        }

        set_slots(nbr_slot);

        for ( local i=0; i<nbr_slot; i++ ){
            local mr = PI * angle[i] / 180;
            w_slots[i].origin_x = wheel_elems.x[i]
            w_slots[i].origin_y = wheel_elems.y[i]
            w_slots[i].origin_r = wheel_elems.r[i]
            w_slots[i].origin_a = angle[i]
            w_slots[i].origin_w = wheel_elems.w[i]
            w_slots[i].origin_h = wheel_elems.h[i]

            w_slots[i].art.preserve_aspect_ratio = true;
            w_slots[i].art.mipmap = true
            w_slots[i].art.zorder = -1;
            w_slots[i].art.visible = true;

            // frame
            if(wheel_frame) w_slots[i].frame.visible = true;
            w_slots[i].art.zorder = 1;
        }

        draw_wheel();

        if(spin_start){
            local rd = rnd_int(5, nbr_slot * 2 - 1);
            buffer.push(rd);
            offset+=rd;
            adjust = max_speed * 0.9;
            fast_start = true;
        }
    }

    function draw_wheel(offset=null){
        if(fe.game_info(Info.Emulator) == "@"){
            m_path = medias_path + "Main Menu/Images/" + artwork + "/";
        }else{
            m_path = medias_path + fe.list.name + "/Images/" + artwork + "/";
        }

        if(offset == null){
            offset = ceil(nbr_slot * 0.5) - 1;
        }

        for ( local i=0; i<nbr_slot; i++ ){
            w_slots[i].art.file_name = m_path + fe.game_info(Info.Name, i - offset ) + ".png";
            w_slots[i].art.set_pos(wheel_elems.x[i], w_slots[i].origin_y, w_slots[i].origin_w, w_slots[i].origin_h);
            w_slots[i].art.rotation = w_slots[i].origin_r;

            w_slots[i].frame.set_pos(wheel_elems.x[i], w_slots[i].origin_y, w_slots[i].origin_w, w_slots[i].origin_h);
            w_slots[i].frame.rotation = w_slots[i].origin_r;
        }
    }


    function curve_points(Rad){
        local angle = [];
        if(Rad){
            local a = Rad
            local b = Rad
            local c = flh - wh
            local aa=acos((b*b+c*c-a*a)/(2*b*c));
            aa=(aa*180/PI)
            local bb=acos((c*c+a*a-b*b)/(2*c*a));
            bb=(bb*180/PI)
            local cc=180.0-aa-bb;
            local ab = cc / nbr_slot;
            // calc elems pos in ° on wheel
            local start_point = -(180-(cc * 0.5));
            local seg = -cc / (nbr_slot - 1);
            for ( local i=0; i<nbr_slot; i++ ){
                angle.push(start_point);
                start_point+=seg
            }
        }
        return angle;
    }

    function main_signal( signal_str )
    {
        switch ( signal_str )
        {
            case "random_game" :
                ::fe.list.index = ::fe.list.index + rnd_int(50, 150)
                local rd = rnd_int(100, 250);
                buffer.push(rd);
                offset+=rd;
                adjust = max_speed
                fast_start = true;

            break;

            case "next_letter":
            case "prev_letter":
                adjust = max_speed
                fast_start = true;
            break;
        }

       return false;
    }

    function on_transition( ttype, var, ttime )
    {
        switch ( ttype )
        {
            case Transition.ToNewSelection:
                buffer.push(var);
                offset+=var;
                surface.alpha = 255;
            break;

            case Transition.ToNewList:
                reset_fade();
            break;

            case Transition.EndNavigation:
            break;

            case Transition.FromOldSelection:
            break;
        }

        return false;
    }

    function on_tick( ttime ){

        if( fe.get_input_state("down") != false || fe.get_input_state("up") != false){
            k_hold++;
        }else{
            k_hold=0;
        }

        if( buffer.len() ){
            timer = ttime
            stop = false
            if(!fast_start){
                tjump = buffer.reduce( function(previousValue, currentValue){
                    return ( previousValue + currentValue );
                });
            }

            if(progress == 1){
                step = 1
                if(k_hold > 20){
                    local max = max_speed * 0.6;
                    if(adjust < max){
                        adjust = max;
                    }
                }
                if(tjump>timer2)adjust+=speed * 0.01
                if(tjump<timer2)adjust-=speed * 0.01
                timer2 = tjump
                adjust = clamp(adjust , 0, max_speed );

                if( abs(tjump) > nbr_slot * 2){
                    buffer.clear();
                    buffer.push(tjump);
                }

                if( abs(buffer[0]) >= nbr_slot * 2  ){
                    step = abs(buffer[0]) - nbr_slot;
                }

                ft = 1.0 /  round( (speed-adjust) / (1000.0 / ScreenRefreshRate), 0 );

                if(buffer[0] > 0){ // key down
                    offset-=step
                    for ( local i = 1; i < nbr_slot; i++ ) w_slots[i].art.swap( w_slots[i-1].art );
                    w_slots[nbr_slot-1].art.file_name = m_path + fe.game_info(Info.Name, r_offset-offset  ) + ".png";
                }else if(buffer[0] < 0){
                    offset+=step
                    for ( local i = nbr_slot - 1; i > 0; i-- ) w_slots[i].art.swap( w_slots[i - 1].art );
                    w_slots[0].art.file_name = m_path + fe.game_info(Info.Name, -offset-r_offset ) + ".png";

                }

                for ( local i=0; i<nbr_slot; i++ ){ // reset original pos
                    w_slots[i].art.set_pos(w_slots[i].origin_x, w_slots[i].origin_y);
                    w_slots[i].art.rotation = w_slots[i].origin_r;

                    w_slots[i].frame.set_pos(w_slots[i].origin_x, w_slots[i].origin_y);
                    w_slots[i].frame.rotation = w_slots[i].origin_r;
                }

                if(abs(buffer[0]) < 2){
                    buffer.remove(0)
                    w_time = ttime
                }else{
                    if(buffer[0]<0) buffer[0]+=step else buffer[0]-=step
                    if(abs(buffer[0]) <= 0) buffer.remove(0)
                }

                progress = 0.0
            }

            if(buffer.len()){

                progress = clamp(progress+=ft, 0.0, 1.0);

                if(buffer[0] < 0){
                    for ( local a = 0; a < nbr_slot - 1; a++ ){

                        if(rounded){
                            local angle = ( w_slots[a+1].origin_a - w_slots[a].origin_a ) * progress / 1.0 + w_slots[a].origin_a
                            w_slots[a].art.x = wheel_x + Rad * cos( angle * PI / 180.0 )
                            w_slots[a].art.y = wheel_y + Rad * sin( angle * PI / 180.0 )
                            w_slots[a].art.rotation = angle - 180;
                            set_rotation(angle, w_slots[a].art);
                        }else{
                            w_slots[a].art.y = ( w_slots[a+1].origin_y - w_slots[a].origin_y ) * progress / 1.0 + w_slots[a].origin_y
                            w_slots[a].art.x = ( w_slots[a+1].origin_x - w_slots[a].origin_x) * progress / 1.0 + w_slots[a].origin_x
                            w_slots[a].art.rotation = ( w_slots[a+1].origin_r - w_slots[a].origin_r) * progress / 1.0 + w_slots[a].origin_r
                        }
                            w_slots[a].frame.set_pos(w_slots[a].art.x, w_slots[a].art.y);
                            w_slots[a].frame.rotation = w_slots[a].art.rotation;
                    }
                }else if(buffer[0] > 0){ // key down
                    for ( local a = 1; a < nbr_slot; a++ ){
                        if(rounded){
                            local angle = ( w_slots[a-1].origin_a - w_slots[a].origin_a ) * progress / 1.0 + w_slots[a].origin_a
                            w_slots[a].art.x = wheel_x + Rad * cos( angle * PI / 180.0 )
                            w_slots[a].art.y = wheel_y + Rad * sin( angle * PI / 180.0 )
                            w_slots[a].art.rotation = angle - 180;
                            set_rotation(angle, w_slots[a].art);
                        }else{
                            w_slots[a].art.y = ( w_slots[a-1].origin_y - w_slots[a].origin_y ) * progress / 1.0 + w_slots[a].origin_y
                            w_slots[a].art.x = ( w_slots[a-1].origin_x - w_slots[a].origin_x) * progress / 1.0 + w_slots[a].origin_x
                            w_slots[a].art.rotation = ( w_slots[a-1].origin_r - w_slots[a].origin_r) * progress / 1.0 + w_slots[a].origin_r
                        }
                            w_slots[a].frame.set_pos(w_slots[a].art.x, w_slots[a].art.y);
                            w_slots[a].frame.rotation = w_slots[a].art.rotation;
                    }
                }
            }
        }else{
            if(ttime - timer > 100){
                ft = 1.0 / round( speed / (1000.0 / ScreenRefreshRate) , 0);
                adjust = 0.0;
                tjump = 0
                fast_start = false;
                spin_start = false;
                fade();
                stop = true
            }
        }
    }

    function reset_fade() {surface.alpha = 255; w_time = ::fe.layout.time;}

    function fade(){
        if(!fade_on) return false;
        local alpha;
        if(!fade_time) fade_time = 0.01;
        local from = 255;
        local to = clamp( fade_alpha * 255 , 0.0 , 255.0);
        local elapsed = ::fe.layout.time - w_time;
        if( elapsed > fade_delay && fade_time > 0) {
            alpha = (from * (fade_time - elapsed + fade_delay)) / fade_time;
            alpha = (alpha < 0 ? 0 : alpha);
            if(alpha <= to || alpha == 0) return false;
            surface.alpha = alpha;
        }
    }

    //clamp a value from min to max
    function clamp(value, min, max) {
        if (value < min) value = min; if (value > max) value = max; return value
    }

    function rnd_int(min, max){
        srand( rand() * time() );
        return (rand() * (max - min + 1) / (RAND_MAX + 1)) + min;
    }


    function set_rotation(r, obj) {
        local mr = PI * r / 180;
        obj.x -= cos( mr ) * (-obj.width * 0.5) - sin( mr ) * (-obj.height * 0.5) - obj.width * 0.5;
        obj.y -= sin( mr ) * (-obj.width * 0.5) + cos( mr ) * (-obj.height * 0.5) - obj.height * 0.5;
    }

    function round(nbr, dec){ //Round Number as decimal
        local f = pow(10, dec) * 1.0;
        local newNbr = nbr.tofloat() * f;
        newNbr = floor(newNbr + 0.5)
        newNbr = (newNbr * 1.0) / f;
        return newNbr;
    }

    wh = 0;
    rounded = true;
    Rad = 0;
    adjust = 0;
    surface = {};
    buffer = [];
    k_hold = false;
    nbr_slot = 6;
    speed = 170;
    wheel_x = 0
    wheel_y = 0
    m_path = "";
    w_slots = [];
}

