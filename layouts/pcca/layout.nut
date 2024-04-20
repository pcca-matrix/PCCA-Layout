/////////////////////////////////////////////////////////////////////
//
// PCCA v2.94
// Use with Attract-Mode Front-End  http://attractmode.org/
//
// This program comes with NO WARRANTY.  It is licensed under
// the terms of the GNU General Public License, version 3 or later.
//
// PCCA-Matrix 2024
//
////////////////////////////////////////////////////////////////////
local start = clock();
local M_order = 0;
class UserConfig {
    </ label="Special Artwork", help="Enable or disable the special artwork (if No, special is disabled globally)", options="Yes, No", order=M_order++ /> special_artworks = "Yes"
    </ label="Screensaver Timer", help="Amount of time in secs to wait before starting the screensaver. (0 to disable)", options="", order=M_order++ /> screen_saver_timer="55"
    </ label="Extra Artworks Key", help="Choose the key to initiate extra artworks overlay", options="custom1,custom2,custom3,custom4,custom5,custom6,none", order=M_order++ />extra_artworks_key="custom2";
    </ label="Settings/Edit Key", help="Choose the key to initiate settings/edit function(HyperTheme Like)", options="custom1,custom2,custom3,custom4,custom5,custom6,none", order=M_order++ />main_menu_key="custom4";
    </ label="Gamepad library", help="Choose the gamedpad library to use for the edit theme function", options="Xinput,Dinput", order=M_order++ />JoyType="Dinput";
    </ label="HD theme resolution", help="Choose the resolution you want when creating new theme ex : (1920x1080)", options="", order=M_order++ />theme_resolution="1920x1080";
    </ label="Media Path", help="Path of HyperSpin media, if empty, media is considered inside layout folder", options="", order=M_order++ /> medias_path=""
    </ label="Low GPU", help="'Yes' = Low GPU (Intel HD,.. less backgrounds transition), 'No' = Recent GPU", options="Yes, No", order=M_order++ /> LowGPU="No"
    </ label="Interface Language", help="Preferred User Language", options="Fr, En, Es", order=M_order++ /> user_lang="En"
    </ label="Global Stats", help="Enable or disable the main menu stats system", options="Yes, No", order=M_order++ /> stats_main = "Yes"
    </ label="Search Key", help="Choose the key to initiate a search", options="custom1,custom2,custom3,custom4,custom5,custom6,none", order=M_order++ />keyboard_search_key="custom1";
    </ label="Help Key", help="Choose the key to initiate the help screen", options="custom1,custom2,custom3,custom4,custom5,custom6,none", order=M_order++ />help_screen_key="custom3";
    </ label="Search Results", help="Choose the search method", options="show_results,next_match", order=M_order++ />keyboard_search_method="show_results";
    </ label="Keyboard Layout", help="Choose the keyboard layout", options="qwerty,azerty,alpha", order=M_order++ />keyboard_layout="alpha";
    </ label="--- Custom Romlists ---", help="", options="", order=M_order++ />mt1=""
    </ label="Recently Played", help="Enable recently played romlist", options="Yes, No", order=M_order++ />Recent_Enabled="Yes";
    </ label="Numbers of recent games", help="How many recently played game should be displayed", options="25, 50, 100", order=M_order++ />Recent_Entry="25";
    </ label="Most Played", help="Enable recently played romlist", options="Yes, No", order=M_order++ />Most_Played_Enabled="Yes";
    </ label="Numbers of most played games", help="How many most played game should be displayed", options="25, 50, 100", order=M_order++ />Most_Played_Entry="25";
    </ label="Global Favourites", help="Enable global favourites romlist", options="Yes, No", order=M_order++ />Global_Favourites_Enabled="Yes";
    </ label="All Games romlist", help="Enable the All Games romlist", options="Yes, No", order=M_order++ />All_Games_Enabled="Yes";
    </ label="--- Attract-Mode ---", help="", options="", order=M_order++ />mt1=""
    </ label="Enabled", help="Enable attract-mode", options="Yes, No", order=M_order++ />AM_Enabled="Yes";
    </ label="Wait Video", help="Wait end of video before starting attract-mode", options="Yes, No", order=M_order++ />AM_WaitVideo="Yes";
    </ label="Max Spin Time", help="Spin for a random amount of time between 3 secs and max spin time", options="", order=M_order++ />AM_MaxSpinTime="5";
    </ label="Wait Time", help="Time to wait before Attract-Mode starts", options="", order=M_order++ />AM_AttractTime="80";
    </ label="All Systems", help="Random in all systems", options="Yes, No", order=M_order++ />AM_all_systems="Yes";
    </ label="Loop by system", help="How many random loop by system", options="", order=M_order++ />AM_system_loop="3";
    </ label="--- Scraper ---", help="", options="", order=M_order++ />mt2=""
    </ label="Scraper User name", help="PCCA Scraper user name", options="", order=M_order++ />scraper_username="test";
    </ label="Scraper password", help="PCCA Scraper password", options="", order=M_order++ />scraper_password="test";
    </ label="Scraper Region", help="PCCA Scraper prefered region", options="", order=M_order++ />scraper_region="Europe";
    </ label="Scraper Country", help="PCCA Scraper prefered country", options="", order=M_order++ />scraper_country="France";
    </ label="Scraper Language", help="PCCA Scraper prefered language", options="", order=M_order++ />scraper_region="Fr";
}

my_config <- fe.get_config();
globs <- {"delay" : 500, "signal":"default_sig", "keyhold":-1, "hold":null, "Stimer":fe.layout.time, "script_dir":fe.script_dir, "config_dir":FeConfigDirectory,
"custom_romlists":["Recent","Favourites","Most Played","All Games"], "customs_romlist_tb":{}, "next_tick_functions":[] }; // super globals temp vars

kiosk <- {"enabled":false, "add_fav":true, "add_tags":true, "menu":true, "exit":true};
try{kiosk.add_fav = fe.nv["kiosk_add_fav"] }catch(e){}
try{kiosk.add_tags = fe.nv["kiosk_add_tags"] }catch(e){}
try{kiosk.exit = fe.nv["kiosk_exit"] }catch(e){}

local TOGame = false;  // temp fix bug in AM  https://github.com/mickelson/attract/issues/747
local wheel_wait = false;

triggers <- {
    "flv_transition":{
        "start": false,
        "delay": 400
    },
    "wheel_anim":{
        "start" : false,
        "delay" :0
    },
    "theme":{
        "start" : false
    },
    "letter":{
        "start": false,
        "delay" : 5
    },
    "background_anim":{
        "start": false,
        "delay" : 0
    },
    "background_music":{
        "start": false,
        "delay" : 2500
    }
}

function replace(string, original, replacement) {
    local str = string.find(original);
    while (str != null) {
        string = string.slice(0, str) + replacement + string.slice(str + original.len());
        str = string.find(original);
    }
    return string;
}

medias_path <- ( my_config["medias_path"] != "" ? my_config["medias_path"] : globs.script_dir + "Media" );
if ( medias_path.len()-1 != '/' ) medias_path += "/";
medias_path = replace(medias_path, "\\", "/")
globs.script_dir = replace(fe.path_expand(globs.script_dir), "\\", "/")
globs.config_dir = replace(fe.path_expand(globs.config_dir), "\\", "/")

// check if it's am or am+ (thanks zpaolo11x)
AMPlus <- true;
try{fe.add_rectangle(0,0,10,10)}
catch(err){
    AMPlus <- false;
}

//-- controls (here you can change control type according your needs)
controls <- {};
controls.Right <- ["Joy0 Right", "Right"];
controls.Left  <- ["Joy0 Left", "Left"];
controls.Up    <- ["Joy0 Up", "Up"];
controls.Down  <- ["Joy0 Down", "Down"];
controls.HC    <- ["Joy0 Button5", "H"]; // horizontal center
controls.VC    <- ["Joy0 Button4", "V"]; // vertical center
if( my_config["JoyType"]  == "Dinput"){
    controls.C     <- ["Joy0 Button7", "Add"];
    controls.CW    <- ["Joy0 Button6", "Subtract"];
    controls.ZWP   <- ["Joy0 Zpos", "Numpad7"];
    controls.ZWM   <- ["Joy0 Zneg", "Numpad9"];
    controls.ZHP   <- ["Joy0 Rneg", "Numpad1"];
    controls.ZHM   <- ["Joy0 Rpos", "Numpad3"];
}else{
    controls.C     <- ["Joy0 Zneg", "Add"];
    controls.CW    <- ["Joy0 Zpos", "Subtract"];
    controls.ZWP   <- ["Joy0 Upos", "Numpad7"];
    controls.ZWM   <- ["Joy0 Uneg", "Numpad9"];
    controls.ZHP   <- ["Joy0 Vneg", "Numpad1"];
    controls.ZHM   <- ["Joy0 Vpos", "Numpad3"];
}

//fe.image_cache.bg_load = true
flw <- fe.layout.width.tofloat();
flh <- fe.layout.height.tofloat();

fe.layout.font = "ArialCEMTBlack.ttf";

surf_ginfos <- fe.add_surface(flw, flh*0.25);
surf_ginfos.visible = false;

local start_background = fe.add_image("images/Backgrounds/Background.jpg",0,0,flw,flh);
local fades = fe.add_image("images/Backgrounds/Black.png",0,0,flw,flh);
fades.zorder = 90;
fades.visible = false;
fades.alpha = 0;

test <- fe.add_text("",100,500,1000,25);// DEBUG
test.set_rgb( 255, 255, 255 );
test.zorder = 0

// HS default ratio
local nw = flh * 1.333;
mul <- nw / 1024;
mul_h <- mul;
offset_x <- 0;
offset_y <- 0;

// Modules
fe.do_nut("nut/func.nut");
fe.load_module("hs-animate");
fe.do_nut("nut/keyboard-search/module.nut");
fe.do_nut("nut/class.nut");
fe.load_module("file");
fe.load_module("file-format");
fe.do_nut("nut/lang.nut");

// replace classe method in XMLNode file-format
function XMLNode::nodeToString( node )
{
    local str = nodeDepth( node ) + "<" + node.tag;
    local attrNames = [];
    foreach (name, val in node.attr) {
        attrNames.append(name);
    }
    attrNames.sort();

    local currentLineLength = str.len();
    local lineWidth = 120;
    local jump = false;
    foreach (attrName in attrNames) {
        local val = node.attr[attrName];
        local attrStr = " " + attrName + "=\"" + val + "\"";
        if (currentLineLength + attrStr.len() > lineWidth) {
            jump = true;
            str += "\n" + nodeDepth(node) + "   ";
            currentLineLength = nodeDepth(node).len() + 4;
        }

        str += attrStr;
        currentLineLength += attrStr.len();
    }

    if ( node.text == "" && node.children.len() == 0)
    {
        //no end tag
        if(jump){
            str+="\n    />\n";
        }else{
            str += " />\n";
        }
    } else
    {
        //show text and/or child nodes
        str += ">\n";;
        str += node.text;
        foreach( child in node.children )
        {
            str += nodeToString( child );
        }
        str += nodeDepth( node ) + "</" + node.tag + ">\n";
    }
    return str;
};
if(file_exist(globs.script_dir + "kiosk")) kiosk.enabled = true; // set kiosk mode

LnG <- _LL[ my_config["user_lang"] ];
prev_back <- { ox = 0, oy = 0, bw = flw, bh = flh }; // previous background table infos ( transitions )

// overlay_surf
overlay_surf <- fe.add_surface(flw, flh);
overlay_surf.zorder = 99;
overlay_surf.visible = false;
top_left_ico <- overlay_surf.add_text("",flw*0.015,flh*0.022,0,0);
top_right_ico <- overlay_surf.add_text( "",flw,flh*0.018,0,0);
bottom_left_ico <- overlay_surf.add_text( "",flw*0.015,flh*0.96,0,0);
bottom_right_ico <- overlay_surf.add_text( "",flw,flh*0.96,0,0);
ctrl_icons <- [top_left_ico,top_right_ico,bottom_left_ico,bottom_right_ico];
foreach(a in ctrl_icons){
    a.zorder = 99
    a.font = "fontello.ttf"
    a.charsize = flh*0.04
    a.set_bg_rgb(255,200,200)
    a.align = Align.Right;
}
top_left_ico.align = Align.Left;
bottom_left_ico.align = Align.Left;

// overlay helper (screen center)
img_overlay <- overlay_surf.add_image("");
text_overlay <- overlay_surf.add_text("",0,0,0,0);
text_overlay.set_pos(0, (flh * 0.5) - flh * 0.02 , flw, 0);
text_overlay.charsize = flh * 0.08;
text_overlay.set_rgb( 220, 220, 220 );
text_overlay.alpha = 230;
text_overlay.zorder = 10;

local overlay_surf_anim = PresetAnimation(overlay_surf)
.key("alpha").from(0).to(255)
.on("stop", function(anim){
    if(anim.opts.target.alpha == 0){
        anim.opts.target.visible = false;
        foreach(v in [top_left_ico,top_right_ico,bottom_left_ico,bottom_right_ico]) v.visible = false;
    }
})
.duration(500)

// Globals
local tr_directory_cache  = get_dir_lists( medias_path + "Frontend/Video/Transitions" ); // cached table of global transitions files

Ini_settings <- get_ini_values("Main Menu"); // initialize and set settings ini value for main menu

xml_root <- [];
path <- "";
curr_sys <- "";
curr_emulator <- "";

ArtObj <- {};
snap_is_playing <- false;
local artwork_list = ["artwork1", "artwork2", "artwork3", "artwork4", "artwork5", "artwork6"]; //  artworks list for the theme
local artwork_list_full = clone(artwork_list);
artwork_list_full.push("video"); // full artwork_list must contain video (frame)

availables <- {}
foreach(a,b in artwork_list_full) availables[b] <- false;

local curr_theme = "";
local prev_path = "";
local glob_time = 0;
local rtime = 0;
local reverse = 0;
local visi = false;
local letters = fe.add_image("");
letters.set_pos(flw * 0.5 - (flw*0.140 * 0.5), flh * 0.5 - (flh*0.280 * 0.5), flw*0.140, flh*0.280);

pcca_wheel <- PCCA_Conveyor();
wheel_surf <- pcca_wheel.surface;
wheel_surf.visible = false;

point <- fe.add_image("");
point.alpha = 255;

point_animation <- PresetAnimation(point)
.name("pointer")
.from({x=flw,y=flh,rotation=0})
.to({x=0,y=0,rotation=0})
.duration( 150 )
.yoyo()

wheel_animation <- PresetAnimation(wheel_surf)
.name("wheel")
.preset("ease")
.starting("right")

surf_ginfos_animation <- PresetAnimation(surf_ginfos)
.name("surf_ginfos")
.preset("ease")

hd <- true; // global bool for hd or hs theme

// Background / Bezel
ArtObj.background <- fe.add_image("", 0, 0, flw, flh);
ArtObj.background.file_name = "images/Backgrounds/Black.png";
ArtObj.background1 <- fe.add_image( (AMPlus ? "" : "images/init.swf"),-2000,-2000,0.1,0.1); // needed for initialising SWF  ?, without can't use any surface overlay when swf is displayed (AM BUG) !
ArtObj.background2 <- fe.add_image("",-2000,-2000,0.1,0.1);
ArtObj.background1.visible = false;
ArtObj.background2.visible = false;
ArtObj.bezel <- fe.add_image("",0,0,flw,flh);
ArtObj.bezel.visible = false;

background_anim <- PresetAnimation(ArtObj.background)
.name("bck_anim")
.preset("none")
.delay(0)
.rest("none")
background_anim.play()

// create all artworks img obj
foreach(a,b in artwork_list_full) ArtObj[b] <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.snap <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.snap.mipmap = true;
// Override Transitions Videos
local flv_transitions = fe.add_image("",0,0,flw,flh);
flv_transitions.video_flags = Vid.NoLoop;

// Z-orders
ArtObj.artwork1.zorder = -8
ArtObj.artwork2.zorder = -4
ArtObj.artwork3.zorder = -3
ArtObj.artwork4.zorder = -2
ArtObj.artwork5.zorder = -9
ArtObj.artwork6.zorder = -9
ArtObj.snap.zorder = -7
ArtObj.bezel.zorder = -1
ArtObj.background.zorder = -10
flv_transitions.zorder = 0
start_background.zorder = -11
surf_ginfos.zorder = 1
wheel_surf.zorder = 0

// Artworks Shaders and Animations
artwork_shader <- [];
anims_shader <- [];
anims <- [];
foreach(k,v in artwork_list ){
    artwork_shader.push( fe.add_shader( Shader.VertexAndFragment, "shaders/main.vert", "shaders/artworks.frag" ) );
    ArtObj[v].mipmap = true;
    ArtObj[v].shader = artwork_shader[k];
    anims_shader.push( ShaderAnimation( artwork_shader[k] ) );
    anims.push( PresetAnimation(ArtObj[v]).name(v));
}

foreach(k,v in artwork_shader){
    v.set_texture_param("Tex0");
    v.set_param("datas",0,0,0,0);
}

foreach(k,v in anims_shader){
    v.name("artwork" + (k+1) );
    v.param("progress");
    v.from([0.0]);
    v.to([1.0]);
}

// video Shaders and Animations
video_shader <- fe.add_shader( Shader.Fragment, "shaders/vframe.frag" );
ArtObj.snap.shader = video_shader;
video_shader.set_texture_param("tex_f", ArtObj.video);
video_shader.set_texture_param("tex_s", ArtObj.snap);
local scanline = fe.add_image("images/scanline-640.png",-1000,-1000,0.1,0.1);
scanline.visible = false;
video_shader.set_texture_param("tex_crt", scanline);
anim_video_shader <- ShaderAnimation( video_shader ).name("video_shader");
anim_video <- PresetAnimation(ArtObj.snap).name("video");

if( my_config["LowGPU"] == "Yes" ) Trans_shader <- fe.add_shader( Shader.Fragment, "shaders/effect_low_gpu.frag" ); else Trans_shader <- fe.add_shader( Shader.Fragment, "shaders/effect.frag" );

ArtObj.background.shader = Trans_shader;

Trans_shader.set_texture_param("back1", ArtObj.background1);
Trans_shader.set_texture_param("back2", ArtObj.background2);
Trans_shader.set_texture_param("bezel", ArtObj.bezel);

local bck_anim = ShaderAnimation(Trans_shader);
bck_anim.param("progress")
bck_anim.duration(globs.delay * 1.40)
bck_anim.delay(0)

// Special Artworks
ArtObj.SpecialA <- fe.add_image("", -1000, -1000, 0, 0);
ArtObj.SpecialB <- fe.add_image("", -1000, -1000, 0, 0);
ArtObj.SpecialC <- fe.add_image("", -1000, -1000, 0, 0);

ArtObj.SpecialA.shader = fe.add_shader( Shader.Fragment, "shaders/special.frag");
ArtObj.SpecialB.shader = fe.add_shader( Shader.Fragment, "shaders/special.frag");
ArtObj.SpecialC.shader = fe.add_shader( Shader.Fragment, "shaders/special.frag");

anim_special <- [];
anim_special.push( PresetAnimation(ArtObj.SpecialA) );
anim_special.push( PresetAnimation(ArtObj.SpecialB) );
anim_special.push( PresetAnimation(ArtObj.SpecialC) );

function load_special(hide=true){
    local list = ["A","B","C"];
    foreach( i,n in list ){
        anim_special[i].reset();
        ArtObj["Special" + n].file_name = "";
    }

    foreach( i,n in ["a","b","c"] ){
        local S_Art = clone(Ini_settings["special art " + n]);
        S_Art["lst"] <- [];
        S_Art["syst"] = curr_sys;
        S_Art["in"] = S_Art["in"] * 1000;
        S_Art["out"] = S_Art["out"] * 1000;
        S_Art["delay"] = (S_Art["delay"] * 1000 < 100 ? 100 : S_Art["delay"] * 1000 );
        S_Art["length"] = S_Art["length"] * 1000;
        S_Art["w"] = S_Art["w"] * flw;
        S_Art["h"] = S_Art["h"] * flh;
        S_Art["cnt"] = S_Art["cnt"];
        S_Art["type"] = ( S_Art["type"] == "normal" ?  "linear" : S_Art["type"] );

        if( !S_Art["active"] ) continue;
        n = n.toupper();
        if( S_Art["default"] ) S_Art["syst"] = "Frontend"; // use Global systeme special artwork ( only if no artwork is found inside sys folder)

        local lst = zip_get_dir( medias_path + S_Art["syst"] + "/Images/Special" );

        foreach( v in lst ){
            if( ["png","swf","jpg","mp4","gif","flv"].find( ext(v) ) != null ){
                if( v.find("Special" + n) != null ) S_Art["lst"].push(v);
            }
        }

        if(!S_Art["lst"].len() ) continue;

        ArtObj["Special" + n].file_name = medias_path + S_Art["syst"] + "/Images/Special/" + S_Art["lst"][0];

        if(hide) ArtObj["Special" + n].visible = false;

        S_Art.nbr = n;

        if(S_Art){
            ArtObj["Special" + n].width = ArtObj["Special" + n].texture_width;
            ArtObj["Special" + n].height = ArtObj["Special" + n].texture_height;

            if(S_Art.w && S_Art.h ){
              ArtObj["Special" + n].width =  S_Art.w;
              ArtObj["Special" + n].height =  S_Art.h;
            }
            if( S_Art.x != 0 && S_Art.y != 0){
                ArtObj["Special" + n].x =  S_Art["x"] * flw
                ArtObj["Special" + n].y =  S_Art["y"] * flh;
            }else{ // default bottom centered
                ArtObj["Special" + n].x = flw * 0.5 - ( (ArtObj["Special" + n].width  ) * 0.5);
                ArtObj["Special" + n].y = flh - ( (ArtObj["Special" + n].height ));
            }

            ArtObj["Special" + n].rotation = S_Art.r;
            if(S_Art.type != "none"){
                anim_special[i].name("Special" + n)
                anim_special[i].preset(S_Art.type)
                anim_special[i].starting(S_Art.start)
                anim_special[i].duration(S_Art["in"])
                anim_special[i].delay(S_Art.delay)
                anim_special[i].loops_delay(S_Art.length)
                anim_special[i].on("yoyo",function(anim){
                    if(S_Art.type == "bounce" ) anim.opts.interpolator = PennerInterpolator("linear");
                    anim.opts.duration = S_Art["out"]; // out
                })
                anim_special[i].on("stop",function(anim){
                    if(S_Art.cnt >= S_Art["lst"].len()) S_Art.cnt = 0;
                    ArtObj["Special" + S_Art.nbr].file_name = medias_path + S_Art["syst"] + "/Images/Special/" + S_Art["lst"][S_Art.cnt];
                    S_Art.cnt++;
                    anim.opts.duration = S_Art["in"]; // in
                    if(S_Art.type == "bounce" ) anim.opts.interpolator = PennerInterpolator("ease-out-bounce");
                    anim.play();
                })
                anim_special[i].yoyo(true)
                anim_special[i].play();
            }
        }
        ArtObj.SpecialA.shader.set_param("alpha", 1.0);
        ArtObj.SpecialB.shader.set_param("alpha", 1.0);
        ArtObj.SpecialC.shader.set_param("alpha", 1.0);
    }
}

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
local Background_Music = fe.add_sound( "" );
local Game_In_Out = fe.add_sound("");
local Wheelclick = [];
local sound_buffer_size = 5; // size of the audio buffer
for (local i=0; i<sound_buffer_size+1; i++) Wheelclick.push(fe.add_sound(""));
local sid = 0;

// dialog
local dialog = fe.add_surface(flw*0.280, flh*0.08);
dialog.set_pos(-flw, flh*0.025);
dialog.zorder=10;
local dialog_text = dialog.add_text("",0,0,0,0);
dialog_text.set_pos(0, 0, flw*0.280, flh*0.05);
dialog_text.charsize = flh*0.022;
dialog_text.set_bg_rgb(91,91,91);
dialog_text.bg_alpha = 35;
dialog_text.align = Align.Left;
local dialog_anim = PresetAnimation(dialog)
.from({x=-flw * 0.280})
.to({x=0})
.yoyo(true)
.loops_delay(1200)
.duration(700)

// Game Infos surface
local ttfont = "ArialCEMTBlack.ttf";
local Tags = surf_ginfos.add_image("[!get_media_tag]")
Tags.set_pos(flw*0.006, 0, flw*0.063, flh*0.036);

local last_played = surf_ginfos.add_text("",0,0,0,0);
last_played.font = ttfont;
last_played.set_pos(flw*0.028, flh*0.011, flw*0.155, flw*0.012);
last_played.align = Align.Left;
last_played.set_bg_rgb(110,100,99);
last_played.bg_alpha = 190;

local favo = surf_ginfos.add_text("[!ret_favo]",0,0,0,0);
favo.set_pos(flw*0.004, flh*0.000, flw*0.050, flh*0.035);
favo.font = "fontello.ttf";
favo.align = Align.Left;
favo.set_rgb( 255, 170, 0 );

local pl_i = surf_ginfos.add_image( "images/players.png");
pl_i.set_pos(flw*0.007, flh*0.040, flw*0.027, flh*0.042);
local pl_t = surf_ginfos.add_text( "[Players]",0,0,0,0);
pl_t.set_pos(-flw*0.001, flh*0.061, flw*0.0415 , flh*0.0160);
pl_t.align = Align.Centre;
pl_t.set_rgb( 100,100,100 );

local Ctrl = surf_ginfos.add_image( "[!periph]");
Ctrl.set_pos(flw*0.037, flh*0.040, flw*0.027, flh*0.042);
local Ctrl2 = surf_ginfos.add_image( "[!periph2]");
Ctrl2.set_pos(flw*0.067, flh*0.040, flw*0.027, flh*0.042);
local cate =  surf_ginfos.add_image("[!category]");
cate.set_pos(flw*0.097, flh*0.040, flw*0.027, flh*0.042);
local cate2 =  surf_ginfos.add_image("[!category2]");
cate2.set_pos(flw*0.127, flh*0.040, flw*0.027, flh*0.042);

Lang <- {};
local lng_x = flw*0.134;
local lng_v = {"y":flh*0.045, "w":flw*0.0220, "h":flh*0.0350};
for ( local i = 0; i < 17; i++ ) {
    lng_x += flw*0.0230;
    Lang[i] <- surf_ginfos.add_image("");
    Lang[i].set_pos(lng_x, lng_v.y, lng_v.w, lng_v.h);
}

local Title_v = {"color":[255,255,255], "x":flw*0.027, "y":flh*0.077, "w": flw*0.9375 , "size":flh*0.037};
local Title = OutlinedText(surf_ginfos, "[Title]", Title_v, 1.6);
Title.set("align" , Align.Left);
Title.set("font" , ttfont);

local list_entry_v = {"color":[255,255,255], "x":flw*0.030, "y":flh*0.135, "w": flw*0.3125 , "size":flh*0.021};
local list_entry = OutlinedText(surf_ginfos, "[ListEntry]/[ListSize] " + LnG.display + ": [FilterName]", list_entry_v, 0.8);
list_entry.set("align" , Align.Left);
list_entry.set("font" , ttfont);

local Copy_v = {"color":[255,255,150], "x":flw*0.030, "y":flh*0.111, "w": flw*0.9375 , "size":flh*0.025};
local Copy = OutlinedText(surf_ginfos, "[!copyright]", Copy_v, 0.5);
Copy.set("align" , Align.Left);
Copy.set("font" , ttfont);

local PCount_v = {"color":[255,255,255], "x":flw*0.030, "y":flh*0.155, "w": flw*0.3325 , "size":flh*0.021} ;
local PCount = OutlinedText(surf_ginfos, LnG.counter + " [PlayedCount] / " + LnG.playedtime + " [!PlayedTime]", PCount_v, 0.8);
PCount.set("align" , Align.Left);
PCount.set("font" , ttfont);

local flags = surf_ginfos.add_image("images/flags/[!region]");
flags.set_pos(flw*0.007, flh*0.081, flw*0.0240, flh*0.036);
local rating = surf_ginfos.add_image("images/rating/[Rating]");
rating.set_pos(flw*0.007, flh*0.119, flw*0.0240, flh*0.053);

/* Main SettingsOverlay */
surf_menu <- fe.add_surface(flw * 0.20, flh);
surf_menu.zorder = 2;
local surf_menu_bck = surf_menu.add_image("images/Backgrounds/faded.png", 0, 0, flw, flh );
surf_menu_bck.alpha = 80;
local surf_menu_img = surf_menu.add_image("");
surf_menu_img.set_pos(flw*0.044, flh * 0.82, flw * 0.16, flh * 0.17);
surf_menu_img.visible = false;
surf_menu_img.preserve_aspect_ratio = true;

local surf_menu_info = surf_menu.add_text("",0,0,0,0);
surf_menu_info.set_pos(flw * 0.005, flh - (flh * 0.046), flw * 0.26, flw * 0.012);
surf_menu_info.align = Align.Left;
surf_menu_info.set_bg_rgb(62,62,62);
surf_menu_info.alpha = 200;
surf_menu_info.visible = false;
surf_menu.visible = false;

/* Extra Artworks and startup infos Screen Overlay */
surf_inf <- fe.add_surface(flw, flh);
surf_bck <- surf_inf.add_image("images/Backgrounds/faded.png", 0, 0, flw, flh );
surf_img <- surf_inf.add_image("");
surf_img.height = flh * 0.082;
surf_img.mipmap = true;
local surf_arrow = surf_inf.add_image("images/double_arrow.png");
surf_arrow.set_pos(flw * 0.5 - ( flw * 0.083 * 0.5), flh * 0.942, flw * 0.083, flh * 0.037);
surf_arrow.visible = false;
surf_img.preserve_aspect_ratio = false;

local crt_sh = surf_inf.add_image("images/frame.png");
crt_sh.visible = false;
local surf_shader = fe.add_shader( Shader.Fragment, "shaders/crt.frag");
surf_img.shader = surf_shader;
surf_img.video_flags = Vid.NoLoop;
surf_shader.set_texture_param("Tex0");
surf_shader.set_texture_param("Tex1", crt_sh);

surf_inf.visible = false;
surf_inf.zorder = 2;
surf_txt <- surf_inf.add_text("",0,0,0,0);
surf_txt.set_pos(flw * 0.007, flh * 0.018, flw, flh * 0.046);
surf_txt.font = ttfont;
surf_txt.align = Align.Left;
surf_infos <- surf_inf.add_text("",0,0,0,0);
surf_infos.set_pos(flw*0.01, flh * 0.58, flw*0.99, flh * 0.36);
surf_infos.font = ttfont;
surf_infos.align = Align.Left;
surf_infos.charsize = 15;
surf_infos.word_wrap = true;

local surf_inf_anim = PresetAnimation(surf_inf)
.key("alpha").from(0).to(255)
.on("stop", function(anim){
    if(anim.opts.target.alpha == 0){
        anim.opts.target.visible = false;
        surf_img.file_name = "";
    }
})
.duration(600)

local extraArtworks = {
    lists = [],
    num = 0,
    pos = "",
    prev = "",
    infos = false,

    function init(){  fe.add_ticks_callback( this, "special_tick" );  },

    function getLists(){
        lists = [];
        num = 0;
        local lst = zip_get_dir( medias_path + curr_emulator + "/Images/Artworks/" +  fe.game_info(Info.Name) );
        foreach( v in lst ) if( ["jpg","png","mp4"].find( ext(v) ) != null ) lists.push(v);
        return lists;
    },

    function Resize(){
        local coeff = 0.90;
        local ini = medias_path + curr_emulator + "/Images/Artworks/" +  fe.game_info(Info.Name) + "/" + strip_ext(lists[num]) + ".txt";
        if(file_exist(ini)){
            coeff = 0.56;
            infos = ini;
        }
        local ratio = surf_img.texture_width.tofloat() / surf_img.texture_height.tofloat();
        if(ratio > (flw / flh)){
            surf_img.width = flw * coeff;
            surf_img.height = (flw * coeff) / ratio;
        }else{
            surf_img.height = (flh * coeff);
            surf_img.width = (flh * coeff) * ratio;
        }

        // if it's a video choose a overlay depending on the date or use simple frame
        if(surf_img.video_duration){
            if(lists[num].find("Commercial") != null){
               local year = strip_ext(lists[num]).slice(strip_ext(lists[num]).len()-4, strip_ext(lists[num]).len());
               try{year = year.tointeger()}catch(e){year = 0;}
                if(CntDigit(year) == 4){
                    if(year <= 1980){
                        crt_sh.file_name = "images/crt-70.png";
                        surf_shader.set_param("datas", 0.11, 0.0, 0.626, 0.835);
                    }else if(year > 1980 && year <= 2000){
                        crt_sh.file_name = "images/crt-80.png";
                        surf_shader.set_param("datas", -0.001, 0.0, 0.67, 0.88);
                    }else if(year > 2000){
                        crt_sh.file_name = "images/crt-2000.png";
                        surf_shader.set_param("datas", 0.0, 0.1, 1.0, 1);
                    }
                }
            }else{
                crt_sh.file_name = "images/frame.png";
                surf_shader.set_param("datas", 0.0, 0.0, 0.940, 0.940);
            }
            surf_shader.set_param("enable", 1);
            ArtObj.snap.video_flags = Vid.NoAudio;  // silence the snap audio if it's a video
            Background_Music.playing = false;
        }else{
            ArtObj.snap.video_flags = Vid.Default;
            surf_shader.set_param("enable", 0);
        }

        if(!infos) surf_img.y = flh * 0.5 - surf_img.height * 0.5; else surf_img.y = flh * 0.04;
    },

    function set_Title(){
        local nbr = "";
        local title = strip_ext(lists[num]);
        if(lists.len() > 1){
            nbr = "(" + (num+1) + "/" + lists.len() + ")";
            surf_arrow.visible = true;
        }else{
            surf_arrow.visible = false;
        }
        if( title.len() ){
            surf_txt.set_rgb( 241, 250, 200 );
            surf_txt.msg = nbr+" "+title.slice( 0, 1 ).toupper() + title.slice( 1, title.len() ); // caps first char
        }

        if(infos){
            local textfile = txt.loadFile( infos );
            local line1 = textfile.lines[0];
            local txt = "";
            foreach( line in textfile.lines ) { txt+=line+"\n"; }
            surf_infos.msg = txt;
        }
    },

    function setImage( act=0 ){
        infos = false;
        surf_infos.msg = "";
        if( !lists.len() ){
            surf_img.file_name = "";
            surf_arrow.visible = false;
            surf_txt.msg = LnG.M_inf_No_Artworks;
            return false;
        }

        if(!act){
            surf_img.file_name =  medias_path + curr_emulator + "/Images/Artworks/" +  fe.game_info(Info.Name) + "/" + lists[num];
            Resize();
            set_Title();
            surf_img.x = flw * 0.5 - surf_img.width * 0.5;
            return false;
        }
        pos = act;
    },

    function special_tick(ttime){
        if(pos == "" || lists.len() < 2) return false;
        local speed = 175;
        if(pos == "left"){
            surf_img.x = clamp(surf_img.x-=speed, -surf_img.width, (flw * 0.5 - surf_img.width * 0.5));
            if(surf_img.x <= -surf_img.width){
               (num > 0 ? num-- : num = lists.len() - 1 );
                surf_img.file_name = medias_path + curr_emulator + "/Images/Artworks/" + fe.game_info(Info.Name) + "/" + lists[num];
                Resize();
                set_Title();
                surf_img.x = flw
                pos = "center";
                prev = "left";
            }
        }

        if(pos == "right"){
            surf_img.x = clamp(surf_img.x+=speed, (flw * 0.5 - surf_img.width * 0.5), flw);
            if(surf_img.x >= flw){
                ( num < lists.len() - 1 ? num++ : num = 0 )
                surf_img.file_name = medias_path + curr_emulator + "/Images/Artworks/" + fe.game_info(Info.Name) + "/" + lists[num];
                Resize();
                set_Title();
                surf_img.x = -surf_img.width;
                pos = "center";
                prev = "right";
            }
        }

        if(pos == "center" && prev == "left"){
            if(surf_img.x <= (flw * 0.5 - surf_img.width * 0.5)){
                pos = "";
            }else{
               surf_img.x = clamp(surf_img.x-=speed, (flw * 0.5 - surf_img.width * 0.5), flw);
            }
        }

        if(pos == "center" && prev == "right"){
            if(surf_img.x >= (flw * 0.5 - surf_img.width * 0.5)){
                pos = "";
            }else{
               surf_img.x = clamp(surf_img.x+=speed, -surf_img.width, (flw * 0.5 - surf_img.width * 0.5))
            }
        }
    }
}

extraArtworks.init()

// Main Menu Infos
main_infos <- {};
local game_elapse = 0;

m_infos <- fe.add_text("",0,0,0,0);
m_infos.set_pos(flw*0.878, flh*0.537, flw*0.12, flh*0.046);
m_infos.visible = false;
m_infos.align = Align.Left;
m_infos.word_wrap = true;
m_infos.charsize = flh*0.014;
m_infos.set_rgb(205, 205, 195);

if( my_config["stats_main"].tolower() == "yes" ){
    if( !file_exist(globs.script_dir + "pcca.stats") ) main_infos <- refresh_stats();
    main_infos <- LoadStats();
}

function stats_text_update( sys ){
    if( main_infos.rawin( sys ) ){
        m_infos.msg = main_infos[sys].cnt + " " + LnG.Games + " / " + LnG.Played + ": " + main_infos[sys].pl;
        if(main_infos[sys].time > 0)  m_infos.msg += "\n" + LnG.playedtime + " " + secondsToDhms( main_infos[sys].time );
    }else{
        m_infos.msg = "";
    }
}

// Synopsis
syno_surf <- fe.add_surface(fe.layout.width , flh*0.022);
syno_surf_bg <- syno_surf.add_image( "images/pixel.png", 0, 0, syno_surf.width, syno_surf.height );
syno_surf_bg.alpha = 75;
syno_surf_bg.set_rgb(20,0,0);
syno <- syno_surf.add_text("",0,0,0,0);
syno.set_pos(flw, -flh*0.001, flw , syno_surf.height);
syno.charsize = syno_surf.height * 0.96;
syno.align = Align.Left;

function overview( offset ) {
    if(!Ini_settings.themes["synopsis"]) return;
    local input = replace(fe.game_info(Info.Overview, offset),"\\n"," ");
    // globals stats
    local main_stats = "";
    if(curr_sys == "Main Menu" && Ini_settings.themes["main_stats"] && my_config["stats_main"].tolower() == "yes" ){
        local totgames=0, tottimes=0, totplay=0;
        foreach(k,d in main_infos){
            if(globs.custom_romlists.find(k) != null) continue; //don't use the custom romlists for the count
            totgames+=d.cnt;
            tottimes+=d.time;
            totplay+=d.pl;
        }
        main_stats = "Stats: " + LnG.counter + ": "+totgames+" - " + LnG.playedtime + ": " + secondsToDhms( tottimes ) + " - " + LnG.Played + ": " + totplay;
    }

    syno_surf_bg.set_rgb(20,0,0);
    syno_surf_bg.alpha = 75;
    syno.msg = (Ini_settings.themes["main_stats"] ? main_stats + " - " + input : input);
    syno.width = (syno.msg.len() * syno.charsize.tofloat());
    if(  input.len() ) syno.x = syno_surf.width;
   if(replace(syno.msg," ", "") == "") syno_surf_bg.alpha = 0;
   return;
}

function background_transitions(transition, File, animation = null){
    if( Ini_settings.themes["reload_backgrounds"] == false && surf_menu.visible == false){ // dot not reload background if it's the same and the option reload_backgrounds is false (Default behavior)
        if(replace (File, "|", "") == ArtObj.background1.file_name && reverse) return;
        if(replace (File, "|", "") == ArtObj.background2.file_name && !reverse) return;
    }

    ArtObj.bezel.visible = false;
    local fromIsSWF = false;
    local toIsSWF = ( ext(File).tolower() == "swf" ? true : false );
    local bw,bh;
    if(reverse){
        ArtObj.background2.file_name = File;
        // fix flipped-y background with swf (why ??? AM Bug) (ex:anteater mame)
        if( ext(ArtObj.background1.file_name).tolower() == "swf" ){
            ArtObj.background1.video_playing = false;
            fromIsSWF = true;
        }

        bw = ArtObj.background2.texture_width;
        bh = ArtObj.background2.texture_height;

    }else{
        ArtObj.background1.file_name = File;
        // fix flipped-y background with swf
        if( ext(ArtObj.background2.file_name).tolower() == "swf" ){
            ArtObj.background2.video_playing = false;
            fromIsSWF = true;
        }

        bw = ArtObj.background1.texture_width;
        bh = ArtObj.background1.texture_height;
    }

        if( Ini_settings.themes["background_stretch"] || hd ) // no scaled backgrounds
        {
            Trans_shader.set_param("prev_res", prev_back.ox  / flw , prev_back.oy / flh, prev_back.bw  / flw, prev_back.bh  / flh); // previous background infos
            if(animation){
                local width = bw;
                local height = bh;
                if(width < flw * 1.5) width = flw*1.5;
                if(height < flh * 1.5) height = flh*1.5;
                switch(animation){
                    case "horizontal panning":
                        local off_x = -( (width-flw) * 0.5);
                        Trans_shader.set_param("back_res", off_x / flw, 0.0, width / flw, 1.0 ); // actual background infos stretched
                        prev_back = { ox = off_x, oy = 0.0, bw = width, bh = flh };
                    break;

                    case "vertical panning":
                        local off_y = (height-flh) * 0.5;
                        Trans_shader.set_param("back_res",0.0, off_y / flh, 1.0, height / flh ); // actual background infos stretched
                        prev_back = { ox = 0, oy = off_y, bw = flw, bh = height };
                    break;

                    case "random panning":
                        local off_x = -( (width-flw) * 0.5);
                        local off_y = (height-flh) * 0.5;
                        Trans_shader.set_param("back_res", off_x / flw, off_y / flh, width / flw, height / flh ); // actual background infos stretched
                        prev_back = { ox = off_x, oy = off_y, bw = width, bh = height };
                    break;

                    case "none":
                       Trans_shader.set_param("back_res", 0.0, 0.0, 1.0, 1.0 ); // actual background infos stretched
                    break;
                }

            }else{  // no animation
                Trans_shader.set_param("back_res", 0.0, 0.0, 1.0, 1.0 ); // actual background infos stretched
                prev_back = { ox = 0, oy = 0, bw = flw, bh = flh }; // si animation précédent alors bw, etc.. doit = a la res précédente
            }

        }else{ // scaled (HyperSpin) Background

            if( toIsSWF ){ // hyperspin seems to stretch any swf backgrounds !
                Trans_shader.set_param("back_res", offset_x / flw, offset_y / flh, (1024 * mul) / flw, (768 * mul_h) / flh); // actual background infos stretched
            }else{
                Trans_shader.set_param("back_res", offset_x / flw, offset_y / flh, (bw * mul) / flw, (bh * mul_h) / flh); // actual background infos
            }

            if(prev_back.len() > 0 ) { // previous background infos
                Trans_shader.set_param("prev_res", prev_back.ox / flw , prev_back.oy  / flh, prev_back.bw / flw, prev_back.bh / flh);
            }else{
                Trans_shader.set_param("prev_res", offset_x / flw, offset_y / flh, (bw * mul) / flw, (bh * mul_h) / flh);
            }
            prev_back = { ox = offset_x, oy = offset_y, bw = bw * mul, bh = bh * mul_h };
        }

    Trans_shader.set_texture_param("back2", ArtObj.background2);
    Trans_shader.set_texture_param("back1", ArtObj.background1);
    Trans_shader.set_texture_param("bezel", ArtObj.bezel);

    if(!transition){
        local rndanim = rnd_num(0,42,"int");
        if(reverse && rndanim == 41) rndanim = 42; // hp corner can only be used right to left so select 42 (canna) instead if it's reverse
        Trans_shader.set_param("datas", rndanim, reverse, fromIsSWF, toIsSWF);// datas = preset number, reverse 0:1 , fromIsSWF, toIsSWF
    }else{
        if(typeof(transition) == "array"){ // select randomly only from passed array values
            Trans_shader.set_param("datas", get_random_table(transition), reverse, fromIsSWF ,toIsSWF);
        }else{
            Trans_shader.set_param("datas", transition, reverse, fromIsSWF ,toIsSWF);
        }
    }

    if( !hd && Ini_settings.themes["bezels_on_top"] ) ArtObj.bezel.visible = true; else ArtObj.bezel.visible = false;

    Trans_shader.set_param("alpha", 1.0);
    local to = (reverse == 0.0 ? 1.0 : 0.0)
    bck_anim.from([reverse])
    bck_anim.to([to])
    bck_anim.on("stop", function(animation){
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

function load_theme(theme_path, theme_content, prev_def){
    if(Ini_settings["game text"]["game_text_active"] && curr_sys != "Main Menu") surf_ginfos.visible = true;
    if(Ini_settings["game text"]["animation"] != "none" && Ini_settings["game text"]["game_text_hide"]) surf_ginfos_animation.play();
    // hide overlay helper
    text_overlay.visible = false;
    overlay_surf_anim.reverse(true).duration(500).play();
    wheel_surf.visible = true;
    set_custom_value(Ini_settings);
    local back_tr = 99; // 99=fade background only , array = random trough array , null=full transitions random
    xml_root = null;
    if(theme_content.len() <= 0){  // If there is no theme file, return (unified theme)
        hd = true;
        if(file_exist(medias_path + curr_emulator + "/Themes/" + fe.game_info(Info.Name) + ".mp4")){
            ArtObj.background.set_pos(0,0,flw, flh);
            reset_art();
            if( Ini_settings.themes["animated_backgrounds"] ) back_tr = null;
            background_transitions(back_tr, medias_path + curr_emulator + "/Themes/" + fe.game_info(Info.Name) + ".mp4");
        }
        return false;
    }

    local zipfolder = ""; // needed when media is inside subfolder on the zip archive
    local DiR = theme_content[0];
    if ( DiR[DiR.len()-1] == '/' ) zipfolder = theme_content[0];
    local f = ReadTextFile( theme_path, zipfolder + "Theme.xml" );
    local raw_xml = "";
    while ( !f.eos() ){
        local l = f.read_line();
        if(raw_xml == ""  && !l.find("Theme")) continue; // skip first line if it's not tag theme
        raw_xml = raw_xml + l;
    }

    //fix common error in a lot of themes with wrong end tags
    raw_xml = replace( raw_xml, "start=\"none\"/>rest=", "start=\"none\"rest=" );
    raw_xml = replace( raw_xml, "start=\"left\"/>rest=", "start=\"left\"rest=" );
    raw_xml = replace( raw_xml, "start=\"top\"/>rest=", "start=\"top\"rest=" );
    raw_xml = replace( raw_xml, "start=\"bottom\"/>rest=", "start=\"bottom\"rest=" );
    raw_xml = replace( raw_xml, "start=\"right\"/>rest=", "start=\"right\"rest=" );
    raw_xml = replace( raw_xml, "encoding=\"utf-8\" version=\"1.0\"", "" );

    try{ xml_root = xml.load( raw_xml ); } catch ( e ) { };
    local theme_node = find_theme_node( xml_root );
    try{ theme_node.children } catch ( e ) { return; }; // return if no xml

    foreach(a,b in artwork_list_full) availables[b] <- false; // reset full artworks availability
    local anim_rotate;

    try{ hd = xml_root.getChild("hd") } catch(e) { hd = false}   // check if it's a real HD theme

    if(hd){
        local lw = hd.attr.lw.tofloat(); // width of the designed theme
        local lh = hd.attr.lh.tofloat(); // height of the designed theme
        local nw = flh * (flw / flh);
        mul = nw / lw;
        mul_h = flh / lh;
        offset_x = 0;
        offset_y = 0;
    }

    set_xml_datas(); // format xml datas

    Sound_Click.file_name = medias_path + "Main Menu/Sound/Wheel Click.mp3";
    if(file_exist(medias_path + curr_sys + "/Sound/Wheel Click.mp3") ) Sound_Click.file_name = medias_path + curr_sys + "/Sound/Wheel Click.mp3"; // wheel_click found in current system media folder

    if(file_exist(medias_path + curr_emulator + "/Sound/Background Music/" + fe.game_info(Info.Name) + ".mp3") ){ // background music found in media folder
        Background_Music.file_name = medias_path + curr_emulator + "/Sound/Background Music/" + fe.game_info(Info.Name) + ".mp3";
        Background_Music.playing = false;
        triggers.background_music.start = true;
        ArtObj.snap.video_flags = Vid.NoAudio;
    }else if(!Background_Music.file_name.find("Default.mp3")){
        if(file_exist(medias_path + curr_emulator + "/Sound/Background Music/Default.mp3" )){
            Background_Music.file_name = medias_path + curr_emulator + "/Sound/Background Music/Default.mp3";
            Background_Music.playing = false;
            triggers.background_music.start = true;
            ArtObj.snap.video_flags = Vid.NoAudio;
        }
    }

    local backg = false;
    foreach(k,v in theme_content){
        if(strip_ext(v.tolower()) == zipfolder.tolower() + "background"){ // background found in theme
            backg = theme_path + "|" + v
            back_tr = null
        }

        if( ext(v.tolower()) == "mp3" ){ // background music found anywhere in theme ( in HS , must be in /Extras/Background Sounds/ ....mp3)
            Background_Music.file_name = theme_path + "|" + v;
            Background_Music.playing = false;
            triggers.background_music.start = true;
            ArtObj.snap.video_flags = Vid.NoAudio;
        }
    }

    // if we are on a default theme or if background is missing in theme, check in background folder
    if( (!backg || theme_path.find("/Default/") ) ){
        local rndbckg = get_random_file(medias_path + curr_sys + "/Images/Backgrounds/" + fe.game_info(Info.Name));
        if(rndbckg != "") backg = rndbckg;
    }

    if(!backg) backg = "images/Backgrounds/Black.png"; // if no background is found , use black

    if(raw_xml == "") return; // if broken with no theme.xml inside zip

    local back_anim = null;
    local rnd_list = [];

    if(globs.customs_romlist_tb.rawin(fe.game_info(Info.Name))) rnd_list = globs.customs_romlist_tb[fe.game_info(Info.Name)].map( function(x) { return x; });

    foreach ( c in theme_node.children )
    {
        // background anim
        if(c.tag == "background"){
            back_anim = c.attr.rest;
            if( c.attr.rest != "none" && !prev_def){
                background_anim.opts.bck_opts.clear(); // reset background options in anim module
                background_anim.rest(c.attr.rest);
                background_anim.opts.rest_speed = c.attr.speed;
                triggers.background_anim.delay = c.attr.delay;
                triggers.background_anim.start = true;
            }
        }
        if( !(c.tag in availables ) ) continue; // if xml tag not know continue

        local art = ""; local Xtag = c.tag;
        anim_rotate = 0;
        foreach(k,v in theme_content){
            if(strip_ext(v.tolower()) == zipfolder.tolower() + Xtag.tolower()){
                availables[Xtag] = true;
                art = v
            }
        }

        local artD = c.attr;
        if( artwork_list.find(Xtag) != null ){
            if( prev_def && availables[Xtag] ) continue;

            if(artD.random == "none"){
                if(availables[Xtag]){
                    ArtObj[Xtag].file_name = theme_path + "|" + art;
                }else{
                    ArtObj[Xtag].file_name =  medias_path + curr_emulator + "/Images/" + Xtag + "/" + art + "/" + fe.game_info(Info.Name) + ".png"; // get hs others medias artwork when they are not available in zip
                }
            }else{
                if(rnd_list.len()){ // for custom romlist randomly select from custom_romlists table
                    local rnd_art = get_random_table(rnd_list);
                    rnd_list.remove(rnd_list.find(rnd_art));
                    local splited = split( rnd_art, ";" );
                    if(artD.random == "video"){
                        ArtObj[Xtag].file_name = medias_path + splited[1] + "/Video/" + splited[0] + ".mp4";
                    }else{
                        ArtObj[Xtag].file_name = medias_path + splited[1] + "/Images/" + artD.random + "/" + splited[0] + ".png";
                    }
                }else{ // choose from system artwork folder
                    if(artD.random == "video"){
                        ArtObj[Xtag].file_name = get_random_file(medias_path + curr_emulator + "/Video/" );
                    }else{
                        ArtObj[Xtag].file_name = get_random_file(medias_path + curr_emulator + "/Images/" + artD.random + "/" );
                    }
                }
            }

            // center rotation ,hyperspin anim artworks rotation only if it's greater than 180 or -180 and time is > 0
            if( abs(artD.r) > 180 && artD.time > 0 ) anim_rotate = artD.r;

            if(!artD.hidden) artworks_transform(Xtag, (anim_rotate ? false : true), art);

        }else if( Xtag == "video" ){
            // Temporary fix for the video datas does not reset !! (see prev_def commented below)
            clean_art("snap");
            clean_art("video");

            if(!artD.random){
                ArtObj.snap.file_name = medias_path + curr_emulator + "/Video/" + fe.game_info(Info.Name) + ".mp4";
            }else{
                if(globs.customs_romlist_tb.rawin(fe.game_info(Info.Name))){ // for custom romlist randomly select from custom_romlists table
                    local i = 0;
                    while( ArtObj.snap.file_name == "" ){
                        local rnd_vid = get_random_table(globs.customs_romlist_tb[fe.game_info(Info.Name)]);
                        local splited = split( rnd_vid, ";" );
                        if(splited.len() > 1) ArtObj.snap.file_name = medias_path + splited[1] + "/Video/" + splited[0] + ".mp4";
                        if(i>5) break;//break if no radom art is found after 6 it
                        i++;
                    }
                }else{
                    ArtObj.snap.file_name = get_random_file(medias_path + fe.game_info(Info.Name) + "/Video");
                    if(fe.game_info(Info.Name) == "All Games" && ArtObj.snap.file_name == ""){ // if all games and no snap, get a random main menu snap
                        local i = 0;
                        while( ArtObj.snap.file_name == "" ){
                            ArtObj.snap.file_name =  medias_path + "Main Menu/Video/"+get_random_table(fe.displays).name+".mp4";
                            if(i>5) break;//break if no radom snap is found after 6 it
                            i++;
                        }
                    }
                }
            }

            ArtObj.snap.video_playing = false; // do not start playing snap now , wait delay from animation
            snap_is_playing = false;
            if(availables["video"]){ // if video overlay available
                ArtObj["video"].file_name = theme_path + "|" + art;
            }

            // hs anim video rotation on any value but only if starting position is set, animation is set and anim time > 0 !!!!
            if( abs(artD.r) > 0 && artD.start != "none" && artD.type != "none" && artD.time > 0 ) anim_rotate = artD.r;

            video_transform((anim_rotate ? false : true));

            if(artD.below) ArtObj.artwork1.zorder = ArtObj.snap.zorder + 1; // only for HS
        }

        if(Xtag !="video"){
            if(!prev_def || !availables[Xtag] ){
                local e = Xtag.slice( Xtag.len() - 1, Xtag.len() ).tointeger();
                if(!hd && artD.type == "pendulum") artD.delay = 0.0; //!  hs does not apply the delay on the pendulum animation
                anims[e-1].preset(artD.type, hd ) // pass if it's hd or hs theme to hs-animate module for pendulum
                anims[e-1].name(Xtag)
                anims[e-1].delay(artD.delay * 1000)
                anims[e-1].duration(artD.time * 1000)
                anims[e-1].starting(artD.start)
                anims[e-1].rest(artD.rest)
                anims[e-1].rotation(anim_rotate)
                anims[e-1].play();
            }
        }else{
            anim_video.preset(artD.type)
            anim_video.name(Xtag)
            anim_video.delay(artD.delay * 1000)
            anim_video.duration(artD.time * 1000)
            anim_video.starting(artD.start)
            anim_video.rest(artD.rest)
            anim_video.rotation(anim_rotate)
            anim_video.play();
        }
    }

    if(!Ini_settings.themes["animated_backgrounds"] ) back_tr = 99;
    background_transitions(back_tr, backg, back_anim);
    if(!back_anim)background_anim.resting = false;
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
        ArtObj.artwork1.zorder = -8;   //set zorder back to normal for hyperspin zorders switching
        ArtObj.artwork2.zorder = -4
        ArtObj.artwork3.zorder = -3
        ArtObj.artwork4.zorder = -2
        ArtObj.artwork5.zorder = -9
        ArtObj.artwork6.zorder = -9
        ArtObj.snap.zorder = -7;

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

    foreach(k,obj in artwork_list ){
        if( !bool || !availables["artwork"+(k+1)] ){
            clean_art(obj);
            anims[k].hide_particles(); // hide each particles medias clones
        }
    }

    ArtObj.snap.video_flags = Vid.Default; // enable snap sound

    if(curr_sys == "Main Menu")
       point.file_name = medias_path + "/Main Menu/Images/Other/Pointer.png";
    else
       point.file_name = medias_path + fe.list.name + "/Images/Other/Pointer.png";

    if(point.file_name ==  "") point.file_name = medias_path + "Frontend/Images/Pointer.png"; // default pointer
}

function hide_art(){
    local random = ["unzoom", "zoom", "fade out", "expl", "swirl", "pixelate fadeout"];
    //--if default theme , we hide with animation only artworks not available in the zip
    local cnt = 0;
    local selected = [];
    while(cnt<6){
        local rnd = rnd_num(0,random.len()-1,"int");
        if(selected.find(rnd)== null){
            selected.push(rnd);
            cnt++
        }
    }

    foreach(a,b in artwork_list ){
        if(curr_theme != "Default" || availables[b] == false ){
            anims[a].resting = false; // disable resting animation before hide artworks
            anims[a].preset(random[ selected[a] ])
            anims[a].on("stop", function(anim){
                anim.opts.target.file_name = "";
                anim.opts.target.visible = false;
            })
            anims[a].on("cancel", function(anim){
                anim.opts.target.file_name = "";
                anim.opts.target.visible = false;
            })
            .duration(globs.delay * 0.8)
            .delay(0)
            anims[a].play();
        }
    }
}

/* OVERLAY SCREEN */
local custom_overlay = fe.add_surface(flw, flh);
custom_overlay.zorder = 10
custom_overlay.visible = false;
overlay_background <- custom_overlay.add_image("",0, 0, flw, flh);
overlay_hide <- fe.add_image("images/Backgrounds/Black.png", 0, 0, flw, flh); // used to hide elems with black background in (Transition.ToGame)
overlay_hide.zorder = 9;
overlay_hide.visible = false;

local overlay_anim = PresetAnimation(custom_overlay)
.key("alpha").from(0).to(255)
.on("stop", function(anim){
    if(anim.opts.target.alpha == 0) anim.opts.target.visible = false;
})
.duration(600)

// overlay list
overlay_list <- custom_overlay.add_listbox(flw*0.369, flh*0.361 , flw*0.260, flh*0.370);
overlay_list.zorder = 3;
overlay_list.font = "SF Slapstick Comic Bold Oblique.ttf";
overlay_list.align = Align.Centre;
SetListBox(overlay_list, {visible = true, rows = 5, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.017 })

overlay_title <- custom_overlay.add_text("",0,0,0,0);
overlay_title.set_pos(0, flh*0.324, flw, flh*0.046);
overlay_title.set_rgb(192, 192, 192); // global
overlay_title.charsize = flw * 0.022; // global

function overlay_message(img=false, icon_pos=false){
    overlay_background.file_name = "images/Backgrounds/faded.png";
    overlay_icon.visible = false;
    overlay_icon.set_pos(flw * 0.5 - (flw * 0.0833 * 0.5), flh * 0.15, flw * 0.0833, flh * 0.1111);
    if(img){
        overlay_icon.file_name = img;
        overlay_icon.visible = true;
    }
    if(icon_pos){
        overlay_icon.set_pos(icon_pos[0], icon_pos[1], icon_pos[2], icon_pos[3]);
    }
    overlay_background.set_pos(0, 0, flw, flh);
    overlay_background.alpha = 255;
    overlay_list.charsize = flw*0.024;
    overlay_list.set_pos(flw*0.369, flh*0.361 , flw*0.260, flh*0.370);

}

fe.overlay.set_custom_controls( overlay_title, overlay_list ); // should be called set_custom_style instead of control ...

wheel_art <- custom_overlay.add_image( "[!ret_wheel]");
wheel_art.set_pos(flw*0.425, flh*0.192, flw*0.156, flh*0.138);
wheel_art.visible = false;

overlay_icon <- custom_overlay.add_image("");
overlay_icon.set_pos( 0, 0, flw * 0.104, flh * 0.185);
overlay_icon.visible = false;

//-- KeyboardSearch
class Keyboard extends KeyboardSearch
{
    function toggle() {
        if(curr_sys != sys){ // reload letters artwork only if sys is changed
            local keysf = get_dir_lists(medias_path + curr_sys + "/Images/Letters/");
            foreach( key, val in key_names ) {
                if(val.tolower() in keysf){
                    keys[ key.tolower() ].file_name = keysf[key.tolower()];
                }else{
                    keys[ key.tolower() ].file_name = globs.script_dir + "nut/keyboard-search/images" + "/" + val.tolower() + ".png";
                }
            }
            sys = curr_sys
        }
        trigger = true;
        if(state == 0 || state == 3){
            state = 2;
            surface.alpha = 255
            if ( !config.retain || config.retain == "false") clear()
        }else if(state == 1 || state == 2){
            state = 3;
        }
    }
}

local search_surface = fe.add_surface(flw*0.370, flh);
search_surface.zorder = 10;
local search = Keyboard( search_surface )
    .set_pos(-flw*0.370,0,flw*0.370,flh)
    .retain(true)
    .search_key( my_config["keyboard_search_key"] )
    .mode( my_config["keyboard_search_method"] )
    .preset( my_config["keyboard_layout"] )
    .text_font("SF Slapstick Comic Bold Oblique.ttf")
    .text_color(214,211,210)
    .text_pos( [ 0.1, 0.31, 0.8, 0.07 ] )
    .keys_selected_color(255,255,255)
    .bg("Images/Backgrounds/Search_Background.png")
    .keys_image_folder(medias_path + fe.list.name + "/Images/Letters")
    .init()

// Start game sounds transition callback
fe.add_transition_callback( "game_in_out" );
function game_in_out( ttype, var, ttime ) {
    switch ( ttype ) {
        case Transition.ToGame:
            Background_Music.playing = false;
            Sound_System_In_Out.playing = false;
            if(file_exist(medias_path + curr_emulator + "/Sound/Game Start/" + fe.game_info(Info.Name) + ".mp3") ){
                Game_In_Out.file_name = medias_path + curr_emulator + "/Sound/Game Start/" + fe.game_info(Info.Name) + ".mp3";
            }else if( file_exist(medias_path + curr_emulator + "/Sound/Game Start/Default.mp3") ){
                Game_In_Out.file_name = medias_path + curr_emulator + "/Sound/Game Start/Default.mp3";
            }else{
                Game_In_Out.file_name = get_random_file( globs.script_dir + "sounds/game_start" );
            }
            Game_In_Out.playing = true;
        break;
    }
    return false;
}

local loader = 0;
//
// Global Transition
//
local prev_tr = 12;
fe.add_transition_callback( "hs_transition" );
function hs_transition( ttype, var, ttime )
{
    //print("\nTransitions= "+debug_array[ttype]+" var="+var+" prev="+debug_array[prev_tr]+"\n")
    switch ( ttype )
    {
        case Transition.FromGame:
            overlay_hide.visible = false;
            globs.Stimer = fe.layout.time;
            if( global_fade( ttime, 700.0, true) ) return true;
            update_recent();
            update_most_played();
            set_last_played_txt(true);
            ArtObj.background1.video_playing = true;
            ArtObj.background2.video_playing = true;
            ArtObj.snap.video_playing = true;
            pcca_wheel.reset_fade();
            // update stats for this system only if Track Usage is set to Yes in AM!
            if( fe.game_info(Info.PlayedTime) != "" ){
                game_elapse = fe.game_info(Info.PlayedTime).tointeger() - game_elapse;
                if(main_infos.rawin(fe.list.name)){
                    main_infos[fe.list.name].time += game_elapse;
                    main_infos[fe.list.name].pl++;
                    SaveStats(main_infos);
                }
            }
        break;

        case Transition.ToGame:
            TOGame = true;
            switch(loader){
                case 0 :
                    if( global_fade( ttime, 1500.0, false) ) {
                        ArtObj.background1.video_playing = false;
                        ArtObj.background2.video_playing = false;
                        ArtObj.snap.video_playing = false;
                    }else{
                        overlay_hide.visible = true; // add black background to hide animation behind
                        loader = 1
                        fades.alpha = 0
                    }
                break;

                case 1 :
                  get_infos_screen(fe.game_info(Info.Name), curr_emulator, ttime);
                  ttime = 0;
                  loader = 2;
                break;

                case 2 :
                    if(custom_overlay.alpha > 0){
                        custom_overlay.alpha -=5;
                    }else{
                        // store old playedtime when lauching a game (only if Track Usage is set to Yes in AM!)
                        if( fe.game_info(Info.PlayedTime) != "" ) game_elapse = fe.game_info(Info.PlayedTime).tointeger();
                        // hide overlay background
                        overlay_background.file_name = "";
                        loader = 0;
                        return false;
                    }
                break;
            }
            return true;
        break;

        case Transition.ChangedTag: // 11
            if(var == 21){
                if(fe.game_info(Info.Favourite) == ""){
                    dialog_text.msg = LnG.ret_fav;
                    update_favourites(false);
                } else {
                    dialog_text.msg = LnG.add_fav;
                    update_favourites(true);
                }
            }
            if(var == 22) dialog_text.msg = LnG.tag_mod; // tag not working if ther is not filter rule set for this tag
            dialog_anim.play();
        break;

        case Transition.NewSelOverlay: // 10
            FE_Sound_Screen_Click.playing = true;
        break;

        case Transition.FromOldSelection: //3
            if(curr_sys == "Main Menu") stats_text_update( fe.game_info(Info.Title) );
            if(Ini_settings["game text"]["game_text_hide"]) {
                surf_ginfos.visible = false;
                if(Ini_settings["game text"]["animation"] != "none") surf_ginfos_animation.cancel("from");
            }
        break;

        case Transition.ToNewSelection: //2
            m_infos.visible = false;
            foreach(a,b in artwork_list ){
                if(curr_theme != "Default" || availables[b] == false ) anims[a].stop(); // used to stop hideart when navigating !
            }
            ArtObj.snap.video_flags = Vid.NoAudio;
            if(curr_theme != "Default" && !Background_Music.file_name.find("Default.mp3")){ // keep playing music on default
                Background_Music.playing = false;
                triggers.background_music.start = false;
            }
            ArtObj.snap.file_name = "";
            if(curr_sys != "Main Menu") syno.x = syno_surf.width; // reset scrolling test position
            if(glob_time - rtime > 150) hide_art(); // 150ms between re-pooling hide_art when navigating fast in wheel (change !!)
            rtime = glob_time;
            flv_transitions.visible = false;
            flv_transitions.file_name = "";
            if(curr_sys == "Main Menu") stats_text_update( fe.game_info(Info.Title, 1) );
            if(Ini_settings["game text"]["game_text_hide"]){
                surf_ginfos.visible = false;
                if(Ini_settings["game text"]["animation"] != "none") surf_ginfos_animation.cancel("from");
            }
        break;

        case Transition.EndNavigation: //7
            if(prev_tr == Transition.ToNewList) return false; // fix back from screensaver reload theme twice.
            Langue();
            if(surf_inf.visible){
                extraArtworks.getLists();
                extraArtworks.setImage();
            }
            triggers.theme.start = true;
            curr_emulator = (fe.game_info(Info.Emulator) == "@" ? "Main Menu" : fe.game_info(Info.Emulator));
            //Play entierly games sounds-fx (Yaron fix)
            if( Ini_settings.sounds["game_sounds"] ) {
                // check if systeme have custom wheel sounds , if not, use main menu wheel sounds like in HS !
                local wsound = get_random_file( medias_path + curr_sys + "/Sound/Wheel Sounds");
                if( wsound == "" ) wsound = get_random_file( medias_path + "Main Menu/Sound/Wheel Sounds");
                sid++;
                if (sid > sound_buffer_size) sid = 0;
                Wheelclick[sid].file_name = wsound;
                Wheelclick[sid].playing = true;
            }
            last_played.visible = false;
            if(curr_sys == "Recent") set_last_played_txt();
        break;

        case Transition.StartLayout: //0
            if( fe.game_info (Info.Emulator) == "@" && global_fade(ttime, 255, true) ) return true; // fade when back to display menu or start layout

            if(var == FromTo.ScreenSaver) return false; //we are back from screensaver no need to continue

            //load custom romlists
            globs.customs_romlist_tb <- load_customs();
            //Sound -  cause we are back to main menu we use name to match the systeme we're leaving.
            Sound_System_In_Out.file_name = get_random_file( medias_path + fe.game_info(Info.Name) + "/Sound/System Exit/" );
            Sound_System_In_Out.playing = true;
            stats_text_update( fe.game_info(Info.Title) );
            local restart = false;
            if(!check_display("Recent") && my_config["Recent_Enabled"] == "Yes"){
                local filters = [];
                filters.push({"name":"All","sort_by":"Extra", "reverse_order":"true"});
                filters.push({"name":"Favourites","rule":"Favourite equals 1", "sort_by":"Title"});
                add_display( "Recent", ["yes","yes","yes"], filters);
                system ("mkdir " + (OS == "Windows" ? "" : "-p ") + "\"" + medias_path + "Main Menu/Images/Wheel/\"");
                local cop = "\"" + globs.script_dir + "images/Wheel/Recent-"+my_config["user_lang"]+".png" + "\"" + " " + "\"" + medias_path + "Main Menu/Images/Wheel/Recent.png" + "\"";
                if(OS == "Windows"){
                    system("copy " + replace(cop, "/","\\"));
                }else{
                   system("cp " + cop);
                }
                restart = true;
            }

            if(!check_display("Most Played") && my_config["Most_Played_Enabled"] == "Yes"){
                create_most_played();
                local filters = [];
                filters.push({"name":"All"});
                filters.push({"name":"Favourites","rule":"Favourite equals 1", "sort_by":"Title"});
                add_display( "Most Played", ["yes","yes","yes"], filters);
                system ("mkdir " + (OS == "Windows" ? "" : "-p ") + "\"" + medias_path + "Main Menu/Images/Wheel/\"");
                local cop = "\"" + globs.script_dir + "images/Wheel/Most Played-"+my_config["user_lang"]+".png" + "\"" + " " + "\"" + medias_path + "Main Menu/Images/Wheel/Most Played.png" + "\"";
                if(OS == "Windows"){
                    system("copy " + replace(cop, "/","\\"));
                }else{
                   system("cp " + cop);
                }
                restart = true;
            }

            if(!check_display("Favourites") && my_config["Global_Favourites_Enabled"] == "Yes"){
                create_favourites();
                local filters = [];
                //filters.push({"name":"All","sort_by":"Title"});
                add_display( "Favourites", ["yes","yes","yes"], filters);
                local cop = "\"" + globs.script_dir + "images/Wheel/Favourites-"+my_config["user_lang"]+".png" + "\"" + " " + "\"" + medias_path + "Main Menu/Images/Wheel/Favourites.png" + "\"";
                if(OS == "Windows"){
                    system("copy " + replace(cop, "/","\\"));
                }else{
                   system("cp " + cop);
                }
                restart = true;
            }
            if(!check_display("All Games") && my_config["All_Games_Enabled"] == "Yes"){
                create_all_games();
                local filters = [];
                //filters.push({"name":"All","sort_by":"Title"});
                filters.push({"name":"Favourites","rule":"Favourite equals 1", "sort_by":"Title"});
                add_display( "All Games", ["yes","yes","yes"], filters);
                system ("mkdir " + (OS == "Windows" ? "" : "-p ") + medias_path + "\"Main Menu/Images/Wheel/\"");
                system ( (OS == "Windows" ? "copy " : "cp ") + "\"" + globs.script_dir + "images/Wheel/All Games-"+my_config["user_lang"]+".png\"" +" \"" + medias_path + "Main Menu/Images/Wheel/All Games.png" + "\"" );
                restart = true;
            }

            if(check_display("Most Played") && my_config["Most_Played_Enabled"] == "No"){ delete_display("Most Played"); restart = true; }
            if(check_display("Recent") && my_config["Recent_Enabled"] == "No") { delete_display("Recent"); restart = true; }
            if(check_display("Favourites") && my_config["Global_Favourites_Enabled"] == "No") { delete_display("Favourites"); restart = true; }
            if(check_display("All Games") && my_config["All_Games_Enabled"] == "No") { delete_display("All Games"); restart = true; }

            if(restart){
                overlay_message(globs.script_dir + "images/warning.png");
                fe.overlay.list_dialog([], "The attract.cfg file has been modified AM needs to be restarted", 0, 0);
                fe.signal("exit_to_desktop")
            }
        break;

        case Transition.ToNewList: //6
            if (TOGame){
                TOGame = false;
                return false
            }
            curr_sys = ( fe.game_info(Info.Emulator) == "@" ? "Main Menu" : fe.list.name );
            if(Ini_settings["wheel"]["animation"] != "none" && wheel_animation.progress == 1.0){
                globs.next_tick_functions.push( function () { wheel_animation.reverse(true).duration(600).play() });
                globs.next_tick_functions.push( function () { FE_Sound_Wheel_Out.playing = true; });
            }else{
                wheel_surf.visible = false;
            }

            curr_emulator = (fe.game_info(Info.Emulator) == "@" ? "Main Menu" : fe.game_info(Info.Emulator));
            if(curr_sys == "Recent" || curr_sys == "Most Played") fe.list.index = 0;

            Ini_settings = get_ini_values(curr_sys); // get settings ini value
            if(curr_sys != "Main Menu"){
                if( fe.game_info(Info.PlayedTime) == "" ) PCount.set("visible", false); else PCount.set("visible", true); //show game stats surface only if Track Usage is set to Yes in AM!
                if(glob_time - rtime > 550) hide_art(); // 500ms between re-pooling hide_art when navigating fast in system
                syno_surf.visible = false; // hide overview
                m_infos.msg = ""; // empty global stats
                // Update and save stats if list size change and we are not on a filter !!
                if( my_config["stats_main"].tolower() == "yes" && glob_time && fe.list.search_rule == "" &&
                    ( fe.filters[fe.list.filter_index].name.tolower() == LnG.Filter_all || fe.filters[fe.list.filter_index].name.tolower() == "all" ) ){
                    if( main_infos.rawin(curr_sys) ){
                        if(fe.list.size != main_infos[curr_sys].cnt){
                            main_infos[curr_sys].cnt = fe.list.size;
                            rebuild_custom_romlists();
                            main_infos <- refresh_stats();
                        }
                    }else{ // new systeme added , create new entry (not in_cycle)
                        rebuild_custom_romlists();
                        main_infos <- refresh_stats();
                    }
                }
                Langue();
            }else{
                //on main menu and system count is different , refresh stats and custom romlists if (in_cycle)
                if( my_config["stats_main"].tolower() == "yes"){
                    if(fe.list.size != main_infos.len()){
                        rebuild_custom_romlists();
                        main_infos <- refresh_stats();
                    }
                }
            }

            if( glob_time ){  // when glob_time > 0 not startlayout
                local es = get_random_file( medias_path + curr_sys + "/Sound/System Start/" );
                if( es != "" ){ // if exit sound exist for this system
                    Sound_System_In_Out.file_name = es;
                    globs.next_tick_functions.push( function () { Sound_System_In_Out.playing = true; });
                }
            }

            rtime = glob_time
            triggers.theme.start = true;
            triggers.background_anim.start = false;
            surf_ginfos.visible = false;
            Background_Music.playing = false;
            triggers.background_music.start = false;
            ArtObj.snap.file_name = "";
            game_surface(); // user setting for game text infos
            last_played.visible = false;
            if(curr_sys == "Recent") set_last_played_txt();
        break;

        /* Custom Overlays */
        case Transition.ShowOverlay: // 8 var = Custom(0), Exit(22), Displays, Filters(15), Tags(31), Favorites(28)
            dialog_anim.cancel("origin"); // cancel dialog animation if in progress
            switch(var) {
                case Overlay.Filters: // = 15 Filters
                    overlay_title.set_pos( 0, flh*0.324, flw, flh*0.046);
                    overlay_title.set_rgb(192, 192, 192);
                    overlay_title.charsize = flw * 0.015;
                    overlay_background.file_name = "images/filters_overlay.png"; // 600 x 675
                    overlay_background.set_pos(flw*0.343, flh*0.187, flw*0.312, flh*0.625);
                    overlay_background.alpha = 250;
                    SetListBox(overlay_list, {visible = true, rows = 7, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.017 })
                    wheel_art.visible = false;
                    overlay_icon.visible = false;
                    FE_Sound_Screen_In.playing = true;
                break;

                case Overlay.Tags: //31 Tags
                    overlay_title.set_pos( 0, flh*0.324, flw, flh*0.046);
                    overlay_title.set_rgb(192, 192, 192);
                    overlay_title.charsize = flw * 0.015;
                    overlay_background.file_name = "images/tags_overlay.png";
                    overlay_background.set_pos(flw*0.312, flh*0.092, flw*0.385, flh*0.740);
                    overlay_background.alpha = 250;
                    SetListBox(overlay_list, {visible = true, rows = 7, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.017 })
                    wheel_art.visible = true;
                    overlay_icon.visible = false;
                    FE_Sound_Screen_In.playing = true;
                break;

                case 28: //28  favorites
                    overlay_title.set_pos( 0, flh*0.324, flw, flh*0.046);
                    overlay_title.set_rgb(192, 192, 192);
                    overlay_title.charsize = flw * 0.015;
                    overlay_background.file_name = "images/favorites_overlay.png";
                    overlay_background.set_pos(flw*0.312, flh*0.092, flw*0.385, flh*0.740);
                    overlay_background.alpha = 250;
                    SetListBox(overlay_list, {visible = true, rows = 5, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.032 })
                    wheel_art.visible = true;
                    overlay_icon.visible = false;
                    FE_Sound_Screen_In.playing = true;
                break;

                case Overlay.Exit: // = 22
                    ArtObj.snap.video_flags = Vid.NoAudio; // stop snap sound on exit screen show (AM cannot pause video ?)
                    overlay_background.file_name = medias_path + "Frontend/Images/Menu_Exit_Background_" + my_config["user_lang"] + ".png";
                    if(overlay_background.file_name == "") overlay_background.file_name = medias_path + "Frontend/Images/Menu_Exit_Background.png"; // if hyperspin default exit screen
                    overlay_background.set_pos(0,0,flw, flh);
                    SetListBox(overlay_list, {visible = true, rows = 3, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.050 })
                    wheel_art.visible = false;
                    overlay_title.msg = "";
                    overlay_icon.visible = false;
                    FE_Sound_Screen_In.playing = true;
                    Background_Music.playing = false;
                    triggers.background_music.start = false;
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
    prev_tr = ttype
}

//
// Ticks
//
fe.add_ticks_callback( "hs_tick" );
function hs_tick( ttime )
{
    if(pcca_wheel.progress) wheel_wait = true
    if(pcca_wheel.stop && wheel_wait){ // when wheel stop
        if(Ini_settings.pointer.animated) point_animation.play();
        if( my_config["stats_main"].tolower() == "yes" ) m_infos.visible = true;
        wheel_wait = false
    }
    glob_time=ttime;
    if(globs.signal == "default_sig"){
        if( fe.get_input_state("down") != false || fe.get_input_state("up") != false){
            globs.keyhold+=1;
        }else{
            globs.keyhold =-1;
        }
    }

    // temp fix bug in AM  https://github.com/mickelson/attract/issues/747
    if (globs.next_tick_functions.len() > 0) {
        local func = globs.next_tick_functions.pop();
        func();
    }

    // Background Music
    if(triggers.background_music.start == true && (glob_time - rtime > triggers.background_music.delay) ){
        Background_Music.playing = true;
        triggers.background_music.start = false;
    }

    if( Background_Music.playing || triggers.background_music.start){
        ArtObj.snap.video_flags = Vid.NoAudio;
    }else{
        if(!surf_inf.visible) ArtObj.snap.video_flags = Vid.Default; // do not restart snap sound if extra info screen is up
    }

    // screensaver
    if(my_config["screen_saver_timer"].tointeger() > 0){
        if(surf_menu.visible) globs.Stimer = fe.layout.time;
        if( (fe.layout.time-globs.Stimer) >= my_config["screen_saver_timer"].tointeger() * 1000 && pcca_wheel.stop ){
            fe.signal("screen_saver")
            globs.Stimer=fe.layout.time;
        }
    }

    // set all artwork and video visible after x ms next to triggerload except those who have width set to 0.1 (unhided later in animation preset)
    if( (glob_time - rtime > globs.delay + 150) && visi == false){
        foreach(obj in ["SpecialA", "SpecialB", "SpecialC", "artwork1", "artwork2", "artwork3", "artwork4", "artwork5", "artwork6", "video", "snap"] ) if(ArtObj[obj].width > 0.1 && ArtObj[obj].height > 0.1) ArtObj[obj].visible = true;
        visi = true;
    }
    if(!snap_is_playing && anim_video.elapsed > anim_video.opts.delay ){ // start playing video snap after animation delay
        ArtObj.snap.video_playing = true;
        snap_is_playing = true;
    }

    if( glob_time - rtime > globs.delay + 350) letters.visible = false; // if visible , hide letter search with a small delay

    // load medias after globs.delay
    if( (glob_time - rtime > globs.delay) && triggers.theme.start && (pcca_wheel.stop || pcca_wheel.spin_start)){

        if(prev_tr == Transition.ToNewList){
            wheel_coord(); // set wheel surface coord
            pcca_wheel.Init(Ini_settings.wheel); // slots, transition_ms, type, fade_delay, fade_time, alpha, curve, first_pos
        }
        hd = false;
        if( Ini_settings.themes["bezels"] && Ini_settings.themes["aspect"] == "center" ){ // Systems bezels!  only if aspect center
            if( file_exist(globs.script_dir + "images/Bezels/" + curr_emulator + ".png") ){
                ArtObj.bezel.file_name = globs.script_dir + "images/Bezels/" + curr_emulator + ".png";
            }else{
                if( !Ini_settings.themes["background_stretch"] )
                    ArtObj.bezel.file_name = globs.script_dir + "images/Bezels/Bezel_Main.png";
            }
        }else{
            ArtObj.bezel.file_name = globs.script_dir + "images/Bezels/Bezel_trans.png";
        }

        prev_path = path;
        overview(0);
        start_background.visible = false;
        local Rpath = medias_path + fe.game_info(Info.Emulator) + "/Themes/";
        if(curr_sys == "Main Menu") Rpath = medias_path + "Main Menu/Themes/";
        path = Rpath + fe.game_info(Info.Name) + "/"
        local theme_content = zip_get_dir( path );
        if(!theme_content.len()){
            path = Rpath + fe.game_info(Info.Name) + ".zip"
            theme_content = zip_get_dir( path );
        }

        // load transitions override video if enabled and not in the default system theme browsing
        if ( Ini_settings.themes["override_transitions"] &&
           ( theme_content.len() || (!theme_content.len() && curr_theme != "Default") ) )
        {
            local tr_cache  = get_dir_lists( medias_path + curr_emulator + "/Video/Override Transitions/" ); // cached table of global transitions files
            if( fe.game_info(Info.Name).tolower() in tr_cache){ // if transition exist for this game/system
                flv_transitions.file_name = tr_cache[fe.game_info(Info.Name).tolower()];
            }else if( (fe.game_info(Info.Category) in tr_directory_cache) ){ // if transitions exist for this game category ( in the frontend folder )
               flv_transitions.file_name = tr_cache[fe.game_info(Info.Category)]
            }else{ // else choose random transition from cached directory front-end
                if( tr_directory_cache.len() > 0 ) flv_transitions.file_name = get_random_table(tr_directory_cache);
            }

            flv_transitions.video_flags = Vid.NoAutoStart
            triggers.flv_transition.start = true;
        }

        if( !theme_content.len() ) { // if no theme is found .
            if(file_exist(medias_path + curr_emulator + "/Themes/" + fe.game_info(Info.Name) + ".mp4")){ // if mp4 is found assume it's unified video theme
                path = medias_path + curr_emulator + "/Themes/" + fe.game_info(Info.Name) + ".mp4";
                theme_content = [];
                ArtObj.bezel.file_name = globs.script_dir + "images/Bezels/Bezel_trans.png";
            }else if(curr_sys != "Main Menu"){ //if no video is found assume it's system default theme
                path = medias_path + curr_emulator + "/Themes/Default/";
                theme_content = zip_get_dir( path );
                if(!theme_content.len()){
                    path = medias_path + curr_emulator + "/Themes/Default.zip";
                    theme_content = zip_get_dir( path );
                }
            }
            /*}else{ //if no video is found assume it's system default theme
                path = medias_path + curr_emulator + "/Themes/Default/";
                theme_content = zip_get_dir( path );
                if(!theme_content.len() && curr_sys != "Main Menu"){
                    path = medias_path + curr_emulator + "/Themes/Default.zip";
                    theme_content = zip_get_dir( path );
                }
            }
            */

            if( prev_path == path && surf_menu.visible == false ){ // if previous and current theme is equal ( and we are not in edit mode ).
                reset_art(true);
                load_theme(path, theme_content, true);
                //foreach(a,b in artwork_list ) if( availables[b] == false ) anims[a].restart(); // not needed anymore (fot list without xml) ???  (in TEST disabled)
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

        triggers.theme.start = false;
        visi = false;
    }

    if(triggers.background_anim.start == true && bck_anim.progress == 1.0 && glob_time - rtime > globs.delay + (triggers.background_anim.delay * 1000)){ // start animate background
        background_anim.resting = true;
        triggers.background_anim.start = false;
    }

    if( triggers.flv_transition.start && glob_time - rtime > globs.delay + triggers.flv_transition.delay ){
        flv_transitions.visible = true;
        flv_transitions.video_flags = Vid.NoLoop;
        triggers.flv_transition.start = false;
    }

    // hide flv transition video when finished
    if ( flv_transitions.visible && !flv_transitions.video_playing )
    {
        flv_transitions.visible = false;
        flv_transitions.file_name = "";
    }

    if(triggers.letter.start == true && glob_time - rtime > triggers.letter.delay ){
        local firstl = fe.game_info(Info.Title);
        letters.file_name = medias_path + fe.list.name + "/Images/Letters/" + firstl.slice(0,1) + ".png";
        if(letters.file_name == "") letters.file_name = medias_path  + "Frontend/Images/Letters/" + firstl.slice(0,1) + ".png";
        FE_Sound_Letter_Click.playing = true;
        letters.visible = true;
        triggers.letter.start = false;
    }

    // syno scrolling
    if ( glob_time - rtime > 2500 && curr_sys != "Main Menu"){
        syno.x-=Ini_settings.themes.scroll_speed;
        if(syno.x <= -(syno.msg.len() * syno.charsize.tofloat() * 0.5) ) syno.x = syno_surf.width;
    }else if (curr_sys == "Main Menu"){
        syno.x-=Ini_settings.themes.scroll_speed;
        if(syno.x <= -(syno.msg.len() * syno.charsize.tofloat()) * 0.5 ) syno.x = syno_surf.width;
    }
    syno.charsize = syno_surf.height * 0.96;
}

// Menu
local artwork_anim_tab = [{"title":"Linear", "target":"linear"}, {"title":"Ease", "target":"ease"}, {"title":"Elastic", "target":"elastic"},
{"title":"Elastic Bounce","target":"elastic bounce"}, {"title":"Flip", "target":"flip"},{"title":"Fade", "target":"fade"}, {"title":"Bounce", "target":"bounce"},
{"title":"Blur", "target":"blur"}, {"title":"Pixelate", "target":"pixelate"}, {"title":"Zoom Out", "target":"zoom out"},{"title":"Pixelate Zoom-Out", "target":"pixelate zoom out"},
{"title":"Chase", "target":"chase"}, {"title":"Sweep Left", "target":"sweep left"}
];

artwork_anim_tab.extend( [{"title":"Sweep Right","target":"sweep right"}, {"title":"Strobe", "target":"strobe"}, {"title":"Grow", "target":"grow"}, {"title":"Grow Blur","target":"grow blur"},
{"title":"Grow Bounce", "target":"grow bounce"}, {"title":"Grow X", "target":"grow x"}, {"title":"Grow Y", "target":"grow y"}, {"title":"Grow Center Shrink", "target":"grow center shrink"},
{"title":"Scroll", "target":"scroll"}, {"title":"Flag", "target":"flag"}, {"title":"Pendulum", "target":"pendulum"}, {"title":"Stripes", "target":"stripes"}, {"title":"Stripes 2",
"target":"stripes 2"}, {"title":"Arc Grow", "target":"arc grow"}, {"title":"Arc Shrink", "target":"arc shrink"},{"title":"Bounce Random", "target":"bounce random"},
{"title":"Rain Float", "target":"rain float"}, {"title":"Bounce Around 3D", "target":"bounce around 3d"}, {"title":"Zoom", "target":"zoom"}, {"title":"Unzoom", "target":"unzoom"},
{"title":"Fade Out", "target":"fade out"}
]);

artwork_anim_tab.sort(@(a,b) a.title <=> b.title)
artwork_anim_tab.insert(0,{"title":"None", "target":"none"});
artwork_anim_tab.insert(1,{"title":"Random", "target":"random"});

local start_tab = [{"title":"None", "target":"none"},{"title":"Top", "target":"top"},{"title":"Bottom", "target":"bottom"},{"title":"Left", "target":"left"},{"title":"Right", "target":"right"}];

local borders = [{"title":"Shape", "target":"bshape"}, {"title":"Border1 Size", "target":"bsize"}, {"title":"Border 1 Color", "target":"bcolor"},
{"title":"Border2 Size", "target":"bsize2"}, {"title":"Border2 Color", "target":"bcolor2"}, {"title":"Border3 Size", "target":"bsize3"}, {"title":"Border3 Color", "target":"bcolor3"}];

local video_anim_tab = [{"title":"Pump","target":"pump"},{"title":"Fade","target":"fade"},{"title":"TV","target":"tv"},
{"title":"TV Zoom Out","target":"tv zoom out"},{"title":"Ease","target":"ease"},{"title":"Bounce","target":"bounce"},{"title":"Grow","target":"grow"},
{"title":"Grow X","target":"grow x"},{"title":"Grow Y","target":"grow y"},{"title":"Grow Bounce","target":"grow bounce"}];
video_anim_tab.sort(@(a,b) a.title <=> b.title)
video_anim_tab.insert(0,{"title":"None", "target":"none"});

local wheel_anim_tab = [{"title":"None","target":"none"},{"title":"Ease","target":"ease"},{"title":"Linear","target":"linear"},{"title":"Bounce","target":"bounce"},
{"title":"Elastic", "target":"elastic"}];

local game_text_anim_tab = [{"title":"None","target":"none"},{"title":"Ease","target":"ease"},{"title":"Linear","target":"linear"},{"title":"Bounce","target":"bounce"},
{"title":"Elastic", "target":"elastic"}];

local rest_tab = [{"title":"Shake", "target":"shake"}, {"title":"Rock", "target":"rock"}, {"title":"Rock Fast", "target":"rock fast"},
{"title":"Squeeze", "target":"squeeze"}, {"title":"Pulse", "target":"pulse"},{"title":"Pulse Fast", "target":"pulse fast"},{"title":"Hover", "target":"hover"},
{"title":"Hover Vertical", "target":"hover vertical"},{"title":"Hover Horizontal", "target":"hover horizontal"},{"title":"Spin","target":"spin"},
{"title":"Spin Slow","target":"spin slow"},{"title":"Spin Fast","target":"spin fast"}];
rest_tab.sort(@(a,b) a.title <=> b.title)
rest_tab.insert(0,{"title":"None", "target":"none"});

local wheel_pos_tab = [{"title":"Left","target":"left"},{"title":"Right","target":"right"},{"title":"Top","target":"top"},{"title":"Bottom","target":"bottom"}];
local wheel_media_tab = [{"title":"Wheel","target":"wheel"},{"title":"Cover","target":"artwork5"},{"title":"Support","target":"artwork6"},{"title":"Snap","target":"video"}];
local YesNo_menu = [{"title":LnG.Yes,"target":"yes"},{"title":LnG.No,"target":"no"}];

local menus = [];

//-- Main Menu (always index 0)
menus.push ({
    "title":"Main", "id":"main",
    "rows":[ {"title":"Theme", "target":"theme",
        "onselect":function(a,b){ // act as filter
            overlay_message();
            SetListBox(overlay_list, {visible = true, rows = 1, sel_alpha = 0, bg_alpha = 0, selbg_alpha = 0 })
            if(curr_sys == "Main Menu"){
                local p = medias_path + "Main Menu/Themes/" + fe.game_info(Info.Name) + "/";
                if( (file_exist(path) && strip_ext(path.tolower()) != "xml") ) {
                    overlay_message(globs.script_dir + "images/warning.png");
                    fe.overlay.list_dialog([], LnG.Uneditable, 0, 0)
                    return false;
                }else if(!zip_get_dir( p ).len()){
                    overlay_list.y = flh*0.261
                    SetListBox(overlay_list, {visible = true, rows = 4, sel_alpha = 255, bg_alpha = 0, selbg_alpha = 0 })
                    local selected = fe.overlay.list_dialog([ LnG.Create + " main menu theme", LnG.Cancel], LnG.Edit_Ask, 0, -1);
                    if(selected == 0){
                        system ("mkdir " + (OS == "Windows" ? "" : "-p ") + "\"" + p + "\"");
                        create_xml();
                        save_xml(xml_root, p);
                        overlay_message(globs.script_dir + "images/validate.png");
                        fe.overlay.list_dialog([], LnG.Create_folder)
                    }
                    return false;
                }
            }else{
                if( (file_exist(path) && strip_ext(path.tolower()) != "xml") || globs.custom_romlists.find(fe.list.name) != null ){
                    overlay_message(globs.script_dir + "images/warning.png");
                    fe.overlay.list_dialog([], LnG.Uneditable, 0, 0)
                    return false;
                }else{
                    local default_theme = false;

                    if( file_exist(medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + "/Theme.xml")){ // if game theme exist
                        return true;
                    }
                    if( file_exist(medias_path + curr_sys + "/Themes/Default/Theme.xml")) default_theme = true;

                    if(default_theme){ // if default theme exist but not game theme
                        SetListBox(overlay_list, {visible = true, rows = 4, sel_alpha = 255, bg_alpha = 0, selbg_alpha = 0 })
                        local selected = fe.overlay.list_dialog([ LnG.Edit + " default theme",  LnG.Create  + " game theme", LnG.Cancel], LnG.Edit_Ask, 2, -1);
                        if(selected == 0){
                            return true;
                        }else if(selected == 1){
                            system ("mkdir " + (OS == "Windows" ? "" : "-p ")  + "\"" + medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + "/");
                            create_xml();
                            save_xml(xml_root, medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + "/")
                            path = ""; // reset path forcing the theme to reload artworks
                            triggers.theme.start = true;
                            overlay_message(globs.script_dir + "images/validate.png");
                            fe.overlay.list_dialog([], LnG.Create_folder)
                        }
                        return false;
                    }else{ // ask to Create Default or game theme
                        SetListBox(overlay_list, {visible = true, rows = 4, sel_alpha = 255, bg_alpha = 0, selbg_alpha = 0 })
                        local selected = fe.overlay.list_dialog([LnG.Create + " default theme", LnG.Create + "game theme", LnG.Cancel], LnG.Edit_Ask, 1, -1);
                        if(selected == 0){
                            create_theme_struct(curr_sys);
                            system ("mkdir \"" + medias_path + curr_sys + "/Themes/Default/");
                            create_xml();
                            save_xml(xml_root, medias_path + curr_sys + "/Themes/Default/")
                            path = ""; // reset path forcing the theme to reload artworks
                            triggers.theme.start = true;
                            overlay_message(globs.script_dir + "images/validate.png");
                            fe.overlay.list_dialog([], LnG.Create_folder);
                        }else if(selected == 1){
                            system ("mkdir \"" + medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + "/");
                            create_xml();
                            save_xml(xml_root, medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + "/")
                            path = ""; // reset path forcing the theme to reload artworks
                            triggers.theme.start = true;
                            overlay_message(globs.script_dir + "images/validate.png");
                            fe.overlay.list_dialog([], LnG.Create_folder)
                        }
                        return false;
                    }
                }
            }
            return true;
        }
    },
    {"title":"Scraper", "target":"", "hide":"Main Menu"},

    {"title":LnG.M_inf_theme, "target":"theme_setting" },

    {"title":"Refresh Stats", "target":"", "hide":"!Main Menu",
        "onselect":function(current_list, selected_row){
            ::main_infos <- refresh_stats();
            return false;
        }
    },
    {"title":"Rebuild Custom Romlists", "target":"", "hide":"!Main Menu",
        "onselect":function(current_list, selected_row){
            rebuild_custom_romlists()
            return false;
        }
    },
    {"title":"Kiosk", "target":"kiosk"}
    ]
})

//-- Kiosk Menu
menus.push ({
    "title":"Theme Settings", "id":"kiosk",
    "rows":[{"title":"Add/Remove Favourites",
            "onselect":function(current_list, selected_row){
                set_list( { "title":"Favourites", "object":kiosk.add_fav, "slot_pos":(kiosk.add_fav ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            kiosk.add_fav = (selected_row.target == "yes" ? true : false)
                            fe.nv["kiosk_add_fav"] <- kiosk.add_fav
                        }
                });
                return true;
            }
        },
        {"title":"Add/Remove Tags",
            "onselect":function(current_list, selected_row){
                set_list( { "title":"Tags", "object":"", "slot_pos":(kiosk.add_tags ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            kiosk.add_tags = (selected_row.target == "yes" ? true : false)
                            fe.nv["kiosk_add_tags"] <- kiosk.add_tags
                        }
                });
                return true;
            }
        },
        {"title":"Exit AM",
            "onselect":function(current_list, selected_row){
                set_list( { "title":"Exit", "object":"", "slot_pos":(kiosk.exit ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            kiosk.exit = (selected_row.target == "yes" ? true : false)
                            fe.nv["kiosk_exit"] <- kiosk.exit
                        }
                });
                return true;
            }
        }
    ]
})

//-- Settings Menu
menus.push ({
    "title":"Theme Settings", "id":"theme_setting",
    "rows":[{"title":"Global settings", "target":"glob_theme_setting"},
            {"title":"Wheel", "target":"wheel", "target":"wheel_settings"},
            {"title":"Sounds", "target":"sound"},
            {"title":"Pointer","target":"pointer"},
            {"title":"Game Text", "target":"game_text", "infos":"Game info surface options" , "hide":"Main Menu"}, // (should not be displayed on main menu)
            {"title":"Special Artworks", "target":"special_list",
                "onselect":function(current_list, selected_row){
                    if(my_config["special_artworks"].tolower() == "no"){
                        overlay_message(globs.script_dir + "images/warning.png");
                        fe.overlay.list_dialog([], LnG.M_inf_Special_disabled, 0, 0)
                        return false;
                    }
                    return true;
                }
            },
            {"title":"Reset Default", "target":"",
                "onselect":function(current_list, selected_row){
                    Ini_settings = global_default_settings();
                    save_ini();
                    triggers.theme.start = true;
                    return true;
                },"infos":LnG.M_inf_theme_reset
            },
    ]
})

//-- Artworks edit menu
menus.push ({
    "title":"", "id":"artwork_menu", "object":"", // object: use as main object for all the menu
    "rows":[
        {"title":"pos/size/rotate",
            "onselect":function(current_list, selected_row){
                // current_list contain title of the artwork we are edit
                local anum = current_list.object.slice( 7, 8 ).tointeger() -1; // get the artwork index for anims array
                anims[anum].cancel(); // cancel all artworks animation
                artwork_shader[anum].set_param("alpha",1.0); // reset artwork shader to alpha 255
                artwork_shader[anum].set_param("datas",0,0,0,0); // reset artwork shader to no effect
                if(anims[anum].opts.rest && anum > -1) anims[anum].resting = false; // disable resting animation if enabled
                artworks_transform(current_list.object); // place the artwork in final fixed position
                //flipx(ArtObj[_obj]); // we must first know the flip status of the artwork
                surf_menu_info.visible = true;
                _edit_type = "pos/size/rotate";
                _slot[_slot_pos].set_bg_rgb(30, 240, 40); // set cell color on the menu
                globs.signal = "edit_sig";
            },
            "onback":function(selected_row, current_list){
                local anum = current_list.object.slice( 7, 8 ).tointeger() -1; // get the artwork index for anims array
                anims[anum].resting = true;
            }
        },
        {"title":"Keep Aspect",
            "onselect":function(current_list, selected_row){
                local elem = xml_root.getChild(current_list.object);
                set_list( { "title":"Keep Aspect", "object":current_list.object, "slot_pos":(elem.attr["keepaspect"] ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            xml_root.getChild(current_list.object).addAttr("keepaspect", (selected_row.target == "yes" ? true : false) );
                            save_xml(xml_root, path);
                            triggers.theme.start = true;
                        }
                });
                return true;
            }
        },

        {"title":"Animation",
            "onselect":function(current_list, selected_row){
                local elem = xml_root.getChild(current_list.object);
                local sel = 0;
                foreach(a,b in artwork_anim_tab){ if(b.target == elem.attr["type"]) sel = a; }
                set_list( {"title":"Animation", "object":current_list.object, "rows":artwork_anim_tab, "slot_pos":sel,
                    "onselect":function(current_list, selected_row){
                        xml_root.getChild(current_list.object).addAttr("type", (selected_row.target));
                        save_xml(xml_root, path);
                        triggers.theme.start = true;
                    }
                })
                return true;
            }
        },

        {"title":"Rest",
            "onselect":function(current_list, selected_row){
                local elem = xml_root.getChild(current_list.object);
                local sel = 0;
                foreach(a,b in rest_tab){ if(b.target == elem.attr["rest"]) sel = a; }
                set_list( {"title":"Artwork Rest", "object":current_list.object, "rows":rest_tab, "slot_pos":sel,
                    "onselect":function(current_list, selected_row){
                        xml_root.getChild(current_list.object).addAttr("rest", (selected_row.target));
                        save_xml(xml_root, path);
                        triggers.theme.start = true;
                    }
                })
                return true;
            }
        },

        {"title":"Start",
            "onselect":function(current_list, selected_row){
                local actual_value = xml_root.getChild(current_list.object).attr["start"];
                local sel = 0;
                foreach(a,b in start_tab){ if(b.target == actual_value) sel = a; }
                set_list( { "title":_selected_row.title, "slot_pos":sel,
                    "rows":start_tab, "object":current_list.object, "onselect":function(current_list, selected_row){
                        xml_root.getChild(current_list.object).addAttr("start", selected_row.target );
                        save_xml(xml_root, path);
                        triggers.theme.start = true;
                    }
                })
                return true;
            }
        },

        {"title":"Time", "type":"float",
            "onselect":function(current_list, selected_row){
                set_list( { "id":"time", "title":_selected_row.title, "target":"xml", "object":current_list.object, "values" : [0.0,60.0,0.1],
                    "rows":[{"title":xml_root.getChild(current_list.object).attr["time"]}]
                });
                return true;
            }

        },

        {"title":"Delay", "type":"float",
            "onselect":function(current_list, selected_row){
                set_list( { "id":"delay", "title":_selected_row.title, "target":"xml", "object":current_list.object, "values" : [0.0,60.0,0.1], "rows":[{"title":xml_root.getChild(current_list.object).attr["delay"]}] });
                return true;
            }
        },

        {"title":"Z-Order", "type":"int",
            "onselect":function(current_list, selected_row){
                try{ xml_root.getChild(current_list.object).attr["zorder"]} catch ( e ) {xml_root.getChild(current_list.object).addAttr("zorder", 0)}
                set_list( { "id":"zorder", "title":_selected_row.title, "target":"xml", "object":current_list.object, "values" : [-9,10,1], "rows":[{"title":xml_root.getChild(current_list.object).attr["zorder"]}] });
                return true;
            }
        },

        {"title":"Visible",
            "onselect":function(current_list, selected_row){
                try{ xml_root.getChild(current_list.object).attr["hidden"]} catch ( e ) {xml_root.getChild(current_list.object).addAttr("hidden", false)}
                set_list( { "title":_selected_row.title, "object":current_list.object, "slot_pos":(xml_root.getChild(current_list.object).attr["hidden"] ? 1 : 0),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            xml_root.getChild(current_list.object).addAttr("hidden", (selected_row.target == "yes" ? "false" : "true") );
                            save_xml(xml_root, path);
                            triggers.theme.start = true;
                        }
                });
                return true;
            }
        },

        {"title":"Random Artwork","hide":"!Main Menu",
            "onselect":function(current_list, selected_row){
                local rnd_l = [{"title":"None","target":"none"},{"title":"Artwork1","target":"artwork1"},{"title":"Artwork2","target":"artwork2"},{"title":"Artwork3","target":"artwork3"},
                {"title":"Artwork4","target":"artwork4"},{"title":"Artwork5","target":"artwork5"},{"title":"Artwork6","target":"artwork6"},{"title":"Video Snap","target":"video"},
                {"title":"Wheel","target":"wheel"}];
                local elem = xml_root.getChild(current_list.object);
                local sel = 0;
                foreach(a,b in rnd_l){ if(b.target == elem.attr["random"]) sel = a; }
                set_list( {"title":"Random Artwork", "object":current_list.object, "rows":rnd_l, "slot_pos":sel,
                    "onselect":function(current_list, selected_row){
                        xml_root.getChild(current_list.object).addAttr("random", (selected_row.target));
                        save_xml(xml_root, path);
                        triggers.theme.start = true;
                    }
                })
                return true;
            }
        }
    ]
})

//-- Video overlay Menu
menus.push({
    "title":"Video Overlay", "id":"video_overlay",
    "rows":[
        {"title":"Pos/Size",
            "onselect":function(current_list, selected_row){
                anim_video.cancel();
                anim_video.resting = false;
                video_shader.set_param("alpha", 1.0);
                video_shader.set_param("progress", 1.0);
                video_transform();
                //ArtObj.snap.pinch_x = 0;
                //ArtObj.snap.pinch_y = 0;
                globs.signal = "edit_sig";
                // check if nothing is missing in xml and add if needed !
                local child = xml_root.getChild("video");
                //try{ child.attr["overlaywidth"] } catch(e){ child.addAttr( "overlaywidth", ArtObj.video.texture_width ); }
                //try{ child.attr["overlayheight"] } catch(e){ child.addAttr( "overlayheight", ArtObj.video.texture_height ); }
                surf_menu_info.visible = true;
                _edit_type = "pos/size";
                _slot[_slot_pos].set_bg_rgb(30, 240, 40);
            }
        },
        {"title":"Overlay Below",
            "onselect":function(current_list, selected_row){
                set_list( { "title":_selected_row.title, "slot_pos":(xml_root.getChild("video").attr["overlaybelow"] ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            xml_root.getChild("video").addAttr("overlaybelow", (selected_row.target == "yes" ? true : false) );
                            video_transform()
                        }
                });
                return true;
            }
        }
    ]
})

//-- Theme Menu
menus.push({
    "title":"Theme", "id":"theme",
    "rows":[{
        "title":"Artworks",
        "onselect":function(current_list, selected_row){
            local art_av = [];
            foreach(a,b in zip_get_dir( path ) ){
                local artw = strip_ext(b).tolower();
                if(artwork_list_full.find(artw) != null){
                    if(artw != "video") art_av.push( artw );
                }
            }

            local refresh = false;
            foreach( v in ["artwork1","artwork2","artwork3","artwork4","artwork5","artwork6"] ) {
                if(!art_av.find(v)){
                    try{ local test = xml_root.getChild(v).attr;
                    }catch(e) {
                        //create a new node as a child of the current one if not exist
                        local f = ReadTextFile( globs.script_dir, "empty.xml" );
                        local raw_xml = "", tmp = null;
                        while ( !f.eos() ) raw_xml += f.read_line();
                        try{ tmp = xml.load( raw_xml ); } catch ( e ) { }
                        local node = XMLNode();
                        node = tmp.getChild(v);
                        xml_root.addChild(node);
                        refresh = true;
                    }
                    art_av.push(v);
                }
            }
            art_av = array_unique(art_av);
            art_av.sort();

            if(refresh){
                set_xml_datas(); // format xml datas
                save_xml(xml_root, path);
                triggers.theme.start = true;
            }

            /*if(!art_av.len()){
                overlay_icon.file_name = "images/warning.png";
                overlay_icon.visible = true;
                fe.overlay.list_dialog([], LnG.M_inf_No_Artworks, 0, 0)
                return;
            }
            */

            // create the artworks list menu
            local arts_list = {};
            arts_list.rows <- [];
            foreach(a,b in art_av ){
                arts_list.rows.push({"target":"artwork_menu","title":b,
                    "onselect":function(current_list, selected_row){
                        // set object we are edit
                        foreach(k,v in menus){
                            if(v.id == "artwork_menu"){
                                menus[k]["title"] = selected_row.title;
                                menus[k]["object"] = selected_row.title;
                            }
                        }
                        return true;
                    }
                });
            }
            _lists.push(_current_list);
            set_list( { "id":"art_lists", "title":"Artworks", "rows":arts_list.rows });
            titles();

            return false;
        }
    },
    {
        "title":"Video", "target":"video_menu"
    },
    {
        "title":"Video Overlay", "target":"video_overlay",
        "onselect":function(current_list, selected_row){
            if(!availables["video"]){
                overlay_icon.file_name = "images/warning.png";
                overlay_icon.visible = true;
                fe.overlay.list_dialog([], LnG.M_inf_No_Overlay, 0, 0)
                return false;
            }
            return true;
        }
    },
    {
        "title":"Background","target":"background_menu",
        "onselect":function(current_list, selected_row){
            try{ local test = xml_root.getChild("background").attr;
            }catch(e) {
                //create a new node as a child of the current one if not exist (temporary)
                local node = XMLNode();
                node.tag = "background";
                node.attr["rest"] <- "none";
                node.attr["speed"] <- 1.0;
                node.attr["delay"] <- 0;
                xml_root.addChild(node);
            }
            return true;
        }
    }
    ]
})

//-- Video Menu
menus.push({
    "title":"Video", "id":"video_menu", "object":"video", // object: use as main object for all the menu
    "rows":[{
        "title":"pos/size/rotate",
        "onselect":function(current_list, selected_row){
            anim_video.cancel();
            anim_video.resting = false;
            video_shader.set_param("alpha", 1.0);
            video_shader.set_param("progress", 1.0);
            video_transform();
            ArtObj.snap.pinch_x = 0;
            ArtObj.snap.pinch_y = 0;
            globs.signal = "edit_sig";
            surf_menu_info.visible = true;
            // we must verify and add if needed the missing tag in xml
            _edit_type = "pos/size/rotate";
            _slot[_slot_pos].set_bg_rgb(30, 240, 40);
        }
    },
    {"title":"Keep Aspect",
            "onselect":function(current_list, selected_row){
                set_list( { "title":"Keep Aspect", "slot_pos":(xml_root.getChild("video").attr["forceaspect"] ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            xml_root.getChild("video").addAttr("forceaspect", (selected_row.target == "yes" ? true : false) );
                            save_xml(xml_root, path);
                            triggers.theme.start = true;
                        }
                });
                return true;
            }
        },
    {"title":"Animations",
        "onselect":function(current_list, selected_row){
            local elem = xml_root.getChild("video");
            local sel = 0;
            foreach(a,b in video_anim_tab){ if(b.target == elem.attr["type"]) sel = a; }
            set_list( {"title":"Animation", "id":"video_anim", "rows":video_anim_tab,"slot_pos":sel,
                "onselect":function(current_list, selected_row){
                    xml_root.getChild("video").addAttr("type", (selected_row.target));
                    save_xml(xml_root, path);
                    triggers.theme.start = true;
                }
            })
            return true;
        }
    },

    {"title":"Rest",
        "onselect":function(current_list, selected_row){
            local sel = 0;
            foreach(a,b in rest_tab){ if(b.target == xml_root.getChild("video").attr["rest"]) sel = a; }
            set_list( {"title":"Video Rest", "id":"video_rest", "rows":rest_tab,"slot_pos":sel,
                "onselect":function(current_list, selected_row){
                    xml_root.getChild("video").addAttr("rest", (selected_row.target));
                    save_xml(xml_root, path);
                    triggers.theme.start = true;
                }
            })
            return true;
        }
    },

    {"title":"Borders", "target":"borders"
    },

    {"title":"Start",
        "onselect":function(current_list, selected_row){
            local sel = 0;
            foreach(a,b in start_tab){ if( b.target == xml_root.getChild("video").attr["start"] ) sel = a; }
            set_list( { "title":_selected_row.title, "slot_pos":sel,
                "rows":start_tab, "target":"", "onselect":function(current_list, selected_row){
                    xml_root.getChild("video").addAttr("start", selected_row.target );
                    save_xml(xml_root, path);
                    triggers.theme.start = true;
                }
            })
            return true;
        }
    },

    {"title":"Time", "target":"video", "type":"float",
        "onselect":function(current_list, selected_row){
            // id should be the name of the tag to be modified and target the type of file (ini or xml)
            set_list( { "id":"time", "title":_selected_row.title, "object":current_list.object, "target":"xml", "values" : [0.0,60.0,0.1], "rows":[{"title":xml_root.getChild("video").attr["time"]}] });
            return true;
        }
    },

    {"title":"Delay", "target":"video", "type":"float",
         "onselect":function(current_list, selected_row){
            set_list( { "id":"delay", "title":_selected_row.title, "object":current_list.object, "target":"xml", "values" : [0.0,60.0,0.1], "rows":[{"title":xml_root.getChild("video").attr["delay"]}] });
            return true;
        }
    },

    {"title":"Crt Scanline",
        "onselect":function(current_list, selected_row){
            set_list( { "title":_selected_row.title, "slot_pos":(xml_root.getChild("video").attr["crt_scanline"] ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        video_shader.set_param("scanline", (selected_row.target == "yes" ? 1 : 0 ) );
                        xml_root.getChild("video").addAttr("crt_scanline", (selected_row.target == "yes" ? true : false) );
                    }
            });
            return true;
        }
    },

    {"title":"Random Snap",
        "onselect":function(current_list, selected_row){
            set_list( { "title":_selected_row.title, "slot_pos":(xml_root.getChild("video").attr["random"] ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        xml_root.getChild("video").addAttr("random", (selected_row.target == "yes" ? true : false) );
                        save_xml(xml_root, path);
                        triggers.theme.start = true;
                    }
            });
            return true;
        }
    },
    ]
})

//-- Border Menu
menus.push({
    "title":"Border", "id":"borders",
    "rows":[{"title":"Shape", "target":"bshape",
                "onselect":function(current_list, selected_row){
                    set_list( { "title":_selected_row.title, "slot_pos":(xml_root.getChild("video").attr["bshape"] == "round" ? 0 : 1),
                        "rows":[{"title":"Round","target":"round"},{"title":"Square","target":"square"}],
                            "onselect":function(current_list, selected_row){
                                xml_root.getChild("video").addAttr("bshape", selected_row.target)
                                video_transform()
                            }
                    });
                    return true;
                }
            },
            {"title":"Border1 Size", "target":"video", "type":"int",
                "onselect":function(current_list, selected_row){
                    set_list( { "id":"bsize", "title":selected_row.title, "target":"xml", "object":"video", "values":[0,60,1], "rows":[{"title":xml_root.getChild("video").attr["bsize"] }] });
                    return true;
                }
            },
            {"title":"Border 1 Color", "target":"bcolor"},
            {"title":"Border2 Size", "target":"video", "type":"int",
                "onselect":function(current_list, selected_row){
                    set_list( { "id":"bsize2", "title":selected_row.title, "target":"xml", "object":"video", "values":[0,60,1], "rows":[{"title":xml_root.getChild("video").attr["bsize2"] }] });
                    return true;
                }
            },
            {"title":"Border2 Color", "target":"bcolor2"},
            {"title":"Border3 Size", "target":"video", "type":"int"
                "onselect":function(current_list, selected_row){
                    set_list( { "id":"bsize3", "title":selected_row.title, "target":"xml", "object":"video", "values":[0,60,1], "rows":[{"title":xml_root.getChild("video").attr["bsize3"] }] });
                    return true;
                }
            },
            {"title":"Border3 Color", "target":"bcolor3"}
    ],
    "afterload":function(current_list, selected_row){ // set border color after load
        local valc = 0;
        foreach(a,b in current_list.rows){
            if(b.target.find("bcolor") != null){
                try{ valc = xml_root.getChild("video").attr[b.target] } catch ( e ) {xml_root.getChild("video").addAttr(selected, "00000000")}
                local rgbC = dec2rgb(valc);
                _slot[a].set_bg_rgb(rgbC[0], rgbC[1], rgbC[2]);
                _slot[a].bg_alpha=0;
            }
        }
    },
    "onselect":function(current_list, selected_row){
        if(selected_row.target.find("bcolor") != null){
            local color = fe.overlay.edit_dialog("Enter color in HEX","").toupper();
            if(color == "") return false;
            xml_root.getChild("video").addAttr(selected_row.target, hex2dec(color));
            video_transform();
            local rgbC = dec2rgb(hex2dec(color));
            _slot[_current_list.slot_pos].set_bg_rgb(rgbC[0], rgbC[1], rgbC[2]);
        }
    }
})

//-- Theme Settings Menu
menus.push({
    "title":"Globals", "id":"glob_theme_setting",
    "rows":[{
        "title":"Overrides Transitions",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["override_transitions"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["override_transitions"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_flv
    },
    {
        "title":"Background Stretch",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["background_stretch"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["background_stretch"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_str_bckg
    },
    {
        "title":"Bezels",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["bezels"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["bezels"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_Bezel
    },
    {
        "title":"Bezels on top",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["bezels_on_top"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["bezels_on_top"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_Bezel_top
    },
    {
        "title":"Background Transitions",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["animated_backgrounds"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["animated_backgrounds"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_bck_trans
    },
    {
        "title":"Reload Backgrounds",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["reload_backgrounds"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["reload_backgrounds"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_reload_bck
    },
    {
        "title":"Aspect",
            "onselect":function(current_list, selected_row){
                set_list( { "title":_selected_row.title, "slot_pos":(Ini_settings.themes["aspect"] == "stretch" ? 0 : 1),
                    "rows":[{"title":LnG.M_Menu_stretch,"target":"stretch"},{"title":LnG.M_Menu_center,"target":"center"}],
                        "onselect":function(current_list, selected_row){
                            Ini_settings.themes["aspect"] = selected_row.target;
                            triggers.theme.start = true;
                        }
                });
                return true;
            },
            "infos" : LnG.M_inf_aspect
    },
    {
    "title":"Scrolling Text", "target":"scrolling_menu"

    }]
})

//-- Scrolling Text Menu
menus.push({
    "title":"Scrolling Text", "id":"scrolling_menu", "object":"syno_surf", // object: use as main object for all the menu
    "rows":[{
        "title":"Active",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["synopsis"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["synopsis"] = (selected_row.target == "yes" ? true : false);
                        syno_surf.visible = (selected_row.target == "yes" ? true : false)
                        syno.x = syno_surf.width; // reset scrolling test position
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_syno
    },
    {
        "title":"Main Menu Stats", "hide":"!Main Menu",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.themes["main_stats"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.themes["main_stats"] = (selected_row.target == "yes" ? true : false);
                        syno.x = syno_surf.width; // reset scrolling test position
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_main_stats
    },
    {
        "title":"Scrolling Text Position", "object":syno_surf,
            "onselect":function(current_list, selected_row){
                _slot[_slot_pos].set_bg_rgb(30, 240, 40); // set cell color on the menu
                current_list.object = selected_row.object;
                globs.signal = "edit_sig";
                _edit_type = "edit_obj";
                _edit_datas.name <- "syno_surf";
            },
            "onback":function(selected_row, current_list){
               Ini_settings["themes"]["scroll_pos"] = (syno_surf.x / flw) + "," + (syno_surf.y / flh) + "," + (syno_surf.width /flw) + "," + (syno_surf.height / flh) + "," + syno_surf.rotation;
            },
            "infos":LnG.M_inf_syno_pos
    },
    {
        "title":"Scrolling speed", "type":"float",
        "onselect":function(current_list, selected_row){
            set_list( { "id":"scroll_speed", "title":_selected_row.title, "target":"ini", "object":"themes", "values" : [0.1,5.0,0.1], "rows":[ {"title":format("%.1f", Ini_settings.themes["scroll_speed"]) }] });
            return true;
        },
        "infos" : LnG.M_inf_syno_speed
    }]
})

//-- Wheel Menu
menus.push({
    "title":"Wheel Settings", "id":"wheel_settings", "object":"",
    "rows":[{
        "title":"Wheel Type",
        "onselect":function(current_list, selected_row){
            local elem = Ini_settings.wheel["type"];
            local sel = 0;
            foreach(a,b in wheel_pos_tab){ if(b.target == elem) sel = a; }
            set_list( {"title":"Type", "rows":wheel_pos_tab,"slot_pos":sel,
                "onselect":function(current_list, selected_row){
                    Ini_settings.wheel["type"] = selected_row.target;
                    pointer_coord(Ini_settings.wheel["type"]);
                    wheel_coord(Ini_settings.wheel["type"]);
                    system_stats_coord(Ini_settings.wheel["type"]);
                    pcca_wheel.Init(Ini_settings.wheel);
                    //triggers.theme.start = true;
                }
            })
            return true;
        },
        "infos" : LnG.M_inf_wheel_type
    },
    {
        "title":"Rounded",
        "onselect":function(current_list, selected_row){
            wheel_surf.alpha = 255;
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.wheel["rounded"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.wheel["rounded"] = (selected_row.target == "yes" ? true : false);
                        pcca_wheel.Init(Ini_settings.wheel);
                        //triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_wheel_round
    },
    {
        "title":"Spin start",
        "onselect":function(current_list, selected_row){
            wheel_surf.alpha = 255;
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.wheel["spin_start"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.wheel["spin_start"] = (selected_row.target == "yes" ? true : false);
                        pcca_wheel.Init(Ini_settings.wheel);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_wheel_spinstart
    },
    {"title":"Animations",
        "onselect":function(current_list, selected_row){
            local elem = Ini_settings.wheel["animation"];
            local sel = 0;
            foreach(a,b in wheel_anim_tab){ if(b.target == elem) sel = a; }
            set_list( {"title":"Animation", "rows":wheel_anim_tab,"slot_pos":sel,
                "onselect":function(current_list, selected_row){
                    Ini_settings.wheel["animation"] = selected_row.target;
                    if(Ini_settings["wheel"]["animation"] != "none"){
                        wheel_surf.alpha = 255;
                        wheel_animation
                        .preset(Ini_settings["wheel"]["animation"])
                        .starting(Ini_settings["wheel"]["type"])
                        .duration(globs.delay)
                        .delay(triggers.wheel_anim.delay)
                        wheel_animation.play()
                    }
                    triggers.theme.start = true;
                }
            })
            return true;
        },
        "infos" : LnG.M_inf_wheel_anim
    },
    {
        "title":"Wheel transition time", "type":"int",
        "onselect":function(current_list, selected_row){
            set_list( { "id":"transition_ms", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [100,500,1],
            "rows":[{"title":Ini_settings.wheel["transition_ms"]}],
            "onselect":function(current_list, selected_row){ pcca_wheel.speed = Ini_settings.wheel["transition_ms"]; }});
            return true;
        },
        "infos" : LnG.M_inf_wheel_speed
    },
    {
        "title":"Wheel fade delay", "type":"float",
        "onselect":function(current_list, selected_row){
            set_list( { "id":"fade_delay", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [0.0,10.0,0.1],
            "rows":[ {"title":format("%.1f", Ini_settings.wheel["fade_delay"]) }],
            "onselect":function(current_list, selected_row){
                pcca_wheel.fade_delay = Ini_settings.wheel["fade_delay"] * 1000;
                pcca_wheel.reset_fade();
            }});
            return true;
        },
        "infos" : LnG.M_inf_wheel_fade_delay
    },
    {
        "title":"Wheel fade time", "type":"float",
        "onselect":function(current_list, selected_row){
            set_list( { "id":"fade_time", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [-1.0,60.0,0.5],
            "rows":[ {"title":format("%.1f", Ini_settings.wheel["fade_time"]) }],
            "onselect":function(current_list, selected_row){
                pcca_wheel.fade_time = Ini_settings.wheel["fade_time"] * 1000;
                pcca_wheel.reset_fade();
            }});
            return true;
        },
        "infos" : LnG.M_inf_wheel_fade
    },
    {
        "title":"Wheel fade alpha", "type":"float",
        "onselect":function(current_list, selected_row){
            set_list( { "id":"alpha", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [0.0,1.0,0.1],
            "rows":[ {"title":format("%.1f", Ini_settings.wheel["alpha"])}], "onselect":function(current_list, selected_row){ pcca_wheel.fade_alpha = Ini_settings.wheel["alpha"]; }});
            return true;
        },
        "infos" : LnG.M_inf_wheel_fade_val
    },
    {
        "title":"Number of wheel", "type":"int",
        "onselect":function(current_list, selected_row){
            set_list( { "id":"slots", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [4,12,1],
            "rows":[{"title":Ini_settings.wheel["slots"]}], "onselect":function(current_list, selected_row){ pcca_wheel.Init(Ini_settings.wheel); }
            });
            return true;
        },
        "infos" : LnG.M_inf_wheel_slots
    },
    {
        "title":"Curve", "type":"float",
        "onselect":function(current_list, selected_row){
            wheel_surf.alpha = 255;
            set_list( { "id":"curve", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [1,5,0.1],
            "rows":[{"title":Ini_settings.wheel["curve"]}], "onselect":function(current_list, selected_row){ pcca_wheel.Init(Ini_settings.wheel); }
            });
            return true;
        },
        "infos" : LnG.M_inf_wheel_curve
    },
    {
        "title":"Elements Size", "type":"float",
        "onselect":function(current_list, selected_row){
            wheel_surf.alpha = 255;
            set_list( { "id":"scale", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [0.5,5.0,0.05],
            "rows":[{"title":Ini_settings.wheel["scale"]}],"onselect":function(current_list, selected_row){ pcca_wheel.Init(Ini_settings.wheel); }
            });
            return true;
        }
    },
    {
        "title":"Center Zoom", "type":"float",
        "onselect":function(current_list, selected_row){
            wheel_surf.alpha = 255;
            set_list( { "id":"center_zoom", "title":_selected_row.title, "target":"ini", "object":"wheel", "values" : [0.5,5.0,0.1],
            "rows":[{"title":Ini_settings.wheel["center_zoom"]}],"onselect":function(current_list, selected_row){ pcca_wheel.Init(Ini_settings.wheel); triggers.theme.start = true; }
            });
            return true;
        },
        "infos" : LnG.M_inf_wheel_center_zoom
    },
    {"title":"Medias",
        "onselect":function(current_list, selected_row){
            wheel_surf.alpha = 255;
            local elem = Ini_settings.wheel["media"];
            local sel = 0;
            foreach(a,b in wheel_media_tab){ if(b.target == elem) sel = a; }
            set_list( {"title":"Animation", "rows":wheel_media_tab,"slot_pos":sel,
                "onselect":function(current_list, selected_row){
                    Ini_settings.wheel["media"] = selected_row.target;
                    pcca_wheel.Init(Ini_settings.wheel);
                    //triggers.theme.start = true;
                }
            })
            return true;
        },
        "infos" : LnG.M_inf_wheel_media
    },
    {
        "title":"Frame",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.wheel["frame"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.wheel["frame"] = (selected_row.target == "yes" ? true : false);
                        pcca_wheel.Init(Ini_settings.wheel);
                        //triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_wheel_frame
    },
    {
        "title":"Main stats", "object":m_infos, "hide":"!Main Menu",
            "onselect":function(current_list, selected_row){
                surf_menu_info.visible = true;
                current_list.object = selected_row.object; // assign m_infos object
                wheel_surf.alpha = 255;
                _slot[_slot_pos].set_bg_rgb(30, 240, 40); // set cell color on the menu
                globs.signal = "edit_sig";
                _edit_type = "edit_obj";
                _edit_datas.name <- "m_infos";
            },
            "onback":function(selected_row, current_list){
                Ini_settings["wheel"]["system stats"] = round(m_infos.x / flw, 4) + "," + round(m_infos.y / flh, 4) + "," + round(m_infos.rotation, 4);
            },"infos":LnG.M_inf_wheel_stats
    },
    {
        "title":"Fade stats with wheel", "object":m_infos, "hide":"!Main Menu",
            "onselect":function(current_list, selected_row){
                wheel_surf.alpha = 255;
                m_infos.alpha = 255;
                set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.wheel["fade_sys_stats"] == true ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings.wheel["fade_sys_stats"] = (selected_row.target == "yes" ? true : false);
                            pcca_wheel.Init(Ini_settings.wheel);
                            triggers.theme.start = true;
                        }
                });
            },"infos":"Fade stats with wheel surface"
    },
    {
        "title":"Position", "object":wheel_surf,
            "onselect":function(current_list, selected_row){
                pcca_wheel.mark_w.visible = true
                pcca_wheel.mark_h.visible = true
                wheel_surf.alpha = 255;
                pcca_wheel.fade_on = false;
                _slot[_slot_pos].set_bg_rgb(30, 240, 40); // set cell color on the menu
                current_list.object = selected_row.object;
                globs.signal = "edit_sig";
                wheel_surf.alpha = 255;
                _edit_type = "edit_obj";
                _edit_datas.name <- "wheel";
                surf_menu_info.visible = true;
            },
            "onback":function(selected_row, current_list){
                Ini_settings["wheel"]["coord"] = round(wheel_surf.x / flw, 4) + "," + round(wheel_surf.y / flh, 4) + "," + round(wheel_surf.width / flw, 4) + "," + round(wheel_surf.height / flh, 4) + "," + round(wheel_surf.rotation, 4);
                pcca_wheel.mark_w.visible = false
                pcca_wheel.mark_h.visible = false
            },
            "infos":LnG.M_inf_wheel_pos
    }]
})

//-- Game surface Menu
menus.push({
    "title":"Game text", "id":"game_text", "object":surf_ginfos,
    "rows":[{
        "title":"Position",
            "onselect":function(current_list, selected_row){
                surf_menu_info.visible = true;
                _slot[_slot_pos].set_bg_rgb(30, 240, 40); // set cell color on the menu
                globs.signal = "edit_sig";
                _edit_type = "edit_obj";
                _edit_datas.name <- "game text";
            },
            "onback":function(selected_row, current_list){
                Ini_settings["game text"]["coord"] = round(surf_ginfos.x / flw, 4) + "," + round(surf_ginfos.y / flh, 4) + "," + round(surf_ginfos.rotation, 4);
                if(Ini_settings["game text"]["animation"] != "none") triggers.theme.start = true;
            },"infos":LnG.M_inf_gsurf_pos
        },
        {"title":"Animations",
            "onselect":function(current_list, selected_row){
                local elem = Ini_settings["game text"]["animation"];
                local sel = 0;
                foreach(a,b in game_text_anim_tab){ if(b.target == elem) sel = a; }
                set_list( {"title":"Animation", "rows":game_text_anim_tab,"slot_pos":sel,
                    "onselect":function(current_list, selected_row){
                        Ini_settings["game text"]["animation"] = selected_row.target;
                        if(Ini_settings["game text"]["animation"] != "none"){
                            surf_ginfos_animation
                            .preset(Ini_settings["game text"]["animation"])
                            .starting(Ini_settings["game text"]["anim_start"])
                            .duration(Ini_settings["game text"]["anim_time"] * 1000)
                            .delay( globs.delay + (Ini_settings["game text"]["anim_delay"] * 1000) )
                            surf_ginfos_animation.play()
                        }
                        triggers.theme.start = true;
                    }
                })
                return true;
            }
        },
        {
        "title":"Animation Time", "type":"float",
            "onselect":function(current_list, selected_row){
                set_list( { "id":"anim_time", "title":_selected_row.title, "target":"ini", "object":"game text", "values" : [0,2,0.1], "rows":[{"title":Ini_settings["game text"]["anim_time"]}] });
                return true;
            },
            "infos" : "(Seconds)"
        },
        {"title":"Animation Delay", "type":"float",
            "onselect":function(current_list, selected_row){
                set_list( { "id":"anim_delay", "title":_selected_row.title, "target":"ini", "object":"game text", "values" : [0,2,0.1], "rows":[{"title":Ini_settings["game text"]["anim_delay"]}] });
                return true;
            },
            "infos" : "(Seconds)"
        },
        {"title":"Animation Start",
            "onselect":function(current_list, selected_row){
                local sel = 0;
                local elem = Ini_settings["game text"]["animation"]
                foreach(a,b in start_tab){ if( b.target == elem ) sel = a; }
                set_list( { "title":_selected_row.title, "slot_pos":sel,
                    "rows":start_tab, "target":"", "onselect":function(current_list, selected_row){
                        Ini_settings["game text"]["anim_start"] = selected_row.target;
                        triggers.theme.start = true;
                    }
                })
                return true;
            }
        },
        {
        "title":"Text Color", "target":"text_color"
            "onselect":function(current_list, selected_row){
                local color = fe.overlay.edit_dialog("Enter color in HEX","").toupper();
                if(color == "") return false;
                local rgbC = dec2rgb(hex2dec(color));
                _slot[_current_list.slot_pos].set_bg_rgb(rgbC[0], rgbC[1], rgbC[2]);
                Title.text_color( [rgbC[0], rgbC[1], rgbC[2]] );
                Ini_settings["game text"]["text_color"] = hex2dec(color);
            },"infos":LnG.M_inf_gametext_col
        },
        {
        "title":"Text strokecolor", "target":"text_stroke_color"
            "onselect":function(current_list, selected_row){
                local color = fe.overlay.edit_dialog("Enter color in HEX","").toupper();
                if(color == "") return false;
                local rgbC = dec2rgb(hex2dec(color));
                _slot[_current_list.slot_pos].set_bg_rgb(rgbC[0], rgbC[1], rgbC[2]);
                Title.thick_rgb([rgbC[0], rgbC[1], rgbC[2]]);
                Ini_settings["game text"]["text_stroke_color"] = hex2dec(color);
            },"infos":LnG.M_inf_gametext_stroke
        },
        {
        "title":"Visible",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["game_text_active"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["game_text_active"] = (selected_row.target == "yes" ? true : false);
                            (selected_row.target == "yes" ? surf_ginfos.visible = true : surf_ginfos.visible = false)
                            triggers.theme.start = true;
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext
        },
        {
        "title":"Hide when navigate",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["game_text_hide"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["game_text_hide"] = (selected_row.target == "yes" ? true : false);
                            triggers.theme.start = true;
                        }
                });
            },"infos":LnG.M_inf_gametext_hide
        },
        {
        "title":"Hide year line",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_year"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_year"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_year
        },
        {
        "title":"Hide language flags",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_lang"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_lang"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_lang
        },
        {
        "title":"Hide counter infos",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_counter"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_counter"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_counter
        },
        {
        "title":"Hide filter line infos",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_filter"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_filter"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_filter
        },
        {
        "title":"Hide rating logo",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_rating"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_rating"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_rating
        },
        {
        "title":"Hide players icon",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_players"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_players"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_players
        },
        {
        "title":"Hide category icons",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_category"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_category"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_category
        },
        {
        "title":"Hide country icons",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_country"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_country"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_country
        },
        {
        "title":"Hide controller icons",
            "onselect":function(current_list, selected_row){
                local actual_value = (Ini_settings["game text"]["hide_ctrl"] == true ? 0 : 1);
                set_list( { "title":selected_row.title, "slot_pos":actual_value,
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["game text"]["hide_ctrl"] = (selected_row.target == "yes" ? true : false);
                            game_surface();
                        }
                });
                return true;
            },"infos":LnG.M_inf_gametext_ctrl
    }],
    "afterload":function(current_list, selected_row){ // set cell color after load
        local valc = 0;
        foreach(a,b in current_list.rows){
            if( !("target" in b) ) continue;
            if(b.target.find("color") != null){
                valc = Ini_settings["game text"][b.target];
                local rgbC = dec2rgb(valc);
                _slot[a].set_bg_rgb(rgbC[0], rgbC[1], rgbC[2]);
                _slot[a].bg_alpha=0;
            }
        }
    }
})

//-- Sounds Menu
menus.push({
    "title":"Sounds", "id":"sound",
    "rows":[
    {"title":"Game Sound",
        "onselect":function(current_list, selected_row){
            local actual_value = (Ini_settings.sounds["game_sounds"] == true ? 0 : 1);
            set_list( { "title":selected_row.title, "slot_pos":actual_value,
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.sounds["game_sounds"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },"infos" : LnG.M_inf_game_sound
    },
    {"title":"Wheel click",
        "onselect":function(current_list, selected_row){
            local actual_value = (Ini_settings.sounds["wheel_click"] == true ? 0 : 1);
            set_list( { "title":selected_row.title, "slot_pos":actual_value,
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.sounds["wheel_click"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                    }
            });
            return true;
        },
        "infos" : LnG.M_inf_wheel_click
    }]
})

//-- Pointer Menu
menus.push({
    "title":"Pointer", "id":"pointer", "object":point,
    "rows":[
    {
        "title":"Position",
        "onselect":function(current_list, selected_row){
            _slot[_slot_pos].set_bg_rgb(30, 240, 40); // set cell color on the menu
            globs.signal = "edit_sig";
            _edit_type = "edit_obj";
            _edit_datas.name <- "pointer";
            surf_menu_info.visible = true;
            wheel_surf.alpha = 255;
            // set pointer to final position
            point_animation.yoyo(false);
            point_animation.play();
        },
        "onback":function(selected_row, current_list){
            unset_rotation(point.rotation, point);
            Ini_settings.pointer.coord = round(point.x / flw, 4) + "," + round(point.y / flh, 4) + "," + round(point.width /flw, 4) + "," + round(point.height / flh, 4) + "," + round(point.rotation, 4)
            pointer_coord();
            triggers.theme.start = true;
        },
        "infos" : LnG.M_inf_pointer_pos
    },

    {"title":"Animated pointer",
        "onselect":function(current_list, selected_row){
            set_list( { "title":selected_row.title, "slot_pos":(Ini_settings.pointer["animated"] == true ? 0 : 1),
                "rows":YesNo_menu,
                    "onselect":function(current_list, selected_row){
                        Ini_settings.pointer["animated"] = (selected_row.target == "yes" ? true : false);
                        triggers.theme.start = true;
                        if(selected_row.target == "yes") point_animation.yoyo(true); else point_animation.yoyo(false);
                        point_animation.play();
                    }
            });
            return true;
        },"infos" : LnG.M_inf_pointer_anim
    }
    ]
})

//-- Special Artworks List Menu
menus.push({
    "title":"Special Artworks", "id":"special_list", "object":"",
        "onselect":function(current_list, selected_row){
            // set special we are on
            foreach(k,v in menus){
                if(v.id == "special_menu"){
                    menus[k]["title"] = selected_row.title;
                    menus[k]["object"] = selected_row.object;
                }
            }
            return true;
        },
    "rows":[
        {"title":"Special A","target":"special_menu","object":ArtObj.SpecialA},
        {"title":"Special B","target":"special_menu","object":ArtObj.SpecialB},
        {"title":"Special C","target":"special_menu","object":ArtObj.SpecialC}
    ]
})

menus.push({
    "title":"Special Artworks", "id":"special_menu", "object":"",
    "rows":[
        {"title":"pos/size/rotate",
            "onselect":function(current_list, selected_row){
                surf_menu_info.visible = true;
                local spec = current_list.title.slice(8);
                foreach( i,n in ["A","B","C"] ){
                    anim_special[i].reset();
                    if(n != spec) ArtObj["Special" + n].file_name = ""; // disable all other specials
                }

                // set current edited special to final pos and restore shader alpha
                if( Ini_settings["special art "+spec.tolower()].x != 0 && Ini_settings["special art "+spec.tolower()].y != 0){
                    current_list.object.set_pos(Ini_settings["special art "+spec.tolower()].x * flw, Ini_settings["special art "+spec.tolower()].y * flh );
                }else{ // default bottom centered
                    current_list.object.set_pos(flw * 0.5 - ( (current_list.object.width  ) * 0.5), flh - ( (current_list.object.height )) );
                }

                current_list.object.shader.set_param("alpha", 1.0);

                _slot[_slot_pos].set_bg_rgb(30, 240, 40); // set cell color on the menu
                globs.signal = "edit_sig";
                _edit_type = "edit_obj";
                _edit_datas.name <- "special";
            },
            "onback":function(selected_row, current_list){
                local spec = current_list.title.slice(8);
                Ini_settings["special art "+spec.tolower()].x = (ArtObj["Special"+spec].x / flw)
                Ini_settings["special art "+spec.tolower()].y = (ArtObj["Special"+spec].y / flh)
                Ini_settings["special art "+spec.tolower()].w = (ArtObj["Special"+spec].width / flw)
                Ini_settings["special art "+spec.tolower()].h = (ArtObj["Special"+spec].height / flh)
                Ini_settings["special art "+spec.tolower()].r = ArtObj["Special"+spec].rotation
                load_special(false);
            }
        },
        {"title":"Active",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                set_list( { "title":_selected_row.title, "slot_pos":(Ini_settings["special art "+spec].active == true ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["special art "+spec].active = (selected_row.target == "yes" ? true : false)
                            load_special(false);
                        }
                });
            }
        },
        {"title":"Start",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                local sel = 0;
                foreach(a,b in start_tab){ if(b.target == Ini_settings["special art "+spec].start) sel = a; }
                set_list( { "title":_selected_row.title, "slot_pos":sel,
                    "rows":start_tab, "target":"", "onselect":function(current_list, selected_row){
                        Ini_settings["special art "+spec].start = selected_row.target;
                        load_special(false);
                    }
                })
                return true;
            }
        },
        {"title":"Animations",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                local sel = 0;
                foreach(a,b in artwork_anim_tab){ if(b.target == Ini_settings["special art "+spec].type) sel = a; }
                set_list( {"title":"Animation", "id":"video_anim", "rows":artwork_anim_tab,"slot_pos":sel,
                    "onselect":function(current_list, selected_row){
                        Ini_settings["special art "+spec].type = selected_row.target;
                        load_special(false);
                    }
                })
                return true;
            }
        },
        {"title":"Default", "target":"",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                set_list( { "title":_selected_row.title, "slot_pos":(Ini_settings["special art "+spec]["default"] == true ? 0 : 1),
                    "rows":YesNo_menu,
                        "onselect":function(current_list, selected_row){
                            Ini_settings["special art "+spec]["default"] = (selected_row.target == "yes" ? true : false);
                            load_special(false);
                        }
                });
            }
        },
        {"title":"Time in", "target":"", "type":"float",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                set_list( { "id":"in", "title":_selected_row.title, "object":"special art "+spec, "target":"ini", "values" : [0.0,60.0,0.1],
                "rows":[{"title":Ini_settings["special art "+spec]["in"]}] });
                return true;
            }
        },
        {"title":"Time out", "target":"", "type":"float",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                set_list( { "id":"out", "title":_selected_row.title, "object":"special art "+spec, "target":"ini", "values" : [0.0,60.0,0.1],
                "rows":[{"title":Ini_settings["special art "+spec]["out"]}] });
                return true;
            }
        },
        {"title":"Time length", "target":"", "type":"float",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                set_list( { "id":"length", "title":_selected_row.title, "object":"special art "+spec, "target":"ini", "values" : [0.0,60.0,0.1],
                "rows":[{"title":Ini_settings["special art "+spec]["length"]}] });
                return true;
            }
        },
        {"title":"Delay", "target":"", "type":"float",
            "onselect":function(current_list, selected_row){
                local spec = current_list.title.slice(8).tolower();
                set_list( { "id":"delay", "title":_selected_row.title, "object":"special art "+spec, "target":"ini", "values" : [0.0,60.0,0.1],
                "rows":[{"title":Ini_settings["special art "+spec]["delay"]}] });
                return true;
            }
        }
    ]
})

//-- Background menu
local back_anim_tab = [{"title":"None", "target":"none"}, {"title":"Random Panning", "target":"random panning"},{"title":"Vertical Panning", "target":"vertical panning"},
{"title":"Horizontal Panning", "target":"horizontal panning"}];

menus.push ({
    "title":"Backgound", "id":"background_menu", "object":"background",
    "rows":[
        {"title":"Animation",
            "onselect":function(current_list, selected_row){
                local elem = xml_root.getChild(current_list.object);
                local sel = 0;
                foreach(a,b in back_anim_tab){ if(b.target == elem.attr["rest"]) sel = a; }
                set_list( {"title":"Animation", "object":current_list.object, "rows":back_anim_tab, "slot_pos":sel,
                    "onselect":function(current_list, selected_row){
                        xml_root.getChild(current_list.object).addAttr("rest", (selected_row.target));
                        save_xml(xml_root, path);
                        background_anim.resting = false;
                        rtime = glob_time
                        triggers.theme.start = true;
                    }
                })
                return true;
            }
        },
        {"title":"Speed", "target":"", "type":"float",
            "onselect":function(current_list, selected_row){
                set_list( { "id":"speed", "title":_selected_row.title, "object":current_list.object, "target":"xml", "values" : [0.1,5.0,0.1], "rows":[{"title":xml_root.getChild("background").attr["speed"]}],
                "onselect":function(current_list, selected_row){ // reset resting delay
                    background_anim.resting = false;
                    rtime = glob_time
                }
                });
                return true;
            }
        },
        {"title":"Delay", "target":"", "type":"float",
            "onselect":function(current_list, selected_row){
                set_list( { "id":"delay", "title":_selected_row.title, "object":current_list.object, "target":"xml", "values" : [0.0,10.0,0.1], "rows":[{"title":xml_root.getChild("background").attr["delay"]}],
                "onselect":function(current_list, selected_row){ // reset resting delay
                    background_anim.resting = false;
                    rtime = glob_time
                }
                });
                return true;
            }
        }
    ]
})

local sel_menu = SelMenu(menus, surf_menu, flh * 0.025);
local surf_menu_anim = PresetAnimation(surf_menu)
.from({x=-surf_menu.width})
.to({x=0})
.delay(0)
.duration(250)
.on("stop", function(anim){
    if(anim.opts.target.x == -surf_menu.width) anim.opts.target.visible = false;
})

local signals = {};

fe.add_signal_handler("main_signal")

function main_signal(str){
    globs.Stimer = fe.layout.time;
    return signals[globs.signal](str)
}

signals["move_sig"] <- function (str) {
    switch (str){
        case my_config["extra_artworks_key"]:
            if(sel_menu._edit_type != "edit_obj"){
                globs.signal = "default_sig";
                sel_menu.reset();
                surf_inf_anim.reverse(true).play();
                return true;
            }
        break;

        case "back":
             if(sel_menu._edit_type == "edit_obj"){
                sel_menu._edit_type = null;
                surf_txt.set_rgb( 241, 250, 200 ); //restore surf_txt when leaving move mode
                return true;
            }else{
                globs.signal = "default_sig";
                sel_menu.reset();
                surf_inf_anim.reverse(true).play();
                return true;
            }
            return true;
        break;

        case "select":
            if(sel_menu._edit_type == "edit_obj"){
                sel_menu._edit_type = null;
                surf_txt.set_rgb( 241, 250, 200 ); //restore surf_txt when leaving move mode
                return true;
            }else{
                sel_menu._edit_datas.name <- "spec_art";
                sel_menu._current_list.object <- surf_img;
                sel_menu._edit_type = "edit_obj";
                surf_txt.set_rgb( 255, 10, 10 ); // set txt in red to specify we are on move mode
                surf_img.preserve_aspect_ratio = true;
            }
        break;

        case "up":
            if(sel_menu._edit_type != "edit_obj") fe.signal("prev_game");
        break;

        case "down":
            if(sel_menu._edit_type != "edit_obj") fe.signal("next_game");
        break;

        case "left":
        case "right":
            if(sel_menu._edit_type != "edit_obj") extraArtworks.setImage(str);
        break;
    }

    if(str == "next_game" || str == "prev_game") return false;

    return true;
}

signals["edit_sig"] <- function (str) {
    if ( str == "back" ){
        surf_menu_info.msg = "";
        surf_menu_info.visible = false;
        sel_menu._slot[sel_menu._current_list.slot_pos].set_bg_rgb(150,100,100); // restore cell color on the current selected menu slot
        if(sel_menu._selected_row.title.find("artwork") != null){
            local anum = sel_menu._selected_row.title.slice( 7, 8 ).tointeger() -1; // get the artwork index for anims array
            if(anims[anum].opts.rest){
                triggers.theme.start = true; // don't restart animation otherwise new xml coord are not used by the anim class
            }
            save_xml(xml_root, path)
        }
        // restore special when back from edit mode
        if(my_config["special_artworks"].tolower() == "yes"){
           ArtObj.SpecialA.visible = true;
           ArtObj.SpecialB.visible = true;
           ArtObj.SpecialC.visible = true;
        }
        // execute onback function when back from pos/size/edit
        if( sel_menu._selected_row.rawin("onback") && typeof(sel_menu._selected_row.onback) == "function"){
            local onback = sel_menu._selected_row.onback;
            onback(sel_menu._selected_row, sel_menu._current_list);
        }
        globs.signal = "menu_sig";
        sel_menu._edit_type = null
    }
    return true;
}

signals["default_sig"] <- function (str) {
    if(str == "configure" && kiosk.enabled) return true;
    if(str == "exit" && kiosk.enabled && !kiosk.exit) return true;

    if(curr_sys == "Main Menu"){ //disable some buttons on main-menu
        switch ( str )
        {
            case my_config["keyboard_search_key"]:
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
    }else if(search.state > 0){
        switch ( str )
        {
            case my_config["keyboard_search_key"]:
            case "up":
            case "down":
            case "left":
            case "right":
            case "select":
            case "back":
            case "exit":
            return false;
        }
        return true;
    }

    switch( str ) {
        case "prev_page":
        case "next_page":
            FE_Sound_Wheel_Jump.playing = true;
        break;

        case "next_display":
        case "prev_display":
            if(curr_sys == "Main Menu") return true;
            letters.visible = false;
            text_overlay.visible = true;
            text_overlay.msg = "";
            local cycle_display = [];
            foreach(b in fe.displays) if(b.in_cycle) cycle_display.push(b.name);
            local idx = cycle_display.find(curr_sys);
            idx = (str == "next_display" ? (idx + 1) % cycle_display.len() : (idx - 1 + cycle_display.len()) % cycle_display.len());
            img_overlay.file_name = medias_path + "Main Menu/Images/Wheel/" + cycle_display[idx] + ".png";
            if(img_overlay.file_name == "") text_overlay.msg = cycle_display[idx];
            img_overlay.width = flw * 0.3;
            img_overlay.height = img_overlay.width  / ( img_overlay.texture_width.tofloat() / img_overlay.texture_height.tofloat() );
            img_overlay.x = flw * 0.5 - img_overlay.width * 0.5;
            img_overlay.y = flh * 0.5 - img_overlay.height * 0.5;
            overlay_surf.visible = true;
            overlay_surf_anim.reverse(false).duration(100).play();
            foreach(v in [top_left_ico,top_right_ico,bottom_left_ico,bottom_right_ico]) v.visible = false; // Immediately hide the battery icons.
        break;

        case "next_game":
        case "prev_game":
            if(triggers.theme.start && prev_tr == Transition.ToNewList) return true; // disable wheel navigation until the theme is fully loaded
            letters.visible = false;
            if( globs.keyhold < 1 &&  Ini_settings.sounds["wheel_click"] ) Sound_Click.playing = true;
        break;

        case "next_letter":
        case "prev_letter":
            triggers.letter.start = true;
        break;

        case my_config["extra_artworks_key"] : // Extra artworks screen
            local spec_list = extraArtworks.getLists();
            if(!spec_list.len()){
                dialog_anim.cancel("origin"); // cancel dialog animation if in progress
                dialog_text.msg = LnG.M_inf_No_Artworks;
                dialog_anim.play();
                break;
            }

            extraArtworks.setImage();
            surf_inf.visible = true;
            surf_inf_anim.reverse(false).play();
            globs.signal = "move_sig";
        break;

        case my_config["main_menu_key"] : // Main menu Key
            if(kiosk.enabled) return true;
            surf_menu.visible = true;
            surf_menu_anim.reverse(false).play();
            globs.signal = "menu_sig";
            sel_menu.set_list( menus[0] );
            return true;
        break;

        case my_config["help_screen_key"] : // Help Screen Key
            globs.signal = "overlay_sig";
            overlay_surf_anim.reverse( (overlay_surf.visible ? true : false) ).duration(500).play();
            if(overlay_surf.visible) return false;
            overlay_surf.visible = true;
            img_overlay.file_name = "images/help_screen.png";
            img_overlay.set_pos(0, 0, flw, flh);
            foreach(v in [top_left_ico,top_right_ico,bottom_left_ico,bottom_right_ico]) v.visible = true;
            if(overlay_surf.visible && OS == "Windows" && my_config["JoyType"]  == "Xinput"){ // only win for now
                local aexec = globs.script_dir + "PCCA-XInput.exe";
                fe.plugin_command( "cmd", "/c " + aexec, "battery_status");
            }
            return true;
        break;

        case "random_game":
            surf_ginfos.visible = false;
        break;

        case "add_favourite":
            if(kiosk.enabled && !kiosk.add_fav) return true;
            if(globs.custom_romlists.find(curr_sys) != null){
                local add = false;
                overlay_hide.visible = false;
                overlay_background.visible = true;
                if(curr_sys == "Favourites" || fe.game_info(Info.Extra).find("f") != null){
                    overlay_title.msg = LnG.ret_fav2;
                }else{
                    overlay_title.msg = LnG.add_fav2;
                    add = true;
                }
                overlay_title.set_pos( 0, flh*0.324, flw, flh*0.046);
                overlay_title.set_rgb(192, 192, 192);
                overlay_title.charsize = flw * 0.015;
                overlay_background.file_name = "images/favorites_overlay.png";
                overlay_background.set_pos(flw*0.312, flh*0.092, flw*0.385, flh*0.740);
                SetListBox(overlay_list, {visible = true, rows = 5, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.032 })
                wheel_art.visible = true;
                overlay_icon.visible = false;
                FE_Sound_Screen_In.playing = true;
                local add_fav = fe.overlay.list_dialog([LnG.Yes,LnG.No], overlay_title.msg, 1, -1);
                if(add_fav == 0){
                    update_favourites(add);// update favourites everywhere
                    if(add) dialog_text.msg = LnG.add_fav; else dialog_text.msg = LnG.ret_fav;
                    //if(curr_sys == "Favourites"){// simulate reload list to refresh the global favourites list ....
                        fe.signal("prev_list")
                        fe.signal("next_list")
                    //}
                    dialog_anim.play();
                }
                return true; // showoverlay launched
            }
        break;

        case "add_tags":
            if(!kiosk.enabled){
                return false;
            }else{
                if(!kiosk.add_tags) return true;
            }
            overlay_title.set_pos( 0, flh*0.324, flw, flh*0.046);
            overlay_title.set_rgb(192, 192, 192);
            overlay_title.charsize = flw * 0.015;
            overlay_background.file_name = "images/tags_overlay.png";
            overlay_background.set_pos(flw*0.312, flh*0.092, flw*0.385, flh*0.740);
            overlay_background.alpha = 250;
            SetListBox(overlay_list, {visible = true, rows = 7, sel_rgba = [255,0,0,255], bg_alpha = 0, selbg_alpha = 0, charsize = flw * 0.017 })
            wheel_art.visible = true;
            overlay_icon.visible = false;
            FE_Sound_Screen_In.playing = true;

            local tags_file = TagFileLister(); // file list of .tag for the system we are on
            local tags = []
            local tag0 = fe.game_info(Info.Tags);
            local tagarr = split(tag0, ";")
            foreach (tag in tagarr) tags.push(tag);
            local tag_filters = []
            foreach(a,b in fe.filters){ tag_filters.push(b.name) }
            local taglist = []
            local tag_idx = []
            foreach(a,b in tags_file){
                if(tag_filters.find(b) == null){
                    if(tags.find(b) != null){
                        taglist.push(LnG.rem_tag + " '" + b + "'")
                        tag_idx.push({"name" : b, "add": false})
                    }else{
                        taglist.push(LnG.add_tag + " '" + b + "'")
                        tag_idx.push({"name" : b, "add": true})
                    }
                }
            }

            taglist.push(LnG.Close)

            local select_tags = fe.overlay.list_dialog(taglist, overlay_title.msg, 0, -1);
            if( select_tags < taglist.len()-1 && select_tags >-1){
                print("la selection est " + select_tags + "sur " + taglist.len() + "donc:"+taglist[select_tags]+"\n");
                update_tags(globs.config_dir + "romlists/" + curr_sys, tag_idx[select_tags].name ,tag_idx[select_tags].add) // update system tag file
                fe.set_display(fe.list.display_index);
            }
            return true;
        break;

    }
    return false
}

signals["menu_sig"] <- function (str) {

    switch ( str ) {
        case my_config["main_menu_key"] : // Main menu Key
            surf_menu_anim.reverse(true).play();
            surf_menu_img.file_name = "";
            globs.signal = "default_sig";
            save_xml(xml_root, path);
            save_ini();
            sel_menu.reset();
        break;
        case "up":
            sel_menu.up();
            if(sel_menu._selected_row.rawin("type")) incdec(sel_menu._selected_row.type, sel_menu._current_list, "up" )
            show_menu_artwork( sel_menu, surf_menu_img, artwork_list );
        break;
        case "down":
            sel_menu.down();
            if(sel_menu._selected_row.rawin("type")) incdec(sel_menu._selected_row.type, sel_menu._current_list, "down" )
            show_menu_artwork( sel_menu, surf_menu_img, artwork_list );
        break;
        case "select":
            local selected = sel_menu.select(path);
            show_menu_artwork( sel_menu, surf_menu_img, artwork_list );
        break;
        case "back":
            //save_xml(xml_root, path);
            sel_menu.back();
            if(sel_menu._current_list.title == "Theme") surf_menu_img.visible = false; // when back from menu artworks , hide artwork image
        break;
    }

    return true;
}

signals["overlay_sig"] <- function (str) {
    switch ( str ) {
        case my_config["help_screen_key"] :
        case "back":
            overlay_surf_anim.reverse( (overlay_surf.visible ? true : false) ).duration(500).play();
            globs.signal = "default_sig";
        break;
    }
    return true;
}

function incdec(type, datas,  dir ){
    local object = datas.object;
    local fsetting = datas.target; // target contain the file extension to be modified
    local minmaxstep = datas.values;  // array [min,max,step]
    local val;
    if(fsetting == "xml"){
        val = xml_root.getChild(object).attr[datas.id];
    }else if(fsetting == "ini"){
        val = Ini_settings[object][datas.id];
    }
    val = ( type == "float" ? round( val , 2) : val.tointeger() );
    if(dir == "up"){
        val+=minmaxstep[2];
        if(val >= minmaxstep[1]) val = minmaxstep[1];
    }else{
        val-=minmaxstep[2]
        if( val <= minmaxstep[0] ) val = minmaxstep[0];
    }

    sel_menu.set_text(0,  (type == "float" ? format("%.1f", val) : val.tointeger() ) )
    if(sel_menu._current_list.id.find("bsize") != null) video_transform(); // if bsize update shader in real time
    if(sel_menu._current_list.id.find("zorder") != null){ // if zorder update z-order in real time
        ArtObj[object].zorder = val;
        zorder_list();
    }

    if(fsetting == "xml"){
        xml_root.getChild(object).addAttr(sel_menu._current_list.id, val )
    }else if(fsetting == "ini"){
        Ini_settings[object][sel_menu._current_list.id] = val;
    }

    if(sel_menu._current_list.id.find("scale") != null){ // update scale of the wheel elems in real time
        pcca_wheel.Init(Ini_settings.wheel);
    }
}

// Apply a global fade on objs and shaders
function global_fade(ttime, target, direction){
   local normalized = clamp(ttime / target, 0, 1);
    if(direction){ // show
       fades.alpha = 255 * (1 - normalized)
    }else{
       fades.alpha = 255 * normalized;
    }
    if(fades.alpha == 0) fades.visible = false; else fades.visible = true

   return normalized < 1
}

function zorder_list(){
    surf_menu_info.msg = "a1:" + ArtObj["artwork1"].zorder + " a2:" + ArtObj["artwork2"].zorder + " a3:" + ArtObj["artwork3"].zorder;
    surf_menu_info.msg += "a4:" + ArtObj["artwork4"].zorder + " a5:" + ArtObj["artwork5"].zorder + " a6:" + ArtObj["artwork6"].zorder + " snap:" + ArtObj["snap"].zorder;
}

function g_input(inp){
    foreach(a,b in controls[inp]){
        if(fe.get_input_state(b) != false) return true;
    }
    return false;
}

function edit_obj(obj, datas){ // edit for pos/size/rotate of object

    local mr = PI * obj.rotation / 180;
    obj.x -= cos( mr ) * (-obj.width * 0.5) - sin( mr ) * (-obj.height * 0.5) + obj.width * 0.5;
    obj.y -= sin( mr ) * (-obj.width * 0.5) + cos( mr ) * (-obj.height * 0.5) + obj.height * 0.5;

    local set = false;
    local w = obj.width;
    local h = obj.height;
    local x = obj.x;
    local y = obj.y;
    local r = obj.rotation;
    local speed = globs.keyhold * 0.10;
    local step = ( !speed ? 0.1 : (speed >=1 ? clamp( speed * 0.1  , 0.1 , 8.00) : 0.0) );
    if(datas.name == "spec_art") step = 5.0;


    if( g_input("Right") ) set = x+=step;
    if( g_input("Left") ) set = x-=step;
    if( g_input("Up") ) set = y-=step;
    if( g_input("Down") ) set = y+=step;

    if(datas.name != "spec_art"){ // for special screen not special artworks !!!
        if( g_input("C") ) {
            if(r > 360) r = 0.0;
            set = r+=step; // rotate cw
        }
        if( g_input("CW") ) {
            if(r < -360) r = 0.0;
            set = r-=step; // rotate cw
        }
    }

    if(datas.name != "game text" && datas.name != "m_infos"){
        if(obj.preserve_aspect_ratio == true){
            if( g_input("ZWP") || g_input("ZHP")){
                set = w+=step;
                x -= step * 0.5
                y -= step * 0.5
            }
            if( g_input("ZWM") || g_input("ZHM")){
                set = w-=step;
                x += step * 0.5
                y += step * 0.5
            }
            h = w / ( obj.texture_width.tofloat() / obj.texture_height.tofloat() );
        }else{
            if( g_input("ZWP") ){
                set = w+=step; // zoom width +
                x -= step * 0.5
            }
            if( g_input("ZWM") ){
                set = w-=step; // zoom width -
                x += step * 0.5
            }
            if( g_input("ZHP") ){
                set = h+=step; // zoom height +
                y -= step * 0.5
            }
            if( g_input("ZHM") ){
                set = h-=step; // zoom height -
                y += step * 0.5
            }
        }
    }

    if( g_input("HC") ) set = x = (flw * 0.5 - (w * 0.5));
    if( g_input("VC") ) set = y = (flh * 0.5 - (h * 0.5));


    surf_menu_info.msg = "x:" + format("%.1f", x ) + " y:" + format("%.1f", y) + " w:" + format("%.1f", w) + " h:" + format("%.1f", h) + " r:" + format("%.1f", r);

    if(set != false){
        obj.set_pos( x ,y );
        if(datas.name != "game text") {
            obj.width = w;
            obj.height = h;
        }
    }

    local mr = PI * r / 180;
    obj.x += cos( mr ) * (-obj.width * 0.5) - sin( mr ) * (-obj.height * 0.5) + obj.width * 0.5;
    obj.y += sin( mr ) * (-obj.width * 0.5) + cos( mr ) * (-obj.height * 0.5) + obj.height * 0.5;
    obj.rotation = r;

    return;
}

function edit_artworks(elem){ // edit for artworks pos/size/rotate
    local set = false;
    local child = xml_root.getChild(elem);

    if(!child) return;
    local r = child.attr["r"];
    local h = child.attr["h"];
    local w = child.attr["w"];
    local x = child.attr["x"];
    local y = child.attr["y"];

    local speed = globs.keyhold * 0.10;
    local step = ( !speed ? 0.1 : (speed >=1 ? clamp( speed * 0.1  , 0.1 , 8.00) : 0.0) );
    if( g_input("Right") ) set = child.addAttr("x", x+= step );
    if( g_input("Left") ) set = child.addAttr("x", x-= step );
    if( g_input("Up") ) set = child.addAttr("y", y-= step );
    if( g_input("Down") ) set = child.addAttr("y", y+= step );
    if( g_input("C") ) {
        if(r > 360) r = 0.0;
        set = child.addAttr("r", r+=step); // rotate c
    }
    if( g_input("CW") ) {
        if(r < -360) r = 0.0;
        set = child.addAttr("r", r-=step); // rotate cw
    }

    local set_aspect = (elem == "video" ? "forceaspect" : "keepaspect");

    if(child.attr[set_aspect]){
        if( g_input("ZWP") || g_input("ZHP")){
           set = child.addAttr("w", w+=step);
        }
        if( g_input("ZWM") || g_input("ZHM")){
           set = child.addAttr("w", w-=step);
        }
        child.addAttr("h", h = w / ( ArtObj[ (elem == "video" ? "snap" : elem) ].texture_width.tofloat() / ArtObj[(elem == "video" ? "snap" : elem)].texture_height.tofloat() ));
    }else{
        if( g_input("ZWP") ){
            set = child.addAttr("w", w+=step); // zoom width +
        }
        if( g_input("ZWM") ){
            set = child.addAttr("w", w-=step); // zoom width -
        }
        if( g_input("ZHP") ){
            set = child.addAttr("h", h+=step); // zoom height +
        }
        if( g_input("ZHM") ){
            set = child.addAttr("h", h-=step); // zoom height -
        }
    }

    if( g_input("HC") ) set = child.addAttr("x", x = xml_root.getChild("hd").attr.lw.tofloat() * 0.5);
    if( g_input("VC") ) set = child.addAttr("y", y = xml_root.getChild("hd").attr.lh.tofloat() * 0.5);

    surf_menu_info.msg = "x:" + format("%.1f", x) + " y:" + format("%.1f", y) + " w:" + format("%.1f", w) + " h:" + format("%.1f", h) + " r:" + format("%.1f", r);
    if(set != false){
        if(elem != "video") artworks_transform(elem) else video_transform();
    }
    return true;
}

function overlay_video(){
    if(!availables["video"]) return;
    local child = xml_root.getChild("video");
    local set = false;
    local overlayoffsetx = child.attr["overlayoffsetx"];
    local overlayoffsety = child.attr["overlayoffsety"];
    local overlaywidth = child.attr["overlaywidth"];
    local overlayheight = child.attr["overlayheight"];
    local speed = globs.keyhold * 0.10;
    local step = ( !speed ? 0.1 : (speed >=1 ? clamp( speed * 0.1  , 0.1 , 3.50) : 0.0) );

    if( g_input("Up") ) set = child.addAttr( "overlayoffsety", overlayoffsety-=step );
    if( g_input("Down") ) set = child.addAttr( "overlayoffsety", overlayoffsety+=step );
    if( g_input("Right") ) set = child.addAttr( "overlayoffsetx", overlayoffsetx+=step );
    if( g_input("Left") ) set = child.addAttr( "overlayoffsetx", overlayoffsetx-=step);
    if( g_input("ZWP") ) set = child.addAttr( "overlaywidth", overlaywidth+=step );
    if( g_input("ZWM") ) set = child.addAttr( "overlaywidth", overlaywidth-=step );
    if( g_input("ZHP") ) set = child.addAttr( "overlayheight", overlayheight+=step );
    if( g_input("ZHM") ) set = child.addAttr( "overlayheight", overlayheight-=step );
    if( g_input("HC") ) set = child.addAttr("overlayoffsetx", overlayoffsetx = step);
    if( g_input("VC") ) set = child.addAttr("overlayoffsety", overlayoffsety = step);

    surf_menu_info.msg = "offsetx:" + format("%.1f", overlayoffsetx) + " offsety:" + format("%.1f", overlayoffsety) + " w:" + format("%.1f", overlaywidth) + " h:" + format("%.1f", overlayheight);
    if(set != false) video_transform();

    return true;
}


function artworks_transform(Xtag, rotate=true, art=""){
    local artD = clone(xml_root.getChild(Xtag).attr);

    if(artD.keepaspect || !hd) artD.h = artD.w / ( ArtObj[Xtag].texture_width.tofloat() / ArtObj[Xtag].texture_height.tofloat() );

    if( !artD.w || !artD.h ){
        artD.w = ArtObj[Xtag].texture_width.tofloat();
        artD.h = ArtObj[Xtag].texture_height.tofloat();
        xml_root.getChild(Xtag).addAttr( "w", ArtObj[Xtag].texture_width.tofloat() );
        xml_root.getChild(Xtag).addAttr( "h", ArtObj[Xtag].texture_height.tofloat() );
    }

    artD.x -= artD.w * 0.5;
    artD.y -= artD.h * 0.5;

    if( rotate ){ // simple rotation
        ArtObj[Xtag].rotation = artD.r;
        local mr = PI * artD.r / 180;
        artD.x += cos( mr ) * (-artD.w * 0.5) - sin( mr ) * (-artD.h * 0.5) + artD.w * 0.5;
        artD.y += sin( mr ) * (-artD.w * 0.5) + cos( mr ) * (-artD.h * 0.5) + artD.h * 0.5;
    }

    if( ext(art).tolower() == "swf" && !hd ){
        local swf_except = { "Mame" : ["bonzeadv","ironclad"] };// table of system and theme name where the swf fixes should not be applied.
        local exception = false;
        if(swf_except.rawin(curr_emulator)) if ( swf_except[curr_emulator].find(fe.game_info(Info.Name)) != null ) exception = true;
        if(!exception){
            // try to fix swf
            if(artD.x > fe.layout.width ) artD.x = 0;
            if(artD.y > fe.layout.height) artD.y = 0;
            if(ArtObj[Xtag].texture_width == 1024) artD.x = 0;
            if(ArtObj[Xtag].texture_height == 768) artD.y = 0;
            if (artD.x < 0) artD.x = 0;
            if (artD.y < 0) artD.y = 0;
        }
    }

    ArtObj[Xtag].set_pos( (artD.x * mul) + offset_x, (artD.y * mul_h) + offset_y, artD.w * mul , artD.h * mul_h);

    if(hd) ArtObj[Xtag].zorder = artD.zorder; // zorder only on HD theme
}

function set_custom_value(Ini_settings) {

    // hs theme
    if( Ini_settings.themes["aspect"] == "stretch"){
        mul = flw / 1024;
        mul_h = flh / 768;
        offset_x = 0;
        offset_y = 0;
    }else{
        local nw = flh * 1.333;
        mul = nw / 1024;
        mul_h = mul;
        offset_x = (flw - nw) * 0.5;
        offset_y = 0;
    }

    if(prev_tr == Transition.ToNewList){
        syno_surf.visible = Ini_settings.themes["synopsis"];

        system_stats_coord();

        local g_c = split( Ini_settings["game text"]["coord"], ",").map(function(v){return v.tofloat()});; // %
        if( g_c.len() == 3 ) {
            surf_ginfos.set_pos( g_c[0]*flw, g_c[1]*flh );
            surf_ginfos.rotation = g_c[2];
            surf_ginfos.alpha = 255;
        }

        if(Ini_settings["game text"]["game_text_active"] && curr_sys != "Main Menu"){
            surf_ginfos.visible = true; // Game infos surface
            if(Ini_settings["game text"]["animation"] != "none" && Ini_settings["game text"]["game_text_hide"]){
                surf_ginfos_animation
                .preset(Ini_settings["game text"]["animation"])
                .starting(Ini_settings["game text"]["anim_start"])
                .duration(Ini_settings["game text"]["anim_time"] * 1000)
                .delay( globs.delay + (Ini_settings["game text"]["anim_delay"] * 1000) )
                surf_ginfos_animation.start()
                surf_ginfos_animation.cancel("from")
                surf_ginfos_animation.start();
            }
        }

        local rgbC = dec2rgb(Ini_settings["game text"]["text_color"]);
        Title.text_color( [rgbC[0], rgbC[1], rgbC[2]] );
        local rgbC = dec2rgb(Ini_settings["game text"]["text_stroke_color"]);
        Title.thick_rgb([rgbC[0], rgbC[1], rgbC[2]]);

        wheel_animation
        .preset(Ini_settings["wheel"]["animation"])
        .starting(Ini_settings["wheel"]["type"])
        .duration(globs.delay)
        .delay(triggers.wheel_anim.delay)

        if(Ini_settings["wheel"]["animation"] != "none"){
            wheel_animation.start()
            wheel_animation.cancel("from")
            wheel_animation.start();
            FE_Sound_Wheel_In.playing = true;
        }else{
            wheel_animation.start()
            wheel_animation.cancel("to")
        }

        pointer_coord(); // set pointer pos

        if(!Ini_settings.pointer.animated){
            point_animation.yoyo(false);
            point_animation.play();
        }

        if(!Ini_settings.wheel["fade_time"]) m_infos.alpha = 255;

        local g_c = split( Ini_settings["themes"]["scroll_pos"], ",").map(function(v){return v.tofloat()}); // %
        if( g_c.len() == 5 ) {
            syno_surf.width = g_c[2] * flw;
            syno_surf.height = g_c[3] * flh;
            syno_surf.x = g_c[0] * flw;
            syno_surf.y = g_c[1] * flh;
            //syno_surf.rotation = g_c[4];
        }
        if(my_config["special_artworks"].tolower() == "yes") load_special(); // Load special artworks
    }
}

function game_surface(){
    if(!Ini_settings["game text"]["game_text_active"] || curr_sys == "Main Menu") return;
    // reset to default pos
    local lng_x = flw*0.134;
    for ( local i = 0; i < 17; i++ ) {
        lng_x += flw*0.0230;
        Lang[i].set_pos(lng_x, lng_v.y, lng_v.w, lng_v.h);
    }

    Title.x(Title_v.x);
    Title.y(Title_v.y);
    list_entry.x(list_entry_v.x);
    list_entry.y(list_entry_v.y);
    PCount.x(PCount_v.x);
    PCount.y(PCount_v.y);

    // set user settings
    rating.visible = !Ini_settings["game text"]["hide_rating"]
    pl_i.visible = !Ini_settings["game text"]["hide_players"]
    pl_t.visible = !Ini_settings["game text"]["hide_players"]
    cate.visible = !Ini_settings["game text"]["hide_category"]
    cate2.visible = !Ini_settings["game text"]["hide_category"]
    Ctrl.visible = !Ini_settings["game text"]["hide_ctrl"]
    Ctrl2.visible = !Ini_settings["game text"]["hide_ctrl"]
    flags.visible = !Ini_settings["game text"]["hide_country"]

    Copy.set("visible", !Ini_settings["game text"]["hide_year"]);
    list_entry.set("visible", !Ini_settings["game text"]["hide_filter"]);
    PCount.set("visible", !Ini_settings["game text"]["hide_counter"]);

    for ( local i = 0; i < 17; i++ ) { Lang[i].visible = !Ini_settings["game text"]["hide_lang"]; }

    // reorder icons and text
    local fline = false;
    foreach(k,v in [Ctrl, pl_i, cate]) if(v.visible) fline=true;
    if(!fline){
        local lng_x = flw*0.007;
        for ( local i = 0; i < 17; i++ ) {
            Lang[i].x = lng_x;
            lng_x += flw*0.0230;
        }
    }

    local order = [Copy_v.y, list_entry_v.y, PCount_v.y];

    local i=0;
    foreach(k,v in  [Copy, list_entry, PCount]) {
        if(v._title.visible){
            v.y(order[i]);
            i++;
        }
    }

    if(!rating.visible){
        Copy.x(0.0);
        list_entry.x(0.0);
        PCount.x(0.0);
    }

    if(!flags.visible) Title.x(-flw * 0.004);
}

function set_last_played_txt(refresh = false){
    if(curr_sys != "Recent") return false;
    local Date;
    try{
        Date = date(fe.game_info(Info.Extra).tointeger());
    }catch(e){}

    last_played.msg = "";

    if(typeof(Date) == "table" || refresh){
        if(refresh) Date = date(time());
        local date_us = Date.day+"-"+PadWithZero(Date.month + 1)+"-"+Date.year+" "+PadWithZero(Date.hour)+":"+PadWithZero(Date.min);
        local date_eu = Date.day+"-"+PadWithZero(Date.month + 1)+"-"+Date.year+" "+PadWithZero(Date.hour)+":"+PadWithZero(Date.min);
        last_played.msg = "Last Played:" + date_eu;
        last_played.visible = true;
    }
}
