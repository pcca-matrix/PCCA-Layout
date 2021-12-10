/////////////////////////////////////////////////////////////////////
//
// PCCA v2.06
// Use with Attract-Mode Front-End  http://attractmode.org/
//
// This program comes with NO WARRANTY.  It is licensed under
// the terms of the GNU General Public License, version 3 or later.
//
// PCCA-Matrix 2021
//
////////////////////////////////////////////////////////////////////
local M_order = 0;
globals_temp <- {"menu_return":false}; // global temporary vars
trigger_load_theme <- false;
class UserConfig {
    </ label="Wheel transition time", help="Time in milliseconds for wheel spin", options="1,25,50,75,100,125,150,175,200,400", order=M_order++ /> wheel_transition_ms="25"
    </ label="Wheel fade time", help="Time in seconds for wheel fade out (-1 disable fading)", options="-1,0,0.5,1.0,1.5,2.0,2.5,3.5", order=M_order++ /> wheel_fade_time="2.5"
    </ label="Wheel fade alpha", help="Alpha value of the faded wheel (0.0 - 1.0)", options="", order=M_order++ /> wheel_alpha="0.0"
    </ label="Number of wheel", help="Number of wheel to display", options="4,6,8,10,12",order=M_order++ /> wheel_slots="12";
    //</ label="Select wheel type", help="Switch between a vertical, round, horizontal, and pin wheel", options="Rounded,Vertical,Horizontal,Pin", order=M_order++ /> wheel_type="rounded"
    </ label="Select wheel type", help="Switch between a vertical or rounded wheel", options="Rounded,Vertical", order=M_order++ /> wheel_type="Rounded"
    </ label="Wheel Offset", help="X Wheel Offset", options="", order=M_order++ /> wheel_offset="0"
    </ label="Screensaver Timer", help="Amount of time in secs to wait before starting the screensaver. (0 to disable)", options="", order=M_order++ /> screen_saver_timer="55"
    //</ label="Wheel image large", help="Center wheel width in pixels (0 = auto)", options="",order=M_order++ /> wheel_large="0";
    //</ label="Wheel image small", help="Others wheel width in pixels (0 = auto)", options="",order=M_order++ /> wheel_small="0";

    </ label="Override Transitions", help="Use FLV Override Video Transitions", options="Yes, No", order=M_order++ /> themes_override_transitions="Yes"
    //</ label="Themes Wait For Override", help="Themes load after override transition has played", options="Yes, No", order=M_order++ /> themes_wait_override="Yes"
    </ label="Animated Backgrounds", help="Use background transitions", options="Yes, No", order=M_order++ /> themes_animated_backgrounds="Yes"
    </ label="Aspect", help="Theme aspect", options="Stretch, Center", order=M_order++ /> themes_aspect="Center"
    </ label="Bezels", help="If display is centered, use bezels to replace pixel stretched border", options="Yes, No", order=M_order++ /> themes_bezels="Yes"
    </ label="Bezels on top", help="Put bezel on top of the theme artworks or below", options="Yes, No", order=M_order++ /> themes_bezels_on_top="No"
    </ label="Background Stretch", help="Stretch all backgrounds", options="Yes, No", order=M_order++ /> themes_background_stretch="No"
    </ label="Game Info Visibility", help="Enable or disable the Game Info Surface", options="Yes, No", order=M_order++ /> themes_infos_visibility = "Yes"
    </ label="Game Info Coordinates", help="x,y coordinates for the game info surface. If empty = left bottom", options="", order=M_order++ /> themes_infos_coord = ""
    //</ label="Animate Out Default", help="When moving off a default theme you can have theme artworks animate out each time", options="Yes, No", order=M_order++ /> themes_animate_out_default = "No"
    </ label="Reload Backgrounds", help="Force reloading background transitions when navigating on default theme", options="Yes, No", order=M_order++ /> themes_reload_backgrounds = "No"
    </ label="Video scanline", help="Add crt scanlines effect to video snap ", options="Yes, No", order=M_order++ /> themes_crt_scanline = "No"
    </ label="Extra Artworks Key", help="Choose the key to initiate extra artworks overlay", options="custom1,custom2,custom3,custom4,custom5,custom6,none", order=M_order++ />extra_artworks_key="custom2";
    </ label="Settings/Edit Key", help="Choose the key to initiate settings/edit overlay", options="custom1,custom2,custom3,custom4,custom5,custom6,none", order=M_order++ />main_menu_key="custom4";
    </ label="Gamepad library", help="Choose the gamedpad library to use for the edit theme function", options="Xinput,Dinput", order=M_order++ />JoyType="Dinput";
    </ label="HD theme resolution", help="Choose the resolution you want when creating new theme ex : (1920x1080)", options="", order=M_order++ />theme_resolution="1920x1080";

    </ label="Media Path", help="Path of HyperSpin media, if empty, media is considered inside layout folder", options="", order=M_order++ /> medias_path=""
    </ label="Low GPU", help="'Yes' = Low GPU (Intel HD,.. less backgrounds transition), 'No' = Recent GPU", options="Yes, No", order=M_order++ /> LowGPU="No"
    </ label="Interface Language", help="Preferred User Language", options="Fr, En", order=M_order++ /> user_lang="En"
    </ label="Global Stats", help="Enable or disable the main menu stats system", options="Yes, No", order=M_order++ /> stats_main = "Yes"

    </ label="Special Artwork", help="Enable or disable the special artwork (if No special is disabled globally)", options="Yes, No", order=M_order++ /> special_artworks = "Yes"
    </ label="Game Sounds", help="Enable or disable the game sounds", options="Yes, No", order=M_order++ /> sounds_game_sounds = "Yes"
    </ label="Wheel Click", help="Enable or disable the wheel click sound", options="Yes, No", order=M_order++ /> sounds_wheel_click = "Yes"
    //</ label="Animated Artworks", help="Animate artworks", options="Yes, No", order=6 /> animated_artworks="Yes"

    </ label="Search Key", help="Choose the key to initiate a search", options="custom1,custom2,custom3,custom4,custom5,custom6,none", order=M_order++ />keyboard_search_key="custom1";
    </ label="Search Results", help="Choose the search method", options="show_results,next_match", order=M_order++ />keyboard_search_method="show_results";
    </ label="Keyboard Layout", help="Choose the keyboard layout", options="qwerty,azerty,alpha", order=M_order++ />keyboard_layout="alpha";
}

local Stimer = fe.layout.time;
flw <- fe.layout.width.tofloat();
flh <- fe.layout.height.tofloat();
fe.layout.font = "ArialCEMTBlack";

// Modules
fe.load_module("hs-animate");
fe.load_module("conveyor");
fe.do_nut("nut/keyboard-search/module.nut");
fe.do_nut("nut/class.nut");
fe.load_module("file");
fe.load_module("file-format");
fe.load_module("objects/scrollingtext");
fe.do_nut("nut/func.nut");
fe.do_nut("nut/lang.nut");

my_config <- fe.get_config();
Ini_settings <- {}; // global settings !
user_settings(); // first, load user settings

medias_path <- ( my_config["medias_path"] != "" ? my_config["medias_path"] : fe.script_dir + "Media" );
if ( medias_path.len()-1 != '/' ) medias_path += "/";

LnG <- _LL[ my_config["user_lang"] ];
local tr_directory_cache  = get_dir_lists( medias_path + "Frontend/Video/Transitions" );
local prev_back = {}; // previous background table infos ( transitions )

//test <- fe.add_text("",0,200,1920,25);// DEBUG

// Globals
xml_root <- [];
local main_menu_rows = ["theme","settings","scraper"];

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

local wheel_offset = 0;
try { wheel_offset = Ini_settings.wheel["offset"].tofloat(); } catch ( e ) { wheel_offset = 0 }

ArtObj <- {};
snap_is_playing <- false;
local artwork_list = ["artwork1", "artwork2", "artwork3","artwork4","artwork5","artwork6"]; //  artworks list for the theme
local artwork_list_full = clone(artwork_list);
artwork_list_full.push("video"); // full artwork_list must contain video (frame)

availables <- {}
foreach(a,b in artwork_list_full) availables[b] <- false;

local path = "";
local curr_theme = "";
local curr_sys = "";
local prev_path = "";
local glob_delay = 400;
local glob_time = 0;
local rtime = 0;
local reverse = 0;
local visi = false;
local trigger_letter = false;
local letters = fe.add_image("", flw * 0.5 - (flw*0.140 * 0.5), flh * 0.5 - (flh*0.280 * 0.5), flw*0.140, flh*0.280);
conveyor_bool <- false; // fading conveyor
hd <- true; // global bool for hd or hs theme

// Background / Bezel
ArtObj.background <- fe.add_image("", 0, 0, flw, flh);
ArtObj.background.file_name = "images/Backgrounds/Black.png";
ArtObj.background1 <- fe.add_image("images/init.swf",-2000,-2000,0.1,0.1); // needed for initialising SWF  ?, without can't use any surface overlay when swf is displayed (AM BUG) !
ArtObj.background2 <- fe.add_image("",-2000,-2000,0.1,0.1);
ArtObj.background1.visible = false;
ArtObj.background2.visible = false;
ArtObj.bezel <- fe.add_image("",0,0,flw,flh);
ArtObj.bezel.visible = false;

// create all artworks img obj
foreach(a,b in artwork_list_full) ArtObj[b] <- fe.add_image("",-1000,-1000,0.1,0.1);
ArtObj.snap <- fe.add_image("",-1000,-1000,0.1,0.1);

// Particles medias clones Array
ArtArray <- [];

// Override Transitions Videos
local flv_transitions = fe.add_image("",0,0,flw,flh);
flv_transitions.video_flags = Vid.NoLoop;

local start_background = fe.add_image("images/Backgrounds/Background.jpg",0,0,flw,flh);
local point = fe.add_image("", flw*0.99, flh*0.394, flw*0.10, flh*0.20);

if ( Ini_settings.wheel["type"] == "vertical") point.set_pos(flw*0.99, flh*0.390, flw*0.10, flh*0.23);
point.alpha = 200;

local point_animation = PresetAnimation(point)
.auto(true)
.key("x").from(flw*0.99).to(flw*0.90)
.duration(180)
.yoyo()

// Z-orders
ArtObj.artwork4.zorder = -2
ArtObj.artwork3.zorder = -3
ArtObj.artwork2.zorder = -4
ArtObj.snap.zorder = -7
ArtObj.artwork1.zorder = -9
ArtObj.bezel.zorder = -1
ArtObj.background.zorder = -10
flv_transitions.zorder = -10 // or -6 for some theme with video overlay on background ? test
start_background.zorder = -11
ArtObj.artwork5.zorder = 0
ArtObj.artwork6.zorder = 0

// Artworks Shaders and Animations
artwork_shader <- [];
anims_shader <- [];
anims <- [];
foreach(k,v in artwork_list ){
    artwork_shader.push( fe.add_shader( Shader.VertexAndFragment, "shaders/main.vert", "shaders/artworks.frag" ) );
    ArtObj[v].shader = artwork_shader[k];
    anims_shader.push( ShaderAnimation( artwork_shader[k] ) );
    anims.push( PresetAnimation(ArtObj[v]).name(v).auto(true) );
}

foreach(k,v in artwork_shader){
    v.set_texture_param("Tex0");
    v.set_param("datas",0,0,0,0);
}
foreach(k,v in anims_shader){
    v.name("artwork" + (k+1) );
    v.param("progress");
    v.auto(true);
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
anim_video_shader <- ShaderAnimation( video_shader ).name("video_shader").auto(true);
anim_video <- PresetAnimation(ArtObj.snap).name("video").auto(true);

if( my_config["LowGPU"] == "Yes" ) Trans_shader <- fe.add_shader( Shader.Fragment, "shaders/effect_low_gpu.frag" ); else Trans_shader <- fe.add_shader( Shader.Fragment, "shaders/effect.frag" );

ArtObj.background.shader = Trans_shader;

Trans_shader.set_texture_param("back1", ArtObj.background1);
Trans_shader.set_texture_param("back2", ArtObj.background2);
Trans_shader.set_texture_param("bezel", ArtObj.bezel);

local bck_anim = ShaderAnimation(Trans_shader);
bck_anim.auto(true)
bck_anim.param("progress")
bck_anim.duration(glob_delay * 1.40)
bck_anim.delay(0)

// Special Artworks
ArtObj.SpecialA <- fe.add_image(medias_path + "Main Menu"+ "/Images/Special/SpecialA1.swf", -1000, -1000, 0, 0);
ArtObj.SpecialB <- fe.add_image(medias_path + "Main Menu"+ "/Images/Special/SpecialB1.swf", -1000, -1000, 0, 0);
ArtObj.SpecialC <- fe.add_surface(flw, flh*0.10);

ArtObj.SpecialA.shader = fe.add_shader( Shader.Fragment, "shaders/special.frag") ;
ArtObj.SpecialB.shader = fe.add_shader( Shader.Fragment, "shaders/special.frag") ;

anim_special <- [];
anim_special.push( PresetAnimation(ArtObj.SpecialA).auto(true) );
anim_special.push( PresetAnimation(ArtObj.SpecialB).auto(true) );

function load_special(){
    foreach( i,n in ["A","B"] ){
        anim_special[i].reset();
        ArtObj["Special" + n].file_name = "";
    }
    
    foreach( i,n in ["a","b"] ){
        local S_Art = Ini_settings["special art " + n];
        S_Art["lst"] <- [];
        S_Art["syst"] = curr_sys;
        S_Art["in"] = S_Art["in"].tofloat() * 1000;
        S_Art["out"] = S_Art["out"].tofloat() * 1000;
        S_Art["delay"] = (S_Art["delay"].tofloat() * 1000 < 100 ? 100 : S_Art["delay"].tofloat() * 1000 );
        S_Art["length"] = S_Art["length"].tofloat()  * 1000;
        S_Art["w"] = S_Art["w"].tofloat();
        S_Art["h"] = S_Art["h"].tofloat();
        S_Art["x"] = S_Art["x"].tofloat();
        S_Art["y"] = S_Art["y"].tofloat();
        S_Art["type"] = ( S_Art["type"] == "normal" ?  "linear" : S_Art["type"] );
        
        if(S_Art["active"].tointeger() == 0 ) continue;
        
        n = n.toupper();
        if(S_Art["default"].tointeger() == 1 ) {
            S_Art["syst"] = "Main Menu"; // if default is true in ini , use main menu special artwork
        } else if(S_Art["sys_global"].tointeger() == 1 ){
            S_Art["syst"] = "Global"; // use Global systeme special artwork ( must be only if not artowrk is fgound inside folder)
        }
    
        local lst = zip_get_dir( medias_path + S_Art["syst"] + "/Images/Special" );
        foreach( v in lst ){
            if( ["png","swf","jpg","mp4","gif"].find( ext(v) ) != null ){
                if( v.find("Special" + n) != null ) S_Art["lst"].push(v);
            }
        } 

        if(!S_Art["lst"].len() && !S_Art["default"]) continue;
        ArtObj["Special" + n].file_name = medias_path + S_Art["syst"] + "/Images/Special/" + S_Art["lst"][0];
        if( !ArtObj["Special" + n].file_name) continue; // continue if special does not exist
        
        ArtObj["Special" + n].visible = true;
        S_Art.nbr = n;
        if(S_Art){
            local special_hd = ( S_Art.w > 0 && S_Art.h > 0 ? true : false);  // if width and height define , assume it's hd Special
            if(special_hd){
                if( S_Art.x > 0 && S_Art.y > 0){ // if coord defined in HD, use them as is
                    S_Art["x"] -= ( S_Art["w"] * 0.5 );
                    S_Art["y"] -= ( S_Art["h"] * 0.5 );
                }else{ //default bottom centered
                    S_Art["x"] = flw * 0.5 - ( S_Art.w * 0.5);
                    S_Art["y"] = flh - S_Art.h;
                }
                ArtObj["Special" + n].set_pos( S_Art["x"] , S_Art["y"], S_Art["w"], S_Art["h"]  );
            }else{ // else assume it's Hyperspin scaled special
               if( S_Art.x > 0 && S_Art.y > 0){ // if coord
                    ArtObj["Special" + n].x =  S_Art["x"] * mul - (ArtObj["Special" + n].texture_width * mul * 0.5) + offset_x;
                    ArtObj["Special" + n].y =  S_Art["y"] * mul_h - (ArtObj["Special" + n].texture_height * mul_h * 0.5) + offset_y;
                }else{ // default bottom centered
                    ArtObj["Special" + n].x = flw * 0.5 - ( (ArtObj["Special" + n].texture_width * mul ) * 0.5);
                    ArtObj["Special" + n].y = flh - ( (ArtObj["Special" + n].texture_height ) * mul_h);
                }
                ArtObj["Special" + n].width = ArtObj["Special" + n].texture_width * mul;
                ArtObj["Special" + n].height = ArtObj["Special" + n].texture_height * mul_h;
            }

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
                if(S_Art.cnt == S_Art["lst"].len()) S_Art.cnt = 0;
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
local Background_Music = fe.add_sound( get_random_file( medias_path + "Sound/Background Music") );
local Game_In_Out = fe.add_sound("");
local Wheelclick = [];
local i;
local sound_buffer_size = 5; // size of the audio buffer
for (i=0; i<sound_buffer_size+1; i++) Wheelclick.push(fe.add_sound(""));
local sid = 0;

// dialog
local dialog = fe.add_surface(flw*0.180, flh*0.08);
dialog.set_pos(-flw, flh*0.025);
local dialog_text = dialog.add_text("", 0, 0, flw*0.180, flh*0.05);
dialog_text.charsize = flh*0.022;
dialog_text.set_bg_rgb(91,91,91);
dialog_text.bg_alpha = 35;
local dialog_anim = PresetAnimation(dialog)
.auto(true)
.from({x=-flw * 0.180})
.to({x=0})
.yoyo(true)
.loops_delay(1500)
.duration(700)

function dialog_datas(type){
    switch (type){
        case "favo":
            if(fe.game_info(Info.Favourite) == "") dialog_text.msg = LnG.ret_fav; else dialog_text.msg = LnG.add_fav;
        break;
    }
    dialog_anim.play();
}

// Game Infos surface
local surf_ginfos = fe.add_surface(flw, flh*0.22);

local ttfont = "ArialCEMTBlack";
local Title = OutlinedText(surf_ginfos, "[Title]", {"color":[255,255,255], "x":flw*0.0195, "y":flh*0.077, "w": flw*0.9375 , "size":flh*0.037}, 1.5);
Title.set("align" , Align.Left);
Title.set("font" , ttfont);

local list_entry = OutlinedText(surf_ginfos, "[ListEntry]/[ListSize] " + LnG.display + ": [FilterName]", {"color":[255,255,255], "x":flw*0.027, "y":flh*0.135, "w": flw*0.3125 , "size":flh*0.021}, 1.5);
list_entry.set("align" , Align.Left);
list_entry.set("font" , ttfont);

local Copy =  OutlinedText(surf_ginfos, "[!copyright]", {"color":[255,255,150], "x":flw*0.023, "y":flh*0.111, "w": flw*0.9375 , "size":flh*0.025}, 1.5);
Copy.set("align" , Align.Left);
Copy.set("font" , ttfont);

local PCount = OutlinedText(surf_ginfos, LnG.counter + " [PlayedCount] / " + LnG.playedtime + " [PlayedTime]", {"color":[255,255,255], "x":flw*0.027, "y":flh*0.152, "w": flw*0.3325 , "size":flh*0.021} , 1.5);
PCount.set("align" , Align.Left);
PCount.set("font" , ttfont);

local flags = surf_ginfos.add_image("images/flags/[!region]", flw*0.007, flh*0.077, flw*0.0213, flh*0.037);
local rating = surf_ginfos.add_image("images/rating/[!rating]", flw*0.007, flh*0.120, flw*0.0213, flh*0.051 );

local pl = surf_ginfos.add_text( "[!font_pl]", -flw*0.006, flh*0.032, flw*0.510, flh*0.0462 );
pl.font = "fontello.ttf";
pl.align = Align.Left;

local Ctrl = surf_ginfos.add_text( "[!font_ctrl]", flw*0.035, flh*0.035, flw*0.030, flh*0.046 );
Ctrl.font = "fontello.ttf";
Ctrl.align = Align.Left;

local Category = surf_ginfos.add_text( "[!category]", flw*0.070, flh*0.050, flw*0.078, flh*0.020 );
Category.align = Align.Left;
Category.style = Style.Bold;

local favo = surf_ginfos.add_text( "[Favourite]", flw*0.071, flh*0.004, flw*0.058, flh*0.045 );
favo.font = "fontello.ttf";
favo.align = Align.Left;
favo.set_rgb( 255, 170, 0 );

/* Main SettingsOverlay */
local surf_menu = fe.add_surface(flw * 0.24, flh);
surf_menu.zorder = 2;
local surf_menu_bck = surf_menu.add_image("images/Backgrounds/faded.png", 0, 0, flw, flh );
surf_menu_bck.alpha = 80;
local surf_menu_img = surf_menu.add_image("", flw*0.044, flh * 0.82, flw * 0.16, flh * 0.17 );
surf_menu_img.visible = false;
surf_menu_img.preserve_aspect_ratio = true;
local surf_menu_title = surf_menu.add_text("", flw * 0.008, flh*0.002, flw * 0.24, flw * 0.009 );
surf_menu_title.align = Align.Left;
local surf_menu_info = surf_menu.add_text("", flw * 0.005, flh - (flh * 0.046), flw * 0.26, flw * 0.012 );
surf_menu_info.align = Align.Left;
surf_menu_info.set_bg_rgb(62,62,62);
surf_menu_info.alpha = 200;
surf_menu_info.visible = false;
surf_menu.visible = false;
local sel_menu = SelMenu(surf_menu, flh * 0.025);

/* Extra Artworks Screen Overlay */
local surf_inf = fe.add_surface(flw, flh);
local surf_bck = surf_inf.add_image("images/Backgrounds/faded.png", 0, 0, flw, flh );
local surf_img = surf_inf.add_image("", 0, 0, 0, flh * 0.82 );
local surf_arrow = surf_inf.add_image("images/double_arrow.png", flw * 0.5 - ( flw * 0.083 * 0.5), flh * 0.942, flw * 0.083, flh * 0.037);
surf_img.preserve_aspect_ratio = true;
surf_inf.visible = false;

local surf_txt = surf_inf.add_text( "", flw * 0.007, flh * 0.018, flw, flh * 0.066)
surf_txt.font = ttfont;
surf_txt.align = Align.Left;
surf_txt.set_rgb( 241, 250, 200 );

local surf_inf_anim = PresetAnimation(surf_inf)
.auto(true)
.key("alpha").from(0).to(255)
.on("stop", function(anim){
    if(anim.opts.target.alpha == 0) anim.opts.target.visible = false;
})
.duration(600)

local extraArtworks = {
    lists = [],
    num = 0,

    function getLists(){
        lists = []
        num = 0
        local lst = zip_get_dir( medias_path + curr_sys + "/Images/Artworks/" +  fe.game_info(Info.Name) );
        foreach( v in lst ) if( ["jpg","png","mp4"].find( ext(v) ) != null ) lists.push(v);
    },

    function setImage( act=0 ){
        if( !lists.len() ){
            surf_img.file_name = "";
            surf_arrow.visible = false;
            surf_txt.msg = "";
            return false;
        }
        if(lists.len() > 1) surf_arrow.visible = true; else surf_arrow.visible = false;
        if(act == "s") num = 0
        if(act == "next_display") ( num < lists.len() - 1 ? num++ : num = 0 )
        if(act == "prev_display") ( num > 0 ? num-- : num = lists.len() - 1 )
        surf_img.file_name =  medias_path + curr_sys + "/Images/Artworks/" +  fe.game_info(Info.Name) + "/" + lists[num];
        local ratio = surf_img.texture_height / (flh * 0.82);
        surf_img.x = flw * 0.5 - (surf_img.texture_width / ratio * 0.5);
        surf_img.y = flh * 0.5 - (flh * 0.82 * 0.5);
        local title = strip_ext(lists[num]);
        if( title.len() ) surf_txt.msg = title.slice( 0, 1 ).toupper() + title.slice( 1, title.len() ); // caps first char
    }
}

Lang <- {};
local lng_x = flw*0.110;
for ( local i = 0; i < 17; i++ ) {
    lng_x += flw*0.0230;
    Lang[i] <- surf_ginfos.add_image("", lng_x, flh*0.049, flw*0.0200, flh*0.0300 );
}
// Main Menu Infos
main_infos <- {};
game_elapse <- 0;

local m_infos = fe.add_text("",(flw*0.878) - wheel_offset, flh*0.537, flw*0.11, flh*0.046);
if ( Ini_settings.wheel["type"] != "vertical"){
    m_infos.set_pos( flw*0.785, flh*0.546 );
    m_infos.rotation = -5.2;
}


if( my_config["stats_main"].tolower() == "yes" ){
    m_infos.align = Align.Left;
    //m_infos.font = ttfont;
    m_infos.word_wrap = true;
    m_infos.charsize = flh*0.014;
    m_infos.set_rgb(205, 205, 195);
    if( !file_exist(fe.script_dir + "pcca.stats") ) refresh_stats();
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

// add tags
surf_ginfos.add_image("[!get_media_tag]", flw*0.006, 0, flw*0.063, flh*0.036)

// Synopsis
syno <- ScrollingText.add( "", offset_x, flh*0.976, fe.layout.width - (offset_x * 2) , flh*0.022, ScrollType.HORIZONTAL_LEFT );
syno.settings.delay = 2500;
syno.settings.speed_x = 2.5;

function overview( offset ) {
   local input = fe.game_info(Info.Overview, offset);
   if( input.len() > 1 ){
        syno.text.width = input.len() * flw*0.022;
        syno.set_bg_rgb(20,0,0,75);
        syno.text.msg = input;
        return;
   }
   syno.text.msg = "";
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

function background_transitions(anim, File){
    if( !Ini_settings.themes["reload_backgrounds"] ){ // dot not reload background if it's the same and option reload_backgrounds is false (Default behavior)
        if(File == ArtObj.background1.file_name && reverse) return;
        if(File == ArtObj.background2.file_name && !reverse) return;
    }
    ArtObj.bezel.visible = false;
    local fromIsSWF = false;
    local toIsSWF = false;
    local bw,bh;
    local back_mul = mul;
    local back_mul_h = mul_h;
    local back_offset_x = offset_x;
    local back_offset_y = offset_y;

    if( ext(File).tolower() == "swf" )toIsSWF = true;

    if(reverse){
        ArtObj.background2.file_name = File;
        // fix flipped-y background with swf (why ??? AM Bug)
        if( ext(ArtObj.background1.file_name).tolower() == "swf" ){
            ArtObj.background1.video_playing = false;
            fromIsSWF = true;
        }

        bw = ArtObj.background2.texture_width;
        bh = ArtObj.background2.texture_height;
    }else{
        ArtObj.background1.file_name = File;
        // fix flipped-y background with swf (why ??? AM Bug)
        if( ext(ArtObj.background2.file_name).tolower() == "swf" ){
            ArtObj.background2.video_playing = false;
            fromIsSWF = true;
        }

        bw = ArtObj.background1.texture_width;
        bh = ArtObj.background1.texture_height;
    }

    if( Ini_settings.themes["background_stretch"] || hd ) // no scaled backgrounds
    {
        if( toIsSWF ){ // hyperspin seems to stretch any swf backgrounds !
            back_mul = flw / 1024;
            back_mul_h = flh / 768;
            back_offset_x = 0;
            back_offset_y = 0;
            Trans_shader.set_param("back_res", 0.0, 0.0, (1024 * back_mul) / flw, (768 * back_mul_h) / flh ); // actual background infos stretched
        }else{
            Trans_shader.set_param("back_res", 0.0, 0.0, 1.0, 1.0 ); // actual background infos
        }

        if(prev_back.len() > 0 ){ // previous background infos
            Trans_shader.set_param("prev_res", prev_back.ox * (1.0 / flw) , prev_back.oy * (1.0 / flh),
            prev_back.bw * (1.0 / flw), prev_back.bh * (1.0 / flh)); // actual background infos
        }else{
            Trans_shader.set_param("prev_res",
            back_offset_x * (1.0 / flw) , back_offset_y * (1.0 / flh),
            (bw * back_mul) / flw, (bh * back_mul_h) / flh );
        }
        prev_back = { ox = 0, oy = 0, bw = flw, bh = flh };

    }else{ // scaled (HyperSpin) Background

        if( toIsSWF ){ // hyperspin seems to stretch any swf backgrounds !
            Trans_shader.set_param("back_res", back_offset_x * (1.0 / flw), back_offset_y * (1.0 / flh), (1024 * back_mul) / flw, (768 * back_mul_h) / flh); // actual background infos stretched
        }else{
            Trans_shader.set_param("back_res", back_offset_x * (1.0 / flw), back_offset_y * (1.0 / flh), (bw * back_mul) / flw, (bh * back_mul_h) / flh); // actual background infos
        }

        if(prev_back.len() > 0 ) { // previous background infos
            Trans_shader.set_param("prev_res", prev_back.ox * (1.0 / flw) , prev_back.oy * (1.0 / flh),
            prev_back.bw / flw, prev_back.bh / flh);
        }else{
            Trans_shader.set_param("prev_res", back_offset_x * (1.0 / flw), back_offset_y * (1.0 / flh),
            (bw * back_mul) / flw, (bh * back_mul_h) / flh);
        }
        prev_back = { ox = back_offset_x, oy = back_offset_y, bw = bw * back_mul, bh = bh * back_mul_h };
    }

    Trans_shader.set_texture_param("back2", ArtObj.background2);
    Trans_shader.set_texture_param("back1", ArtObj.background1);
    Trans_shader.set_texture_param("bezel", ArtObj.bezel);

    if(!anim){
        local rndanim = rndint(43);
        if(reverse && rndanim == 41)rndanim = 42; // hp corner can only be used right to left so select 42 (canna) instead if it's reverse
        Trans_shader.set_param("datas", rndanim, reverse, fromIsSWF, toIsSWF);// datas = preset number, reverse 0:1 , fromIsSWF, toIsSWF
    }else{
        Trans_shader.set_param("datas", anim, reverse, fromIsSWF ,toIsSWF);
    }

    if( !hd && Ini_settings.themes["bezels_on_top"] ) ArtObj.bezel.visible = true; else ArtObj.bezel.visible = false;

    Trans_shader.set_param("alpha", 1.0);
    local to = (reverse == 0.0 ? 1.0 : 0.0)
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
    xml_root = null;
    if(theme_content.len() <= 0){  // If there is no theme file, return (unified theme)
        hd = true;
        if(file_exist(medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + ".mp4")){
            ArtObj.background.set_pos(0,0,flw, flh);
            reset_art();
            flv_transitions.zorder = -6; // put override video on top of video snap
            background_transitions(null, medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + ".mp4");
        }
        return false;
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

    try{ xml_root = xml.load( raw_xml ); } catch ( e ) { };

    local theme_node = find_theme_node( xml_root );
    try{ theme_node.children } catch ( e ) { return; }; // return if no xml
    foreach(a,b in artwork_list_full) availables[b] <- false; // reset full artworks availability
    local anim_rotate;

    try{ hd = xml_root.getChild("hd") } catch(e) {}   // check if it's a real HD theme

    if(file_exist(medias_path + fe.list.name + "/Sound/Background Music/" + fe.game_info(Info.Name) + ".mp3") ){ // backrgound music found in media folder
        Background_Music.file_name = medias_path + fe.list.name + "/Sound/Background Music/" + fe.game_info(Info.Name) + ".mp3";
        Background_Music.playing = true;
        ArtObj.snap.video_flags = Vid.NoAudio;
    }

    local backg = false;
    foreach(k,v in theme_content){
        if(strip_ext(v.tolower()) == zippath.tolower() + "background"){ // background found in theme
            backg = name + "|" + v;
            if( Ini_settings.themes["animated_backgrounds"] ){
               background_transitions(null, backg);
            }else{
               background_transitions(99, backg);
            }
        }

        if( ext(v.tolower()) == "mp3" ){ // backrgound music found anywhere in theme ( in HS , must be in /Extras/Background Sounds/ ....mp3)
            Background_Music.file_name = name + "|" + v;
            Background_Music.playing = true;
            ArtObj.snap.video_flags = Vid.NoAudio;
        }
    }

    if(!backg){ // when background is missing in theme zip, fade anim and check in media background folder if background is present , otherwise use alternate
        backg = medias_path + fe.list.name + "/Images/Backgrounds/" + fe.game_info(Info.Name) + ".png";
        if(!file_exist(backg)) backg = "images/Backgrounds/Alt_Background.png";
        if( Ini_settings.themes["animated_backgrounds"] )
            background_transitions(31 , backg);
        else
            background_transitions(99, backg);
    }

    if(raw_xml == "") return; // if broken with no theme.xml inside zip

    foreach ( c in theme_node.children )
    {
        if(!availables.rawin( c.tag )) continue; // if xml tag not know continue
        local art = ""; local Xtag = c.tag;
        anim_rotate = 0;

        foreach(k,v in theme_content){
            if(strip_ext(v.tolower()) == zippath.tolower() + Xtag.tolower()){
                availables[Xtag] = true;
                art = v
            }
        }
        local artD = set_art_datas(Xtag); // get original xml value

        if( artwork_list.find(Xtag) != null ){
            if( prev_def && availables[Xtag] ) continue;

            if(availables[Xtag]){
                ArtObj[Xtag].file_name = name + "|" + art;
            }else{
                // get hs others medias artwork when they are not available in zip
                ArtObj[Xtag].file_name =  medias_path + fe.list.name + "/Images/" + Xtag + "/" + art + "/" + fe.game_info(Info.Name) + ".png";
            }

            // center rotation ,hyperspin anim artworks rotation only if it's greater than 180 or -180 and time is > 0
            if( abs(artD.r) > 180 && artD.time > 0 ) anim_rotate = artD.r;
            artworks_transform(Xtag, (anim_rotate ? false : true), art);

        }else if( Xtag == "video" ){
            // Temporary fix for the video datas does not reset !! (see prev_def commented below)
            clean_art("snap");
            clean_art("video");

            ArtObj.snap.file_name = ret_snap();
            ArtObj.snap.video_playing = false; // do not start playing snap now , wait delay from animation
            snap_is_playing = false;
            if(availables["video"]){ // if video overlay available
                ArtObj["video"].file_name = name + "|" + art;
            }

            // hs anim video rotation on any value but only if starting position is set, animation is set and anim time > 0 !!!!
            if( abs(artD.r) > 0 && artD.start != "none" && artD.type != "none" && artD.time > 0 ) anim_rotate = artD.r;

            video_transform((anim_rotate ? false : true));

            if(artD.below) ArtObj.artwork1.zorder = ArtObj.snap.zorder + 1; // only for HS
        }

        if(Xtag !="video"){
            if(!prev_def || !availables[Xtag] ){
                local e = Xtag.slice( Xtag.len() - 1, Xtag.len() ).tointeger();
                anims[e-1].preset(artD.type)
                anims[e-1].name(Xtag)
                anims[e-1].delay(artD.delay)
                anims[e-1].duration(artD.time)
                anims[e-1].starting(artD.start)
                anims[e-1].rest(artD.rest)
                anims[e-1].rotation(anim_rotate)
                anims[e-1].play();
            }
        }else{
            anim_video.preset(artD.type)
            anim_video.name(Xtag)
            anim_video.delay(artD.delay)
            anim_video.duration(artD.time)
            anim_video.starting(artD.start)
            anim_video.rest(artD.rest)
            anim_video.rotation(anim_rotate)
            anim_video.play();

            /*if(!prev_def ){
                anim_video.preset(artD.type)
                anim_video.name(Xtag)
                anim_video.delay(artD.delay)
                anim_video.duration(artD.time)
                anim_video.starting(artD.start)
                anim_video.rest(artD.rest)
                anim_video.rotation(anim_rotate)
                anim_video.play();
            }else{
                ArtObj.snap.visible = false; // avoid clipping when game change in default theme
                anim_video.play();
            }
            */
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
        ArtObj.artwork1.zorder = -9;   //set zorder back to normal for hyperspin zorders switching
        ArtObj.artwork2.zorder = -4
        ArtObj.artwork3.zorder = -3
        ArtObj.artwork4.zorder = -2
        ArtObj.artwork5.zorder = 0
        ArtObj.artwork6.zorder = 0
        ArtObj.snap.zorder = -7;
        flv_transitions.zorder = -10; // reset back to normal for override videos

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
        if( !bool || !availables["artwork"+(k+1)] ) clean_art(obj);
    }

    ArtObj.snap.video_flags = Vid.Default; // enable snap sound

   if(curr_sys == "Main Menu")
       point.file_name = medias_path + "/Main Menu/Images/Other/Pointer.png";
    else
       point.file_name = medias_path + fe.list.name + "/Images/Other/Pointer.png";
}


// hide art animated
function hide_art(){
    local random = ["unzoom", "zoom", "fade out", "expl"];
     //--if default theme , we hide only artwork not availables in them zip
        foreach(a,b in artwork_list ){
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
                .duration(glob_delay * 0.9)
                anims[a].play();
            }
        }
        // hide every particles medias clones
        for (local i=0; i < ArtArray.len(); i++ ) ArtArray[i].visible = false;
}


// Wheels
local wheel_count = Ini_settings.wheel["slots"].tointeger();

local ww = flw*0.15;
local wh = flh*0.10;
local wheel_x = [ flw*0.94, flw*0.935, flw*0.896, flw*0.865, flw*0.84, flw*0.82, flw*0.78, flw*0.82, flw*0.84, flw*0.865, flw*0.896, flw*0.90, ];
local wheel_y = [ -flh*0.22, -flh*0.105, flh*0.0, flh*0.105, flh*0.215, flh*0.325, flh*0.436, flh*0.61, flh*0.72 flh*0.83, flh*0.935, flh*0.99, ];
local wheel_h = [ wh, wh, wh, wh, wh, wh, flh*0.11, wh, wh, wh, wh, wh, ];
local wheel_w = [ ww, ww, ww, ww, ww, ww, flw*0.17, ww, ww, ww, ww, ww, ];
local wheel_r = [  30,  25,  20,  15,  10,   5,   0, -10, -15, -20, -25, -30, ];
local wheel_a = [  255,  255,  255,  255,  255,  255,  255  ,  255,  255,  255,  255,  255, ];

if ( Ini_settings.wheel["type"] == "vertical" ) // Vertical wheel
{
    local wx = flw*0.874;
    ww = flw*0.12;
    wh = flh*0.075;
    wheel_x = [ wx, wx, wx, wx, wx, wx, wx, wx, wx, wx, wx, wx, ];
    wheel_y = [ -flh*0.22, -flh*0.105, flh*0.0, flh*0.105, flh*0.215, flh*0.325, flh*0.466, flh*0.61, flh*0.72 flh*0.83, flh*0.935, flh*0.99, ];
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
        m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] ) - wheel_offset;
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

try { conveyor.transition_ms = Ini_settings.wheel["transition_ms"].tointeger(); } catch ( e ) { }

local center_animation = PresetAnimation(conveyor.m_objs[wheel_count/2].m_obj)
.auto(true)
.preset("zoom", 1.25)
.yoyo()
.duration(300)
.delay(100)
.easing("ease-in-cubic")

function conveyor_tick( ttime )
{
    local alpha;
    local delay = 650;
    local fade_time = Ini_settings.wheel["fade_time"].tofloat() * 1000;
    if(!fade_time) fade_time = 0.01;
    local from = 255; local to = clamp( Ini_settings.wheel["alpha"].tofloat() * 255 , 0.0 , 255.0);
    local elapsed = glob_time - rtime;
    if( !conveyor_bool && elapsed > delay && fade_time > 0 ) {
        alpha = (from * (fade_time - elapsed + delay)) / fade_time;
        alpha = (alpha < 0 ? 0 : alpha);
        local count = conveyor.m_objs.len();
        for (local i=0; i < count; i++) conveyor.m_objs[i].alpha=alpha;
        if(alpha <= to || alpha == 0) conveyor_bool = true;
    }
}
fe.add_ticks_callback( "conveyor_tick" );

/* OVERLAY SCREEN */

local custom_overlay = fe.add_surface(flw, flh);
custom_overlay.visible = false;
local overlay_background = custom_overlay.add_image("",0, 0, flw, flh);
overlay_background.zorder=-99

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
overlay_title.charsize = flw*0.018;
overlay_title.set_rgb(192, 192, 192);
local exit_overlay = fe.overlay.set_custom_controls( overlay_title, overlay_list );

local wheel_art = custom_overlay.add_image( "[!ret_wheel]", flw*0.425, flh*0.192, flw*0.156, flh*0.138);
wheel_art.visible = false;

function custom_settings() {
    local g_coord = [ 0, flh*0.805 ];
    if(Ini_settings.themes["infos_coord"] != "") {
        local g_c = split( Ini_settings.themes["infos_coord"], ",");
        if( g_c.len() == 2 ) {
            local I_x = 0; local I_y = 0;
            try { I_x = g_c[0].tofloat(); } catch ( e ) { I_x = 0 }
            try { I_y = g_c[1].tofloat(); } catch ( e ) { I_y = 0 }
            if( I_x >=0 && I_x < flw && I_y >=0 && I_y < flh ) g_coord = [ I_x, I_y ];
        }
    }
    surf_ginfos.set_pos( g_coord[0], g_coord[1] );
    surf_ginfos.alpha = 255;

    if( Ini_settings.themes["aspect"] == "stretch"){
        mul = flw / 1024;
        mul_h = flh / 768;
        offset_x = 0;
        offset_y = 0;
    }else{
        nw = flh * 1.333;
        mul = nw / 1024;
        mul_h = mul;
        offset_x = (flw - nw) * 0.5;
        offset_y = 0;
    }
}

//-- KeyboardSearch
class Keyboard extends KeyboardSearch
{
    function toggle() {
        if(curr_sys != sys){ // reload letters artwork only if sys is changed
            foreach( key, val in key_names ) {
                if(file_exist(medias_path + curr_sys + "/Images/Letters/" + val.tolower() + ".png")){
                    keys[ key.tolower() ].file_name = medias_path + curr_sys + "/Images/Letters/" + val.tolower() + ".png";
                }else{
                    keys[ key.tolower() ].file_name = fe.script_dir + "nut/keyboard-search/images" + "/" + val.tolower() + ".png";
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


local search = Keyboard( fe.add_surface(flw*0.370, flh) )
    .set_pos(-flw*0.370,0,flw*0.370,flh)
    .retain(true)
    .search_key( my_config["keyboard_search_key"] )
    .mode( my_config["keyboard_search_method"] )
    .preset( my_config["keyboard_layout"] )
    .text_font("SF Slapstick Comic Bold Oblique")
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
            Stimer = fe.layout.time;
            if ( ttime <= 500  ) {
                global_fade( ttime, 500, true);
                return true;
            }else{
                ArtObj.background1.video_playing = true;
                ArtObj.background2.video_playing = true;
                ArtObj.snap.video_playing = true;
                global_fade( 500, 500, true); // security for sure 100% alpha is passed to function
                rtime = glob_time + 2000 // add 2 seconds before fading wheel
                conveyor_bool = false; // do not restore alpha on conveyor
                // update stats for this system only if Track Usage is set to Yes in AM!
                if( fe.game_info(Info.PlayedTime) != "" ){
                    game_elapse = fe.game_info(Info.PlayedTime).tointeger() - game_elapse;
                    if(main_infos.rawin(fe.list.name)){
                        main_infos[fe.list.name].time += game_elapse;
                        main_infos[fe.list.name].pl++;
                        if( main_infos.rawin("Main Menu") ){
                            main_infos["Main Menu"].pl++;
                            main_infos["Main Menu"].time += game_elapse;
                        }
                        SaveStats(main_infos);
                    }
                }
            }
        break;

        case Transition.ToGame:
            if ( ttime <= 1500  ) {
                global_fade(ttime, 1500, false)
                ArtObj.background1.video_playing = false;
                ArtObj.background2.video_playing = false;
                ArtObj.snap.video_playing = false;
                return true;
            }else{
                global_fade(1500, 1500, false)
                // store old playedtime when lauching a game (only if Track Usage is set to Yes in AM!)
                if( fe.game_info(Info.PlayedTime) != "" ) game_elapse = fe.game_info(Info.PlayedTime).tointeger();
            }
        break;

        case Transition.ChangedTag: // 11
            dialog_datas("favo"); // tag not working , only for favourites ?!?
        break;

        case Transition.NewSelOverlay: // 10
            FE_Sound_Screen_Click.playing = true;
        break;

        case Transition.FromOldSelection: //3
            if(curr_sys == "Main Menu") stats_text_update( fe.game_info(Info.Title) );
        break;

        case Transition.ToNewSelection: //2
            center_animation.cancel("origin");
            if(Ini_settings.wheel["transition_ms"].tointeger() < 150) point_animation.play(); // disable pointer animation on slow wheel transition
            ArtObj.snap.video_flags = Vid.NoAudio;
            Background_Music.playing = false;
            Background_Music.file_name = "";
            ArtObj.snap.file_name = "";
            syno.set_bg_rgb(20,0,0,0);
            syno.text.msg = "";

            if(glob_time - rtime > 150){
                hide_art(); // 150ms between re-pooling hide_art when navigating fast in wheel (change !!)
            }
            rtime = glob_time;
            conveyor_bool = false; // reset conveyor fade
            flv_transitions.visible = false;
            flv_transitions.file_name = "";
            if(curr_sys == "Main Menu") stats_text_update( fe.game_info(Info.Title, 1) );
        break;

        case Transition.EndNavigation: //7
            if(conveyor.m_objs[wheel_count/2].m_obj.alpha == 255) center_animation.play();
            Langue();
            if(surf_inf.visible){
                extraArtworks.getLists();
                extraArtworks.setImage();
            }
            trigger_load_theme = true;
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
        break;

        case Transition.StartLayout: //0
            surf_ginfos.visible = false;
            if( !glob_time ){  // glob_time == 0 on first start layout
                if( ttime <= 255  && fe.game_info (Info.Emulator) == "@" ){ // fade when back to display menu or start layout
                    global_fade(ttime, 255, true);
                    return true;
                }else{
                    global_fade(255, 255, true);
                }
                //Sound -  cause we are back to main menu we use name to match the systeme we're leaving.
                Sound_System_In_Out.file_name = get_random_file( medias_path + fe.game_info(Info.Name) + "/Sound/System Exit/" );
                Sound_System_In_Out.playing = true;
                FE_Sound_Wheel_Out.playing = true;
                stats_text_update( fe.game_info(Info.Title) );
            }
        break;

        case Transition.ToNewList: //6
            curr_sys = ( fe.game_info(Info.Emulator) == "@" ? "Main Menu" : fe.list.name );
            center_animation.cancel("origin");
            for (local i=0; i < conveyor.m_objs.len(); i++) conveyor.m_objs[i].alpha=255;
            if(curr_sys != "Main Menu"){
                if( fe.game_info(Info.PlayedTime) == "" ) PCount.set("visible", false); else PCount.set("visible", true); //show game stats surface only if Track Usage is set to Yes in AM!
                hide_art(); // hide artwork when you change list
                conveyor_bool = false;
                syno.set_bg_rgb(20,0,0,0);
                syno.text.msg = ""; // Hide Overview
                m_infos.msg = ""; // Hide global stats

                // Update stats if list size change and we are not on a filter !!
                if( my_config["stats_main"].tolower() == "yes" && glob_time && fe.filters[fe.list.filter_index].name.tolower() == "all"){
                    if( main_infos.rawin(curr_sys) ){
                        if(fe.list.size != main_infos[curr_sys].cnt){
                            main_infos[curr_sys].cnt = fe.list.size;
                            SaveStats(main_infos);
                        }
                    }else{ // new systeme added , create new entry
                        main_infos <- refresh_stats(curr_sys);
                    }
                }
            }
            if( glob_time ){  // when glob_time > 0 not startlayout
                local es = get_random_file( medias_path + curr_sys + "/Sound/System Start/" );
                if( es != "" ){ // if exit sound exist for this system
                    Sound_System_In_Out.file_name = es;
                    Sound_System_In_Out.playing = true;
                }
                FE_Sound_Wheel_In.playing = true;
            }
            Ini_settings = get_ini_values(curr_sys); // get settings ini value
            custom_settings(); // load theme custom settings
            if(my_config["special_artworks"].tolower() == "yes") load_special(); // Load special artworks

            rtime = glob_time
            trigger_load_theme = true;
        break;

        /* Custom Overlays */
        case Transition.ShowOverlay: // 8 var = Custom, Exit(22), Displays, Filters(15), Tags(31), Favorites(28)
            FE_Sound_Screen_In.playing = true;
            dialog_anim.cancel(); // cancel dialog animation if in progress
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
                    overlay_background.file_name = medias_path + "Frontend/Images/Menu_Exit_Background_" + my_config["user_lang"] + ".png";
                    if(overlay_background.file_name == "") overlay_background.file_name = medias_path + "Frontend/Images/Menu_Exit_Background.png"; // if hyperspin default exit screen
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

    if( prev_tr != ttype ) prev_tr = ttype;
}


//
// Ticks
//

fe.add_ticks_callback( "hs_tick" );
function hs_tick( ttime )
{
    glob_time=ttime;

    // screensaver
    if(my_config["screen_saver_timer"].tointeger() > 0){
        if( (fe.layout.time-Stimer) >= my_config["screen_saver_timer"].tointeger() * 1000 ){
            fe.signal("screen_saver")
            Stimer=fe.layout.time;
        }
        if(surf_menu.visible) Stimer = fe.layout.time;
    }

    // set all artwork and video visible after x ms next to triggerload except those who have width set to 0.1 (unhided later in animation preset)
    if( (glob_time - rtime > glob_delay + 150) && visi == false){
        foreach(obj in ["artwork1", "artwork2", "artwork3", "artwork4", "artwork5", "artwork6", "video", "snap"] ) if(ArtObj[obj].width > 0.1) ArtObj[obj].visible = true;
        visi = true;
    }
    if(!snap_is_playing && anim_video.elapsed > anim_video.opts.delay ){ // start playing video snap after animation delay
        ArtObj.snap.video_playing = true;
        snap_is_playing = true;
    }

    if( glob_time - rtime > glob_delay + 350) letters.visible = false; // if visible , hide letter search with a small delay

    // load medias after glob_delay
    if( (glob_time - rtime > glob_delay) && trigger_load_theme){
        hd = false;
        if( Ini_settings.themes["bezels"] && Ini_settings.themes["aspect"] == "center" ){ // Systems bezels!  only if aspect center
            if( file_exist(fe.script_dir + "images/Bezels/" + curr_sys + ".png") ){
                ArtObj.bezel.file_name = fe.script_dir + "images/Bezels/" + curr_sys + ".png";
            }else{
                if( !Ini_settings.themes["background_stretch"] )
                    ArtObj.bezel.file_name = fe.script_dir + "images/Bezels/Bezel_Main.png";
            }
        }else{
            ArtObj.bezel.file_name = fe.script_dir + "images/Bezels/Bezel_trans.png";
        }

        prev_path = path;
        overview(0); // start checking for games overview
        start_background.visible = false;
        local Rpath = medias_path + fe.list.name + "/Themes/";
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

        if( !theme_content.len() ) { // if no theme is found .
            if(file_exist(medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + ".mp4")){ // if mp4 is found assume it's unified video theme
                path = medias_path + curr_sys + "/Themes/" + fe.game_info(Info.Name) + ".mp4";
                theme_content = [];
            }else{ //if no video is found assume it's system default theme
                path = medias_path + fe.list.name + "/Themes/Default/";
                theme_content = zip_get_dir( path );
                if(!theme_content.len()){
                    path = medias_path + fe.list.name + "/Themes/Default.zip";
                    theme_content = zip_get_dir( path );
                }
            }

            if( prev_path == path && surf_menu.visible == false ){ // if previous and current theme is equal ( and we are not in edit mode ).
                reset_art(true);
                load_theme(path, theme_content, true);
                foreach(a,b in artwork_list ) if( availables[b] == false ) anims[a].restart(); // not needed aymore (fot list without xml) ???
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

        if(Ini_settings.themes["infos_visibility"]) surf_ginfos.visible = ( curr_sys == "Main Menu" ? false : true ); // Game infos surface

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
        letters.file_name = medias_path + fe.list.name + "/Images/Letters/" + firstl.slice(0,1) + ".png";
        FE_Sound_Letter_Click.playing = true;
        letters.visible = true;
        trigger_letter = false;
    }
}

local last_click = 0;
fe.add_signal_handler(this, "on_signal")
function on_signal(str) {
    Stimer = fe.layout.time;
    //print("\n SIGNAL = "+str+ " - "+ last_click +"\n")
    if(curr_sys == "Main Menu" || surf_inf.visible){ //disable some buttons on main-menu and on special artwork screen
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
    }

        switch( str ) {
            case "prev_page":
            case "next_page":
                FE_Sound_Wheel_Jump.playing = true;
            break;

            case "next_display":
            case "prev_display":
                letters.visible = false;
                if(surf_inf.visible){
                    extraArtworks.setImage(str);
                    return true;
                }
            break;

            case "next_game":
            case "prev_game":
                letters.visible = false;
                conveyor.transition_ms = 50;
                try { conveyor.transition_ms = Ini_settings.wheel["transition_ms"].tointeger(); } catch ( e ) { } // restore conveyor transition time
                if( glob_time - last_click  > 160 &&  Ini_settings.sounds["wheel_click"] ) Sound_Click.playing = true; // need better key hold detection
                last_click = glob_time;
            break;

            case "next_letter":
            case "prev_letter":
                conveyor.transition_ms = 200; // smooth conveyor on letter jump
                trigger_letter = true;
            break;

            case my_config["extra_artworks_key"] : // Extra artworks screen
                if(curr_sys == "Main Menu") break;
                if(surf_inf.visible){
                    surf_inf_anim.reverse(true).play();
                }else{
                    extraArtworks.getLists();
                    extraArtworks.setImage();
                    surf_inf.visible = true;
                    surf_inf_anim.reverse(false).play();
                }
            break;

            case my_config["main_menu_key"] : // Main menu Key
                if(surf_inf.visible) return true; // do not show menu if special artwork screen is up
                surf_menu.visible = true;
                local MMenu = main_menu_rows;
                if(curr_sys == "Main Menu") MMenu = ["theme","settings"];
                sel_menu.add_rows( {"title":"main", "obj":"main", "rows":MMenu} );
                surf_menu_title.msg = sel_menu.titles();
                sel_menu.signal("list");
            break;
        }
    return false
}


// Apply a global fade on objs and shaders
function global_fade(ttime, target, direction){
   ttime = ttime.tofloat();
   local objlist = [surf_ginfos, point, syno.surface, flv_transitions, ArtObj.bezel]; // objects list to fade
   if(direction){ // show
        foreach(obj in objlist) obj.alpha = ttime * (255.0 / target);
        video_shader.set_param("alpha", (ttime / target) );
        foreach(k, obj in artwork_list ) artwork_shader[k].set_param("alpha", (ttime / target) );
        Trans_shader.set_param("alpha", ttime / target);
        ArtObj.SpecialA.shader.set_param("alpha", ttime / target);
        ArtObj.SpecialB.shader.set_param("alpha", ttime / target);
        for (local i=0; i < conveyor.m_objs.len(); i++) conveyor.m_objs[i].alpha = ttime * (255.0 / target);
        for (local i=0; i < ArtArray.len(); i++ ) ArtArray[i].alpha = ttime * (255.0 / target);
   }else{ // hide
        flv_transitions.video_playing = false; // stop playing ovveride video during fade
        foreach(obj in objlist) obj.alpha = 255.0 - ttime * (255.0 / target);
        video_shader.set_param("alpha", 1.0 - (ttime / target) );
        foreach(k, obj in artwork_list ) artwork_shader[k].set_param("alpha", 1.0 - (ttime / target) );
        Trans_shader.set_param("alpha",1.0 - (ttime / target) );
        ArtObj.SpecialA.shader.set_param("alpha",1.0 - (ttime / target) );
        ArtObj.SpecialB.shader.set_param("alpha",1.0 - (ttime / target) );
        for (local i=0; i < conveyor.m_objs.len(); i++) conveyor.m_objs[i].alpha = 0;
        for (local i=0; i < ArtArray.len(); i++ ) ArtArray[i].alpha = 255.0 - ttime * (255.0 / target);
   }
   return;
}


// Menu
local anim_tab = ["none","linear","ease","elastic","elastic bounce","flip","fade","bounce","blur","pixelate","zoom out","pixelate zoom out","chase","sweep left"];
anim_tab.extend( ["sweep right","strobe","grow","grow blur","grow bounce","grow x","grow y","grow center shrink","scroll","flag","pendulum","stripes","stripes 2","arc grow"] );
anim_tab.extend( ["arc shrink","bounce random","rain float","bounce around 3d","zoom","unzoom","fade out","expl"] );
local rest_tab = ["none","shake","rock","rock fast","squeeze","pulse","pulse fast","spin","spin slow","spin fast","hover","hover vertical","hover horizontal"];
local video_rest_tab = ["none","shake","rock","rock fast","squeeze","pulse","pulse fast","hover","hover vertical","hover horizontal"];
local start_tab = ["none","Top","Bottom","Left","Right"];
local video_anim_tab = ["none","pump","fade","tv","tv zoom out","ease","bounce","grow","grow x","grow y","grow bounce"];
local borders = ["bshape","bsize","bcolor","bsize2","bcolor2","bsize3","bcolor3"];
local border_conv = {"bsize":"border1","bsize2":"border2","bsize3":"border3"}
local truefalse = ["crt_scanline","keepaspect","override_transitions","overlaybelow"];
local cfloat = ["delay","time"];
local cinteger = ["zorder"];
local inivalue = ["crt_scanline","override_transitions"];

function update_list(str) {
    if(globals_temp.menu_return){ // prevent menu back to artwork list when on move/po/size
        globals_temp.menu_return = false;
        return true;
    }
    local upd_res = 0;
    local child = null;

    switch( str ) {

        case "select":
            local discard = false;
            local selected = sel_menu.select();
            local actual = xml_root.getChild(sel_menu.obj());

            switch(sel_menu.title()){
                case "time":
                case "delay":
                case "zorder":
                case "bshape":
                case "bcolor":
                case "bsize":
                case "bcolor2":
                case "bsize2":
                case "bsize3":
                case "bsize3":
                case "bcolor3":
                    discard = true;
                break;
            }

            // borders color
            if(sel_menu.title().find("bcolor") != null){
                local color = fe.overlay.edit_dialog("Enter color in HEX","").toupper();
                if(color == "") break;
                try{ actual.attr[ sel_menu.title() ]} catch ( e ) {actual.addAttr(sel_menu.title(), "")}
                actual.addAttr(sel_menu.title(), hex2dec(color));
                video_transform();
                local rgbC = dec2rgb(hex2dec(color));
                sel_menu._slot[0].set_bg_rgb(rgbC[0], rgbC[1], rgbC[2]);
            }

            if(selected == "pos/size/rotate" || selected == "pos/size") { 
                sel_menu._slot[0].set_bg_rgb(30, 240, 40);
                sel_menu.signal("pos_rot"); 
            }
            
            if(discard) break;

            surf_menu_title.msg = sel_menu.titles() + selected;

            if(selected == "settings"){
               sel_menu.add_rows( {"title":selected, "obj":selected, "rows":["ini test"]} );
            }else

            if(selected == "scraper"){
               sel_menu.add_rows( {"title":selected, "obj":selected, "rows":["Update Romlist","Update Infos","Update Medias","Update Synopsis"]} );
            }else

            if(selected == "theme"){
                // check if theme is editable (hd, no zip, theme.xml present)
                if(IS_ARCHIVE(path)){
                    fe.overlay.edit_dialog("Zip Theme are not editable...","Close")
                    break;
                }
                if( !file_exist(path + "Theme.xml") ){
                    fe.overlay.edit_dialog("No theme xml found, empty one is created for your resolution", "Close")
                    local f = ReadTextFile( fe.script_dir, "empty.xml" );
                    local raw_xml = "";
                    while ( !f.eos() ) raw_xml += f.read_line();
                    try{ xml_root = xml.load( raw_xml ); } catch ( e ) { }
                    local res_c = split( my_config["theme_resolution"].tolower(), "x");
                    xml_root.getChild("hd").addAttr("lw", res_c[0]);
                    xml_root.getChild("hd").addAttr("lh", res_c[1]);
                    save_xml(xml_root, path);
                    path = ""; // reset path forcing the theme reload artworks ( add user_setting() for ini load )
                    trigger_load_theme = true;
                    break;
                }

                if(!xml_root.getChild("hd")){
                    fe.overlay.edit_dialog("Only HD are editable...","Close")
                    break;
                }

                // display only available artworks
                local art_av = ["video"];
                foreach(a,b in availables) if(b) art_av.push( (a == "video" ? "video overlay" : a ) );
                art_av.sort();
                sel_menu.add_rows( {"title":selected, "obj":selected, "rows":art_av} );
                show_menu_artwork( sel_menu, surf_menu_img, artwork_list );
            }else

            if(selected.find("artwork") != null){
               sel_menu.add_rows( {"title":selected "obj":selected, "rows":["pos/size/rotate","keepaspect","animation","rest","start","time","delay","zorder"] });
            }else

            if(selected == "video"){
                sel_menu.add_rows( {"title":selected, "obj":selected ,"rows": ["pos/size/rotate","video anim","video rest","borders","start","time","delay","crt_scanline"]} );
            }else

            if(selected == "video overlay"){
                sel_menu.add_rows( {"title":selected, "obj":"video" ,"rows": ["pos/size","overlaybelow"]} );
            }else

            if(selected == "start"){
                try{ actual.attr["start"]} catch ( e ) {actual.addAttr("start", "none")}
                local posT = start_tab.map( function(value) {return value.tolower()} ).find( actual.attr["start"] );
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows": start_tab} );
                sel_menu.set_slot_pos(posT);
            }else

            if(selected == "borders"){
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows": borders} );
            }else

            if(truefalse.find(selected) != null){
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows": ["true","false"]} );
                local posT = null;
                if(inivalue.find(selected) != null){
                    posT = (Ini_settings.themes["crt_scanline"] == "true" ? 0 : 1);
                }else{
                    try{ actual.attr[selected]} catch ( e ) {actual.addAttr(selected, "none")}
                    posT = (actual.attr[selected] == "true" ? 0 : 1);
                }
                if(posT != null) sel_menu.set_slot_pos(posT);
            }else

            if(selected == "true" || selected == "false"){
                if(sel_menu.title() == "keepaspect"){
                    child = xml_root.getChild(sel_menu.obj());
                    if(child) child.addAttr(sel_menu.title(), selected);
                    ArtObj[sel_menu.obj()].preserve_aspect_ratio = (selected == "true" ? true : false ) ;
                }else if(sel_menu.title() == "overlaybelow"){
                        local c = xml_root.getChild(sel_menu.obj());
                        if(c)c.addAttr(sel_menu.title(), selected);
                        video_transform()
                }else{
                    save_ini( {"obj":sel_menu.title(), "val":selected}, curr_sys);
                    if(sel_menu.title() == "crt_scanline") video_shader.set_param("scanline", (selected == "true" ? 1.0 : 0.0 ) );
                }
            }else

            if(selected == "rest"){
                try{ actual.attr["rest"]} catch ( e ) {actual.addAttr("rest", "none")}
                local posT = rest_tab.find( actual.attr["rest"] );
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows":rest_tab} );
                sel_menu.set_slot_pos(posT);
            }else

            if(selected == "video rest"){
                try{ actual.attr["rest"]} catch ( e ) {actual.addAttr("rest", "none")}
                local posT = video_rest_tab.find( actual.attr["rest"] );
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows":video_rest_tab} );
                sel_menu.set_slot_pos(posT);
            }else

            if(selected == "animation"){
                try{ actual.attr["type"]} catch ( e ) {actual.addAttr("type", "none")}
                local posT = anim_tab.find( actual.attr["type"] );
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows": anim_tab} );
                sel_menu.set_slot_pos(posT);
            }else

            if(selected == "video anim"){
                try{ actual.attr["type"]} catch ( e ) {actual.addAttr("type", "none")}
                local posT = video_anim_tab.find( actual.attr["type"] );
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj() ,"rows": video_anim_tab} );
                sel_menu.set_slot_pos(posT);
            }else

            if(cinteger.find(selected) != null || selected.find("bsize") != null){
                local valb = 0;
                try{ valb = actual.attr[selected]} catch ( e ) {actual.addAttr(selected, 0)}
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows":[valb]} );
            }else

            if(cfloat.find(selected) != null){
                local valb = 0;
                try{ valb = actual.attr[selected]} catch ( e ) {actual.addAttr(selected, format("%.1f", 0))}
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows":[valb]} );
            }else

            if(selected.find("bcolor") != null){
                local valc = 0;
                try{ valc = actual.attr[selected].tointeger() } catch ( e ) {actual.addAttr(selected, "00000000")}
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows":[""]} );
                local rgbC = dec2rgb(valc);
                sel_menu._slot[0].set_bg_rgb(rgbC[0], rgbC[1], rgbC[2]);

            }else

            if(selected == "bshape"){
                local rd = "square";
                try{ rd = actual.attr[selected]} catch ( e ) {actual.addAttr(selected, "square")}
                sel_menu.add_rows( {"title":selected, "obj":sel_menu.prev_obj(), "rows":[rd]} );
            }else

            if( (video_anim_tab.find(selected) != null && sel_menu.title() == "video anim") || (anim_tab.find(selected) != null && sel_menu.title() == "animation" ) ){
                child = xml_root.getChild(sel_menu.obj());
                if(child) child.addAttr("type", selected);
            }else

            if( (rest_tab.find(selected) != null && sel_menu.title() == "rest" ) || start_tab.find(selected) != null ){
                child = xml_root.getChild(sel_menu.obj());
                if(child) child.addAttr(sel_menu.title(), selected.tolower());
            }

            if( video_rest_tab.find(selected) != null && sel_menu.title() == "video rest" ){
                child = xml_root.getChild(sel_menu.obj());
                if(child) child.addAttr("rest", selected.tolower());
            }

            if(child != null){
                save_xml(xml_root, path)
                hide_art();
                trigger_load_theme = true;
            }
        break;

        case "prev_game":
        case "up":
            sel_menu.up();
            show_menu_artwork( sel_menu, surf_menu_img, artwork_list );
            if(sel_menu.title().find("bsize") != null){
                child = xml_root.getChild(sel_menu.obj());
                if(child){
                    local border = border_conv[sel_menu.title()];
                    local bsize = child.attr[sel_menu.title()].tofloat();
                    bsize+=1;
                    if(bsize > 60) break;
                    child.addAttr(sel_menu.title(), format("%.1f", bsize))
                    sel_menu.set_text(0,  format("%.1f", bsize))
                    video_transform();
                }
            }

            if(sel_menu.title() == "bshape"){
               child = xml_root.getChild(sel_menu.obj());
               if(child){
                    local shp = child.attr[sel_menu.title()];
                    shp = (shp == "round" ? "square" : "round")
                    child.addAttr(sel_menu.title(), shp)
                    sel_menu.set_text(0, shp)
                    video_transform()
                }
            }

            if( cinteger.find(sel_menu.title()) != null ){ // increase int value
                child = xml_root.getChild(sel_menu.obj());
                if(child){
                    local valb = child.attr[sel_menu.title()].tointeger();
                    if(sel_menu.title() == "zorder"){
                        if(ArtObj[sel_menu.obj()].zorder == 0) break;
                        valb = ArtObj[sel_menu.obj()].zorder +=1;
                        ArtObj[sel_menu.obj()].zorder = valb;
                        zorder_list();
                    }else{
                        if(valb == 30) break;
                        valb+=1.0
                    }
                    child.addAttr(sel_menu.title(), valb)
                    sel_menu.set_text(0, valb)
                }
            }

            if( cfloat.find(sel_menu.title()) != null ){ // increase float value
                child = xml_root.getChild(sel_menu.obj());
                if(child){
                    local valb = child.attr[sel_menu.title()].tofloat();
                    if(valb == 30) break;
                    valb+=0.5
                    child.addAttr(sel_menu.title(), format("%.1f", valb))
                    sel_menu.set_text(0,  format("%.1f", valb))
                }
            }
        break;

        case "next_game":
        case "down":
            sel_menu.down();
            show_menu_artwork( sel_menu, surf_menu_img, artwork_list );
            if(sel_menu.title().find("bsize") != null){
                child = xml_root.getChild(sel_menu.obj());
                if(child){
                    local border = border_conv[sel_menu.title()];
                    local bsize = child.attr[sel_menu.title()].tofloat();
                    bsize-=1;
                    if(bsize < 0) break;
                    child.addAttr(sel_menu.title(), format("%.1f", bsize))
                    sel_menu.set_text(0,  format("%.1f", bsize))
                    video_transform();
                }
            }

            if(sel_menu.title() == "bshape"){
               child = xml_root.getChild(sel_menu.obj());
               if(child){
                    local shp = child.attr[sel_menu.title()];
                    shp = (shp == "round" ? "square" : "round")
                    child.addAttr(sel_menu.title(), shp)
                    sel_menu.set_text(0, shp)
                    video_transform()
                }
            }

            if( cinteger.find(sel_menu.title()) != null ){ // decrease int value
                child = xml_root.getChild(sel_menu.obj());
                if(child){
                    local valb = child.attr[sel_menu.title()].tointeger();
                    if(sel_menu.title() == "zorder"){
                        if(ArtObj[sel_menu.obj()].zorder < -10) break;
                        valb = ArtObj[sel_menu.obj()].zorder -=1;
                        ArtObj[sel_menu.obj()].zorder = valb;
                        zorder_list();
                    }else{
                        if(valb == 30) break;
                        valb-=1.0
                    }
                    child.addAttr(sel_menu.title(), valb)
                    sel_menu.set_text(0, valb)
                }
            }

            if( cfloat.find(sel_menu.title()) != null ){ // decrease float value
                child = xml_root.getChild(sel_menu.obj());
                if(child){
                    local valb = child.attr[sel_menu.title()].tofloat();
                    if(valb == 0) break;
                    valb-=0.5
                    child.addAttr(sel_menu.title(), format("%.1f", valb))
                    sel_menu.set_text(0,  format("%.1f", valb))
                }
            }
        break;

        case "back":
            if( main_menu_rows.find(sel_menu.select()) != null ){ // first menu then exit
                surf_menu_img.visible = false;
                close_menu()
            }else{
                sel_menu.back();
                surf_menu_title.msg = sel_menu.titles();
                surf_menu_info.visible = false;
            }
        break;

        case my_config["main_menu_key"] : // Save Xml when exiting menu
            close_menu();
        break;
    }
    return true;
}

function zorder_list(){
    surf_menu_info.msg = "a1:" + ArtObj["artwork1"].zorder + " a2:" + ArtObj["artwork2"].zorder + " a3:" + ArtObj["artwork3"].zorder;
    surf_menu_info.msg += "a4:" + ArtObj["artwork4"].zorder + " a5:" + ArtObj["artwork5"].zorder + " a6:" + ArtObj["artwork6"].zorder + " snap:" + ArtObj["snap"].zorder;
    surf_menu_info.visible = true;
}

function close_menu(save=true){
    if(save) save_xml(xml_root, path);
    sel_menu.signal("default");
    sel_menu.reset();
    surf_menu.visible = false;
    surf_menu_img.visible = false;
}

function g_input(inp){

    local ar = {};
    ar.Right <- ["Joy0 Right", "Right"];
    ar.Left  <- ["Joy0 Left", "Left"];
    ar.Up    <- ["Joy0 Up", "Up"];
    ar.Down  <- ["Joy0 Down", "Down"];
    ar.HC    <- ["Joy0 Button5", "H"]; // horizontal center
    ar.VC    <- ["Joy0 Button4", "V"]; // vertical center
    if( my_config["JoyType"]  == "Dinput"){
        ar.C     <- ["Joy0 Button7", "Add"];
        ar.CW    <- ["Joy0 Button6", "Subtract"];
        ar.ZWP   <- ["Joy0 Zpos", "Numpad7"];
        ar.ZWM   <- ["Joy0 Zneg", "Numpad9"];
        ar.ZHP   <- ["Joy0 Rneg", "Numpad1"];
        ar.ZHM   <- ["Joy0 Rpos", "Numpad3"];
    }else{
        ar.C     <- ["Joy0 Zneg", "Add"];
        ar.CW    <- ["Joy0 Zpos", "Subtract"];
        ar.ZWP   <- ["Joy0 Upos", "Numpad7"];
        ar.ZWM   <- ["Joy0 Uneg", "Numpad9"];
        ar.ZHP   <- ["Joy0 Vneg", "Numpad1"];
        ar.ZHM   <- ["Joy0 Vpos", "Numpad3"];
    }
    foreach(a,b in ar[inp]) if(fe.get_input_state(b) != false) return true;

    return false;
}

local step = 0.5;
function accel(ttime, last_click, sel_menu){
    local key_delay = 1200;
    if ( (ttime - last_click) > key_delay ){
        step*=1.5;
        sel_menu._last_click = ttime;
    }
    return step > 3.00 ? 3.5 : step;
}

function fake_sig(str){
    return true;
}

function edit(elem, ttime, last_click){ // edit for pos/size/rotat

    if(fe.get_input_state("back")){
        _slot[0].set_bg_rgb(150,100,100); // restore cell color
        sel_menu.signal("list");
        return true;
    }
    local set = false;
    local child = xml_root.getChild(elem);
    if(!child) return;

    local w,h,r;
    try{ w = child.attr["w"].tofloat(); } catch(e){ // add var to xml if missing (needed !)
        child.addAttr( "w", ArtObj[elem].texture_width );
        w = child.attr["w"].tofloat();
    }
    try{ h = child.attr["h"].tofloat(); } catch(e){ // add var to xml if missing (needed !)
        child.addAttr( "h", ArtObj[elem].texture_height );
        h = child.attr["h"].tofloat();
    }
    try{ child.attr["keepaspect"] } catch(e){ // add var to xml if missing (needed !)
        child.addAttr( "keepaspect", "false" );
    }

    local x = child.attr["x"].tofloat();
    local y = child.attr["y"].tofloat();
    try{ r = child.attr["r"].tofloat(); } catch(e){ r = 0.0 }

    local inf = "x:" + format("%.1f", x) + " y:" + format("%.1f", y) + " w:" + format("%.1f", w) + " h:" + format("%.1f", h) + " r:" + format("%.1f", r);
    surf_menu_info.msg = inf;
    surf_menu_info.visible = true;

    if( g_input("Right") ) set = child.addAttr("x", x+=accel(ttime, last_click, sel_menu));

    if( g_input("Left") ) set = child.addAttr("x", x-=accel(ttime, last_click, sel_menu));

    if( g_input("Up") ) set = child.addAttr("y", y-=accel(ttime, last_click, sel_menu));

    if( g_input("Down") ) set = child.addAttr("y", y+=accel(ttime, last_click, sel_menu));

    if( g_input("CW") ){
        if(r < -360) r = 0.0;
        set = child.addAttr("r", r-=step); // rotate cw
    }

    if( g_input("C") ){
        if(r > 360) r = 0.0;
        set = child.addAttr("r", r+=step); // rotate c
    }
    if( g_input("ZWP") ){
        set = child.addAttr("w", w+=step); // zoom width +
        if(child.attr["keepaspect"] == "true") child.addAttr("h", h+=step);
    }
    if( g_input("ZWM") ){
        set = child.addAttr("w", w-=step); // zoom width -
        if(child.attr["keepaspect"] == "true") child.addAttr("h", h-=step);
    }
    if( g_input("ZHP") ){
        set = child.addAttr("h", h+=step); // zoom height +
        if(child.attr["keepaspect"] == "true") child.addAttr("w", h+=step);
    }
    if( g_input("ZHM") ){
        set = child.addAttr("h", h-=step); // zoom height -
        if(child.attr["keepaspect"] == "true") child.addAttr("w", w-=step);
    }

    if( g_input("HC") ) set = child.addAttr("x", x = xml_root.getChild("hd").attr.lw.tofloat() * 0.5);
    if( g_input("VC") ) set = child.addAttr("y", y = xml_root.getChild("hd").attr.lh.tofloat() * 0.5);

    if( !g_input("Right") && !g_input("Left") && !g_input("Up") && !g_input("Down") ) step = 0.5;

    if(set != false) if(elem != "video") artworks_transform(elem) else video_transform();

    return;
}

function overlay_video(){
    if(fe.get_input_state("back")){
        _slot[0].set_bg_rgb(150,100,100); // restore cell color
        sel_menu.signal("list");
        return;
    }

    if(!availables["video"]) return;
    local child = xml_root.getChild("video");
    local set = false;
    local overlaywidth, overlayheight, overlayoffsetx, overlayoffsety;

    try{ overlayoffsetx = child.attr["overlayoffsetx"].tofloat(); } catch(e){ // add var to xml if missing (needed !)
        child.addAttr( "overlayoffsetx", ArtObj.video.texture_width );
        overlayoffsetx = child.attr["overlayoffsetx"].tofloat();
    }
    try{ overlayoffsety = child.attr["overlayoffsety"].tofloat(); } catch(e){ // add var to xml if missing (needed !)
        child.addAttr( "overlayoffsety", 0.0 );
        overlayoffsety = child.attr["overlayoffsety"].tofloat();
    }

    try{ overlaywidth = child.attr["overlaywidth"].tofloat(); } catch(e){ // add var to xml if missing (needed !)
        child.addAttr( "overlaywidth", 0.0 );
        overlaywidth = child.attr["overlaywidth"].tofloat();
    }
    try{ overlayheight = child.attr["overlayheight"].tofloat(); } catch(e){ // add var to xml if missing (needed !)
        child.addAttr( "overlayheight", ArtObj.video.texture_height );
        overlayheight = child.attr["overlayheight"].tofloat();
    }

    if( g_input("Up") ) set = child.addAttr( "overlayoffsety", overlayoffsety-=0.5 ); // Up

    if( g_input("Down") ) set = child.addAttr( "overlayoffsety", overlayoffsety+=0.5 ); // Down

    if( g_input("Right") ) set = child.addAttr( "overlayoffsetx", overlayoffsetx+=0.5 ); // right

    if( g_input("Left") ) set = child.addAttr( "overlayoffsetx", overlayoffsetx-=0.5); // left

    if( g_input("ZWP") ) set = child.addAttr( "overlaywidth", overlaywidth+=0.5 ); // zoom width +

    if( g_input("ZWM") ) set = child.addAttr( "overlaywidth", overlaywidth-=0.5 ); // zoom width -

    if( g_input("ZHP") ) set = child.addAttr( "overlayheight", overlayheight+=0.5 ); // zoom height +

    if( g_input("ZHM") ) set = child.addAttr( "overlayheight", overlayheight-=0.5 ); // zoom height -

    if( g_input("HC") ) set = child.addAttr("overlayoffsetx", overlayoffsetx = 0.0); // horizontal center

    if( g_input("VC") ) set = child.addAttr("overlayoffsety", overlayoffsety = 0.0); // vertical center

    local inf = "offsetx:" + format("%.1f", overlayoffsetx) + " offsety:" + format("%.1f", overlayoffsety) + " w:" + format("%.1f", overlaywidth) + " h:" + format("%.1f", overlayheight);
    surf_menu_info.msg = inf;
    surf_menu_info.visible = true;
    if(set != false) video_transform();

    return;
}

function artworks_transform(Xtag, rotate=true, art=""){
    local artD = set_art_datas(Xtag);  // get original xml value
    local rt = SRT();
    if(artD.keepaspect || !hd) ArtObj[Xtag].preserve_aspect_ratio = true;

    if( !artD.w || !artD.h ){
        artD.w = ArtObj[Xtag].texture_width;
        artD.h = ArtObj[Xtag].texture_height;
    }

    artD.x -= artD.w * 0.5;
    artD.y -= artD.h * 0.5;

    if( rotate ){
        ArtObj[Xtag].rotation = artD.r;
        local mr = PI * artD.r / 180;
        artD.x += cos( mr ) * (-artD.w * 0.5) - sin( mr ) * (-artD.h * 0.5) + artD.w * 0.5;
        artD.y += sin( mr ) * (-artD.w * 0.5) + cos( mr ) * (-artD.h * 0.5) + artD.h * 0.5;
    }

    if( ext(art).tolower() == "swf" && !hd ){
        local swf_except = { "Mame" : ["bonzeadv","ironclad"] };// table of system and theme name where the swf fixes should not be applied.
        local exception = false;
        if(swf_except.rawin(curr_sys)) if ( swf_except[curr_sys].find(fe.game_info(Info.Name)) != null ) exception = true;
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

    ArtObj[Xtag].set_pos( (artD.x * rt.mul) + rt.offset_x, (artD.y * rt.mul_h) + rt.offset_y, artD.w * rt.mul , artD.h * rt.mul_h);

    if(hd) ArtObj[Xtag].zorder = artD.zorder; // zorder only on HD theme
}
