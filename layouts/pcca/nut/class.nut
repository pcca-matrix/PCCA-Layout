/*
elem : surface
Tickness: 1.0-5.0
msg: text
data: {x, y, w, h, font-size}
set : set any of the add_text properties : ("align" , Align.Left)
stroke_rgb : thick_rgb( [0,0,255] )
*/
class OutlinedText
{
    constructor(elem, msg, datas, thickness)
    {
        thickness = clamp(thickness, 1.0, 5.0);
        outl = datas.size * 0.00080 * thickness;
        x_offset = datas.x * outl;
        y_offset = datas.y * (outl * 0.40);

        _title_l = elem.add_text( msg, datas.x - x_offset, datas.y, datas.w, datas.size );
        _title_l.set_rgb( 0, 0, 0 );

        _title_r = elem.add_text( msg, datas.x + x_offset , datas.y, datas.w, datas.size );
        _title_r.set_rgb( 0, 0, 0 );

        _title_d = elem.add_text( msg, datas.x, datas.y + y_offset, datas.w, datas.size );
        _title_d.set_rgb( 0, 0, 0 );

        _title_u = elem.add_text( msg, datas.x, datas.y - y_offset, datas.w, datas.size );
        _title_u.set_rgb( 0, 0, 0 );

        _title = elem.add_text( msg, datas.x, datas.y, datas.w, datas.size );
        _title.set_rgb( datas.color[0],datas.color[1], datas.color[2]  );
    }

    function set(param, val){
        _title_l[param] = val;
        _title_r[param] = val;
        _title_d[param] = val;
        _title_u[param] = val;
        _title[param] = val;
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
    
    outl = null;
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
          _slot.push(surface.add_text( "", flw * 0.006, flh * 0.041 + (row_space * i), flw * 0.17, flh * 0.022 ));
          _slot[i].align = Align.Left;
          _slot[i].set_bg_rgb(100,100,100);
          _slot[i].bg_alpha=0;
        }
        _list_title = surface.add_text("", flw * 0.008, flh * 0.002, flw * 0.24, flw * 0.008 );
        _list_title.align = Align.Left;
        _list_info = surface.add_text("", flw * 0.008, flh * 0.022, flw * 0.24, flw * 0.0085 );
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
        foreach(a,v in _lists) if(a>0) tmp+=v.title + "->"; // by passe first elem (main)
        if(_lists.len() > 0) tmp+=_current_list.title;
        _list_title.msg = tmp;
    }

    function select(){
        if(_selected_row.rawin("type")){ // save and reload theme if select pressed on rows that have type attr
            save_xml(xml_root, path);
            triggers.theme.start = true;
        }

        if(_selected_row.rawin("type") || _edit_type != null) return false; // do not enter if we are on these item (prevent changing menu selected_row)
        _list_info.msg = "";
        _current_list.slot_pos = _slot_pos; // set the current list position
        local prev_list = _current_list;
        _selected_row = clone(_current_list.rows[_slot_pos]);
        local onselect = false;
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