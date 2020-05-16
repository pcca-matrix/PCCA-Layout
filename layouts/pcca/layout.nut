/////////////////////////////////////////////////////////////////////
//
// PCCA v1.0 beta
// Use with Attract-Mode Front-End  http://attractmode.org/
//
// This program comes with NO WARRANTY.  It is licensed under
// the terms of the GNU General Public License, version 3 or later.
//
// PCCA-Matrix 2020
//
////////////////////////////////////////////////////////////////////

class UserConfig {
    </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=1 /> transition_ms="30"
    </ label="Select rounded or vertical wheel", help="Switch between a rounded and vertical wheel", options="Wheel,Vertical Wheel", order=2 /> wheel_type="Wheel"
    </ label="Medias Path", help="Path of HyperSpin medias, if empty, medias is inside layout folder", options="", order=3 /> medias_path=""
    </ label="Override Transitions", help="Use FLV Override Videos Transitions", options="Yes, No", order=4 /> override_transitions="Yes"
    </ label="Themes Wait For Override", help="Themes load after override transition has played", options="Yes, No", order=4 /> wait_override="Yes"
    </ label="Animated Backgrounds", help="Use backgrounds transitions", options="Yes, No", order=5 /> animated_backgrounds="Yes"
    </ label="Aspect", help="Theme aspect", options="Stretch, Center", order=6 /> Aspect="Center"
    </ label="Bezels", help="If display is centered , use bezels to replace black borders", options="Yes, No", order=7 /> Bezels="Yes"
    </ label="Bezels On Top", help="Display bezel on top of background Yes, or below No", options="Yes, No", order=8 /> Top_Bezel="No"
    </ label="Background Stretch", help="Stretch all background or main menu only", options="Yes, No, Main Menu", order=9 /> Background_Stretch="Main Menu"
    </ label="Interface Language", help="User Language", options="Fr, En", order=10 /> user_lang="En"
    </ label="List Name", help="MUST be the display menu prompt value (default: Select System)", options="", order=11 /> list_name="Select System"
    </ label="Infos Coord", help="game infos surface x,y coord, empty = left bottom", options="", order=12 /> infos_coord = ""
    //</ label="Animated Artworks", help="Animate artworks", options="Yes, No", order=6 /> animated_artworks="Yes"
}

// Modules
fe.load_module("hs-animate");
fe.load_module("conveyor");
//fe.load_module("objects/keyboard-search");
fe.load_module("file");
fe.load_module("file-format");
fe.load_module("objects/scrollingtext");
fe.do_nut("nut/func.nut");
fe.do_nut("nut/lang.nut");

my_config <- fe.get_config();

medias_path <- ( my_config["medias_path"] != "" ? my_config["medias_path"] : fe.script_dir + "Media" );
if ( medias_path.len()-1 != '/' ) medias_path += "/";

local LnG = _LL[ my_config["user_lang"] ];
local tr_directory_cache  = get_dir_lists( medias_path + "Frontend/Video/Transitions" );
local prev_back = {}; // previous background table infos ( transitions )

//test <- fe.add_text("",0,200,1920,25);// DEBUG

// Globals
flw <- fe.layout.width.tofloat();
flh <- fe.layout.height.tofloat();

// Aspect - Center (only for HS theme)
local nw = flh * 1.333;
local mul = nw / 1024;
local mul_h = mul;
local offset_x = (flw - nw) * 0.5;
local offset_y = 0;

if( my_config["Aspect"] == "Stretch"){
    mul = flw / 1024;
    mul_h = flh / 768;
    offset_x = 0;
    offset_y = 0;
}

ArtObj <- {};
snap_is_playing <- false;
availables <- { artwork1 = false, artwork2 = false, artwork3 = false, artwork4 = false, video = false }; // artworks available in theme zip
local path = "";
local curr_theme = "";
local curr_sys = "";
local glob_delay = 400;
local glob_time = 0;
local rtime = 0;
local reverse = 0;
local trigger_load_theme = false;
local visi = false;
local trigger_letter = false;
local letters = fe.add_image("", flw * 0.5 - (flw*0.140 * 0.5), flh * 0.5 - (flh*0.280 * 0.5), flw*0.140, flh*0.280);
conveyor_bool <- false; // fading conveyor

// Background / Bezel
ArtObj.background <- fe.add_image("", 0, 0, flw, flh);
ArtObj.background.file_name = "images/Backgrounds/Black.png";
ArtObj.background1 <- fe.add_image("images/init.swf",-2000,-2000,0.1,0.1); // needed for initialising SWF  ?, without can't use any surface overlay when swf is displayed (AM BUG) !
ArtObj.background2 <- fe.add_image("",-2000,-2000,0.1,0.1);
ArtObj.background1.visible = false;
ArtObj.background2.visible = false;
ArtObj.bezel <- fe.add_image("",0,0,flw,flh);
ArtObj.bezel.visible = false;

// Themes Artworks
ArtObj.artwork1 <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.artwork2 <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.artwork3 <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.artwork4 <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.snap <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.video <- fe.add_image("",-1000,-1000,0.1,0.1);

// Override Transitions Videos
local flv_transitions = fe.add_image("",0,0,flw,flh);
flv_transitions.video_flags = Vid.NoLoop;

local start_background = fe.add_image("images/Backgrounds/Background.jpg",0,0,flw,flh);
local point = fe.add_image("", flw*0.90, flh*0.394, flw*0.10, flh*0.20);
local center_wheel = fe.add_image( "[!ret_wheel]", flw*0.82, flh*0.465, flw*0.12, flh*0.075);

if ( my_config["wheel_type"] == "Vertical Wheel") { // Vertical wheel
    center_wheel.set_pos(flw*0.88, flh*0.471, flw*0.11, flh*0.070);
    point.set_pos(flw*0.99, flh*0.390, flw*0.10, flh*0.23);
}

point.alpha = 200;

PresetAnimation(point)
.auto(true)
.triggers([Transition.ToNewSelection])
.key("x").from(flw*0.99).to(flw*0.90)
.duration(180)
.yoyo()
.play();

PresetAnimation(center_wheel)
.auto(true)
.triggers([Transition.ToNewSelection])
.preset("zoom", 1.20)
.yoyo()
.loops(-1)
.duration(1800)
.easing("ease-in-cubic")
.play();

local center_Wheel_fade = PresetAnimation(center_wheel)
.auto(true)
.from({alpha=0})
.to({alpha=255})
.delay(500)
.duration(800)

// Z-orders
ArtObj.artwork4.zorder = -2
ArtObj.artwork3.zorder = -3
ArtObj.artwork2.zorder = -4
ArtObj.snap.zorder = -7
ArtObj.artwork1.zorder = -9
ArtObj.bezel.zorder = -10
ArtObj.background.zorder = -10
flv_transitions.zorder = -10 // or -6 for some theme with video overlay on background ? test
start_background.zorder=-11

// Shaders
artwork_shader <- [];
artwork_shader.push( fe.add_shader( Shader.VertexAndFragment, "shaders/main.vert", "shaders/artworks.frag" ) );
artwork_shader.push( fe.add_shader( Shader.VertexAndFragment, "shaders/main.vert", "shaders/artworks.frag" ) );
artwork_shader.push( fe.add_shader( Shader.VertexAndFragment, "shaders/main.vert", "shaders/artworks.frag" ) );
artwork_shader.push( fe.add_shader( Shader.VertexAndFragment, "shaders/main.vert", "shaders/artworks.frag" ) );
video_shader <- fe.add_shader( Shader.Fragment, "shaders/vframe.frag" );

ArtObj.snap.shader = video_shader;
video_shader.set_texture_param("tex_f", ArtObj.video);
video_shader.set_texture_param("tex_s", ArtObj.snap);

ArtObj.artwork1.shader = artwork_shader[0];
ArtObj.artwork2.shader = artwork_shader[1];
ArtObj.artwork3.shader = artwork_shader[2];
ArtObj.artwork4.shader = artwork_shader[3];
foreach(k,v in artwork_shader){
    v.set_texture_param("texture");
    v.set_param("datas",0,0,0,0);
}

anims_shader <- [];
anims_shader.push( ShaderAnimation(artwork_shader[0] ) );
anims_shader.push( ShaderAnimation(artwork_shader[1] ) );
anims_shader.push( ShaderAnimation(artwork_shader[2] ) );
anims_shader.push( ShaderAnimation(artwork_shader[3] ) );

foreach(k,v in anims_shader){
    v.name("artwork" + (k+1) );
    v.param("progress");
    v.auto(true);
    v.from([0.0]);
    v.to([1.0]);
}

anim_video_shader <- ShaderAnimation( video_shader );
anim_video_shader.auto(true);
anim_video_shader.name("video_shader");

anims <- [];
anims.push(PresetAnimation(ArtObj.artwork1));
anims.push(PresetAnimation(ArtObj.artwork2));
anims.push(PresetAnimation(ArtObj.artwork3));
anims.push(PresetAnimation(ArtObj.artwork4));
foreach(k,v in anims){
    v.name("artwork"+(k+1));
    v.auto(true);
}

anim_video <- PresetAnimation(ArtObj.snap);
anim_video.name("video");
anim_video.auto(true);

Trans_shader <- fe.add_shader( Shader.Fragment, "shaders/effect.frag" );
ArtObj.background.shader = Trans_shader;

Trans_shader.set_texture_param("back1", ArtObj.background1);
Trans_shader.set_texture_param("back2", ArtObj.background2);
Trans_shader.set_texture_param("bezel", ArtObj.bezel);

local bck_anim = ShaderAnimation(Trans_shader);
bck_anim.auto(true)
bck_anim.param("progress")
bck_anim.duration(glob_delay * 1.40)
bck_anim.delay(0)

// Sounds

// default Front-End sounds
local FE_Sound_Letter_Click = fe.add_sound( medias_path + "Frontend/Sounds/Sound_Letter_Click.mp3" );
local FE_Sound_Screen_Click = fe.add_sound(medias_path + "Frontend/Sounds/Sound_Screen_Click.mp3" );
local FE_Sound_Screen_In = fe.add_sound(medias_path + "Frontend/Sounds/Sound_Screen_In.mp3" );
local FE_Sound_Screen_Out = fe.add_sound(medias_path + "Frontend/Sounds/Sound_Screen_Out.mp3" );
local FE_Sound_Wheel_In = fe.add_sound(medias_path + "Frontend/Sounds/Sound_Wheel_In.mp3" );
local FE_Sound_Wheel_Out = fe.add_sound(medias_path + "Frontend/Sounds/Sound_Wheel_Out.mp3" );
local FE_Sound_Wheel_Jump = fe.add_sound(medias_path + "Frontend/Sounds/Sound_Wheel_Jump.mp3" );

// medias Sounds
local Sound_Click = fe.add_sound( medias_path + "Main Menu/Sound/Wheel Click.mp3" );
local Sound_System_In_Out = fe.add_sound("");
local Sound_Wheel = fe.add_sound( get_random_file( medias_path + "Sound/Wheel Sounds") );
local Background_Music = fe.add_sound( get_random_file( medias_path + "Sound/Background Music") );
local Game_In_Out = fe.add_sound("");

// Game Infos
local surf_ginfos = fe.add_surface(flw, flh*0.22);
surf_ginfos.alpha = 200;
local g_coord = [ 0, flh*0.805 ];

if(my_config["infos_coord"] != ""){
   local g_c = split( my_config["infos_coord"], ",");
   if( g_c.len() == 2 ) g_coord = [ g_c[0].tofloat(), g_c[1].tofloat() ];
}

surf_ginfos.set_pos( g_coord[0], g_coord[1] );
local ttfont = "College Halo";

local txt_title = surf_ginfos.add_text( "[Title]", flw*0.021, flh*0.072, flw*0.9375, flh*0.040 );
txt_title.set_rgb( 255, 255, 255 );
txt_title.font = ttfont;
txt_title.align = Align.Left;

local copyr = surf_ginfos.add_text("[!copyright]", flw*0.023, flh*0.106, flw*0.9375, flh*0.030 );
copyr.font = ttfont;
copyr.align = Align.Left;
copyr.set_rgb( 255, 255, 150 );

local list_entry = surf_ginfos.add_text( "[ListEntry]/[ListSize] " + LnG.display + ": [FilterName]", flw*0.027, flh*0.135, flw*0.3125, flh*0.022 );
list_entry.font = ttfont;
list_entry.align = Align.Left;

local PCount = surf_ginfos.add_text( LnG.counter + " [PlayedCount] / " + LnG.playedtime + " [PlayedTime]", flw*0.027, flh*0.152, flw*0.3125, flh*0.022 );
PCount.font = ttfont;
PCount.align = Align.Left;

local flags = surf_ginfos.add_image("images/flags/[!region]", flw*0.007, flh*0.085, flw*0.0213, flh*0.037);
copyr.align = Align.Left;

local rating = surf_ginfos.add_image("images/rating/[!rating]", flw*0.007, flh*0.120, flw*0.0213, flh*0.051 );

local pl = surf_ginfos.add_text( "[!font_pl]", -flw*0.006, flh*0.032, flw*0.510, flh*0.0462 );
pl.font = "fontello.ttf";
pl.align = Align.Left;

local Ctrl = surf_ginfos.add_text( "[!font_ctrl]", flw*0.031, flh*0.032, flw*0.030, flh*0.046 );
Ctrl.font = "fontello.ttf";
Ctrl.align = Align.Left;

local Category = surf_ginfos.add_text( "[!category]", flw*0.070, flh*0.050, flw*0.078, flh*0.020 );
Category.align = Align.Left;
Category.style = Style.Bold;

local favo = surf_ginfos.add_text( "[Favourite]", flw*0.071, flh*0.004, flw*0.058, flh*0.045 );
favo.font = "fontello.ttf";
favo.align = Align.Left;
favo.set_rgb( 255, 170, 0 );

// add tags
surf_ginfos.add_image("[!get_media_tag]", flw*0.030, 0, flw*0.063, flh*0.036)

// Synopsis
syno <- ScrollingText.add( "", flw*0.125, flh*0.976, fe.layout.width - (offset_x * 2) , flh*0.022, ScrollType.HORIZONTAL_LEFT );
syno.settings.delay = 2500;
syno.settings.speed_x = 2.5;

function overview( offset ) {
   local input = fe.game_info(Info.Overview, offset);
   if( input.len() > 1 ){
        syno.text.width = input.len() * flh*0.022;
        syno.set_bg_rgb(20,0,0,75);
        syno.text.msg = input;
        return;
   }
   syno.set_bg_rgb(20,0,0,0);
   return;
}

// Fix Bugs in ScrollingText module
ScrollingText.actual_text = function(obj, var) return obj.text.msg;

ScrollingText.tick_callback = function( ttime ) {
    for ( local i = 0; i < ScrollingText.objs.len(); i++ )
    {
        local obj = ScrollingText.objs[i];
        if ( glob_time - rtime > obj.settings.delay && (obj.settings.loop < 0 || obj._count < obj.settings.loop) ) ScrollingText.scroll( obj );
    }
}

ScrollingText.transition_callback = function( ttype, var, ttime ) {
    switch ( ttype )
    {
        case Transition.ToNewList:
        case Transition.EndNavigation:
            for ( local i = 0; i < ScrollingText.objs.len(); i++ )
            {
                local obj = ScrollingText.objs[i];
                obj._text = ScrollingText.actual_text(obj, var);
                obj.text.width = obj.settings.fixed_width;
                obj._count = 0;
                obj.text.align = Align.Left;
                obj.text.x = obj.surface.width;
                obj._dir = "left";
            }
        break;
    }
}

function background_transitions(anim, File, hd=false){
    if(File == ArtObj.background1.file_name && reverse) return;
    if(File == ArtObj.background2.file_name && !reverse) return;

    local fromIsSWF = false;
    local toIsSWF = false;
    local bw,bh;

    if(reverse){
         // fix flipped-y background with swf (why ???)
        if( ext(File).tolower() == "swf" ){
            toIsSWF = true;
        }
        if( ext(ArtObj.background1.file_name).tolower() == "swf" ){
            ArtObj.background1.video_playing = false;
            fromIsSWF = true;
        }
        ArtObj.background2.file_name = File;
        bw = ArtObj.background2.texture_width;
        bh = ArtObj.background2.texture_height;
    }else{
        // fix flipped-y background with swf (why ???)
        if( ext(File).tolower() == "swf" ){
            toIsSWF = true;
        }
        if( ext(ArtObj.background2.file_name).tolower() == "swf" ){
            ArtObj.background2.video_playing = false;
            fromIsSWF = true;
        }
        ArtObj.background1.file_name = File;

        bw = ArtObj.background1.texture_width;
        bh = ArtObj.background1.texture_height;
    }

    if( my_config["Background_Stretch"] == "Yes" || ( my_config["Background_Stretch"] == "Main Menu" && curr_sys == "Main Menu" ) || hd )
    {
        Trans_shader.set_param("back_res", flw, flh, 0, 0);

        if(prev_back.len() > 0 ){
            Trans_shader.set_param("prev_res", prev_back.bw, prev_back.bh, prev_back.ox, prev_back.oy );
        }else{
            Trans_shader.set_param("prev_res", bw * mul, bh * mul_h, offset_x, offset_y);
        }
        prev_back = { bw = flw, bh = flh, ox = 0, oy = 0};

    }else{

        Trans_shader.set_param("back_res", bw * mul, bh * mul , offset_x, offset_y);

        if(prev_back.len() > 0 ) {
            Trans_shader.set_param("prev_res", prev_back.bw, prev_back.bh, prev_back.ox, prev_back.oy );
        }else{
            Trans_shader.set_param("prev_res", bw * mul, bh * mul_h, offset_x, offset_y);
        }

        prev_back = { bw = bw * mul, bh = bh * mul, ox = offset_x, oy = offset_y };
    }

    Trans_shader.set_texture_param("back2", ArtObj.background2);
    Trans_shader.set_texture_param("back1", ArtObj.background1);
    Trans_shader.set_texture_param("bezel", ArtObj.bezel);

    if(!anim){
        local rndanim = rndint(42);
        Trans_shader.set_param("datas", rndanim, reverse, fromIsSWF, toIsSWF);// datas = preset number, reverse 0:1 , fromIsSWF, toIsSWF
    }else{
        Trans_shader.set_param("datas", anim, reverse, fromIsSWF ,toIsSWF);
    }

    Trans_shader.set_param("screen_res", flw, flh, ( ( my_config["Top_Bezel"] == "Yes" && !hd ) ? true : false) ); // if hd do not put bezel on top even top_bezel is true
    Trans_shader.set_param("alpha", 1.0);

    local to = (reverse == 0 ? 1.0 : 0.0)
    bck_anim.from([reverse])
    bck_anim.to([to])
    bck_anim.on("stop", function(anim){
        if(!reverse){
            ArtObj.background2.video_playing = true;
            ArtObj.background1.file_name = "";
        }else{
            ArtObj.background1.video_playing = true;
            ArtObj.background2.file_name = "";
        }
    })
    bck_anim.play();
    reverse = 1 - reverse;
}

function load_theme(name, theme_content, prev_def){

    if(theme_content.len() <= 0){
        if(file_exist(medias_path + curr_sys + "/Video/" + fe.game_info(Info.Name) + ".mp4")){
            ArtObj.background.set_pos(0,0,flw, flh);
            reset_art();
            background_transitions(null, medias_path + curr_sys + "/Video/" + fe.game_info(Info.Name) + ".mp4", true);
        }
        return false; // If there is no theme file, return (only video is present ! for unified theme)
    }

    local zippath = "";
    local DiR = theme_content[0];
    if ( DiR[DiR.len()-1] == '/' ) zippath = theme_content[0];
    local f = ReadTextFile( name, zippath + "Theme.xml" );

    local raw_xml = "";
    while ( !f.eos() ) raw_xml = raw_xml + f.read_line();

    //fix common error in a lot of themes with wrong end tags
    raw_xml = replace( raw_xml, "start=\"none\"/>rest=", "start=\"none\"rest=" );
    raw_xml = replace( raw_xml, "start=\"left\"/>rest=", "start=\"left\"rest=" );
    raw_xml = replace( raw_xml, "start=\"top\"/>rest=", "start=\"top\"rest=" );
    raw_xml = replace( raw_xml, "start=\"bottom\"/>rest=", "start=\"bottom\"rest=" );
    raw_xml = replace( raw_xml, "start=\"right\"/>rest=", "start=\"right\"rest=" );

    local xml_root = null;
    try{ xml_root = xml.load( raw_xml ); } catch ( e ) { };

    local theme_node = find_theme_node( xml_root );

    availables = { artwork1 = false, artwork2 = false, artwork3 = false, artwork4 = false, video = false };
    local w,h,x,y,r,time,delay,overlayoffsetx,overlayoffsety,overlaybelow,below,forceaspect,type,start,rest,bsize,bsize2,bsize3,bcolor,bcolor2,bcolor3,bshape,anim_rotate,hd;

    local art_mul = mul;
    local art_mul_h = mul_h;
    local art_offset_x = offset_x;
    local art_offset_y = offset_y;

    // check if it's a real HD theme
    foreach ( c in theme_node.children )
    {
        if(c.tag.tolower() == "hd"){
            hd = true;
            local lw = c.attr.lw.tofloat();
            local lh = c.attr.lh.tofloat();
            local nw = flh * (flw / flh);
            art_mul = flh / lh;
            art_mul_h = art_mul;
            art_offset_x = (flw - nw) * 0.5;
            art_offset_y = 0;

            if( my_config["Aspect"] == "Stretch"){
                art_mul = flw / lw;
                art_mul_h = flh / lh;
                art_offset_x = 0;
                offset_y = 0;
            }
        }
    }

    if(file_exist(medias_path + fe.game_info(Info.System) + "/Sound/Background Music/" + fe.game_info(Info.Name) + ".mp3") ){ // backrgound music found in media folder
        Background_Music.file_name = medias_path + fe.game_info(Info.System) + "/Sound/Background Music/" + fe.game_info(Info.Name) + ".mp3";
        Background_Music.playing = true;
        ArtObj.snap.video_flags = Vid.NoAudio;
    }

    local backg = false;
    foreach(k,v in theme_content){
        if(strip_ext(v.tolower()) == zippath.tolower() + "background"){ // background found in theme
            backg = name + "|" + v;
            if( my_config["animated_backgrounds"] == "Yes" ){
               background_transitions(null, backg, hd);
            }else{
               background_transitions(99, backg, hd);
            }
        }

        if( ext(v.tolower()) == "mp3" ){ // backrgound music found anywhere in theme ( in HS , must be in /Extras/Background Sounds/ ....mp3)
            Background_Music.file_name = name + "|" + v;
            Background_Music.playing = true;
            ArtObj.snap.video_flags = Vid.NoAudio;
        }
    }

    if(!backg){ // when background is missing in theme zip, fade anim and check in media background folder if background is present , otherwise use alternate
        backg = medias_path + fe.game_info(Info.System) + "/Images/Backgrounds/" + fe.game_info(Info.Name) + ".png";
        if(!file_exist(backg)) backg = "images/Backgrounds/Alt_Background.png";
        if( my_config["animated_backgrounds"] == "Yes" )
            background_transitions(31 , backg, hd);
        else
            background_transitions(99, backg, hd);
    }

    if(raw_xml == "") return; // if broken with no theme.xml inside zip

    foreach ( c in theme_node.children )
    {
        if(!availables.rawin( c.tag )) continue; // if xml tag not know continue
        local art = ""; local Xtag = c.tag;
        w=0,h=0,x=0,y=0,r=0,time=0,delay=0,overlayoffsetx=0,overlayoffsety=0,overlaybelow=false,below=false,forceaspect="none",type="none",start="none",rest="none";
        bsize=0,bsize2=0,bsize3=0,bcolor=0,bcolor2=0,bcolor3=0,bshape=false,anim_rotate=0,hd=false;

        foreach(k,v in theme_content){
            if(strip_ext(v.tolower()) == zippath.tolower() + Xtag.tolower()){
                availables[Xtag] = true;
                art = v
            }
        }

        foreach(k,v in c.attr){
            switch(k){
                case "w": w = ( v == "" ? 0 : v.tofloat() ); break;
                case "h": h = ( v == "" ? 0 : v.tofloat() ); break;
                case "x": x = ( v == "" ? 0 : v.tofloat() ); break;
                case "y": y = ( v == "" ? 0 : v.tofloat() ); break;
                case "r": r = ( v == "" ? 0 : v.tointeger() ); break;
                case "time": time = ( v == "" ? 0 : v.tofloat() * 1000 );  break;
                case "delay": delay = ( v == "" ? 0 : v.tofloat() * 1000 );  break;
                case "overlayoffsetx": overlayoffsetx =  ( v == "" ? 0 : v.tofloat() ); break;
                case "overlayoffsety": overlayoffsety = ( v == "" ? 0 : v.tofloat() ); break;
                case "overlaybelow": overlaybelow = (v == "true" ?  true : false );  break;
                case "below": below = (v == "true" ? true : false ); break;
                case "forceaspect": forceaspect = ( v == "" ? "none" : v ); break;
                case "type":  type = ( v != "" ? v.tolower() : "none" ); break;
                case "start": start = (v != "" ?  v : "none "); break;
                case "rest":  rest = (v != "" ? v : "none" ); break;
                case "bsize": bsize = (v != "" ? v.tointeger() : 0 ); break;
                case "bsize2": bsize2 = (v != "" ? v.tointeger() : 0 ); break;
                case "bsize3": bsize3 = (v != "" ? v.tointeger() : 0 ); break;
                case "bcolor": bcolor = (v != "" ? v.tointeger() : 0 ); break;
                case "bcolor2": bcolor2 = (v != "" ? v.tointeger() : 0 ); break;
                case "bcolor3": bcolor3 = (v != "" ? v.tointeger() : 0 ); break;
                case "bshape": bshape =  ( (v == "round" || v == "true") ? true : false ); break;
            }
        }

        if( Xtag == "artwork1" || Xtag == "artwork2" || Xtag == "artwork3" || Xtag == "artwork4" ){

            if( prev_def && availables[Xtag] ) continue;

            local xx=x, yy=y;
            if(availables[Xtag]){
                ArtObj[Xtag].file_name = name + "|" + art;
            }else{
                // get hs others medias artwork when they are not available in zip
                ArtObj[Xtag].file_name =  medias_path + fe.game_info(Info.System) + "/Images/" + Xtag + "/" + art + "/" + fe.game_info(Info.Name) + ".png";
            }

            if( w > 0 || h > 0 ){ // theme resize if width and height available
                ArtObj[Xtag].preserve_aspect_ratio = true; // keep aspect ratio
                if(ArtObj[Xtag].texture_width < ArtObj[Xtag].texture_height){ // portrait or landscape swap the 2
                   local www = w;
                   local hhh = h;
                   w = hhh;
                   h = www;
                }

                if( abs(r) < 180 || time <= 0 ){ // center rotation ,hyperspin anim rotation only if it's greater than 180 or -180
                    local mr = PI * r / 180;
                    x += cos( mr ) * (-w * 0.5) - sin( mr ) * (-h * 0.5) + w * 0.5;
                    y += sin( mr ) * (-w * 0.5) + cos( mr ) * (-h * 0.5) + h * 0.5;
                    ArtObj.snap.rotation = r;
                }else if( r != 0 ){
                    anim_rotate = r;
                }
                xx = (x - ( w * 0.5 ) );
                yy = (y - ( h * 0.5 ) );

                ArtObj[Xtag].set_pos( (xx * art_mul) + art_offset_x, (yy * art_mul_h) + art_offset_y, w * art_mul , h * art_mul_h);

            }else{ // no resize ( HS Default)

                if( abs(r) < 180 || time <= 0 ){ // center rotation ,hyperspin anim rotation only if it's greater than 180 or -180
                    local mr = PI * r / 180;
                    x += (cos( mr ) * (-ArtObj[Xtag].texture_width * 0.5) - sin( mr ) * (-ArtObj[Xtag].texture_height * 0.5) + ArtObj[Xtag].texture_width * 0.5);
                    y += (sin( mr ) * (-ArtObj[Xtag].texture_width * 0.5) + cos( mr ) * (-ArtObj[Xtag].texture_height * 0.5) + ArtObj[Xtag].texture_height * 0.5);
                    ArtObj[Xtag].rotation = r;
                }else if( r != 0 ){
                    anim_rotate = r;
                }

                xx = (x - ( ArtObj[Xtag].texture_width  * 0.5 ) );
                yy = (y - ( ArtObj[Xtag].texture_height * 0.5 ) );

                if( ext(art).tolower() == "swf"){
                   // try to fix swf  - arch rivals, asura blade, bombjack, ashura blaster, beast busters , gladiator, must understand before fixing
                    /*if (ArtObj[Xtag].texture_width >= 1024){
                        xx = 0;
                    }

                    if (ArtObj[Xtag].texture_height >= 768){
                        yy = 0;
                    }
                    */
                    if(x > fe.layout.width || y > fe.layout.height){
                        yy = 0;
                        xx = 0;
                    }

                    if(ArtObj[Xtag].texture_width == 1024){
                        //if (xx < 0) xx = 0;
                        xx = 0;
                    }

                    if(ArtObj[Xtag].texture_height == 768){
                       //if (yy < 0) yy = 0;
                        yy = 0;
                    }

                }

                ArtObj[Xtag].set_pos( (xx * art_mul) + art_offset_x, (yy * art_mul_h) + art_offset_y, ArtObj[Xtag].texture_width * art_mul, ArtObj[Xtag].texture_height * art_mul_h);
            }
       }else if( Xtag == "video" ){

            ArtObj.snap.file_name = ret_snap();
            ArtObj.snap.video_playing = false; // do not start playing snap now , wait delay from animation
            snap_is_playing = false;
            if(forceaspect == "none" || forceaspect == "vertical") h = w / 1.33; // both , horizontal ?
            local borderMax = 0;
            foreach(v in [bsize/2, bsize2, bsize3] ) if(v > borderMax) borderMax=v;

            if(availables["video"]){
                ArtObj["video"].file_name = name + "|" + art;
                video_shader.set_param("datas",true, overlaybelow);
            }else{
                video_shader.set_param("datas",false, overlaybelow);
                overlayoffsetx = 0; overlayoffsety = 0; // fix if theme contain offset and no frame video is present
            }

            video_shader.set_param("snap_coord", overlayoffsetx, overlayoffsety , w, h);

            if(borderMax > 0){
                if(bsize  > 0)video_shader.set_param("border1", bcolor,  bsize, bshape); // + rounded
                if(bsize2 > 0)video_shader.set_param("border2", bcolor2, bsize2, bshape);
                if(bsize3 > 0)video_shader.set_param("border3", bcolor3, bsize3, bshape);
                w = w + borderMax * 2;
                h = h + borderMax * 2;
            }

            local overlay_width = ArtObj[Xtag].texture_width;
            local overlay_height = ArtObj[Xtag].texture_height;
            // if no frame overlay available
            if(overlay_width  < w) overlay_width = w;
            if(overlay_height < h ) overlay_height = h;

            x =  (x + overlayoffsetx ) - ( overlay_width  * 0.5 );
            y =  (y + overlayoffsety ) - ( overlay_height * 0.5 );

            if( abs(r) < 180 || time <= 0 ){// center rotation hyperspin anime rotation only if it's greater 180 or lesser -180
                local mr = PI * r / 180;
                x += cos( mr ) * (-w * 0.5) - sin( mr ) * (-h * 0.5) + w * 0.5;
                y += sin( mr ) * (-w * 0.5) + cos( mr ) * (-h * 0.5) + h * 0.5;
                ArtObj.snap.rotation = r;
            }else if( r != 0 ){
                anim_rotate = r;
            }

            ArtObj.snap.set_pos(x  * art_mul + art_offset_x, y * art_mul_h + art_offset_y, overlay_width * art_mul, overlay_height * art_mul_h);
            if(below) ArtObj.artwork1.zorder = ArtObj.snap.zorder + 1;
            if(type == "fade") type = "video_fade";
        }

        if(Xtag !="video"){
            if(!prev_def || !availables[Xtag] ){
                local e = Xtag.slice( Xtag.len() - 1, Xtag.len() ).tointeger();
                anims[e-1].preset(type)
                anims[e-1].name(Xtag)
                anims[e-1].delay(delay)
                anims[e-1].duration(time)
                anims[e-1].starting(start)
                anims[e-1].rest(rest)
                anims[e-1].rotation(anim_rotate)
                anims[e-1].play();
            }
        }else{
            if(!prev_def ){
                anim_video.preset(type)
                anim_video.name(Xtag)
                anim_video.delay(delay)
                anim_video.duration(time)
                anim_video.starting(start)
                anim_video.rest(rest)
                anim_video.rotation(anim_rotate)
                anim_video.play();
            }else{
                ArtObj.snap.visible = false; // avoid clipping when game change in default theme
                anim_video.play();
            }
        }
    }
}

function clean_art(obj){
    ArtObj[obj].preserve_aspect_ratio = false;
    ArtObj[obj].set_pos(-1000,-1000,0.1,0.1);
    ArtObj[obj].file_name = "";
    ArtObj[obj].visible = false;
    ArtObj[obj].set_rgb(255,255,255);
    ArtObj[obj].rotation=0;
    ArtObj[obj].alpha=255;
    ArtObj[obj].skew_x=0;
    ArtObj[obj].skew_y=0;
    ArtObj[obj].pinch_x=0;
    ArtObj[obj].pinch_y=0;
    ArtObj[obj].subimg_y=0;
    ArtObj[obj].subimg_x=0;
    ArtObj[obj].origin_x=0;
    ArtObj[obj].origin_y=0;
}

function reset_art( bool = false ){ // true if default theme
    if(!bool){
        ArtObj.artwork1.zorder=-9;   //set zorder back to normal for hyperspin zorders switching
        ArtObj.snap.zorder=-7;

        // reset frame shaders
        anim_video_shader._param = null;
        video_shader.set_param("border1", 0, 0, false);
        video_shader.set_param("border2", 0, 0, false);
        video_shader.set_param("border3", 0, 0, false);
        video_shader.set_param("alpha", 1.0);
        video_shader.set_param("progress", 1.0);
        clean_art("snap");
        clean_art("video");
    }


    // reset all artwork shaders to no effect
    foreach(k,v in artwork_shader){
        if(!bool || !availables["artwork"+(k+1)]){
            v.set_param("datas",0,0,0,0);
            v.set_param("alpha",1.0);
        }
    }

    foreach(k,obj in ["artwork1", "artwork2", "artwork3", "artwork4"] ){
        if( !bool || !availables["artwork"+(k+1)] ) clean_art(obj);
    }

    ArtObj.snap.video_flags = Vid.Default; // enable snap sound

   if(curr_sys == "Main Menu")
       point.file_name = medias_path + "/Main Menu/Images/Other/Pointer.png";
    else
       point.file_name = medias_path + fe.game_info(Info.System) + "/Images/Other/Pointer.png";
}


// hide art animated
function hide_art(){
    local random = ["unzoom", "zoom", "fade out", "expl"];
     //--if default theme , we hide only artwork not availables in them zip
        foreach(a,b in ["artwork1", "artwork2", "artwork3", "artwork4"] ){
           if(curr_theme != "Default" || availables[b] == false ){
                anims[a].preset( random[ rndint(random.len()) ] )
                anims[a].on("stop",function(anim){
                    anim.opts.target.file_name = "";
                    anim.opts.target.visible = false;
                })
                anims[a].on("cancel",function(anim){
                    anim.opts.target.file_name = "";
                    anim.opts.target.visible = false;
                })
                .duration(glob_delay * 0.5)
                anims[a].play();
            }
        }
}


// Wheels
local wheel_count = 12;
local wheel_x = [ flw*0.94, flw*0.935, flw*0.896, flw*0.865, flw*0.84, flw*0.82, flw*0.78, flw*0.82, flw*0.84, flw*0.865, flw*0.896, flw*0.90, ];
local wheel_y = [ -flh*0.22, -flh*0.105, flh*0.0, flh*0.105, flh*0.215, flh*0.325, flh*0.436, flh*0.61, flh*0.72 flh*0.83, flh*0.935, flh*0.99, ];
local wheel_w = [ flw*0.15, flw*0.15, flw*0.15, flw*0.15, flw*0.15, flw*0.15, flw*0.22, flw*0.15, flw*0.15, flw*0.15, flw*0.15, flw*0.15, ];
local wheel_h = [  flh*0.10,  flh*0.10,  flh*0.10,  flh*0.10,  flh*0.10,  flh*0.10, flh*0.14,  flh*0.10,  flh*0.10,  flh*0.10,  flh*0.10,  flh*0.10, ];
local wheel_r = [  30,  25,  20,  15,  10,   5,   0, -10, -15, -20, -25, -30, ];
local wheel_a = [  255,  255,  255,  255,  255,  255,  255  ,  255,  255,  255,  255,  255, ];

if ( my_config["wheel_type"] == "Vertical Wheel") // Vertical wheel
{
    local wx = flw*0.88;
    local ww = flw*0.12;
    local wh = flh*0.075;
    wheel_x = [ wx, wx, wx, wx, wx, wx, wx, wx, wx, wx, wx, wx, ];
    wheel_y = [ -flh*0.22, -flh*0.105, flh*0.0, flh*0.105, flh*0.215, flh*0.325, flh*0.436, flh*0.61, flh*0.72 flh*0.83, flh*0.935, flh*0.99, ];
    wheel_w = [ ww, ww, ww, ww, ww, ww, ww, ww, ww, ww, ww, ww, ];
    wheel_h = [ wh, wh, wh, wh, wh, wh, wh, wh, wh, wh, wh, wh, ];
    wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
    wheel_a = [  255,  255, 255,  255,  255,  255,   255   ,  255,  255,  255,  255,  255, ];	
}

class WheelEntry extends ConveyorSlot
{
    constructor()
    {
        base.constructor( ::fe.add_image( "[!ret_wheel]" ) );
    }

    function on_progress( progress, var )
    {
        local p = progress / 0.1;
        local slot = p.tointeger();
        p -= slot;

        slot++;

        if ( slot < 0 ) slot=0;
        if ( slot >=10 ) slot=10;

        m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
        m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
        m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
        m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
        m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
        m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
    }
}

local wheel_entries = [];
for ( local i=0; i<wheel_count/2; i++ )
    wheel_entries.push( WheelEntry() );

local remaining = wheel_count - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
    wheel_entries.insert( wheel_count * 0.5, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
conveyor.m_objs[6].visible = false; // hide totally center wheel (repaced by center_wheel obj)

function conveyor_tick( ttime )
{
    local alpha;
    local delay = 1100; local fade_time = 1000;
    local from = 255; local to = 0;
    local elapsed = glob_time - rtime;
    if ( !conveyor_bool && elapsed > delay && curr_sys != "Main Menu") {
        alpha = (from * (fade_time - elapsed + delay)) / fade_time;
        local count = conveyor.m_objs.len();
        for (local i=0; i < count; i++) conveyor.m_objs[i].alpha=alpha;
        if(alpha <= to) conveyor_bool = true;
    }
}
fe.add_ticks_callback( "conveyor_tick" );

/* OVERLAY SCREEN */

local custom_overlay = fe.add_surface(flw, flh);
custom_overlay.visible = false;
local overlay_background = custom_overlay.add_image("",0, 0, flw, flh);

local overlay_anim = PresetAnimation(custom_overlay)
.auto(true)
.key("alpha").from(0).to(255)
.on("stop", function(anim){
    if(anim.opts.target.alpha == 0) anim.opts.target.visible = false;
})
.duration(600)

// overlay list
local overlay_list = custom_overlay.add_listbox(flw*0.369, flh*0.361 , flw*0.260, flh*0.370);
overlay_list.font = "SF Slapstick Comic Bold Oblique";
overlay_list.align = Align.Centre;
overlay_list.selbg_alpha = 0;
overlay_list.set_sel_rgb( 255, 0, 0 );

local overlay_title = custom_overlay.add_text("", flw*0.346, flh*0.324, flw*0.312, flh*0.046);
overlay_title.font = "College Halo";
overlay_title.charsize = flw*0.018;
overlay_title.set_rgb(192, 192, 192);
local exit_overlay = fe.overlay.set_custom_controls( overlay_title, overlay_list );

local wheel_art = custom_overlay.add_image( "[!ret_wheel]", flw*0.425, flh*0.192, flw*0.156, flh*0.138);
wheel_art.visible = false;

/*
search_surface <- fe.add_surface(800, 1080);
//search_surface.set_pos(850,0);
local search = KeyboardSearch( search_surface )
.search_key( "custom1" )
.mode( "next_match" ) // or  show_results
.text_font("SF Slapstick Comic Bold Oblique")
.init()
//.bg_color()
//.keys_pos()
//.keys_color()
//.keys_selected_color()
//.text_pos()
//.text_color()

/*search_surface_anim <- PresetAnimation(search_surface)
.auto(false)
.from({x=search_surface.x, alpha=0})
.to({x=0, alpha=255})
.reverse(false)
.duration(1050)
*/

// Start game sounds transition callback
fe.add_transition_callback( "game_in_out" );
function game_in_out( ttype, var, ttime ) {
    switch ( ttype ) {
        case Transition.ToGame:
            Game_In_Out.file_name = get_random_file( fe.script_dir + "sounds/game_start" );
            Game_In_Out.playing = true;
        break;
    }
    return false;
}

//
// Global Transition
//
local prev_tr = 0;

fe.add_transition_callback( "hs_transition" );
function hs_transition( ttype, var, ttime )
{
    //print("\nTransitions= "+debug_array[ttype]+" var="+var+"\n")
    switch ( ttype )
    {
        case Transition.FromGame:
            conveyor_bool = true; // do not restore alpha on conveyor
            if ( ttime < 500  ) {
                global_fade(ttime, 500, true)
                return true;
            }
        break;

        case Transition.ToGame:
            if ( ttime < 1500  ) {
                global_fade(ttime, 1500, false)
                return true;
            }
        break;

        case Transition.NewSelOverlay: // 10
            FE_Sound_Screen_Click.playing = true;
        break;

        case Transition.ToNewSelection: //2
            ArtObj.snap.video_flags = Vid.NoAudio;
            Background_Music.playing = false;
            Background_Music.file_name = "";
            ArtObj.snap.file_name = "";

            if(glob_time - rtime > 150){
                hide_art(); // 150ms between re-pooling hide_art when navigating fast in wheel (change !!)
            }
            rtime = glob_time;
            conveyor_bool = false; // reset conveyor fade
            flv_transitions.visible = false;
            flv_transitions.file_name = "";
        break;

        case Transition.EndNavigation: //7
            trigger_load_theme = true;
            // check if systeme have custom wheel sounds , if not, use main menu wheel sounds like in HS !
            local wsound = get_random_file( medias_path + curr_sys + "/Sound/Wheel Sounds");
            if( wsound != "" ) Sound_Wheel.file_name = wsound; else Sound_Wheel.file_name = get_random_file( medias_path + "Main Menu/Sound/Wheel Sounds");
            Sound_Wheel.playing = true;
        break;

        case Transition.StartLayout: //0
            surf_ginfos.visible = false;
            if( !glob_time ){  // glob_time == 0 on first start layout
                if( ttime <= 255 && fe.list.name == my_config["list_name"] ){ global_fade(ttime, 255, true); return true; } // fade when back to display menu or start layout
                //Sound -  cause we are back to main menu we use name to match the systeme we're leaving.
                Sound_System_In_Out.file_name = get_random_file( medias_path + fe.game_info(Info.Name) + "/Sound/System Exit/" );
                Sound_System_In_Out.playing = true;
                FE_Sound_Wheel_Out.playing = true;
            }
        break;

        case Transition.ToNewList: //6
            curr_sys = ( fe.game_info(Info.Emulator) == "@" ? "Main Menu" : fe.game_info(Info.System) );

            if(curr_sys != "Main Menu"){ // conveyor don't fade on main menu
                local count = conveyor.m_objs.len();
                for (local i=0; i < count; i++) conveyor.m_objs[i].alpha=0;
                conveyor_bool = true;
                center_Wheel_fade.play();
            }

            if( glob_time ){  // when glob_time > 0 not startlayout
                local es = get_random_file( medias_path + curr_sys + "/Sound/System Start/" );
                if( es != "" ){ // if exit sound exist for this system
                    Sound_System_In_Out.file_name = es;
                    Sound_System_In_Out.playing = true;
                }
                FE_Sound_Wheel_In.playing = true; // when glob_time > 0
            }

            rtime = glob_time
            trigger_load_theme = true;
        break;

        /* Custom Overlays */
        case Transition.ShowOverlay: // var = Custom, Exit(22), Displays, Filters(15), Tags(31), Favorites(28)
            FE_Sound_Screen_In.playing = true;

            switch(var) {

                case Overlay.Filters: // = 15 Filters
                    overlay_background.file_name = "images/filters_overlay.png"; // 600 x 675
                    overlay_background.set_pos(flw*0.343, flh*0.187, flw*0.312, flh*0.625);
                    overlay_background.alpha = 250;
                    overlay_list.rows = 7;
                    overlay_list.charsize = flw*0.017;
                    wheel_art.visible = false;
                    //overlay_title.msg = "Filtres";
                break;

                case Overlay.Tags: //31 Tags
                    overlay_background.file_name = "images/tags_overlay.png";
                    overlay_background.set_pos(flw*0.312, flh*0.092, flw*0.385, flh*0.740);
                    overlay_background.alpha = 250;
                    overlay_list.rows = 7;
                    overlay_list.charsize = flw*0.017;
                    wheel_art.visible = true;
                break;

                case 28: //28  favorites
                    overlay_background.file_name = "images/favorites_overlay.png";
                    overlay_background.set_pos(flw*0.312, flh*0.092, flw*0.385, flh*0.740);
                    overlay_background.alpha = 250;
                    overlay_list.rows = 5;
                    overlay_list.charsize = flw*0.032;
                    wheel_art.visible = true;
                break;

                case Overlay.Exit: // = 22
                    ArtObj.snap.video_flags = Vid.NoAudio; // stop snap sound on exit screen show (AM cannot pause video ?)
                    overlay_background.file_name = medias_path + "Frontend/Images/Menu_Exit_Background.png";
                    overlay_background.set_pos(0,0,flw, flh);
                    overlay_list.rows = 3;
                    overlay_list.charsize  = flw*0.052;
                    overlay_title.msg = "";
                    wheel_art.visible = false;
                break;
            }

            custom_overlay.visible = true;
            overlay_anim.reverse(false).play();
            overlay_list.visible = true;
        break;

        case Transition.HideOverlay:
            FE_Sound_Screen_Out.playing = true;
            overlay_anim.reverse(true).play();
            overlay_list.visible = false;
            ArtObj.snap.video_flags = Vid.Default; // enable snap sound on exit (AM cannot pause video ?)
        break;
    }

    if( prev_tr!=ttype )prev_tr = ttype;
}


//
// Ticks
//

fe.add_ticks_callback( "hs_tick" );
function hs_tick( ttime )
{
    glob_time=ttime;
    // give all artwork and video visible after x ms next to triggerload
    if( (glob_time - rtime > glob_delay + 150) && visi == false){
        foreach(obj in ["artwork1", "artwork2", "artwork3", "artwork4", "video", "snap"] ) ArtObj[obj].visible = true;
        visi = true;
    }
    if(!snap_is_playing && anim_video.elapsed > anim_video.opts.delay ){ // start playing video snap after animation delay
        ArtObj.snap.video_playing = true;
        snap_is_playing = true;
    }

    // load medias after glob_delay
    if( (glob_time - rtime > glob_delay) && trigger_load_theme){

        if( my_config["Bezels"] == "Yes" && my_config["Aspect"] == "Center" ){ // Systems bezels!  only if aspect center
            if( file_exist(fe.script_dir + "images/Bezels/" + curr_sys + ".png") ){
                ArtObj.bezel.file_name = fe.script_dir + "images/Bezels/" + curr_sys + ".png";
            }else{
                if( ( my_config["Background_Stretch"] == "Main Menu" && curr_sys != "Main Menu" ) || my_config["Background_Stretch"] == "No" )
                    ArtObj.bezel.file_name = fe.script_dir + "images/Bezels/Bezel_Main.png";
            }
        }

        overview(0); // start checking for games overview
        start_background.visible = false;
        letters.visible = false; // hide letter search if present
        path = medias_path + fe.game_info(Info.System) + "/Themes/";
        if(curr_sys == "Main Menu") path = medias_path + "Main Menu/Themes/";
        path+=fe.game_info(Info.Name) + ".zip";
        local theme_content = zip_get_dir( path );

        // load transitions override video if enabled and not in default system theme browsing
        if ( my_config["override_transitions"] == "Yes" &&
           ( theme_content.len() || (!theme_content.len() && curr_theme != "Default") ) )
        {
            local flv_folder = medias_path + curr_sys + "/Video/Override Transitions/";
            if( file_exist( flv_folder + fe.game_info(Info.Name) + ".flv" ) ){ // if transition exist for this game
                flv_transitions.file_name = flv_folder + fe.game_info(Info.Name) + ".flv";
            }else if( file_exist( flv_folder + fe.game_info(Info.Category) + ".flv" ) ){ // if transitions exist for this game category
               flv_transitions.file_name = flv_folder + fe.game_info(Info.Category) + ".flv"
            }else{ // else choose random transition from front-end folder
                if( tr_directory_cache.len() > 0 ) flv_transitions.file_name = get_random_table(tr_directory_cache);
            }
            flv_transitions.visible = true;
        }

        // if no theme is found assume it's system default theme.
        if( !theme_content.len() ) {
            path = medias_path + fe.game_info(Info.System) + "/Themes/Default.zip";
            theme_content = zip_get_dir( path );
            if(curr_theme == "Default"){ //curr_theme = previous theme here
                reset_art(true);
                load_theme(path, theme_content, true);
               foreach(a,b in ["artwork1", "artwork2", "artwork3", "artwork4"] ) if( availables[b] == false ) anims[a].restart();
            }else{
                reset_art();
                load_theme(path, theme_content, false);
            }

            curr_theme = "";//( must be empty for unifified video theme )
            if( theme_content.len() ) curr_theme = "Default"; // if content's empty , it's not a default theme (necessary for unfified video theme)

        }else{
            reset_art();
            curr_theme = path;
            load_theme(path, theme_content, false);
        }

        surf_ginfos.visible = ( curr_sys == "Main Menu" ? false : true ); // Game infos surface

        trigger_load_theme = false;
        visi = false;
    }

    // hide flv transition video when finished
    if ( flv_transitions.visible && !flv_transitions.video_playing )
    {
        flv_transitions.visible = false;
        flv_transitions.file_name = "";
    }

    if(trigger_letter == true){
        local firstl = fe.game_info(Info.Title);
        letters.file_name = medias_path + fe.game_info(Info.System) + "/Images/Letters/" + firstl.slice(0,1) + ".png";
        FE_Sound_Letter_Click.playing = true;
        trigger_letter = false;
    }
}

local last_click = 0;
fe.add_signal_handler(this, "on_signal")
function on_signal(str) {
    //print("\n SIGNAL = "+str+ " - "+ last_click +"\n")
    //if(fe.overlay.is_up){
    if(curr_sys == "Main Menu"){ //disable some buttons on main-menu
       	switch ( str )	
        {
            case "custom1":
            case "add_favourite":
            case "add_tags":
            case "prev_favourite":
            case "next_favourite":
            case "prev_filter":
            case "next_filter":
            case "next_letter":
            case "prev_letter":
            case "filters_menu":
            return true;
        }
    }
    //}else{
        switch( str ) {
            case "prev_page":
            case "next_page":
                FE_Sound_Wheel_Jump.playing = true;
            break;

            case "next_game":
            case "prev_game":
                if( glob_time - last_click  > 160 ) Sound_Click.playing = true; // need better key hold detection
                last_click = glob_time;
            break;

            case "next_letter":
            case "prev_letter":
                trigger_letter = true;
                letters.visible = true;
            break;
        }
    //}

    return false
}



// Apply a global fade on objs and shaders
function global_fade(ttime, target, direction){
   ttime = ttime.tofloat();
   local objlist = [center_wheel, surf_ginfos, point, syno.surface]; // objects list to fade (flv_transitions ?)
   if(direction){ // show
        foreach(obj in objlist) obj.alpha = ttime * (255.0 / target);
        video_shader.set_param("alpha", (ttime / target) );
        foreach(k, obj in ["artwork1", "artwork2", "artwork3", "artwork4"] ) artwork_shader[k].set_param("alpha", (ttime / target) );
        Trans_shader.set_param("alpha", ttime / 500);
   }else{ // hide
        foreach(obj in objlist) obj.alpha = 255.0 - ttime * (255.0 / target);
        video_shader.set_param("alpha", 1.0 - (ttime / target) );
        foreach(k, obj in ["artwork1", "artwork2", "artwork3", "artwork4"] ) artwork_shader[k].set_param("alpha", 1.0 - (ttime / target) );
        Trans_shader.set_param("alpha",1.0 - (ttime / target) );
        for (local i=0; i < conveyor.m_objs.len(); i++) conveyor.m_objs[i].alpha = 0;
   }
   return;
}
