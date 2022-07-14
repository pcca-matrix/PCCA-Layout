/* RPCS3 Loader , profile selector */

local rpcs3dir = "F:\\Hyperspin\\Emulators\\PS3\\"; //Rpcs3 path
local Users = ["00000001","00000002"]; // userId array in same order as opt_selected in settings.ini

local f = ReadTextFile( rpcs3dir + "GuiConfigs\\persistent_settings.dat" );
local entity = null;
local map = {};
while ( !f.eos() )
{
    local line = strip( f.read_line() );
    if (( line.len() > 0 ) && ( line[0] == '[' ))
    {
        entity = line.slice( 1, line.len()-1 );
        map[ entity ] <- {};
    }
    else
    {
        if(!line.find("=")) continue;
        local temp = split( line, "=" );
        local v = ( temp.len() > 1 ) ? strip( temp[1] ): "";
        local key = strip(temp[0]);
        if(!map.rawin(entity))map.entity <- []
        map[ entity ][ key ] <- v;
    }
}

if( "Users" in map ){
    if("active_user" in map.Users && opt_selected != -1){
      map.Users.active_user = Users[opt_selected];  
    }
}

local fileout = file(rpcs3dir + "GuiConfigs\\persistent_settings.dat" , "w");
local line = "";
local i = 0;
foreach(ke, va in map){
    line=( i == 0 ? "" : "\n");
    line += "["+ke+"]\n";
    fileout.writeblob( writeB(line) );
    line="";
    foreach(k,v in va){
       line+=k+"="+v+"\n"
    }
    fileout.writeblob( writeB(line) );
    i++;
}