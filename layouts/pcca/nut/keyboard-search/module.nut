/********************************************
KeyboardSearch module
This module allows any layout to easily add a customizable keyboard search to its interface. You can modify the key
layout, look, search key, search method and more..

For usage, see:
https://github.com/liquid8d/attract-extra/tree/master/modules/objects/keyboard-search/

*********************************************/
class KeyboardSearch {
    VERSION = 1.0
    debug = false
    surface = null
    keys = null
    search_text = null
    text = ""
    last_key_check = 0
    last_key = null
    trigger = false;
    state = 0 // 0 closed, 1 open, 2 move open, 3 move close
    sys = ""
    //map of supported values and their filename equivalent
    key_names = { "a": "a", "b": "b", "c": "c", "d": "d", "e": "e", "f": "f", "g": "g", "h": "h", "i": "i", "j": "j", "k": "k", "l": "l", "m": "m", "n": "n", "o": "o", "p": "p", "q": "q", "r": "r", "s": "s", "t": "t", "u": "u", "v": "v", "w": "w", "x": "x", "y": "y", "z": "z", "1": "Num1", "2": "Num2", "3": "Num3", "4": "Num4", "5": "Num5", "6": "Num6", "7": "Num7", "8": "Num8", "9": "Num9", "0": "Num0", "<": "Backspace", " ": "Space", "-": "Clear", "~": "Done" }
    
    config = {
        search_key = "custom1",
        mode = "show_results",
        retain = false,
        key_delay = 100,
        repeat_key_delay = 250,
        bg = ::fe.module_dir + "/images/pixel.png",
        bg_red = 30,
        bg_green = 30,
        bg_blue = 30,
        bg_alpha = 240,
        search_text = {
            pos = [ 0.075, 0.2, 1, 0.1 ],
            rgba = [ 20, 255, 20, 255 ],
            font = "Arial"
        },
        keys = {
            folder = ::fe.module_dir + "/images",
            font = "Arial",
            charsize = 46,
            pos = [ 0.1, 0.4, 0.8, 0.5 ],
            rows = [ "1234567890", "abcdefghi", "jklmnopqr", "stuvwxyz", "- <~" ],
            rgba = [ 255, 255, 255, 200 ],
            rgba_selected = [ 20, 150, 20, 255 ],
            selected = [ 0, 0 ]
        }
    }
    
    constructor(surface) {
        this.surface = surface
        this.keys = {}
    }
    function get_text() { return text }
    function search_key(key) { this.config.search_key = key; return this; }
    function mode(mode) { this.config.mode = mode; return this; }
    function retain(retain) { this.config.retain = retain; return this; }
    function key_delay(delay) { this.config.key_delay = delay; return this; }
    function repeat_key_delay(delay) { this.config.repeat_key_delay = delay; return this; }
    function set_pos(x, y, width, height) { this.surface.set_pos( x, y, width, height); return this; }
    function bg(filename) { this.config.bg = filename; return this; }
    function bg_color(red, green, blue, alpha = 255) { this.config.bg_red = red; this.config.bg_green = green; this.config.bg_blue = blue; this.config.bg_alpha = alpha; return this; }
    function text_pos( arr ) { this.config.search_text.pos = arr; return this; }
    function text_color ( red, green, blue, alpha = 255 ) { this.config.search_text.rgba[0] = red; this.config.search_text.rgba[1] = green; this.config.search_text.rgba[2] = blue; this.config.search_text.rgba[3] = alpha; return this; }
    function text_font(font) { this.config.search_text.font = font; return this; }
    function keys_image_folder(folder=null) { this.config.keys.folder = folder; return this; }
    function keys_pos( arr ) { this.config.keys.pos = arr; return this; }
    function keys_rows(rows) { this.config.keys.rows = rows; return this; }
    function keys_font(font) { this.config.keys.font = font; return this; }
    function keys_charsize(size) { this.config.keys.charsize = size; return this; }
    function keys_color(red, green, blue, alpha = 255) { this.config.keys.rgba[0] = red; this.config.keys.rgba[1] = green; this.config.keys.rgba[2] = blue; this.config.keys.rgba[3] = alpha; return this; }
    function keys_selected_color(red, green, blue, alpha = 255) { this.config.keys.rgba_selected[0] = red; this.config.keys.rgba_selected[1] = green; this.config.keys.rgba_selected[2] = blue; this.config.keys.rgba_selected[3] = alpha; return this; }
    function keys_selected(col, row) { this.config.keys.selected[0] = col; this.config.keys.selected[1] = row; return this; }
    function preset(name) {
        switch(name) {
            case "qwerty":
                keys_rows([ "1234567890", "qwertyuiop", "asdfghjkl", "zxcvbnm", "- <~" ])
                break
            case "azerty":
                keys_rows([ "1234567890", "azertyuiop", "qsdfghjklm", "wxcvbn", "- <~" ])
                break
            case "alpha":
                keys_rows(["1234567890", "abcdefghi", "jklmnopqr", "stuvwxyz", "- <~"])
                break
        }
        return this
    }
    function init() {
        surface.preserve_aspect_ratio = true
        surface.alpha = 0
        draw_osd()
        select( config.keys.selected[0], config.keys.selected[1] )
        ::fe.add_signal_handler(this, "on_signal")
        ::fe.add_ticks_callback(this, "on_tick")
        return this
    }
    
    
    function draw_osd(){
        //draw the search surface bg
        local bg = surface.add_image(config.bg, 0, 0, surface.width, surface.height)
        bg.set_rgb(config.bg_red, config.bg_green, config.bg_blue)
        bg.alpha = config.bg_alpha

        //draw the search text object
        local osd_search = {
            x = ( surface.width * config.search_text.pos[0] ) * 1.0,
            y = ( surface.height * config.search_text.pos[1] ) * 1.0,
            width = ( surface.width * config.search_text.pos[2] ) * 1.0,
            height = ( surface.height * config.search_text.pos[3] ) * 1.0
        }
        
        local title = surface.add_text("s", (surface.width * 0.5) - flw*0.024, osd_search.y - flh*0.1, flw*0.041, flw*0.041) 
        title.font = "fontello.ttf"
        title.charsize = flw*0.048;
        title.set_rgb( config.search_text.rgba[0], config.search_text.rgba[1], config.search_text.rgba[2] )
        
        search_text = surface.add_text(text, osd_search.x, osd_search.y, osd_search.width, osd_search.height)
        search_text.align = Align.MiddleLeft
        search_text.set_bg_rgb(60,60,60)
        search_text.bg_alpha = 150
        search_text.font = config.search_text.font
        search_text.set_rgb( config.search_text.rgba[0], config.search_text.rgba[1], config.search_text.rgba[2] )
        search_text.alpha = config.search_text.rgba[3]

        //draw the search key objects
        foreach( key, val in key_names ) {
            if ( config.keys.folder != null && config.keys.folder != "" ) {
                //use key images
                keys[ key.tolower() ] <- surface.add_image( "", -1, -1, 64, 64 )
            } else {
                //use text
                local key_name = ( key == "-" ) ? "CLR" : ( key == " " ) ? "SPC" : ( key == "<" )  ? "DEL" : ( key == "~" ) ? "DONE" : key.toupper()
                keys[ key.tolower() ] <- surface.add_text( key_name, -1, -1, 1, 1 )
                keys[ key.tolower() ].font = config.keys.font
                keys[ key.tolower() ].charsize = config.keys.charsize
            }
            keys[ key.tolower() ].set_rgb( config.keys.rgba[0], config.keys.rgba[1], config.keys.rgba[2])
            keys[ key.tolower() ].alpha = config.keys.rgba[3]
        }

        //set search key positions
        local row_count = 0
        foreach ( row in config.keys.rows )
        {
            local col_count = 0
            local osd = {
                x = ( surface.width * config.keys.pos[0] ) * 1.0,
                y = ( surface.height * config.keys.pos[1] ) * 1.0,
                width = ( surface.width * config.keys.pos[2] ) * 1.0,
                height = ( surface.height * config.keys.pos[3] ) * 1.0
            }
            local key_width = ( osd.width / row.len() ) * 1.0
            local key_height = ( osd.height / config.keys.rows.len() ) * 1.0
            foreach ( char in row )
            {
                local key_image = keys[ char.tochar() ]
                local pos = {
                    x = osd.x + ( key_width * col_count ),
                    y = osd.y + key_height * row_count,
                    w = key_width,
                    h = key_height
                }
                key_image.set_pos( pos.x, pos.y, pos.w, pos.h )
                col_count++
            }
            row_count++
        }
    }
    
    //select the col/row relative to the current selection
    // select_relative( 0, 1 ) would select the row below the current one
    function select_relative( rel_col, rel_row )
    {
        select( config.keys.selected[0] + rel_col, config.keys.selected[1] + rel_row )
    }
    
    //select the col/row specified
    function select( col, row )
    {
        row = ( row < 0 ) ? config.keys.rows.len() - 1 : ( row > config.keys.rows.len() - 1 ) ? 0 : row
        col = ( col < 0 ) ? config.keys.rows[row].len() - 1 : ( col > config.keys.rows[row].len() - 1 ) ? 0 : col
        local previous = config.keys.rows[config.keys.selected[1]][config.keys.selected[0]].tochar()
        local selected = config.keys.rows[row][col].tochar()
        print( "selected: " + selected + "(" + col + "," + row + ") previous: " + previous + "(" + config.keys.selected[0] + "," + config.keys.selected[1] + ")" )
        keys[previous].set_rgb( config.keys.rgba[0], config.keys.rgba[1], config.keys.rgba[2] )
        keys[previous].alpha = config.keys.rgba[3]
        keys[selected].set_rgb( config.keys.rgba_selected[0], config.keys.rgba_selected[1], config.keys.rgba_selected[2] )
        keys[selected].alpha = config.keys.rgba_selected[3]
        config.keys.selected = [ col, row ]
    }
    
    //type the character specified
    //special characters are "<" (backspace), "-" (clear) and "~" (done)
    function type( c )
    {
        print("typed: " + c)
        if ( c == "<" )
            text = ( text.len() > 0 ) ? text.slice( 0, text.len() - 1 ) : ""
        else if ( c == "-" )
            clear()
        else if ( c == "~" )
            toggle()
        else
            text = text + c
        search_text.msg = ( text == "" ) ? "" : "\"" + text + "\""
        update_rule()
    }
    
    //update the current search rule
    function update_rule()
    {
        try
        {
            local rule = "Title contains " + _massage(text)
            switch ( config.mode )
            {
                case "next_match":
                    if ( text.len() == 0 ) return
                    local s = fe.filters[fe.list.filter_index].size
                    for ( local i = 1; i < s; i++ )
                    {
                        local name = fe.game_info( Info.Title, i ).tolower()
                        if ( regexp( text ).capture(name) ) {
                            fe.list.index = (fe.list.index+i)%s
                            break
                        }
                    }
                    break
                case "show_results":
                default:
                    if(text.len() < 2) return;
                    fe.list.search_rule = "";
                    fe.list.search_rule = ( text.len() > 1 ) ? rule : ""
                    break
            }
        } catch ( err ) { print( "Unable to apply filter: " + err ); }
    }
    
    function _massage( str )
    {
        if ( str.len() == 0 ) return ""
        str = str.tolower()
        local words = split( str, " " )

        local temp=""
        foreach ( idx, w in words )
        {
            print("searching: " + w )
            //if ( idx > 0 ) temp += " "
            //foreach( c in w )
            //    if ( c != " " ) temp += ( "1234567890".find(c.tochar()) != null ) ? c.tochar() : "[" + c.tochar().toupper() + c.tochar().tolower() + "]"
            if ( temp.len() > 0 )
                temp += " "
            local f = w.slice( 0, 1 )
            temp += ( "1234567890".find(f) != null ) ? "[" + f + "]" + w.slice(1) : "[" + f.toupper() + f.tolower() + "]" + w.slice(1)
        }

        return temp
    }
    
    //clear the current search
    function clear()
    {
        text = ""
        search_text.msg = ""
        fe.list.search_rule = "";
        //update_rule()
    }
    
    //toggle the search surface
    function toggle() {
        surface.alpha = ( surface.alpha == 0 ) ? 255: 0
        //clear text when shown
        if ( visible() && config.retain == "false" ) clear()
        print("toggle keyboard " + visible() )
    }
    
    //get current visibility
    function visible() {
        return (surface.alpha == 255)
    }
    
    //debug print
    function print(msg) {
        if ( debug ) ::print("KeyboardSearch plugin: " + msg + "\n")
    }

    //process keys
    function on_signal(str) {
        if ( str == config.search_key ) {
            toggle()
            return true
        }
        if ( visible() )
        {
            print("key press: " + str)
            if ( str == "up" ) select_relative( 0, -1 )
            else if ( str == "down" ) select_relative( 0, 1 )
            else if ( str == "left" ) select_relative( -1, 0 )
            else if ( str == "right" ) select_relative( 1, 0 )
            else if ( str == "select" ) type( config.keys.rows[config.keys.selected[1]][config.keys.selected[0]].tochar() )
            else if ( str == "back" ) if ( text.len() == 0 ) toggle() else type("<")
            else if ( str == "exit" ) toggle()
            return true
        }
        return false;
    }
    
    function on_tick( ttime )
    {
        if(trigger == true){

            if(state == 3){ surface.x = surface.x - flw*0.032 }
            if(state == 2){ surface.x = surface.x + flw*0.028 }

            if(state == 2 && surface.x >= 0){
                state = 1;
                surface.x = 0
                trigger = false;
            }
            if(state == 3 && surface.x <= -surface.width){
                surface.x = -surface.width;
                surface.alpha = 0;
                state = 0;
                trigger = false;
            }
        }
    }
    
}