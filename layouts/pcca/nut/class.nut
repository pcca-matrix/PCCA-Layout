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

    function select(path){
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

    progress = 0.0;
    offset = 0;
    r_offset = 0;
    type = "right";
    surface_w = 0.0;
    surface_h = 0.0;
    ft = 0.0;
    tjump = 0;
    step = null;
    config_speed = 40.0; // config speed from attract.cfg
    max_speed = 0.0;
    fast_nav = false;
    spin_start = true;
    wheel_frame = false;
    frame_img = null;
    timer = 0;
    stop = false;
    media = "Wheel";
    rounded = true;
    Rad = 0;
    Curve = 1.0;
    adjust = 0.0;
    surface = {};
    buffer = [];
    buff = 0;
    nbr_slot = 6;
    speed = 170;
    wheel_center_x = 0.0;
    wheel_center_y = 0.0;
    scale = 1.0;
    el_rot = 0.0;
    m_path = "";
    w_slots = [];
    new_val = 0.0;
    center_zoom = 1.5;
    mark_h = null;
    mark_w = null;
    // attract
    AttractEnabled = true
    attract_time = 80000;
    MaxSpinTime = 5000;
    am_counter = 0;
    am_WaitVideo = true; // true disable timer
    last_selected = "";
    AM_all_systems = true;
    AM_system_loop = 3
    next_tick = false

    // fade
    w_time = 0;
    fade_time = 4000;
    fade_delay = 3000;
    fade_alpha = 0;
    fade_on = false;

    constructor( ... )
    {
        surface = ::fe.add_surface( ::fe.layout.width.tofloat(), ::fe.layout.height.tofloat() );
        surface.set_pos(0,0);
        fe.add_transition_callback( this, "on_transition" );
        fe.add_ticks_callback( this, "on_tick" )
        fe.add_signal_handler(this, "main_signal")
        frame_img = surface.add_image("")
        frame_img.visible = false
        mark_w = surface.add_image("images/line.png", surface.width * 0.5, 0, 1, surface.height) // center ver
        mark_h = surface.add_image("images/line.png", 0, surface.height * 0.5, surface.width, 1) // center hor
        mark_w.visible=false
        mark_h.visible=false
    }

    function set_slots(nbr_slot){
        nbr_slot+=2;
        if(nbr_slot % 2 == 0 ) nbr_slot+=1;
        local wlen = w_slots.len();
        if(wlen < nbr_slot){
            for ( local i=0; i<nbr_slot - wlen; i++ ){
                w_slots.push({
                    art = surface.add_image(""),
                    frame = surface.add_clone(frame_img),
                    x = 0.0,
                    y = 0.0,
                    r = 0.0,
                    width = 0.0,
                    height = 0.0,
                });
            }
        }else if(wlen > nbr_slot){
            for ( local i=nbr_slot; i<wlen; i++ ){
                w_slots[i].art.file_name = "";
                w_slots[i].art.visible = false;
                w_slots[i].frame.visible = false;
            }
        }

        for ( local i=0; i<nbr_slot; i++ ){
            w_slots[i].art.visible = true;
            w_slots[i].frame.visible = true;
            w_slots[i].art.preserve_aspect_ratio = true;
            w_slots[i].frame.preserve_aspect_ratio = true;
            w_slots[i].art.zorder = 1;
        }
    }

    function Init(opts){
        buffer.clear()
        surface_h = surface.height
        surface_w = surface.width
        Rad = surface_h * 0.5
        reset_fade();
        if(opts){
            try{ speed = (opts.transition_ms < 150 ? 150 :  opts.transition_ms) } catch(err){}
            try{ nbr_slot = opts.slots } catch(err){}
            try{ fade_alpha = opts.alpha } catch(err){}
            try{ fade_time = opts.fade_time * 1000 } catch(err){}
            try{ fade_delay = opts.fade_delay * 1000 } catch(err){}
            try{ Curve = opts.curve } catch(err){}
            try{ rounded = opts.rounded } catch(err){}
            try{ wheel_frame = opts.frame } catch(err){}
            try{ type = opts.type } catch(err){}
            try{ spin_start = opts.spin_start } catch(err){}
            try{ media = opts.media.slice( 0, 1 ).toupper() + opts.media.slice( 1, opts.media.len() ) } catch(err){} // caps first char
            try{ scale = opts.scale.tofloat() } catch(err){}
            try{ center_zoom = opts.center_zoom } catch(err){}
            // attract-mode
            try{ attract_time = my_config["AM_AttractTime"].tointeger() * 1000 } catch(err){}
            try{ MaxSpinTime = my_config["AM_MaxSpinTime"].tointeger() * 1000 } catch(err){}
            try{ am_WaitVideo = (my_config["AM_WaitVideo"].tolower() == "yes" ? true : false) } catch(err){}
            try{ AttractEnabled = (my_config["AM_Enabled"].tolower() == "yes" ? true : false) } catch(err){}
            try{ AM_all_systems = (my_config["AM_all_systems"].tolower() == "yes" ? true : false) } catch(err){}
            try{ AM_system_loop = my_config["AM_system_loop"].tointeger() } catch(err){}
        }

        if(fade_time) fade_on = true;
        max_speed = (speed - config_speed) * 0.95;
        ft = 1.0 / round( speed / (1000.0 / ScreenRefreshRate), 0);
        offset = 0;
        progress = 0.0;

        Type(type)

        // frame
        frame_img.file_name = "";
        if(wheel_frame){
            if(fe.game_info(Info.Emulator) == "@"){
                frame_img.file_name = medias_path + "Main Menu/Images/WheelFrame/frame.png";
            }else{
                frame_img.file_name = medias_path + fe.list.name + "/Images/Wheel/Frame/frame.png";
            }
            if(frame_img.file_name == "") frame_img.file_name = ::globs.script_dir + "/images/Wheel/frame.png";
        }

        if(spin_start && !::surf_menu.visible){
            for ( local i=1; i<nbr_slot + 2; i++ ){
                buffer.push(1);
                offset+=1;
            }
            adjust = max_speed;
            fast_nav = true;
        }

        draw_wheel(offset);
    }

    function Type(pos){
        local x,y,wh,ww,pad,angle;
        set_slots(nbr_slot);

        switch (pos) {
            case "top":
            case "bottom":
                ww = surface_w / nbr_slot
                wh = ww / 2.5 // standard ratio for a hs wheel
                pad = ww / nbr_slot
                ww -= pad
                x = -ww * 0.5 - pad * 0.5
                y = surface_h * 0.5;
                if(nbr_slot % 2 == 0 ){ // if slot is even
                    nbr_slot+=1
                    x = -ww - pad;
                }

                nbr_slot+=2 // add the 2 offscreen wheel
                if(rounded){
                    Rad = surface_w * 0.7
                    wheel_center_x = surface_w * 0.5
                    if(pos == "top"){
                        wheel_center_y = -Rad + y - (Curve - 1.0) * Rad
                    }else{
                        wheel_center_y = Rad + y + (Curve - 1.0) * Rad
                    }
                    Rad*=Curve
                    el_rot = (pos == "top" ? 90.0 : -90.0)
                    angle = curve_points(Rad, surface_w * 1.3,  el_rot + 180.0 )
                    local len = ((angle[0] - angle[angle.len() - 1]) + 180) % 360 - 180;
                    len = (2 * PI * (Rad - wh ) ) * (len / 360.0);
                    ww = (len / nbr_slot);
                }
            break;

            default:
                wh = surface_h / nbr_slot
                pad = wh / nbr_slot
                wh -= pad
                ww = wh * 2.5 // standard ratio for a hs wheel
                x = surface_w * 0.5;
                y = -wh * 0.5 - pad * 0.5
                if(nbr_slot % 2 == 0 ){ // if slot is even
                    nbr_slot+=1
                    y = -wh - pad
                }

                nbr_slot+=2; // add the 2 offscreen wheel
                if(rounded){
                    Rad = surface_h * 0.7
                    if(pos == "left"){
                        wheel_center_x = -Rad + x - (Curve - 1.0) * Rad
                    }else{
                        wheel_center_x = Rad + x + (Curve - 1.0) * Rad
                    }
                    wheel_center_y = surface_h * 0.5
                    Rad*=Curve;
                    el_rot = (pos == "left" ? 0 : 180)
                    angle = curve_points(Rad, surface_h * 1.3, el_rot);
                    local len = ((angle[0] - angle[angle.len() - 1]) + 180) % 360 - 180;
                    len = (2 * PI * (Rad - wh ) ) * (len / 360.0);
                    wh = (len / nbr_slot);
                }
            break;
        }

            r_offset = floor(nbr_slot * 0.5);
            ww*=scale
            wh*=scale
            local delta = 0;

            if(pos == "top" || pos =="bottom"){
                delta = (ww * center_zoom - ww) * 0.5
                x-=delta
            }else{
                delta = (wh * center_zoom - wh) * 0.5
                y-=delta
            }

            for ( local i=0; i<nbr_slot; i++ ){
                w_slots[i].width = (i == r_offset ? ww * center_zoom : ww)
                w_slots[i].height = (i == r_offset ? wh * center_zoom : wh)
                if(rounded){
                    local mr = PI * angle[i] / 180;
                    w_slots[i].x = wheel_center_x  + (Rad * cos(mr)) - w_slots[i].width * 0.5
                    w_slots[i].y = wheel_center_y  + (Rad * sin(mr)) - w_slots[i].height * 0.5
                    set_rotation(angle[i] - el_rot, w_slots[i]);
                    w_slots[i].r = angle[i] - el_rot;
                }else{
                    w_slots[i].x = x - (w_slots[i].width * 0.5);
                    w_slots[i].y = y - (w_slots[i].height * 0.5);
                    w_slots[i].r = 0;

                    if(pos == "top" || pos =="bottom"){
                        x+=(w_slots[i].width / scale) + pad
                        if(i == r_offset-1) x+=delta
                        if(i == r_offset) x-=delta
                    }else{
                        y+=(w_slots[i].height / scale) + pad
                        if(i == r_offset-1) y+=delta
                        if(i == r_offset) y-=delta //
                    }
                }

                // Set Zorder for center wheel and frame
                w_slots[i].art.zorder = (i == r_offset ? 3 : 1)
                w_slots[i].frame.zorder = (i == r_offset ? 2 : 0)
            }
    }

    function draw_wheel(offset){

        offset += ceil(nbr_slot * 0.5) - 1;

        for ( local i=0; i<nbr_slot; i++ ){
            if(fe.game_info(Info.Emulator) == "@"){
                m_path = medias_path + "Main Menu/" + (media != "Video" ? "Images/" : "/") + media + "/";
            }else{
                m_path = medias_path + fe.game_info(Info.Emulator, i - offset) + (media != "Video" ? "/Images/" : "/") + media + "/";
            }
            w_slots[i].art.video_flags = Vid.NoAudio
            w_slots[i].art.file_name = m_path + fe.game_info(Info.Name, i - offset ) + (media != "Video" ? ".png" : ".mp4");
            w_slots[i].art.set_pos(w_slots[i].x, w_slots[i].y, w_slots[i].width, w_slots[i].height);
            w_slots[i].art.rotation = w_slots[i].r;

            local frame_x = w_slots[i].art.x - (w_slots[i].art.width * 0.025);
            local frame_y = w_slots[i].art.y - (w_slots[i].art.height * 0.025);
            w_slots[i].frame.set_pos(frame_x, frame_y, w_slots[i].width * 1.05, w_slots[i].height * 1.05);
            w_slots[i].frame.rotation = w_slots[i].r;
        }
    }


    function curve_points(Rad, surf, middle){
        local angle = [];
        if(Rad){
            local a = Rad
            local b = Rad
            local c = surf
            local aa=acos((b*b+c*c-a*a)/(2*b*c));
            aa=(aa*180/PI)
            local bb=acos((c*c+a*a-b*b)/(2*c*a));
            bb=(bb*180/PI)
            local cc=180.0 - aa-bb;
            //local ab = cc / nbr_slot - 1;
            // calc elems pos in ° on wheel
            local start_point = -(middle-(cc * 0.5));
            local seg = -cc / (nbr_slot - 1.0);
            for ( local i=0; i<nbr_slot; i++ ){
                angle.push(start_point);
                start_point+=seg
            }
        }
        return angle;
    }

    function main_signal( signal_str )
    {
        last_selected = signal_str
        switch ( signal_str )
        {
            case "random_game" :
                if(!stop) return true; // return if wheel is still spining
            break;
        }
        return false;
    }

    function on_transition( ttype, var, ttime )
    {
        switch ( ttype )
        {
            case Transition.StartLayout:
            case Transition.FromGame:
            case Transition.ToGame:
                am_counter = 0; // reset attract counter
                timer = ::fe.layout.time;
            break;

            case Transition.ToNewSelection:
                var = circular_idx_diff( fe.layout.index + var, fe.layout.index );
                surface.alpha = 255;
                fast_nav = false
                if(last_selected == "random_game"){
                    local rd = rnd_int( 4000 / config_speed, MaxSpinTime / config_speed);
                    for ( local i=1; i<rd; i++ ){
                        buffer.push(1);
                        offset+=1;
                    }
                    buff = buffer.len();
                    fast_nav = true;
                }else{
                    offset+=var;
                    buffer.push(var);
                }
            break;

            case Transition.ToNewList:
                reset_fade();
                am_counter = 0; // reset attract counter
                timer = ::fe.layout.time;
            break;
        }

        return false;
    }

    function on_tick( ttime ){
        if(::wheel_animation.progress < 1.0) return false
        if(next_tick){
            next_tick()
            next_tick = false
        }

        if( buffer.len() ){
            timer = ttime
            stop = false
            tjump = buffer.reduce( function(previousValue, currentValue){
                return ( previousValue + currentValue );
            });

            if(last_selected != "random_game"){
                if( abs(tjump) > 3 ){
                    adjust = (max_speed - adjust) * 0.04 + adjust
                    fast_nav = true;
                }
                if( abs(tjump) < 3 && fast_nav){
                    adjust-=10
                }
            }else{
                if(new_val <= buff * 0.5){
                    adjust = (max_speed - adjust) * 0.05 + adjust
                }

                if(new_val > buff * 0.7){
                    adjust = expo_speed(( (new_val - buff * 0.7) / (buff * 0.3) ), max_speed,  -config_speed * 2.0, 1.0);
                }

                new_val = (buff - buffer.len()).tofloat();
            }

            adjust = clamp(adjust , -config_speed * 2.0, max_speed);

            if(progress == 1){
                step = 1

                if(last_selected != "random_game"){
                    if( abs(tjump) > nbr_slot * 2){
                        buffer.clear();
                        buffer.push(tjump);
                        step = abs(buffer[0]) - nbr_slot;
                    }
                }

                ft = 1.0 /  round( (speed-adjust) / (1000.0 / ScreenRefreshRate), 0 );

                if(buffer[0] > 0){ // key down
                    offset-=step
                    for ( local i = 1; i < nbr_slot; i++ ) w_slots[i].art.swap( w_slots[i-1].art );

                    if(fe.game_info(Info.Emulator) == "@"){
                        m_path = medias_path + "Main Menu" + (media != "Video" ? "/Images/" : "/") + media + "/";
                    }else{
                        m_path = medias_path + fe.game_info(Info.Emulator, r_offset-offset) + (media != "Video" ? "/Images/" : "/") + media + "/";
                    }

                    w_slots[nbr_slot-1].art.file_name = m_path + fe.game_info(Info.Name, r_offset-offset  ) + (media != "Video" ? ".png" : ".mp4");
                }else if(buffer[0] < 0){
                    offset+=step
                    for ( local i = nbr_slot - 1; i > 0; i-- ) w_slots[i].art.swap( w_slots[i-1].art );

                    if(fe.game_info(Info.Emulator) == "@"){
                        m_path = medias_path + "Main Menu/" + (media != "Video" ? "Images/" : "/") + media + "/";
                    }else{
                        m_path = medias_path + fe.game_info(Info.Emulator, -offset-r_offset) + (media != "Video" ? "/Images/" : "/") + media + "/";
                    }

                    w_slots[0].art.file_name = m_path + fe.game_info(Info.Name, -offset-r_offset ) + (media != "Video" ? ".png" : ".mp4");
                }

                for ( local i = 0; i < nbr_slot; i++ ){ // reset to prev pos
                    w_slots[i].art.set_pos(w_slots[i].x, w_slots[i].y, w_slots[i].width, w_slots[i].height);
                    w_slots[i].art.rotation = w_slots[i].r;

                    local frame_x = w_slots[i].art.x - (w_slots[i].art.width * 0.025);
                    local frame_y = w_slots[i].art.y - (w_slots[i].art.height * 0.025);
                    w_slots[i].frame.set_pos(frame_x, frame_y , w_slots[i].width * 1.05, w_slots[i].height * 1.05);
                    w_slots[i].frame.rotation = w_slots[i].r;
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
                ft = 1.0 /  round( (speed-adjust) / (1000.0 / ScreenRefreshRate), 0 );
                progress = clamp(progress+=ft, 0.0, 1.0);

                if(buffer[0] < 0){
                    for ( local a = 0; a < nbr_slot - 1; a++ ){

                        if(rounded){
                            local angle = ( ( w_slots[a+1].r - w_slots[a].r ) * progress / 1.0 + w_slots[a].r ) + el_rot;
                            local mr = PI * angle / 180;
                            local orig_W = w_slots[a].width
                            local orig_H = w_slots[a].height
                            local new_W = (w_slots[a+1].width - w_slots[a].width) * progress / 1.0 + w_slots[a].width
                            local new_H = (w_slots[a+1].height - w_slots[a].height) * progress / 1.0 + w_slots[a].height
                            local off_X = (orig_W - new_W) * 0.5
                            local off_Y = (orig_H - new_H) * 0.5
                            w_slots[a].art.x = wheel_center_x + Rad * cos( mr ) - orig_W * 0.5 + off_X
                            w_slots[a].art.y = wheel_center_y + Rad * sin( mr ) - orig_H * 0.5 + off_Y
                            w_slots[a].art.width = new_W
                            w_slots[a].art.height = new_H
                            w_slots[a].art.rotation = angle - el_rot;
                            set_rotation(angle - el_rot, w_slots[a].art);
                        }else{
                            w_slots[a].art.y = ( w_slots[a+1].y - w_slots[a].y ) * progress / 1.0 + w_slots[a].y
                            w_slots[a].art.x = ( w_slots[a+1].x - w_slots[a].x) * progress / 1.0 + w_slots[a].x
                            w_slots[a].art.rotation = ( w_slots[a+1].r - w_slots[a].r) * progress / 1.0 + w_slots[a].r
                            w_slots[a].art.width = ( w_slots[a+1].width - w_slots[a].width ) * progress / 1.0 + w_slots[a].width;
                            w_slots[a].art.height = ( w_slots[a+1].height - w_slots[a].height ) * progress / 1.0 + w_slots[a].height;
                        }

                        local frame_x = w_slots[a].art.x - (w_slots[a].art.width * 0.025);
                        local frame_y = w_slots[a].art.y - (w_slots[a].art.height * 0.025);
                        w_slots[a].frame.set_pos(frame_x, frame_y, w_slots[a].art.width * 1.05, w_slots[a].art.height * 1.05 );
                        w_slots[a].frame.rotation = w_slots[a].art.rotation;
                    }
                }else if(buffer[0] > 0){ // key down

                    for ( local a = 1; a < nbr_slot; a++ ){
                        if(rounded){
                            local angle = ( ( w_slots[a-1].r - w_slots[a].r ) * progress / 1.0 + w_slots[a].r ) + el_rot
                            local mr = PI * angle / 180;
                            local orig_W = w_slots[a].width
                            local orig_H = w_slots[a].height
                            local new_W = (w_slots[a-1].width - w_slots[a].width) * progress / 1.0 + w_slots[a].width
                            local new_H = (w_slots[a-1].height - w_slots[a].height) * progress / 1.0 + w_slots[a].height
                            local off_X = (orig_W - new_W) * 0.5
                            local off_Y = (orig_H - new_H) * 0.5
                            w_slots[a].art.x = wheel_center_x + Rad * cos( mr ) - orig_W * 0.5 + off_X
                            w_slots[a].art.y = wheel_center_y + Rad * sin( mr ) - orig_H * 0.5 + off_Y
                            w_slots[a].art.width = new_W
                            w_slots[a].art.height = new_H
                            w_slots[a].art.rotation = angle - el_rot;
                            set_rotation(angle - el_rot, w_slots[a].art);

                        }else{
                            w_slots[a].art.width = ( w_slots[a-1].width - w_slots[a].width ) * progress / 1.0 + w_slots[a].width;
                            w_slots[a].art.height = ( w_slots[a-1].height - w_slots[a].height ) * progress / 1.0 + w_slots[a].height;
                            w_slots[a].art.y = ( w_slots[a-1].y - w_slots[a].y ) * progress / 1.0 + w_slots[a].y
                            w_slots[a].art.x = ( w_slots[a-1].x - w_slots[a].x) * progress / 1.0 + w_slots[a].x
                            w_slots[a].art.rotation = ( w_slots[a-1].r - w_slots[a].r) * progress / 1.0 + w_slots[a].r
                        }

                        local frame_x = w_slots[a].art.x - (w_slots[a].art.width * 0.025);
                        local frame_y = w_slots[a].art.y - (w_slots[a].art.height * 0.025);
                        w_slots[a].frame.set_pos(frame_x, frame_y, w_slots[a].art.width * 1.05, w_slots[a].art.height * 1.05 );
                        w_slots[a].frame.rotation = w_slots[a].art.rotation;
                    }
                }
            }
        }else{
            if(ttime - timer > 100){
                adjust = 0.0;
                tjump = 0
                fast_nav = false;
                spin_start = false;
                if(fade_on) fade();
                stop = true
                buff = 0;
                if(AttractEnabled) attract_start(ttime);
            }
        }
    }

    function CheckVideoWait(){
        local snap = (::ArtObj.snap.video_duration !=0 && ::ArtObj.snap.video_playing)
        local back = (::ArtObj.background1.video_duration !=0 && ::ArtObj.background1.video_playing) || (::ArtObj.background2.video_duration !=0 && ::ArtObj.background2.video_playing);
        if( (snap && !back) || (back && !snap) ) return true
        return false
    }

    function attract_start(ttime){
        local tmp = ::globs.Stimer
        if(::surf_menu.visible) timer = ttime; // disable on edit mode
        if(ttime - timer < 4000) return false; // wait minimum 4 secs
        local VideoWait = am_WaitVideo;
        local start = false;

        if(VideoWait){
            start = !CheckVideoWait() && (::fe.layout.time - tmp) > attract_time;
        }else{
            start = (ttime - timer > attract_time);
            timer = start ? ttime : timer;
        }

        if(!start) return false;

        if(fe.game_info(Info.Emulator) == "@"){
            if(am_counter > 1 ){
                fe.signal("select");
            }else{
                fe.signal("random_game");
            }
        }else{
            if(am_counter < AM_system_loop ) fe.signal("random_game");
        }

        am_counter++;

        if(AM_all_systems && am_counter > AM_system_loop){
            local rnd_disp = rnd_int(0, ::fe.displays.len() - 1);
            if(fe.displays.len() > 1 ){
                while( rnd_disp  == ::fe.list.display_index) rnd_disp = rnd_int(0, ::fe.displays.len() - 1);
            }
            fe.set_display( rnd_disp );
        }
        next_tick = function(){::globs.Stimer = tmp}
    }

    function expo_speed (progress, from, to, bas) { if ( progress == 0) return from; return to * pow( 2, 10 * ( progress / bas - 1) ) + from; }

    function reset_fade() {surface.alpha = 255; w_time = ::fe.layout.time;}

    function fade(){
        local alpha;
        local to = clamp( fade_alpha * 255.0 , 0.0 , 255.0);
        local elapsed = ::fe.layout.time - w_time;
        if( elapsed > fade_delay && fade_time > 0) {
            alpha = (255.00 * (fade_time - elapsed + fade_delay)) / fade_time;
            alpha = (alpha < 0 ? 0 : alpha);
            if(alpha <= to || alpha == 0) return false;
            surface.alpha = alpha;
        }
    }

    function circular_idx_diff(a, b) {
        local diff = (a - b + fe.list.size) % fe.list.size;
        return diff <= fe.list.size * 0.5 ? diff : diff - fe.list.size;
    }

    function clamp(value, min, max) {
        if (value < min) value = min; if (value > max) value = max; return value
    }

    function rnd_int(min, max){
        srand( rand() * time() );
        return (rand() * (max - min + 1) / (RAND_MAX + 1)) + min;
    }


    function set_rotation(r, obj) {
        local mr = PI * r / 180;
        obj.x += cos( mr ) * (-obj.width * 0.5) - sin( mr ) * (-obj.height * 0.5) + obj.width * 0.5;
        obj.y += sin( mr ) * (-obj.width * 0.5) + cos( mr ) * (-obj.height * 0.5) + obj.height * 0.5;
    }

    function round(nbr, dec){ // Round Number as decimal
        local f = pow(10, dec) * 1.0;
        local newNbr = nbr.tofloat() * f;
        newNbr = floor(newNbr + 0.5)
        newNbr = (newNbr * 1.0) / f;
        return newNbr;
    }
}