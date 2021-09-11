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