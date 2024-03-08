function global_default_settings(){
    local Ini_settings = {}
    Ini_settings["themes"] <- {}
    Ini_settings["themes"]["aspect"] <- "center";
    Ini_settings["themes"]["background_stretch"] <- false;
    Ini_settings["themes"]["bezels"] <- true;
    Ini_settings["themes"]["bezels_on_top"] <- false;
    Ini_settings["themes"]["reload_backgrounds"] <- false;
    Ini_settings["themes"]["animated_backgrounds"] <- true;
    Ini_settings["themes"]["override_transitions"] <- true;
    Ini_settings["themes"]["synopsis"] <- true;
    Ini_settings["themes"]["main_stats"] <- true;
    Ini_settings["themes"]["scroll_pos"] <- "0.0,0.980,1.0,0.0200,0"; // x,y,w,h in % and rotation
    Ini_settings["themes"]["scroll_speed"] <- 1.0;

    Ini_settings["wheel"] <- {}
    Ini_settings["wheel"]["transition_ms"] <- 170;
    Ini_settings["wheel"]["animation"] <- "ease";
    Ini_settings["wheel"]["fade_time"] <- 3.0;
    Ini_settings["wheel"]["alpha"] <- 0.0;
    Ini_settings["wheel"]["slots"] <- 7;
    Ini_settings["wheel"]["rounded"] <- true;
    Ini_settings["wheel"]["type"] <- "right";
    Ini_settings["wheel"]["coord"] <- "0,0,1,1,0"; // in %
    Ini_settings["wheel"]["system stats"] <- "0.7126,0.5517,0"; // in %
    Ini_settings["wheel"]["curve"] <- 1.2;
    Ini_settings["wheel"]["frame"] <- false;
    Ini_settings["wheel"]["spin_start"] <- true;
    Ini_settings["wheel"]["scale"] <- 1.0;
    Ini_settings["wheel"]["center_zoom"] <- 1.0;
    Ini_settings["wheel"]["media"] <- "Wheel";

    Ini_settings["game text"] <- {}
    Ini_settings["game text"]["animation"] <- "elastic";
    Ini_settings["game text"]["anim_time"] <- 1.0;
    Ini_settings["game text"]["anim_start"] <- "bottom";
    Ini_settings["game text"]["anim_delay"] <- 0.2;
    Ini_settings["game text"]["game_text_active"] <- true;
    Ini_settings["game text"]["game_text_hide"] <- false;
    Ini_settings["game text"]["hide_year"] <- false;
    Ini_settings["game text"]["hide_lang"] <- false;
    Ini_settings["game text"]["hide_counter"] <- false;
    Ini_settings["game text"]["hide_filter"] <- false;
    Ini_settings["game text"]["hide_rating"] <- false;
    Ini_settings["game text"]["hide_players"] <- false;
    Ini_settings["game text"]["hide_category"] <- false;
    Ini_settings["game text"]["hide_country"] <- false;
    Ini_settings["game text"]["hide_ctrl"] <- false;
    Ini_settings["game text"]["coord"] <- "0,0.805,0"; // in %
    Ini_settings["game text"]["text_color"] <- 16777215; // color in dec
    Ini_settings["game text"]["text_stroke_color"] <- 000000; // color in dec
    //text_font=Style1
    //text1_textsize=26
    Ini_settings["sounds"] <- {}
    Ini_settings["sounds"]["game_sounds"] <- true;
    Ini_settings["sounds"]["wheel_click"] <- true;

    Ini_settings["pointer"] <- {}
    Ini_settings["pointer"]["animated"] <- true;
    Ini_settings["pointer"]["coord"] <- "0.910,0.401,0.100,0.200,0"; //(animation to) x,y,w,h in % and rotation

   /* Special artworks */
    foreach( n in ["a","b","c"] ){
        Ini_settings["special art " + n] <- {
            "nbr":"", "cnt": 1, "in": 0.5, "out": 0.5, "length": 3, "delay": 0.1, "type": "linear", "start": "bottom",
            "active" : true, "default" : true, "w": 0.0, "h": 0.0, "x": 0.0 , "y": 0.0, "r":0.0,  "syst" : "",
        }
        if( n == "b" ){
            Ini_settings["special art " + n].type = "fade";
            Ini_settings["special art " + n].start = "none";
        }
    }
    return Ini_settings;
}

function get_ini_values(name){
    local map = global_default_settings();
    local f = ReadTextFile( globs.script_dir + "Settings/" + name + ".ini" );
    local entity = null;
    while ( !f.eos() )
    {
        local line = strip( f.read_line() );
        if (( line.len() > 0 ) && ( line[0] == '[' ))
        {
            entity = line.slice( 1, line.len()-1 ).tolower();
            if( ! map.rawin(entity) ) map[ entity ] <- {};
        }
        else
        {
            if(!line.find("=")) continue;
            local temp = split( line, "=" );
            local v = ( temp.len() > 1 ) ? strip( temp[1] ).tolower() : "";
            local key = strip(temp[0]).tolower();
            try{map[ entity ][ key ]} catch( e ){ continue; }
            v = set_type(v, map[ entity ][ key ]); // set var types
            if ( entity ) map[ entity ][ key ] <- v;
            else map[ key ] <- v;
        }
    }
    return map;
}

function get_ini(path){
    local map = {};
    local f = ReadTextFile( path );
    local entity = null;
    while ( !f.eos() )
    {
        local line = strip( f.read_line() );
        if (( line.len() > 0 ) && ( line[0] == '[' ))
        {
            entity = line.slice( 1, line.len()-1 ).tolower();
            map[ entity ] <- {};
        }
        else
        {
            if(!line.find("=")) continue;
            local temp = split( line, "=" );
            local v = ( temp.len() > 1 ) ? strip( temp[1] ).tolower() : "";
            local key = strip(temp[0]).tolower();
            if ( entity ) map[ entity ][ key ] <- v;
            else map[ key ] <- v;
        }
    }
    return map;
}

function refresh_stats() {
    fe.overlay.splash_message (LnG.RefreshTxt + " ...")
    local datas = {}; local sys = "";local cnt;
    local g_cnt = 0; local g_time = 0; local g_played = 0; local dirs = {};
    dirs.results <- [];
    foreach(b in fe.displays) if(b.in_menu) dirs.results.push(b.name);
    foreach(display in dirs.results){
        cnt=0;
        local romlist = "";
        for ( local i = 0; i < fe.displays.len(); i++ ){
            if(fe.displays[i].name == display){
                romlist = fe.displays[i].romlist;
                break;
            }
        }

        if(romlist != ""){
            local text = txt.loadFile( globs.config_dir + "romlists/" + romlist + ".txt" );
            foreach( line in text.lines ){
                if( line != "" ){
                    if(line[0] != 35) cnt++; // discard #
                }
            }
            datas[display] <- {"cnt":cnt, "pl":0, "time":0};
            g_cnt+=cnt;
        }
    }

    // Get Stats for each System
    dirs = DirectoryListing( globs.config_dir + "stats", false );
    foreach(subdir in dirs.results){
        if( !datas.rawin(subdir) ) continue; // assume only systems listed by fe.display is used
        local files = DirectoryListing( globs.config_dir + "stats/" + subdir, false );
        foreach(file in files.results){
            if ( ext(file) == "stat" ){
                local f_stat = ReadTextFile(globs.config_dir + "stats/" + subdir + "/" + file);
                local i = 0;
                while ( !f_stat.eos() ) {
                    local num = f_stat.read_line().tointeger();
                    if(i){
                        datas[subdir].time+=num;
                        g_time+=num;
                    }else{
                        datas[subdir].pl+=num;
                        g_played+=num;
                    }
                    i++;
                }
            }
        }
    }
    SaveStats(datas); // Save stats to file
    return datas;
}

function LoadStats(){
    local tabl = {};
    local f = ReadTextFile( globs.script_dir, "pcca.stats" );
    if( f._f.len() < 10 ) refresh_stats(); // if file is empty or too small to be complete (10 should be ok)
    while ( !f.eos() ) {
        local l = split( f.read_line(), ";");
        if( l.len() ) tabl[ l[0] ] <- {"cnt":l[1].tointeger(), "pl":l[2].tointeger(), "time":l[3].tointeger()}
    }
    return tabl;
}

function SaveStats(tbl){ // update global systems stats
    local f2 = file( globs.script_dir + "pcca.stats", "w" );
    foreach(k,d in tbl){
        local line = k + ";" + d.cnt + ";" + d.pl + ";" + d.time + "\n";
        f2.writeblob(writeB(line));
    }
}

function secondsToDhms(seconds) {
    if(seconds == "") return;
    seconds = seconds.tointeger();
    local h = floor(seconds / 3600);
    local m = floor(seconds % 3600 / 60);
    local s = floor(seconds % 60);

    local hDisplay = h > 0 ? h + " H " : "";
    local mDisplay = (h > 0 || m > 0) ? m + " Min. " : "";
    local sDisplay = (h > 0 || m > 0 || s > 0) ? s + " Sec." : "";

    if( seconds <= 0 ){
        return LnG.Never;
    }else if( seconds < 60 ){
        return sDisplay;
    }

    return hDisplay + mDisplay;
}

// get media tags
function get_media_tag(offset){
    local tags = fe.game_info(Info.Tags, offset).tolower();
    local taglist = split (tags,";")
    if ( (taglist.len() == 1) ) return "images/tags/" + taglist[0] + ".png";
    return;
}

// return directory listing
function get_dir_lists(path)
{
    local files = {};
    local temp = DirectoryListing( path, false );
    foreach ( t in temp.results )
    {
        local temp = strip_ext( t ).tolower();
        files[temp] <- path + "/" + t;
    }
    return files;
}

//Check if file exist
function file_exist(path)
{
    return fe.path_test(path, PathTest.IsFile);
    //try { local a = file(path, "r" ); a.close(); return true; }
    //catch( e ){ return false; }
}

//Round Number as decimal
function round(nbr, dec){
    local f = pow(10, dec) * 1.0;
    local newNbr = nbr.tofloat() * f;
    newNbr = floor(newNbr + 0.5)
    newNbr = (newNbr * 1.0) / f;
    return newNbr;
}

//Generate a pseudo-random number between min and max
function rnd_num(min, max, type){
    srand( rand() * time() );
    switch(type){
        case "int":
            return (rand() * (max - min + 1) / (RAND_MAX + 1)) + min;
        break;

        case "float":
            return min + (rand().tofloat() / (RAND_MAX + 1.0).tofloat()) * (max - min);
        break;
    }
}

//get random index in a table
function get_random_table(tb){
    local i=0;
    local sel = rnd_num(0,tb.len()-1,"int");
    foreach( key, val in tb ){
        if(i == sel) return val
        i++;
    }
    return "";
}

//Select Random file in a folder
function get_random_file(dir){
    local fname = "";
    local tmp = zip_get_dir( dir );
    if( tmp.len() > 0 ) fname = dir + "/" + tmp[ rnd_num(0,tmp.len()-1,"int") ];
    return fname;
}

//Flip Effect
function flipy( img ) { img.subimg_height = -1 * img.texture_height; img.subimg_y = img.texture_height; }
function flipx( img ) { img.subimg_width = -1 * img.texture_width; img.subimg_x = img.texture_width; }

//Return file ext
function ext( name )
{
    local s = split( name, "." );
    if ( s.len() <= 1 ) return "";
    return s[s.len()-1];
}

//Return filename without ext
function strip_ext( name )
{
    if( !name.find(".") ) return name;
    return replace (name, "." + split(name, ".").pop(), "")
}

function find_theme_node( node )
{
    if ( node.tag == "Theme" )
        return node;

    foreach ( c in node.children )
    {
        local n = find_theme_node( c );
        if ( n ) return n;
    }

    return null;
}

/* Magic tokens Functions */
function Langue( offset = 0 ){
   local lng = fe.game_info(Info.Language, offset);
    for ( local i = 0; i < 17; i++ ) Lang[i].file_name = "";
    if( lng.len() > 0 ){
        local g_c = split( lng, ",");
        for ( local i = 0; i < g_c.len(); i++ ) Lang[i].file_name = "images/flags/lang/" + g_c[i] + ".png";
    }
}

function copyright( index_offset ) {
    local d = "";
    local year =  fe.game_info( Info.Year);
    local manu = fe.game_info( Info.Manufacturer, index_offset );
    if( year ) d = "© " + year;
    if( manu ) d += (year != "" ? ", " : " ") + manu;
    return d;
}

function region( offset ){
   local input = fe.game_info(Info.Region, offset);
   if( input.len() > 0 ) return input;
   return "Unknow";
}

function periph( offset ){
    local ctsp = split(fe.game_info(Info.Control, offset), "," );
    if ( ctsp.len() <= 1 ) return "images/controller/" + fe.game_info(Info.Emulator) + "/" + fe.game_info(Info.Control, offset);
    return "images/controller/" + fe.game_info(Info.Emulator) + "/" + ctsp[0];
}

function periph2( offset ){
    local ctsp = split(fe.game_info(Info.Control, offset), "," );
    if ( ctsp.len() < 2 ) return "";
    return "images/controller/" + fe.game_info(Info.Emulator) + "/" + ctsp[1];
}

function category( offset ){
    local ctsp = split(fe.game_info(Info.Category, offset), "," );
    if ( ctsp.len() <= 1 ) return "images/category/" + fe.game_info(Info.Category, offset);
    return "images/category/" + ctsp[0];
}

function category2( offset ){
    local ctsp = split(fe.game_info(Info.Category, offset), "," );
    if ( ctsp.len() < 2 ) return "";
    return "images/category/" + ctsp[1];
}

function ret_wheel( offset ){
    if(fe.game_info(Info.Emulator) == "@") return medias_path + "Main Menu/Images/Wheel/[Name].png";
    return medias_path + fe.game_info(Info.Emulator) + "/Images/Wheel/[Name].png";
}

function ret_favo( offset ){
    if( fe.game_info(Info.Favourite) == "1" || fe.game_info(Info.Extra).find("f") != null || fe.list.name == "Favourites" ) return 1;
    return "";
}

function PlayedTime( offset ){
    return secondsToDhms( fe.game_info(Info.PlayedTime) );
}

//clamp a value from min to max
function clamp(value, min, max) {
    return value < min ? min : (value > max ? max : value);
}

function dec2rgb(c){
    c = c.tointeger();
    return [floor(c / (256*256)), floor(c / 256) % 256, c % 256];
}

function hex2dec(hexVal){
    local b = 1;
    local dec_val = 0;
    for (local i = hexVal.len() - 1; i >= 0; i--) {
        if (hexVal[i] >= '0' && hexVal[i] <= '9') {
            dec_val += ((hexVal[i]) - 48) * b;
            b*= 16;
        }
        else if (hexVal[i] >= 'A' && hexVal[i] <= 'F') {
            dec_val += ((hexVal[i]) - 55) * b;
            b*= 16;
        }
    }
    return dec_val;
}

function writeB(Line){
    local b = blob( Line.len() );
    for (local i=0; i<Line.len(); i++) b.writen( Line[i], 'b' );
    return b;
}

function merge_table(tb1,tb2){
    foreach(a,b in tb2) tb1[a]<-b;
    return tb1;
}

function show_menu_artwork(sel_menu, surf_menu_img, artwork_list){
    local artwork = sel_menu._current_list.rows[sel_menu._slot_pos].title;
    if(artwork_list.find( artwork ) != null){
        surf_menu_img.file_name = ArtObj[artwork].file_name;
        surf_menu_img.visible = true;
    }
    return true;
}

function set_type(val, ref){
    switch(typeof(ref)){
        case "float":
            try{ val = val.tofloat() } catch(e){val = 0.0}
        break;
        case "integer":
            try{ val = val.tointeger() } catch(e){val = 0}
        break;
        case "bool":
            val = (val == "true" || val == "yes" ? true : false);
        break;
    }
    return val;
}


function set_xml_datas(){
    local common = {"x":0.0,"y":0.0,"w":0.0,"h":0.0,"r":0.0,"time":0.0,"delay":0.0,"type":"none","start":"none","rest":"none","zorder":0,"ry":0.0,"rx":0.0,"keepaspect":true,
    "hidden":false,"random":"none"};
    local video = merge_table (clone(common), {"bsize":0,"bsize2":0,"bsize3":0,"bcolor":0,"bcolor2":0,"bcolor3":0,"overlayoffsetx":0.0,"overlayoffsety":0.0,"overlaybelow":false,
    "bshape":"square", "overlaywidth":0.0, "overlayheight":0.0, "below":false, "forceaspect":false, "crt_scanline":false, "random":false} );
    video.rawdelete("hidden");
    video.rawdelete("keepaspect");
    local node = find_theme_node( xml_root );
    foreach ( child in node.children )
    {
        local datas = node.getChild(child.tag);
        switch(child.tag){
            case "video":
                foreach(k,v in video){
                    datas.addAttr( k, (!(k in datas.attr) ? v : set_type(datas.attr[k], v)) );
                }
            break;

            case "artwork1":
            case "artwork2":
            case "artwork3":
            case "artwork4":
            case "artwork5":
            case "artwork6":
                foreach(k,v in common) datas.addAttr( k, (!(k in datas.attr) ? v : set_type(datas.attr[k], v)) );
            break;

            case "background":
                foreach(k,v in {"delay":0,"rest":"none","speed":1.0}) datas.addAttr( k, (!(k in datas.attr) ? v : set_type(datas.attr[k], v)) );
            break;
        }
    }
}

// Save XMl
function save_xml(xml_root, path){
    if( xml_root == null || IS_ARCHIVE(path) ) return; // don't save xml if it's a zip or xml_root is empty
    // add tag hd if it's not present
    try{ local test = xml_root.getChild("hd").attr; }catch(e){
        local res_c = split( my_config["theme_resolution"].tolower(), "x");
        local node = XMLNode();
        node.tag = "hd";
        node.attr["lw"] <- res_c[0];
        node.attr["lh"] <- res_c[1];
        xml_root.addChild(node);
    }
    local fileout = file(path + "Theme.xml", "w");
    local line = xml_root.toXML();
    fileout.writeblob( writeB(line) );
    return true;
}

// Save Ini
function save_ini(filename=false){
    if(!filename) filename = curr_sys;
    local fileout = file(globs.script_dir + "Settings/" + filename + ".ini", "w");
    local line = "";
    foreach(ke, va in Ini_settings){
        line="";
        line += "["+ke+"]\n";
        fileout.writeblob( writeB(line) );
        line="";
        foreach(k,v in va){
           if( ["cnt","syst","nbr"].find(k) == null ) line+=k+"="+v+"\n" // do not save counter for the array of keys (special artworks)
        }
        fileout.writeblob( writeB(line) );
    }
    return true;
}

function video_transform(rotate=true){
    local artD = clone(xml_root.getChild("video").attr);
    local f_w = artD.overlaywidth;
    local f_h = artD.overlayheight;

    if((f_w == 0 || f_h == 0) && availables["video"]){
        f_w = ArtObj["video"].texture_width;
        f_h = ArtObj["video"].texture_height;
    }

    if(!hd){ // only for HS themes
        if(ArtObj.snap.texture_width > ArtObj.snap.texture_height){ // landscape video
            if(artD.forceaspect == "vertical" || artD.forceaspect == "none" ) artD.h = artD.w / ( ArtObj.snap.texture_width.tofloat() / ArtObj.snap.texture_height.tofloat() );
        }

        if(ArtObj.snap.texture_width < ArtObj.snap.texture_height){ // portrait video
            if(artD.forceaspect == "horizontal" || artD.forceaspect == "none") artD.w = artD.h * ( ArtObj.snap.texture_width.tofloat() / ArtObj.snap.texture_height.tofloat() );
        }
    }else{
        if(artD.forceaspect == "true") artD.h = artD.w / ( ArtObj.snap.texture_width.tofloat() / ArtObj.snap.texture_height.tofloat() );
        //if(artD.forceaspect == "true")  ArtObj.snap.preserve_aspect_ratio = true;
    }

    local borderMax = 0;
    foreach(v in [artD.bsize * 0.5, artD.bsize2, artD.bsize3] ) if(v > borderMax) borderMax = v;
    local viewport_snap_width = artD.w;
    local viewport_snap_height = artD.h;
    if(borderMax > 0){
        artD.bshape = (artD.bshape == "round" || artD.bshape == "true" ? true : false)
        if(artD.bsize  > 0)video_shader.set_param("border1", artD.bcolor,  artD.bsize, artD.bshape); // + rounded
        if(artD.bsize2 > 0)video_shader.set_param("border2", artD.bcolor2, artD.bsize2, artD.bshape);
        if(artD.bsize3 > 0)video_shader.set_param("border3", artD.bcolor3, artD.bsize3, artD.bshape);
        viewport_snap_width += borderMax * 2;
        viewport_snap_height += borderMax * 2;
    }

    local viewport_width = viewport_snap_width;
    local viewport_height = viewport_snap_height;

    if(availables["video"]){ // if video overlay available
        video_shader.set_param("datas", true, artD.overlaybelow);
        if( f_w + abs(artD.overlayoffsetx) > artD.w  ) viewport_width = f_w + (abs(artD.overlayoffsetx) * 2 );
        if( f_h + abs(artD.overlayoffsety) > artD.h  ) viewport_height = f_h + (abs(artD.overlayoffsety) * 2 );
    }else{
        video_shader.set_param("datas", false, artD.overlaybelow);
        artD.overlayoffsetx = 0; artD.overlayoffsety = 0; // fix if theme contain offset and no frame video is present
    }
    artD.x -= viewport_width  * 0.5;
    artD.y -= viewport_height * 0.5;

    if( rotate ){
        ArtObj.snap.rotation = artD.r;
        local mr = PI * artD.r / 180;
        artD.x += cos( mr ) * (-viewport_width * 0.5) - sin( mr ) * (-viewport_height * 0.5) + viewport_width * 0.5;
        artD.y += sin( mr ) * (-viewport_width * 0.5) + cos( mr ) * (-viewport_height * 0.5) + viewport_height * 0.5;
    }

    video_shader.set_param("scanline", artD.crt_scanline);
    video_shader.set_param("offsets", artD.overlayoffsetx, artD.overlayoffsety);
    video_shader.set_param("snap_coord", artD.w, artD.h, viewport_snap_width, viewport_snap_height);
    video_shader.set_param("frame_coord", f_w, f_h , viewport_width, viewport_height);

    ArtObj.snap.set_pos( (artD.x  * mul) + offset_x, (artD.y * mul_h) + offset_y, viewport_width * mul, viewport_height * mul_h);
}

function create_theme_struct(sys){
    local arr = ["/Images/", "/Images/Letters/", "/Images/Other/", "/Images/Particle/", "/Images/Special/", "/Images/Wheel/", "/Images/Backgrounds/",
    "/Images/Artwork1/", "/Images/Artwork2/", "/Images/Artwork3/", "/Images/Artwork4/", "/Images/Artwork5/", "/Images/Artwork6/", "/Sound/",
    "/Sound/Background Music/", "/Sound/Game Start/", "/Sound/System Exit/", "/Sound/Wheel Sounds/", "/Themes/", "/Video/", "/Video/Override Transitions/"];
    foreach(sub in arr) system ("mkdir " + (OS == "Windows" ? "" : "-p ") + "\"" + medias_path + sys + sub + "\"");
}

function create_xml(){
    local f = ReadTextFile( globs.script_dir, "empty.xml" );
    local raw_xml = "";
    while ( !f.eos() ) raw_xml += f.read_line();
    try{ xml_root = xml.load( raw_xml ); } catch ( e ) { }
    local res_c = split( my_config["theme_resolution"].tolower(), "x");
    xml_root.getChild("hd").addAttr("lw", res_c[0]);
    xml_root.getChild("hd").addAttr("lh", res_c[1]);
}

function get_infos_screen(curr_game, curr_emulator, ttime){
    local script_dir = globs.script_dir;
    local def = false, game = false, globals = false;
    overlay_title.charsize = flw*0.022;
    // check if infos is available for this systeme and for selected game
    if(file_exist(script_dir + "Loader/" + curr_emulator + "/Default/settings.ini")) def = true;
    if(file_exist(script_dir + "Loader/" + curr_emulator + "/" + curr_game + "/settings.ini")) game = true;

    SetListBox(overlay_list, {visible = true, rows = 5, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.020 })
    if(def){
        local def_ini = get_ini(script_dir + "Loader/" + curr_emulator + "/Default/settings.ini");
        if(def_ini.main.globals == "true"){
            overlay_background.file_name = script_dir + "Loader/" + curr_emulator + "/Default/default.png";
            overlay_background.set_pos(0,0,flw, flh);
            // type
            switch(def_ini.main.type){
                case "select":
                    local opts = split( def_ini.main.options, "," );
                    opt_selected <- fe.overlay.list_dialog(opts, def_ini.main.select_title, 0, -1);
                    fe.do_nut(script_dir + "Loader/" + curr_emulator + "/Default/action.nut");
                break;
            }
        }
    }

    if(game){
        local game_ini = get_ini(script_dir + "Loader/" + curr_emulator + "/" + curr_game + "/settings.ini");
        overlay_background.file_name = script_dir + "Loader/" + curr_emulator + "/" + curr_game + "/default.png";
        overlay_background.set_pos(0,0,flw, flh);
        overlay_title.visible = true;
        // type
        switch(game_ini.main.type){
            case "select":
                local opts = split( game_ini.main.options, "," );
                opt_selected <- fe.overlay.list_dialog(opts, game_ini.main.select_title, 0, -1);
                fe.do_nut(script_dir + "Loader/" + curr_emulator + "/" + curr_game + "/action.nut");
            break;

            case "infos":
                if( "infos" in game_ini.main ) overlay_title.msg = game_ini.main.infos;
                if( "infos_pos" in game_ini.main ){
                    local pos = split( game_ini.main.infos_pos, "," ).map(function(v){return v.tofloat()});
                    overlay_title.set_pos(flw * pos[0], flh * pos[1], flw * pos[2], flh * pos[3])
                }
                if( "infos_rgb" in game_ini.main ){
                    local rgb = split( game_ini.main.infos_rgb, "," ).map(function(v){return v.tointeger()});;
                    overlay_title.set_rgb( rgb[0], rgb[1], rgb[2] );
                }

                fe.overlay.list_dialog(["Continue"], overlay_title.msg, 0, -1); // simulate wait
            break;
        }
    }

    overlay_title.msg = "";
   return true;
}

// count numbers of digits in integer
function CntDigit(i)
{
    if (i/10 == 0)
        return 1;
    return 1 + CntDigit((i / 10));
}

/* DEBUG */

//Convert a squirrel table to a string
function table_as_string( table )
{
    if ( table == null ) return ""
    local str = ""
    foreach ( name, value in table )
        if ( typeof(value) == "table" )
            str += "[" + name + "] -> " + table_as_string( value ) +"\n"
        else
            str += name + ": " + value + " \n"

    return str
}

function SetListBox(obj, p) {
    if ( obj == null ) return;
    foreach( key, val in p )
        try {
            if ( key == "rgba" ) {
                obj.set_rgb(p[key][0], p[key][1], p[key][2]);
                obj.alpha = p[key][3];
            } else if ( key == "bg_rgba" ) {
                obj.set_bg_rgb(p[key][0], p[key][1], p[key][2]);
                obj.bg_alpha = p[key][3];
            } else if ( key == "sel_rgba" ) {
                obj.set_sel_rgb(p[key][0], p[key][1], p[key][2]);
                obj.sel_alpha = p[key][3];
            } else if ( key == "selbg_rgba" ) {
                obj.set_selbg_rgb(p[key][0], p[key][1], p[key][2]);
                obj.selbg_alpha = p[key][3];
            } else {
                obj[key] = val;
            }
        } catch(e) {}
}

function unset_rotation(r, obj) {
    local mr = PI * r / 180;
    obj.x -= cos( mr ) * (-obj.width * 0.5) - sin( mr ) * (-obj.height * 0.5) + obj.width * 0.5;
    obj.y -= sin( mr ) * (-obj.width * 0.5) + cos( mr ) * (-obj.height * 0.5) + obj.height * 0.5;
}

function pointer_coord(set=false){
    local pointer_coord = Ini_settings["pointer"]["coord"];
    switch(set){
        case "left":
            pointer_coord = "0.0,0.401,0.100,0.200,180";
        break;

        case "right":
            pointer_coord = "0.910,0.401,0.100,0.200,0";
        break;

        case "bottom":
            pointer_coord = "0.449,0.831,0.1,0.2,90";
        break;

        case "top":
            pointer_coord = "0.451,-0.0286,0.1,0.2,270";;
        break;
    }

    local g_c = split( pointer_coord, ",").map(function(v){return v.tofloat()}); // %
    if( g_c.len() == 5 ) {
            if(set) Ini_settings["pointer"]["coord"] = g_c[0]+","+g_c[1]+","+g_c[2]+","+g_c[3]+","+g_c[4];
            point.width = g_c[2] * flw;
            point.height = g_c[3] * flh;
            point.x = g_c[0] * flw;
            point.y = g_c[1] * flh;
            point.alpha = 255;
            local start = {"x":flw, "y":point.y}
            if(Ini_settings["wheel"]["type"] == "left") { start.y = point.y, start.x = point.x-point.width }
            if(Ini_settings["wheel"]["type"] == "top") { start.y = -point.height; start.x = point.x; }
            if(Ini_settings["wheel"]["type"] == "bottom"){ start.y = flh + point.height, start.x = point.x }
            point_animation.opts.from = {x=start.x y=start.y, rotation=g_c[4]}
            point_animation.opts.to = {x=point.x, y=point.y, rotation=g_c[4] }
            point.set_pos(start.x, start.y);
            point.rotation = g_c[4];
    }
}

function wheel_coord(set=false){
    local wheel_coord = Ini_settings["wheel"]["coord"];
    if(set) wheel_coord = "0,0,1,1,0";
    local g_c = split( wheel_coord, ",").map(function(v){return v.tofloat()}); // %
    if( g_c.len() == 5 ) {
        if(set) Ini_settings["wheel"]["coord"] = g_c[0]+","+g_c[1]+","+g_c[2]+","+g_c[3]+","+g_c[4];
        local x=g_c[0] * flw;
        local y=g_c[1] * flh;
        local width = g_c[2] * flw;
        local height = g_c[3] * flh;
        //local mr = PI * g_c[2] / 180;
        //x -= cos( mr ) * (-width * 0.5) - sin( mr ) * (-height * 0.5) + width * 0.5;
        //y -= sin( mr ) * (-width * 0.5) + cos( mr ) * (-height * 0.5) + height * 0.5;
        wheel_surf.rotation = g_c[4];
        wheel_surf.set_pos(x, y, width, height);
    }
}

function system_stats_coord(set=false){
    local sys_stats_coord = Ini_settings["wheel"]["system stats"];
    switch(set){
        case "left":
            sys_stats_coord = "0.1979,0.5587,0";
        break;

        case "right":
            sys_stats_coord = "0.7126,0.5517,0";
        break;

        case "bottom":
            sys_stats_coord = "0.445,0.8535,0";
        break;

        case "top":
            sys_stats_coord = "0.445,0.105,0";
        break;
    }

   local g_c = split( sys_stats_coord, ",").map(function(v){return v.tofloat()}); // %
    if( g_c.len() == 3 ) {
        if(set) Ini_settings["wheel"]["system stats"] = g_c[0]+","+g_c[1]+","+g_c[2];
        m_infos.x = g_c[0]*flw;
        m_infos.y = g_c[1]*flh;
        m_infos.rotation = g_c[2];
    }
}

function PadWithZero(value) {
    return (value.tointeger() < 10 ? "0" : "") + value.tostring();
}

function implode(arr, sep="") {
    local o = arr[0];
    for (local i = 1; i < arr.len(); i++) o+= sep + arr[i];
    return o;
}

function game_infos(){
    local st = [Info.Name, Info.Title, Info.Emulator, Info.CloneOf, Info.Year, Info.Manufacturer, Info.Category, Info.Players, Info.Rotation, Info.Control, Info.Status, Info.DisplayCount,
    Info.DisplayType, Info.AltRomname, Info.AltTitle, Info.Extra, Info.Buttons, Info.Series, Info.Language, Info.Region, Info.Rating];
    local i = [];
    foreach(v in st) i.push(fe.game_info(v))
    return i;
}

function RealSplit(str, separator) {
    local result = [];
    local chars = "";
    for (local i = 0; i < str.len(); i++){
        if(str[i].tochar() != separator){
            chars = chars + str[i].tochar();
        }else{
            result.push(chars);
            chars = "";
        }
    }
    if(chars != "") result.push(chars);
    return result;
}

function check_display(name){
    foreach(v in fe.displays ) if(v.name.tolower() == name.tolower()) return true;
    return false;
}

function delete_display(disp_name){
    fe.overlay.splash_message ("Deleting Romlist");
    local cfg = file(globs.config_dir + "attract.cfg", "rb")
    local output = [];
    local char
    while (!cfg.eos()){
        local ln = ""
        char = 0
        while (char != 10) {
            char = cfg.readn('b')
            if (char != 13 && char != 10) ln = ln + char.tochar()
        }
        output.push(ln)
    }
    cfg.close();

    local cmd = ["layout","romlist","in_cycle","in_menu","filter","rule","sort_by","reverse_order"];
    local c = false;
    local new_output = [];
    foreach(k,v in output){
        local keep = true;
        local ln = strip(v.tolower());
        if(ln.len() > 6 && ln.slice(0,7) == "display"){
            local found_disp = strip( ln.slice(7, ln.len()) );
            c = (found_disp == disp_name.tolower());
            if(c) keep = false;
        }

        if(c){
            foreach (item in cmd) {
                if ( ln.find(item) == 0 && ln[item.len()+1] == 32) {
                    keep = false;
                    break;
                }
            }
        }
        if (keep) new_output.append(v);
    }

    local f2 = file( globs.config_dir + "attract.cfg", "w" );
    foreach (v in new_output) f2.writeblob(writeB(v + "\n"));
    f2.close()
}

function add_display(name, opts, filters){
    fe.overlay.splash_message ("Creating romlist");
    local cfg = file(globs.config_dir + "attract.cfg", "rb")
    local output = [];
    local char
    while (!cfg.eos()){
        local ln = ""
        char = 0
        while (char != 10) {
            char = cfg.readn('b')
            if (char != 13 && char != 10) ln = ln + char.tochar()
        }
        output.push(ln)
    }
    cfg.close();

    local new_disp = "display   " + name + "\n" +
    "\tlayout               pcca\n"+
    "\tromlist              " + name + "\n" +
    "\tin_cycle             " + opts[0] + "\n" +
    "\tin_menu              " + opts[1] + "\n";

    foreach(k,v in filters){
        new_disp+="\tfilter               "+v.name + "\n";
        foreach(kk,vv in v){
            if(kk != "name"){
                local cnt = 21 - kk.len();
                local sp = "";
                for (local k = 0; k < cnt; k++) sp+=" "
                new_disp+="\t\t"+kk+ sp + vv + "\n";
            }
        }
    }
    //check in array where is the first display block
    for (local k = 0; k < output.len(); k++) {
        local l = strip(output[k]);
        if(l.len() > 6 && l.slice(0,7) == "display"){
            output.insert(k, new_disp);
            break;
        }
    }

    local f2 = file( globs.config_dir + "attract.cfg", "w" );
    foreach (v in output) f2.writeblob(writeB(v + "\n"));
    f2.close()
}


function update_most_played(){
    local elapse = fe.game_info(Info.PlayedTime).tointeger();
    if(elapse < 60) return false; // do not add if played less than 1 minute
    local g_inf = game_infos();
    g_inf.push(fe.game_info(Info.PlayedCount).tointeger());
    g_inf.push(elapse);

    // check if it's a favourites
    if(ret_favo(0)== 1) g_inf[15] = "f";

    local m_pl = [];
    local ln = implode(g_inf, ";");
    local game = {"sys":g_inf[2], "name":g_inf[0],"line":ln, "cnt":fe.game_info(Info.PlayedCount).tointeger(), "elapse":elapse};

    local Mostpath = globs.config_dir + "romlists/Most Played.txt";
    local tempf = ReadTextFile(Mostpath);
    while (!tempf.eos()){
        local tmpline = tempf.read_line();
        if(tmpline == "") continue; // if empty line
        local spl = RealSplit( tmpline, ";" );
        if(spl.len() < 23) continue; // security if the romlist has missing element
        if(spl[0] == g_inf[0] && spl[2] == g_inf[2]) continue; // discard if already exist in array
        m_pl.push( { "line":tmpline, "cnt":spl[21].tointeger(), "elapse":spl[22].tointeger() } )
    }

    m_pl.push(game);
    m_pl.sort(function(a, b) { if (b.cnt == a.cnt) return b.elapse <=> a.elapse; else  return b.cnt <=> a.cnt; } );
    while( m_pl.len() > my_config["Most_Played_Entry"].tointeger() ) m_pl.pop();

    local f2 = file(Mostpath, "w");
    foreach(a,b in m_pl) f2.writeblob( writeB(b.line + "\n") );
    f2.close();
}


function create_most_played()
{
    local m_pl = [];
    local dirs = DirectoryListing( globs.config_dir + "stats", false );
    foreach(display in dirs.results){
        if(!check_display(display) || !file_exist(globs.config_dir + "romlists/" + display + ".txt")) continue; // check if display and romlist exist
        local games = [];

        // load romlist in games array
        local romlist_file = ReadTextFile( globs.config_dir + "romlists/" + display + ".txt" );
        while (!romlist_file.eos()){
            local tmpline = romlist_file.read_line();
            local splited = split( tmpline, ";" );
            games.push({"name":splited[0],"line":tmpline, "cnt":0, "elapse":0});
        }

        if(!games.len()) continue; // if empty romlist

        local files = DirectoryListing( globs.config_dir + "stats/" + display, false );
        foreach(file in files.results){
            if ( ext(file) == "stat" ){
                local f_stat = ReadTextFile(globs.config_dir + "stats/" + display + "/" + file);
                local stats = [];
                for (local i = 0; !f_stat.eos(); i++) stats.push(f_stat.read_line().tointeger());

                if(stats.len() && stats[1] > 60){ // do not add if played less than 1 minute
                    local filename = strip_ext(file);
                    foreach(k,v in games){
                        if(v.name == filename){
                            games[k].cnt = stats[0];
                            games[k].elapse = stats[1];
                        }
                    }
                }
            }
        }

        // add favourites flag to extra inf
        if(file_exist(globs.config_dir + "romlists/" + display + ".tag")){
            local temp_favo = ReadTextFile(globs.config_dir + "romlists/" + display + ".tag");
            while (!temp_favo.eos()){
                local tmpline = temp_favo.read_line();
                foreach(k,v in games){
                    if(v.name == strip(tmpline)){
                        local g_inf = RealSplit( v.line, ";" );
                        g_inf[15] = "f";
                        games[k].line = implode(g_inf , ";");
                    }
                }
            }
        }

        foreach(k,v in games){
            if(v.cnt > 0){
                m_pl.push(v);
                m_pl.sort(function(a, b) { if (b.cnt == a.cnt) return b.elapse <=> a.elapse; else  return b.cnt <=> a.cnt; } );
                while( m_pl.len() > my_config["Most_Played_Entry"].tointeger() ) m_pl.pop();
            }
        }
    }

    local mostPlpath = globs.config_dir + "romlists/Most Played.txt";
    local f2 = file(mostPlpath, "w");
    foreach(b in m_pl) f2.writeblob( writeB(b.line + ";" + b.cnt + ";" + b.elapse + "\n") ); // add 2 new cols to the romlist (count and time) for the sorting order
    f2.close()
}

function update_recent()
{
    local g_inf = game_infos();
    // check if it's a favourites and add time to extra information
    if(ret_favo(0)== 1) g_inf[15] = time() + ":f"; else g_inf[15] = time();
    local Recentpath = globs.config_dir + "romlists/Recent.txt";
    local tempf = ReadTextFile(Recentpath);
    local ln = "";
    ln+=implode(g_inf, ";") + "\n";
    for (local i = 0; !tempf.eos(); i++) {
        local templ = tempf.read_line();
        local spl = RealSplit( templ, ";" );
        if(spl[0] == g_inf[0] && spl[2] == g_inf[2]) continue;
        if( i > my_config["Recent_Entry"].tointeger() ) break;
        ln+=templ + "\n";
    }

    local f2 = file(  Recentpath, "w" );
    f2.writeblob(writeB(ln));
    f2.close()
}

function update_favourites(add){
    fe.overlay.splash_message (LnG.Wait + " ...")
    local g_inf = game_infos();
    local Favopath = globs.config_dir + "romlists/Favourites.txt";
    local tempf = ReadTextFile(Favopath);
    local ln = "";
    while (!tempf.eos()){
        local templ = tempf.read_line();
        local spl = RealSplit( templ, ";" );
        if(spl[0] == g_inf[0] && spl[2] == g_inf[2]) continue; // remove from favourites
        ln+=templ + "\n";
    }
    if(add) ln+=implode(g_inf, ";") + "\n";
    local f2 = file(  Favopath, "w" );
    f2.writeblob(writeB(ln));
    f2.close();

    //update custom romlist
    local output = [];
    foreach( v in globs.custom_romlists ){
        if(v == "Favourites") continue;
            local Favopath = globs.config_dir + "romlists/" + v + ".txt";
            local tempf = ReadTextFile(Favopath);
            local found = false;
            output.clear();
            while (!tempf.eos()){
                local templ = tempf.read_line();
                if(!found && templ.find(g_inf[0]) != null){
                    local spl = RealSplit( templ, ";" );
                    if(spl[2] == g_inf[2]){
                        if(v == "Recent"){ // Recent romlist
                           local datas = RealSplit(spl[15], ":");
                           spl[15] = datas[0] + (add == true ? ":f" : "" );
                        }else{ // other romlist
                           spl[15] = (add == true ? "f" : "" );
                        }
                        templ = implode(spl, ";");
                        found = true;
                    }
                }
                output.push(templ);
            }

            local f2 = file( globs.config_dir + "romlists/" + v + ".txt", "w" );
            foreach (v in output) f2.writeblob(writeB(v + "\n"));
            f2.close()
    }
    update_tags(globs.config_dir + "romlists", g_inf[2], add) // update system tag file
    return true;
}

function create_favourites(){
    local Favourites = [];
    local files = DirectoryListing( globs.config_dir + "romlists", false );
    foreach(file in files.results){
        if ( ext(file) == "tag" && globs.custom_romlists.find(strip_ext(file)) == null ){
            local f = ReadTextFile(globs.config_dir + "romlists/" + file);
            local favo = [];
            for (local i = 0; !f.eos(); i++) favo.push(strip(f.read_line()));
            local romlist = ReadTextFile (globs.config_dir + "romlists/" + strip_ext(file) + ".txt");
            while (!romlist.eos()){
                local tmpline = romlist.read_line();
                local spl = split( tmpline, ";" );
                if( favo.find( strip(spl[0])) != null ) Favourites.push(tmpline);
            }
        }
    }
    // sort by Title
    Favourites.sort(function(a, b) {
        return split(a, ";")[1].tolower() > split(b, ";")[1].tolower() ? 1 : (split(a, ";")[1].tolower() < split(b, ";")[1].tolower() ? -1 : 0);
    });

    local favoPath = globs.config_dir + "romlists/Favourites.txt";
    local f2 = file(favoPath, "w");
    foreach(ln in Favourites) f2.writeblob( writeB(ln + "\n") );
    f2.close()
}


function update_tags(path, name, add){
    path = path + "/" + name + ".tag";
    local tabl = [];
    local f = ReadTextFile(path);
    local game = fe.game_info(Info.Name);
    while ( !f.eos() ) {
        local l = f.read_line()
        if( l.len() && l == game) continue;
        tabl.push(l);
    }
    if(add) tabl.push(game);

    local f2 = file(  path, "w" );
    foreach(ln in tabl) f2.writeblob( writeB(ln + "\n") );
    f2.close()
}

function load_customs(){ // load custom romlist in array
    local custom_lists = {};
    foreach(a,v in globs.custom_romlists){
        if(v == "All Games") continue;
        local lists = [];
        local romlist_file = ReadTextFile( globs.config_dir + "romlists/" + v + ".txt" );
        while (!romlist_file.eos()){
            local tmpline = romlist_file.read_line();
            local splited = split( tmpline, ";" );
            if( splited.len() > 1 ) lists.push( splited[0] + ";" + splited[2] );
        }
        custom_lists[v] <- lists;
    }
    return custom_lists;
}

function array_unique(arr) {
    local uniqueArr = [];
    foreach (item in arr) {
        if (uniqueArr.find(item) == null) {
            uniqueArr.append(item);
        }
    }
    return uniqueArr;
}

function create_all_games()
{
    local games = [];
    foreach(k, display in fe.displays){
        if(globs.custom_romlists.find(display.romlist) != null || display.romlist == "All Games") continue; //don't use the custom romlists
        if(!check_display(display.romlist) || !file_exist(globs.config_dir + "romlists/" + display.romlist + ".txt")) continue; // check if display and romlist exist
        local file = globs.config_dir + "romlists/" + display.romlist + ".txt";
        local tmpfile = ReadTextFile(file);
        while (!tmpfile.eos()){
            local tmpline = tmpfile.read_line();
            if(tmpline[0] == 35 || strip(tmpline) == "") continue;
            local splited = split( tmpline, ";" );
            games.push({"name":splited[0],"title":splited[1],"line":tmpline});
        }
        // add favourites flag to all inf
        if(file_exist(globs.config_dir + "romlists/" + display.romlist + ".tag")){
            local temp_favo = ReadTextFile(globs.config_dir + "romlists/" + display.romlist + ".tag");
            while (!temp_favo.eos()){
                local tmpline = temp_favo.read_line();
                foreach(k,v in games){
                    if(v.name == strip(tmpline)){
                        local g_inf = RealSplit( v.line, ";" );
                        g_inf[15] = "f";
                        games[k].line = implode(g_inf , ";");
                    }
                }
            }
        }
    }
    //sort by title
    games.sort(function(a, b) { return a.title.tolower() > b.title.tolower() ? 1 : (a.title.tolower() < b.title.tolower() ? -1 : 0); });

    local AllPath = globs.config_dir + "romlists/All Games.txt";
    local f2 = file(AllPath, "w");
    foreach(b in games) f2.writeblob( writeB(b.line + "\n") );
    f2.close()
}

function rebuild_custom_romlists(){
    fe.overlay.splash_message ("List size change, rebuilding custom romlist ...")
    if(my_config["Most_Played_Enabled"] == "Yes") create_most_played();
    if(my_config["Global_Favourites_Enabled"] == "Yes") create_favourites();
    if(my_config["All_Games_Enabled"] == "Yes") create_all_games();
}

// get text between occurence
function GetBetween(str, start, end) {
    local start_idx = str.find(start);
    local end_idx = str.find(end, start_idx + start.len());
    if (start_idx >= 0 && end_idx > start_idx) {
        return str.slice(start_idx + start.len(), end_idx);
    } else {
        return false;
    }
}

function battery_status(data){
    data = strip(data)
    local start = "<!=";
    local end = "=!>";
    if (data.slice(0, start.len()) != start || data.slice(-end.len()) != end) return false; // check data validity
    data = GetBetween(data, start, end);
    local bat_state = {"EMPTY":",", "LOW":"-", "MEDIUM":".", "FULL":"/"};
    local controllers = split(data, ";");
    foreach(v in controllers){
        local b = split(v, ":");
        local c = split(b[1], ",");
        local idx = b[0].tointeger();
        local status = strip( replace(c[0], "\"","") );
        local bat_level = strip( replace(c[1], "\"","") );
        ctrl_icons[idx].msg = "";
        if(status != "DISCONNECTED"){
            ctrl_icons[idx].set_rgb(0,255,0);
            if(status == "WIRED"){
                ctrl_icons[idx].msg = "0";
                continue;
            }
            if(bat_level == "EMPTY" || bat_level == "LOW"){
                ctrl_icons[idx].set_rgb(255,20,10);
            }
            if(bat_level == "MEDIUM") ctrl_icons[idx].set_rgb(200,220,0);
            ctrl_icons[idx].msg = bat_state[bat_level];
        }
    }
}

// named transitions
debug_array <- [];
debug_array.push("StartLayout")// 0
debug_array.push("EndLayout") //1
debug_array.push("ToNewSelection") //2
debug_array.push("FromOldSelection")//3
debug_array.push("ToGame") //4
debug_array.push("FromGame") //5
debug_array.push("ToNewList") //6
debug_array.push("EndNavigation") //7
debug_array.push("ShowOverlay") //8
debug_array.push("HideOverlay") //9
debug_array.push("NewSelOverlay") //10
debug_array.push("ChangedTag") //11
debug_array.push("Nothing") //12
