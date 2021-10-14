function user_settings(){
    foreach(v, value in my_config){
        if(v.find("_")){
            value = value.tolower();
            local temp = split(v, "_" );
            local valr = v.slice(v.find("_") + 1);
            local key = strip(temp[0]);
            if(!Ini_settings.rawin(key)) Ini_settings[ key ] <- {};
            if(!Ini_settings[ key ].rawin(valr)) Ini_settings[ key ][ valr ] <- {};
            if(value == "no")value = false; if(value == "yes")value = true;
            Ini_settings[ key ][ valr ] <- value;
        }else{
            Ini_settings[v] <- my_config[v];
        }

    }

  /* Special artworks */
    foreach( n in ["a","b"] ){
        Ini_settings["special art " + n] <- {
            "nbr":"", "cnt": 1, "in": 0.5, "out": 0.5, "length": 3, "delay": 0.1, "type": "linear", "start": "bottom",
            "active" : 1, "default" : 0, "w": 0, "h": 0, "x": 0 , "y": 0, "syst" : "", "sys_global" : 0
        }
        if( n == "b" ){
            Ini_settings["special art " + n].type = "fade";
            Ini_settings["special art " + n].start = "none";
        }
    }

   return Ini_settings;
}


function get_ini_values(name, load_user=true){
    local f = ReadTextFile( fe.script_dir + "Settings/" + name + ".ini" );
    local entity = null;
    local map = (load_user ? user_settings() : {} );
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
            if(v == "true")v = true; if(v == "false") v = false;
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
        local files = DirectoryListing( FeConfigDirectory + "stats\\" + subdir, false );
        if( !datas.rawin(subdir) ) datas[subdir] <- {"cnt":0, "pl":0, "time":0};
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

    datas["Main Menu"] <-{"cnt":g_cnt, "pl":g_played, "time":g_time};
    SaveStats(datas); // Save stats to file
    return datas;
}

function LoadStats(){
    local tabl = {};
    local f = ReadTextFile( fe.script_dir, "pcca.stats" );
    if( f._f.len() < 10 ) refresh_stats(); // if file is empty or too small to be complete (10 must be ok)
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
    local newNbr = nbr * f;
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
    local sel = rand()%tb.len();
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
    if( tmp.len() > 0 ) fname = dir + "/" + tmp[ rand()%tmp.len() ];
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
    local s = split( name, "." );
    if ( s.len() == 1 )
        return name;
    else
    {
        local retval;
        retval = s[0];
        for ( local i=1; i<s.len()-1; i++ ) retval = retval + "." + s[i];
        return retval;
    }
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
    for ( local i = 1; i < 18; i++ ) Lang[i].file_name = "";
    if( lng.len() > 0 ){
        local g_c = split( lng, ",");
        for ( local i = 1; i < g_c.len(); i++ ) Lang[i].file_name = "images/flags/lang/" + g_c[i] + ".png";
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

function rating( offset ){
   local input = fe.game_info(Info.Rating, offset);
   if( input.len() > 0 ) return input;
   return "Other - NR (Not Rated)";
}

function region( offset ){
   local input = fe.game_info(Info.Region, offset);
   if( input.len() > 0 ) return input;
   return "Unknow";
}

function category( offset ){
   local input = fe.game_info(Info.Category, offset);
   local a = split(input, "-");
   if( a.len() > 1 ) return a[1];
   return input;
}

function font_ctrl( offset ){
   local input = fe.game_info(Info.Control, offset);
    switch(input){
        case "pad":
            return "e";
        break;
    }
    return "e";
}

function font_pl( offset ){
   local input = fe.game_info(Info.Players,offset);
    if(input == "1" || input == "")return "b";
    if(input == "2")return "c";
    if(input != "")return "f";
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

function show_menu_artwork(hover, surf_menu_img, artwork_list){
    local ff = artwork_list.find(hover);
    if(ff != null) {
        surf_menu_img.file_name = ArtObj[artwork_list[ff]].file_name;
        surf_menu_img.visible = true;
    }else{
      surf_menu_img.visible = false;  
    }
}

function SRT(){
    // Aspect - Center (only for HS theme)
    local nw = flh * 1.333;
    local mul = nw / 1024;
    local mul_h = mul;
    local offset_x = (flw - nw) * 0.5;
    local offset_y = 0;

    if( Ini_settings.themes["aspect"] == "stretch"){
        mul = flw / 1024;
        mul_h = flh / 768;
        offset_x = 0;
        offset_y = 0;
    }
    local hd = false;
    local node = find_theme_node( xml_root );
    try{ hd = node.getChild("hd") } catch(e) {} // check if hd tag is present

    if(hd){
        local lw = hd.attr.lw.tofloat();
        local lh = hd.attr.lh.tofloat();
        nw = flh * (flw / flh);
        mul = flw / lw;
        mul_h = mul;
        offset_x = 0;
        offset_y = 0;
    }


    return( {"mul":mul, "mul_h":mul_h, "offset_x":offset_x, "offset_y":offset_y} )
}

function set_art_datas(Xtag){
    local artD = {"x":0,"y":0,"w":0,"h":0,"r":0,"time":0,"delay":0,"overlayoffsetx":0,"overlayoffsety":0,"overlaybelow":false,"below":false};
    artD = merge_table (artD, {"forceaspect":"none","type":"none","start":"none","rest":"none","bsize":0,"bsize2":0,"bsize3":0,"bcolor":0,"bcolor2":0,"bcolor3":0} );
    artD = merge_table (artD, {"bshape":false,"ry":0,"rx":0,"keepaspect":false,"zorder":0,"overlaywidth":0,"overlayheight":0} );

    local node = find_theme_node( xml_root );
    local datas = node.getChild(Xtag);

    foreach(k,v in datas.attr){
        switch(k){
            case "w": // float
            case "h":
            case "x":
            case "y":
            case "overlayoffsetx":
            case "overlayoffsety":
            case "overlaywidth":
            case "overlayheight":
                artD[k] = ( v == "" ? 0.0 : v.tofloat() );
            break;

            case "r": // int
            case "bsize":
            case "bsize2":
            case "bsize3":
            case "bcolor":
            case "bcolor2":
            case "bcolor3":
            case "rx":
            case "ry":
            case "zorder":
                artD[k] = ( v == "" ? 0 : v.tointeger() );
            break;

            case "time": // time value
            case "delay":
                artD[k] = ( v == "" ? 0.0 : v.tofloat() * 1000 );
            break;

            case "overlaybelow": // true/false
            case "below":
            case "keepaspect":
                artD[k] = (v == "true" ?  true : false );
            break;

            case "forceaspect": // strings with def "none"
            case "type":
            case "rest":
                artD[k] = ( v == "" ? "none" : v.tolower() );
            break;

            case "start":
                artD[k] = ( (v.tolower() == "left" || v.tolower() == "right" || v.tolower() == "bottom" || v.tolower() == "top") ?  v.tolower() : "none");
            break;

            case "bshape":
                artD[k] =  ( (v == "round" || v == "true") ? true : false );
            break;
        }
    }
    return artD;
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
function save_ini(datas, name){
    // if main menu return !!!!! or set main settings at least for crt_scanline !!!!
    local map = get_ini_values(name, false);
    local fileout = file(fe.script_dir + "Settings/" + name + ".ini", "w");
    local line = "";
    if(!map.len()){
        map = {};
        map ["themes"] <- {}
        map ["themes"][datas.obj] <- {}
        map ["themes"][datas.obj] = datas.val;
    }
    foreach(ke, va in map){
        line="";
        line += "["+ke+"]\n";
        fileout.writeblob( writeB(line) );
        line="";
        foreach(k,v in va){line+=k+"="+v+"\n"}
        fileout.writeblob( writeB(line) );
    }
    Ini_settings["themes"][datas.obj] = datas.val;
    return true;
}

function video_transform(rotate=true){
    local artD = set_art_datas("video");
    local rt = SRT();
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
    }

    local borderMax = 0;
    foreach(v in [artD.bsize * 0.5, artD.bsize2, artD.bsize3] ) if(v > borderMax) borderMax = v;
    local viewport_snap_width = artD.w;
    local viewport_snap_height = artD.h;
    if(borderMax > 0){
        if(artD.bsize  > 0)video_shader.set_param("border1", artD.bcolor,  artD.bsize, artD.bshape); // + rounded
        if(artD.bsize2 > 0)video_shader.set_param("border2", artD.bcolor2, artD.bsize2, artD.bshape);
        if(artD.bsize3 > 0)video_shader.set_param("border3", artD.bcolor3, artD.bsize3, artD.bshape);
        viewport_snap_width += borderMax * 2;
        viewport_snap_height += borderMax * 2;
    }

    local viewport_width = viewport_snap_width;
    local viewport_height = viewport_snap_height;

    if(availables["video"]){ // if video overlay available
        video_shader.set_param("datas",true, artD.overlaybelow);
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

    video_shader.set_param("scanline", (Ini_settings.themes["crt_scanline"] ? 1.0 : 0.0 ) );
    video_shader.set_param("offsets",artD.overlayoffsetx, artD.overlayoffsety);
    video_shader.set_param("snap_coord", artD.w, artD.h, viewport_snap_width, viewport_snap_height);
    video_shader.set_param("frame_coord", f_w, f_h , viewport_width, viewport_height);

    ArtObj.snap.set_pos( (artD.x  * rt.mul) + rt.offset_x, (artD.y * rt.mul_h) + rt.offset_y, viewport_width * rt.mul, viewport_height * rt.mul_h);
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