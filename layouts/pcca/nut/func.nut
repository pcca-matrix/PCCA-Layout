function refresh_stats(system = "") {
    fe.overlay.splash_message (LnG.RefreshTxt + " ...")
    local datas = main_infos; local sys = "";local cnt;
    local g_cnt = 0; local g_time = 0; local g_played = 0; local dirs = {};

    if(system != ""){ // Get games count for single system
        dirs.results <- [];
        dirs.results.push( system + ".txt");
    }else{ // Get games count for each system
        dirs = DirectoryListing( FeConfigDirectory + "romlists", false );
    }

    foreach(file in dirs.results){
        cnt=0;
        if ( ext(file) == "txt" ){
            sys = strip_ext(file);
            local text = txt.loadFile( FeConfigDirectory + "romlists\\" + file );
            foreach( line in text.lines ) if( line != "" ) cnt++;
            datas[sys] <- {"cnt":cnt-1, "pl":0, "time":0};
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
        local b = blob( line.len() );
        for (local i=0; i<line.len(); i++) b.writen( line[i], 'b' );
        f2.writeblob(b);
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
    try { file(path, "r" ); return true; }
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
        m  = medias_path + "Main Menu/Images/Wheel/"+fe.game_info(Info.Name, offset)
    }else{
        m = medias_path + fe.list.name + "/Images/Wheel/" + fe.game_info(Info.Name, offset);
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