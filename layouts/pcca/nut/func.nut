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
    Ini_settings["wheel"]["transition_ms"] <- 50;
    Ini_settings["wheel"]["animation"] <- "ease";
    Ini_settings["wheel"]["fade_time"] <- 3.0;
    Ini_settings["wheel"]["alpha"] <- 0.0;
    Ini_settings["wheel"]["slots"] <- 10;
    Ini_settings["wheel"]["type"] <- "rounded"; // rounded
    Ini_settings["wheel"]["offset"] <- "0.0,0.0,0"; // in %
    Ini_settings["wheel"]["system stats"] <- "0.780,0.531,0"; // in %

    Ini_settings["game text"] <- {}
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
            "active" : true, "default" : true, "w": 0.0, "h": 0.0, "x": 0.0 , "y": 0.0, "r":0.0,  "syst" : "", "sys_global" : 0
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
    local f = ReadTextFile( fe.script_dir + "Settings/" + name + ".ini" );
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

function refresh_stats(system = "") {
    fe.overlay.splash_message (LnG.RefreshTxt + " ...")
    local datas = main_infos; local sys = "";local cnt;
    local g_cnt = 0; local g_time = 0; local g_played = 0; local dirs = {};
    dirs.results <- [];
    if(system != ""){ // Get games count for single system
        dirs.results.push( system );
    }else{ // Get games count for each system
        for ( local i = 0; i < fe.displays.len(); i++ ) dirs.results.push(fe.displays[i].name);
    }

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
            local text = txt.loadFile( FeConfigDirectory + "romlists\\" + romlist + ".txt" );
            foreach( line in text.lines ) if( line != "" ) cnt++;
            datas[display] <- {"cnt":cnt-1, "pl":0, "time":0};
            g_cnt+=cnt-1;
        }
    }

    // Get Stats for each System
    dirs = DirectoryListing( FeConfigDirectory + "stats", false );
    foreach(subdir in dirs.results){
        if( !datas.rawin(subdir) ) continue; // assume only systems listed by fe.display is used
        local files = DirectoryListing( FeConfigDirectory + "stats\\" + subdir, false );
        foreach(file in files.results){
            if ( ext(file) == "stat" ){
                local f_stat = ReadTextFile(FeConfigDirectory + "stats\\" + subdir + "\\" + file);
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
    local f = ReadTextFile( fe.script_dir, "pcca.stats" );
    if( f._f.len() < 10 ) refresh_stats(); // if file is empty or too small to be complete (10 should be ok)
    while ( !f.eos() ) {
        local l = split( f.read_line(), ";");
        if( l.len() ) tabl[ l[0] ] <- {"cnt":l[1].tointeger(), "pl":l[2].tointeger(), "time":l[3].tointeger()}
    }
    return tabl;
}

function SaveStats(tbl){ // update global systems stats
    local f2 = file( fe.script_dir + "pcca.stats", "w" );
    foreach(k,d in tbl){
        local line = k + ";" + d.cnt + ";" + d.pl + ";" + d.time + "\n";
        f2.writeblob(writeB(line));
    }
}

function secondsToDhms(seconds) {
    seconds = seconds.tointeger();
    local d = floor(seconds / (3600*24));
    local h = floor(seconds % (3600*24) / 3600);
    local m = floor(seconds % 3600 / 60);
    local s = floor(seconds % 60);

    local dDisplay = d > 0 ? d + LnG.Sday +" " : "";
    local hDisplay = h > 0 ? h + " H " : "";
    local mDisplay = m > 0 ? m + " Min. ":"";
    local sDisplay = s > 0 ? s + " Sec." : "";

    if( seconds <= 0 ){
        return LnG.Never;
    }else if( seconds < 60 ){
        return sDisplay;
    }else if( d >= 1 ){
        return dDisplay + hDisplay;
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
    try { local a = file(path, "r" ); a.close(); return true; }
    catch( e ){ return false; }
}

//Round Number as decimal
function round(nbr, dec){
    local f = pow(10, dec) * 1.0;
    local newNbr = nbr.tofloat() * f;
    newNbr = floor(newNbr + 0.5)
    newNbr = (newNbr * 1.0) / f;
    return newNbr;
}

//Generate a pseudo-random integer between 0 and max
function rndint(max) {
    local roll = 1.0 * max * rand() / RAND_MAX;
    return roll.tointeger();
}

//get random index in a table
function get_random_table(tb){
    local i=0;
    local sel = rndint(tb.len());
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
    if( tmp.len() > 0 ) fname = dir + "/" + tmp[ rndint(tmp.len()) ];
    return fname;
}

//Replace text in a string
function replace (string, original, replacement)
{
  local expression = regexp(original);
  local result = "";
  local position = 0;
  local captures = expression.capture(string);
  while (captures != null)
  {
    foreach (i, capture in captures)
    {
      result += string.slice(position, capture.begin);
      result += replacement;
      position = capture.end;
    }
    captures = expression.capture(string, position);
  }
  result += string.slice(position);
  return result;
}

//Flip Effect
function flipy( img ) { img.subimg_height = -1 * img.texture_height; img.subimg_y = img.texture_height; }
function flipx( img ) { img.subimg_width = -1 * img.texture_width; img.subimg_x = img.texture_width; }

//Return file ext
function ext( name )
{
    local s = split( name, "." );
    if ( s.len() <= 1 )
        return "";
    else
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
    if ( ctsp.len() <= 1 )
        return "images/controller/" + fe.list.name + "/" + fe.game_info(Info.Control, offset);
    else
        return "images/controller/" + fe.list.name + "/" + ctsp[0];
}

function periph2( offset ){
    local ctsp = split(fe.game_info(Info.Control, offset), "," );
    if ( ctsp.len() < 2 )
        return "";
    else
        return "images/controller/" + fe.list.name + "/" + ctsp[1];
}

function category( offset ){
    local ctsp = split(fe.game_info(Info.Category, offset), "," );
    if ( ctsp.len() <= 1 )
        return "images/category/" + fe.game_info(Info.Category, offset);
    else
        return "images/category/" + ctsp[0];
}

function category2( offset ){
    local ctsp = split(fe.game_info(Info.Category, offset), "," );
    if ( ctsp.len() < 2 )
        return "";
    else
        return "images/category/" + ctsp[1];
}

function ret_wheel( offset ){
    local m;
    if(fe.game_info(Info.Emulator) == "@"){
        m  = medias_path + "Main Menu/Images/Wheel/[Name].png";
    }else{
        m = medias_path + fe.list.name + "/Images/Wheel/[Name].png";
    }
    return m;
}

function ret_snap(){
    local m;
    if(fe.game_info(Info.Emulator) == "@"){
        m  = medias_path + "Main Menu/Video/" + fe.game_info(Info.Name) + ".mp4";
    }else{
        m = medias_path + fe.list.name + "/Video/" + fe.game_info(Info.Name) + ".mp4";
    }
    return m;
}

//clamp a value from min to max
function clamp(value, min, max) {
    if (value < min) value = min; if (value > max) value = max; return value
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
    foreach(a,b in tb2)tb1[a]<-b;
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
            val = (val == "true" ? true : false);
        break;
    }
    return val;
}


function set_xml_datas(){
    local common = {"x":0.0,"y":0.0,"w":0.0,"h":0.0,"r":0.0,"time":0.0,"delay":0.0,"type":"none","start":"none","rest":"none","zorder":0,"ry":0.0,"rx":0.0,"keepaspect":true};
    local video = merge_table (clone(common), {"bsize":0,"bsize2":0,"bsize3":0,"bcolor":0,"bcolor2":0,"bcolor3":0,"overlayoffsetx":0.0,"overlayoffsety":0.0,"overlaybelow":false,
    "bshape":"square", "overlaywidth":0.0, "overlayheight":0.0, "below":false, "forceaspect":false, "crt_scanline":false} );
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
        }
    }
}

// Save XMl
function save_xml(xml_root, path){
    if( xml_root == null || IS_ARCHIVE(path) ) return; // don't save xml if it's a zip or xml_root is empty
    local fileout = file(path + "Theme.xml", "w");
    local line = xml_root.toXML();
    fileout.writeblob( writeB(line) );
    return true;
}

// Save Ini
function save_ini(filename=false){
    if(!filename) filename = curr_sys;
    local fileout = file(fe.script_dir + "Settings/" + filename + ".ini", "w");
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
    system ("mkdir \"" + medias_path + sys + "\\Images\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Letters\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Other\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Particle\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Special\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Wheel\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Backgrounds\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Artwork1\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Artwork2\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Artwork3\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Artwork4\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Artwork5\\");
    system ("mkdir \"" + medias_path + sys + "\\Images\\Artwork6\\");
    system ("mkdir \"" + medias_path + sys + "\\Sound\\");
    system ("mkdir \"" + medias_path + sys + "\\Sound\\Wheel sounds\\");
    system ("mkdir \"" + medias_path + sys + "\\Themes\\");
    system ("mkdir \"" + medias_path + sys + "\\Video\\");
    system ("mkdir \"" + medias_path + sys + "\\Video\\Override Transitions\\");
}

function create_xml(){
    local f = ReadTextFile( fe.script_dir, "empty.xml" );
    local raw_xml = "";
    while ( !f.eos() ) raw_xml += f.read_line();
    try{ xml_root = xml.load( raw_xml ); } catch ( e ) { }
    local res_c = split( my_config["theme_resolution"].tolower(), "x");
    xml_root.getChild("hd").addAttr("lw", res_c[0]);
    xml_root.getChild("hd").addAttr("lh", res_c[1]);
}

function get_infos_screen(curr_game, curr_sys, ttime){
    local script_dir = fe.script_dir;
    local def = false, game = false, globals = false;
    overlay_title.charsize = flw*0.022;
    // check if infos is available for this systeme and for selected game
    if(file_exist(script_dir + "Loader/" + curr_sys + "/Default/settings.ini")) def = true;
    if(file_exist(script_dir + "Loader/" + curr_sys + "/" + curr_game + "/settings.ini")) game = true;

    SetListBox(overlay_list, {visible = true, rows = 5, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.020 })
    if(def){
        local def_ini = get_ini(script_dir + "Loader/" + curr_sys + "/Default/settings.ini");
        if(def_ini.main.globals == "true"){
            overlay_background.file_name = script_dir + "Loader/" + curr_sys + "/Default/default.png";
            overlay_background.set_pos(0,0,flw, flh);
            // type
            switch(def_ini.main.type){
                case "select":
                    local opts = split( def_ini.main.options, "," );
                    opt_selected <- fe.overlay.list_dialog(opts, def_ini.main.select_title, 0, -1);
                    fe.do_nut(script_dir + "Loader/" + curr_sys + "/Default/action.nut");
                break;
            }
        }
    }

    if(game){
        local game_ini = get_ini(script_dir + "Loader/" + curr_sys + "/" + curr_game + "/settings.ini");
        overlay_background.file_name = script_dir + "Loader/" + curr_sys + "/" + curr_game + "/default.png";
        overlay_background.set_pos(0,0,flw, flh);
        overlay_title.visible = true;
        // type
        switch(game_ini.main.type){
            case "select":
                local opts = split( game_ini.main.options, "," );
                opt_selected <- fe.overlay.list_dialog(opts, game_ini.main.select_title, 0, -1);
                fe.do_nut(script_dir + "Loader/" + curr_sys + "/" + curr_game + "/action.nut");
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
