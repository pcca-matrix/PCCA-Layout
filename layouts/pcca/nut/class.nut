/*
elem : surface
Tickness: 1.0-5.0
msg: text
data: {x, y, w, h, font-size}
set : set any of the add_text properties : ("align" , Align.Left)
thick_rgb : thick_rgb( [0,0,255] )
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

    outl = null;
    x_offset = null;
    y_offset = null;

    _title = null;
    _title_u = null;
    _title_d = null;
    _title_l = null;
    _title_r = null;
}


/* Menu Class */

class SelMenu
{
    constructor( surface , row_space)
    {
        _slot = [];
        for ( i=0; i < 35; i++){
          _slot.push(surface.add_text( "", flw * 0.005, flw * 0.020 + (row_space * i), flw * 0.20, flh * 0.022 ));
          _slot[i].set_bg_rgb(100,100,100);
          _slot[i].bg_alpha=0;
        }
        fe.add_ticks_callback( this, "on_tick" );
    }

    function add_rows(tbl, add=true){
        if(add){
            _menu_tables.push(tbl);
            _title.push(_menu_tables.top().title);
        }
        for ( i=0; i < 35; i++){
            if(i < tbl.rows.len()){
                _slot[i].msg = tbl.rows[i];
            }else{
                _slot[i].msg = "";
            }
            _slot[i].set_bg_rgb(150,100,100);
            _slot[i].bg_alpha=0;
        }
        _slot[0].bg_alpha = 255;
        _slot_pos = 0;
    }

    function reset(){
        _edit_type = null;
        _menu_tables = [];
        _title = [];
    }

    function back(){
        if( _menu_tables.len() > 1 ){
            _menu_tables.pop();
            _title.pop();
        }
        add_rows( _menu_tables.top(), false );
        _edit_type = null;
        return true;
    }

    function set_text(pos, msg){
        _slot[pos].msg = msg;
        return true;
    }

    function obj() return _obj;
    function prev_obj(){ return _menu_tables[_menu_tables.len()-1].obj }
    function set_slot_pos(pos){
        _slot_pos = pos;
        _slot[pos].bg_alpha = 255;
        _slot[pos].set_bg_rgb(150,100,100);
        if(pos)_slot[0].bg_alpha = 0;
    }

    function title(){ return _menu_tables.top().title; }

    function selection() return  _menu_tables[_menu_tables.len()-1].rows[_slot_pos];

    function titles(){
        local tmp = "";
        foreach(a,v in _title) tmp+=v + "->";
        return tmp;
    }

    function up(){
        _slot[_slot_pos].bg_alpha=0;
        if(!_slot_pos) _slot_pos =_menu_tables[_menu_tables.len()-1].rows.len();
        _slot[_slot_pos-1].bg_alpha=255;
        _slot_pos--;
    }

    function down(){
        _slot[_slot_pos].bg_alpha=0;
        if(_slot_pos == _menu_tables[_menu_tables.len()-1].rows.len()-1) _slot_pos=-1;
        _slot[_slot_pos+1].bg_alpha=255;
        _slot_pos++;
    }

    function select(){
        if(!_menu_tables.len()) return null;
        _obj = _menu_tables.top().obj;
        _edit_type = _menu_tables[_menu_tables.len()-1].rows[_slot_pos];
        return _edit_type;
    }

    function signal(s) sig = s;

    function on_tick(ttime) {
        if(sig){
            fe.remove_signal_handler("on_signal")
            switch (sig){
              case "list":
                fe.remove_signal_handler("fake_sig");
                fe.add_signal_handler("update_list");
                _edit_type = null;
              break;

              case "pos_rot":
              case "pos":
                fe.remove_signal_handler("update_list")
                fe.add_signal_handler("fake_sig");
              break;

              case "default":
                fe.remove_signal_handler("update_list")
                fe.remove_signal_handler("fake_sig");
                fe.add_signal_handler("on_signal");
              break;
            }

            sig = null;
            return false;
        }

        if(_edit_type == "pos/size") overlay_video();
        if(_edit_type == "pos/size/rotate") edit(_obj, ttime, _last_click);
    }

    sig = null;
    i=0;
    _last_click = 0;
    _obj = "";
    _edit_type = null;
    _title = [];
    _menu_tables = [];
    _slot = [];
    _slot_pos = 0;
}

