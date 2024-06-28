/********************************************
KeyboardSearch module
This module allows any layout to easily add a customizable keyboard search to its interface. You can modify the key
layout, look, search key, search method and more..

For usage, see:
https://github.com/liquid8d/attract-extra/tree/master/modules/objects/keyboard-search/

*********************************************/

pcca_genres <- [
    {"id": "1", "fr": "Action", "en": "Action"},
    {"id": "2", "fr": "Aventure", "en": "Adventure"},
    {"id": "3", "fr": "Casse briques", "en": "Breakout games"},
    {"id": "4", "fr": "Escalade", "en": "Climbing"},
    {"id": "5", "fr": "Labyrinthe", "en": "Labyrinth"},
    {"id": "6", "fr": "Action RPG", "en": "Action RPG"},
    {"id": "7", "fr": "Adulte", "en": "Adult"},
    {"id": "8", "fr": "Aventure", "en": "Adventure"},
    {"id": "9", "fr": "3D Temps Réel", "en": "RealTime 3D"},
    {"id": "10", "fr": "Film Interactif", "en": "Interactive Movie"},
    {"id": "11", "fr": "Graphique", "en": "Graphics"},
    {"id": "12", "fr": "Point and Click", "en": "Point and Click"},
    {"id": "13", "fr": "Roman Visuel", "en": "Visual Novel"},
    {"id": "14", "fr": "Survival Horror", "en": "Survival Horror"},
    {"id": "15", "fr": "Jeu Texte", "en": "Textual Game"},
    {"id": "16", "fr": "Beat'em All", "en": "Beat'em Up"},
    {"id": "17", "fr": "Casino", "en": "Casino"},
    {"id": "18", "fr": "Cartes", "en": "Cards"},
    {"id": "19", "fr": "Casino / Course", "en": "Casino / Race"},
    {"id": "20", "fr": "Loterie", "en": "Lottery"},
    {"id": "21", "fr": "Machine a sous", "en": "Slot machine"},
    {"id": "22", "fr": "Roulette", "en": "Roulette"},
    {"id": "23", "fr": "Casual Game", "en": "Casual Game"},
    {"id": "24", "fr": "Chasse", "en": "Hunting"},
    {"id": "25", "fr": "Chasse et Peche", "en": "Hunting and Fishing"},
    {"id": "26", "fr": "Combat", "en": "Fight"},
    {"id": "27", "fr": "2.5D", "en": "2.5D"},
    {"id": "28", "fr": "2D", "en": "2D"},
    {"id": "29", "fr": "3D", "en": "3D"},
    {"id": "30", "fr": "Versus", "en": "Versus"},
    {"id": "31", "fr": "Versus Co-op", "en": "Co-op"},
    {"id": "32", "fr": "Vertical", "en": "Vertical"},
    {"id": "33", "fr": "Compilation", "en": "Compilation"},
    {"id": "34", "fr": "Construction & Management", "en": "Build And Management"},
    {"id": "35", "fr": "Course de chevaux", "en": "Horses race"},
    {"id": "36", "fr": "Course de Moto vue 1er pers.", "en": "Motorcycle Race, 1st Pers."},
    {"id": "37", "fr": "Course de Moto vue 3eme pers.", "en": "Motorcycle Race, 3rd Pers."},
    {"id": "38", "fr": "Course vue 1ere pers.", "en": "Race 1st Pers. view"},
    {"id": "39", "fr": "Course vue 3eme pers.", "en": "Race 3rd Pers. view"},
    {"id": "40", "fr": "Course, Conduite", "en": "Race, Driving"},
    {"id": "41", "fr": "Avion", "en": "Plane"},
    {"id": "42", "fr": "Bateau", "en": "Boat"},
    {"id": "43", "fr": "Course", "en": "Race"},
    {"id": "44", "fr": "Deltaplane", "en": "Hang-glider"},
    {"id": "45", "fr": "Course, Conduite / Moto", "en": "Race, Driving / Motorcycle"},
    {"id": "46", "fr": "Demo", "en": "Demo"},
    {"id": "47", "fr": "Divers", "en": "Various"},
    {"id": "48", "fr": "Electro-mecanique", "en": "Electro- Mechanical"},
    {"id": "49", "fr": "Print Club", "en": "Print Club"},
    {"id": "50", "fr": "Système", "en": "System"},
    {"id": "51", "fr": "Utilitaires", "en": "Utilities"},
    {"id": "52", "fr": "Dungeon RPG", "en": "Dungeon Crawler RPG"},
    {"id": "53", "fr": "Flipper", "en": "Pinball"},
    {"id": "54", "fr": "Go", "en": "Go"},
    {"id": "55", "fr": "Hanafuda", "en": "Hanafuda"},
    {"id": "56", "fr": "Jeu de cartes", "en": "Playing cards"},
    {"id": "57", "fr": "Jeu de Rôle Japonais", "en": "Japanese RPG"},
    {"id": "58", "fr": "Jeu de Rôle Tactique", "en": "Tactical RPG"},
    {"id": "59", "fr": "Jeu de rôles", "en": "Role playing games"},
    {"id": "60", "fr": "Jeu de rôles en équipe", "en": "Team-as-one RPG"},
    {"id": "61", "fr": "Jeu de societe / plateau", "en": "Board game"},
    {"id": "62", "fr": "Jeu de societe asiatique", "en": "Asiatic board game"},
    {"id": "63", "fr": "Ludo-Educatif", "en": "Educational"},
    {"id": "64", "fr": "Mahjong", "en": "Mahjong"},
    {"id": "65", "fr": "MMORPG", "en": "Massive Multiplayer Online RPG"},
    {"id": "66", "fr": "Musique et Danse", "en": "Music and Dance"},
    {"id": "67", "fr": "N/A", "en": "N/A"},
    {"id": "68", "fr": "Othello", "en": "Othello"},
    {"id": "69", "fr": "Pachinko", "en": "Pachinko"},
    {"id": "70", "fr": "Peche", "en": "Fishing"},
    {"id": "71", "fr": "Plateforme", "en": "Platform"},
    {"id": "72", "fr": "Fighter Scrolling", "en": "Fighter Scrolling"},
    {"id": "73", "fr": "Run Jump", "en": "Run Jump"},
    {"id": "74", "fr": "Run Jump Scrolling", "en": "Run Jump Scrolling"},
    {"id": "75", "fr": "Shooter Scrolling", "en": "Shooter Scrolling"},
    {"id": "76", "fr": "Puzzle-Game", "en": "Puzzle-Game"},
    {"id": "77", "fr": "Egaler", "en": "Equalize"},
    {"id": "78", "fr": "Glisser", "en": "Glide"},
    {"id": "79", "fr": "Lancer", "en": "Throw"},
    {"id": "80", "fr": "Tomber", "en": "Fall"},
    {"id": "81", "fr": "Quiz", "en": "Quiz"},
    {"id": "82", "fr": "Quiz / Allemand", "en": "Quiz / German"},
    {"id": "83", "fr": "Quiz / Anglais", "en": "Quiz / English"},
    {"id": "84", "fr": "Quiz / Coréen", "en": "Quiz / Korean"},
    {"id": "85", "fr": "Quiz / Espagnol", "en": "Quiz / Spanish"},
    {"id": "86", "fr": "Quiz / Français", "en": "Quiz / French"},
    {"id": "87", "fr": "Quiz / Italien", "en": "Quiz / Italian"},
    {"id": "88", "fr": "Quiz / Japonais", "en": "Quiz / Japanese"},
    {"id": "89", "fr": "Quiz / Musical Anglais", "en": "Quiz / Music English"},
    {"id": "90", "fr": "Quiz / Musical Japonais", "en": "Quiz / Music Japanese"},
    {"id": "91", "fr": "Réflexion", "en": "Reflection"},
    {"id": "92", "fr": "Renju", "en": "Renju"},
    {"id": "93", "fr": "Rythme", "en": "Rhythm"},
    {"id": "94", "fr": "Shoot'em Up", "en": "Shoot'em Up"},
    {"id": "95", "fr": "Diagonal", "en": "Diagonal"},
    {"id": "96", "fr": "Horizontal", "en": "Horizontal"},
    {"id": "97", "fr": "Vertical", "en": "Vertical"},
    {"id": "98", "fr": "Shooter Small", "en": "Shooter Small"},
    {"id": "99", "fr": "Shougi", "en": "Shougi"},
    {"id": "100", "fr": "Simulation", "en": "Simulation"},
    {"id": "101", "fr": "Science Fiction", "en": "SciFi"},
    {"id": "102", "fr": "Véhicules", "en": "Vehicle"},
    {"id": "103", "fr": "Vie", "en": "Life"},
    {"id": "104", "fr": "Sport", "en": "Sports"},
    {"id": "105", "fr": "Baseball", "en": "Baseball"},
    {"id": "106", "fr": "Basketball", "en": "Basketball"},
    {"id": "107", "fr": "Billard", "en": "Pool"},
    {"id": "108", "fr": "Bowling", "en": "Bowling"},
    {"id": "109", "fr": "Boxe", "en": "Boxing"},
    {"id": "110", "fr": "Bras de fer", "en": "Arm wrestling"},
    {"id": "111", "fr": "Combat", "en": "Fighting"},
    {"id": "112", "fr": "Course a pied", "en": "Running trails"},
    {"id": "113", "fr": "Dodgeball", "en": "Dodgeball"},
    {"id": "114", "fr": "Flechette", "en": "Darts"},
    {"id": "115", "fr": "Football", "en": "Soccer"},
    {"id": "116", "fr": "Football Américain", "en": "Football"},
    {"id": "117", "fr": "Golf", "en": "Golf"},
    {"id": "118", "fr": "Handball", "en": "Handball"},
    {"id": "119", "fr": "Hockey", "en": "Hockey"},
    {"id": "120", "fr": "Jeu de palet", "en": "Shuffleboard"},
    {"id": "121", "fr": "Lutte", "en": "Wrestling"},
    {"id": "122", "fr": "Natation", "en": "Swimming"},
    {"id": "123", "fr": "Parachutisme", "en": "Skydiving"},
    {"id": "124", "fr": "Ping pong", "en": "Table tennis"},
    {"id": "125", "fr": "Rugby", "en": "Rugby"},
    {"id": "126", "fr": "Skateboard", "en": "Skateboard"},
    {"id": "127", "fr": "Ski", "en": "Skiing"},
    {"id": "128", "fr": "Sumo", "en": "Sumo"},
    {"id": "129", "fr": "Tennis", "en": "Tennis"},
    {"id": "130", "fr": "Volleyball", "en": "Volleyball"},
    {"id": "131", "fr": "Sport avec animaux", "en": "Sports with Animals"},
    {"id": "132", "fr": "Stratégie", "en": "Strategy"},
    {"id": "133", "fr": "Tir", "en": "Shooter"},
    {"id": "134", "fr": "Tir / 1ere Personne", "en": "Shooter / 1st person"},
    {"id": "135", "fr": "Tir / 3eme Personne", "en": "Shooter / 3rd person"},
    {"id": "136", "fr": "Tir / A pied", "en": "Shooter / Run and Shoot"},
    {"id": "137", "fr": "Tir / Avion", "en": "Shooter / Plane"},
    {"id": "138", "fr": "Tir / Avion, 1ere personne", "en": "Shooter / Plane, 1st person"},
    {"id": "139", "fr": "Tir / Avion, 3eme personne", "en": "Shooter / Plane, 3rd person"},
    {"id": "140", "fr": "Tir / Horizontal", "en": "Shooter / Horizontal"},
    {"id": "141", "fr": "Tir / Missile Command Like", "en": "Shooter / Missile Command Like"},
    {"id": "142", "fr": "Tir / Run and Gun", "en": "Shooter / Run and Gun"},
    {"id": "143", "fr": "Space Invaders Like", "en": "Space Invaders Like"},
    {"id": "144", "fr": "Tir / Véhicule, 1ere personne", "en": "Shooter / Vehicle, 1st person"},
    {"id": "145", "fr": "Tir / Vehicule, 3eme personne", "en": "Shooter / Vehicle, 3rd person"},
    {"id": "146", "fr": "Tir / Véhicule, Diagonal", "en": "Shooter / Vehicle, Diagonal"},
    {"id": "147", "fr": "Tir / Véhicule, Horizontal", "en": "Shooter / Vehicle, Horizontal"},
    {"id": "148", "fr": "Tir / Véhicule, Vertical", "en": "Shooter / Vehicle, Vertical"},
    {"id": "149", "fr": "Tir / Vertical", "en": "Shooter / Vertical"},
    {"id": "150", "fr": "Tir avec accessoire", "en": "Lightgun Shooter"},
    {"id": "151", "fr": "Fetes", "en": "Party"},
    {"id": "191", "fr": "Snowboard", "en": "Snowboard"},
    {"id": "190", "fr": "Cyclisme ", "en": "Cycling"}
]


class KeyboardSearch {
    VERSION = 1.2
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

    result_text = null
    // title object, input object, title text , options array, options idx
    sub_index = -1
    sub_rows = [
        [null, null, "Condition:", ["contains", "not_contains", "equals", "not_equals"], 0],
        [null, null, "Filter By:", ["Title", "CloneOf", "Year", "Players", "Status", "PlayedCount", "Tags", "Category", "Manufacturer"], 0]
    ];

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
    user_lang = "en";
    pcca_list = false;

    constructor(surface) {
        this.surface = surface
        this.keys = {}
    }
    function get_text() { return text }
    function user_lang(lang) { this.user_lang = lang.tolower(); return this; }
    function cat_mode(mode) { this.pcca_list = (mode == "Yes" ? true : false); return this; }
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

    function auto_size(size) {
        local widthRatio = fe.layout.width / 1920.0;
        local heightRatio = fe.layout.height / 1080.0;
        return size * (widthRatio < heightRatio ? widthRatio : heightRatio);
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

        local title_txt = surface.add_text("Search", osd_search.x, osd_search.y * 0.08, osd_search.width, auto_size(80))

        search_text = surface.add_text(text, osd_search.x, osd_search.y, osd_search.width, osd_search.height)
        search_text.align = Align.MiddleLeft
        search_text.set_bg_rgb(60,60,60)
        search_text.bg_alpha = 150
        search_text.font = config.search_text.font
        search_text.set_rgb( config.search_text.rgba[0], config.search_text.rgba[1], config.search_text.rgba[2] )
        search_text.alpha = config.search_text.rgba[3]
        search_text.charsize = auto_size(60)

        //draw rules input
        result_text = surface.add_text("", osd_search.x, surface.height * 0.95, osd_search.width, surface.height * 0.04)
        result_text.align = Align.MiddleLeft
        result_text.charsize = auto_size(35)
        result_text.font = config.search_text.font
        result_text.set_bg_rgb(60,60,60)


        foreach( key, val in sub_rows ) {
            local y = osd_search.y - osd_search.height - (key * (osd_search.height * 0.50) )
            sub_rows[key][0] = surface.add_text(sub_rows[key][2], osd_search.x, y, osd_search.width * 0.35, osd_search.height);
            sub_rows[key][0].font = config.search_text.font
            sub_rows[key][0].align = Align.Left
            sub_rows[key][0].charsize = auto_size(35)
            sub_rows[key][0].set_rgb( config.search_text.rgba[0], config.search_text.rgba[1], config.search_text.rgba[2] )

            sub_rows[key][1] = surface.add_text(sub_rows[key][3][sub_rows[key][4]], osd_search.x + sub_rows[key][0].width, y , osd_search.width, osd_search.height);
            sub_rows[key][1].font = config.search_text.font
            sub_rows[key][1].align = Align.Left
            sub_rows[key][1].charsize = auto_size(35)
            sub_rows[key][1].set_rgb( config.search_text.rgba[0], config.search_text.rgba[1], config.search_text.rgba[2] )
            sub_rows[key][1].alpha = 255
        }

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
            //local rule = "Name contains " + _massage(text)
            local rule = sub_rows[1][3][sub_rows[1][4]]  + " " + sub_rows[0][3][sub_rows[0][4]] + " "  + _massage(text)

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
                    //if(text.len() < 1) return;
                    fe.list.search_rule = ( text.len() > 0 ) ? rule : ""
                    local r = ::main_infos[curr_sys].cnt - fe.list.size;
                    r = r > 0 ? fe.list.size : 0;
                    result_text.msg = ( text.len() > 0 ) ? "Result: " + r : ""
                    break
            }
        } catch ( err ) { print( "Unable to apply filter: " + err ); }
    }

    function replace_char(str, ch) {
        local parts = split(str, ch);
        local result = "";
        foreach (part in parts) {
            if (result.len() > 0)
                result += " " + ch + " ";
            result += part;
        }
        return result;
    }
    function _massage( str )
    {
        if(pcca_list){
            local regx = "^"+str+"$|,"+str+"$|^"+str+",|,"+str+",";
            return regx
        }
        str = replace_char(str, "-")
        if ( str.len() == 0 ) return ""
        str = str.tolower()
        local words = split( str, " " )
        local temp = ""
        foreach ( idx, w in words )
        {
            print("searching: " + w +"\n")
            if ( temp.len() > 0 )
                temp += " "
            local f = w.slice( 0, 1 )
            temp += ( "1234567890".find(f) != null ) ? "[" + f + "]" + w.slice(1) : "[" + f.toupper() + f.tolower() + "]" + w.slice(1)
        }
        temp = replace(temp, " [--] ", "-")
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
        if(curr_sys != sys){ // reload artwork letters only if sys is changed
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

    //get current visibility
    function visible() {
        return (surface.alpha == 255)
    }

    //debug print
    function print(msg) {
        if ( debug ) ::print("KeyboardSearch plugin: " + msg + "\n")
    }



    function subMenu(str) {
        foreach (row in sub_rows) {
           row[1].set_rgb( config.search_text.rgba[0], config.search_text.rgba[1], config.search_text.rgba[2] )
        }
        if (str == "down" && sub_index == 0){
            sub_index = -1
            local prev = config.keys.rows[config.keys.selected[1]][config.keys.selected[0]].tochar();
            keys[prev].set_rgb( config.keys.rgba_selected[0], config.keys.rgba_selected[1], config.keys.rgba_selected[2] )
            return false;
        }
        if (str == "up" && sub_index < sub_rows.len() - 1) sub_index++
        if (str == "down" && sub_index > 0) sub_index--
        sub_rows[sub_index][1].set_rgb( config.keys.rgba_selected[0], config.keys.rgba_selected[1], config.keys.rgba_selected[2] )
    }

    //process keys
    function on_signal(str) {
        if ( str == config.search_key ) {
            toggle()
            return true
        }
        if ( visible() )
        {
            print("key press: " + str + "\n")
            if (str == "up") {
                if(config.keys.selected[1] == 0){
                       local prev = config.keys.rows[config.keys.selected[1]][config.keys.selected[0]].tochar();
                       keys[prev].set_rgb( config.search_text.rgba[0], config.search_text.rgba[1], config.search_text.rgba[2] )
                       subMenu(str);
                }else{
                    select_relative(0, -1);
                }
            }else if ( str == "down" ){
                if (sub_index > -1){
                    subMenu(str);
                    return true;
                }
                select_relative( 0, 1 )
            }else if ( str == "left" ){
                if(sub_index > -1){
                    update_selected_option(-1)
                }else{
                    select_relative( -1, 0 )
                }
            }else if ( str == "right" ){
                if(sub_index > -1){
                    update_selected_option(1)
                }else{
                    select_relative( 1, 0 )
                }
            }else if ( str == "select" ){
                if(sub_index > -1){
                    local filter_options = sub_rows[sub_index][3];
                    switch (filter_options[sub_rows[sub_index][4]]){
                        case "Category":
                            clear()
                            if(pcca_list){
                                category_list_pcca();
                            }else{
                                category_list();
                            }
                        break;
                        case "Tags":
                        case "Manufacturer":
                            clear()
                            group_list(filter_options[sub_rows[sub_index][4]]);
                    }
                    return true; // discard select on condition field
                }
                type( config.keys.rows[config.keys.selected[1]][config.keys.selected[0]].tochar() )
            }else if ( str == "back" ) {
                if ( text.len() == 0 ) toggle() else type("<")
            }else if ( str == "exit" ){
                toggle()
            }
            return true
        }
        return false;
    }

    function group_list(group) {
        // set var to "equal" by default
        sub_rows[0][4] = 0
        sub_rows[0][1].msg = sub_rows[0][3][2]
        local list_attr = Info.Tags;
        switch (group){
            case "Manufacturer":
                list_attr = Info.Manufacturer
        }
        local grouplist = []
        for (local i = 0 ; i < fe.list.size ; i++) {
            local tag0 = fe.game_info (list_attr, i, (fe.filters.len() != 0 ? -fe.list.filter_index : 0))
            local tagarr = split(tag0, ";")
            foreach (tag in tagarr) grouplist.push(tag);
        }
        grouplist = array_unique(grouplist)
        grouplist.sort()
        if(!grouplist.len()) return false
        ::SetListBox(::overlay_list, {visible = true, rows = 5, sel_rgba = [255,0,0,255], bg_alpha = 125, selbg_alpha = 190, charsize = auto_size(42) })
        local selected = ::fe.overlay.list_dialog(grouplist, group + " list");
        if(selected > -1){
            search_text.msg = grouplist[selected]
            text = grouplist[selected]
        }
        update_rule();

        return grouplist
    }

    function category_list_pcca(){
        // set var to "contain" by default
        sub_rows[0][4] = 0
        sub_rows[0][1].msg = sub_rows[0][3][0]

        local catlist = []
        for (local i = 0 ; i < fe.list.size ; i++) {
            local tag0 = fe.game_info (Info.Category,i, (fe.filters.len()!=0 ? - fe.list.filter_index:0))
            local catarr = split(tag0, ",")
            foreach (tag in catarr) catlist.push(tag);
        }
        catlist = array_unique(catlist)
        if(!catlist.len()) return false
        local newcat = [];
        foreach(a,b in catlist){
            foreach (genre in pcca_genres) {
                if(b == genre["id"]){
                    newcat.push(genre[user_lang])
                    break;
                }
            }
        }
        newcat.sort()
        ::overlay_title.y = flh*0.317
        ::overlay_title.set_rgb(255, 10, 10);
        ::SetListBox(::overlay_list, {visible = true, rows = 6, sel_rgba = [255,0,0,255], bg_alpha = 125, selbg_alpha = 190, charsize = auto_size(42) })
        local selected = ::fe.overlay.list_dialog(newcat, "Category list");
        if(selected > -1){
            local pcca_id = 0;
            foreach (genre in pcca_genres) {
                if(newcat[selected] == genre[user_lang]){
                    pcca_id = genre["id"];
                    break;
                }
            }

            search_text.msg = newcat[selected]
            text = pcca_id
        }
        update_rule();
    }

    function category_list(){
        // set var to "contain" by default
        sub_rows[0][4] = 0
        sub_rows[0][1].msg = sub_rows[0][3][0]

        local catlist = []
        for (local i = 0 ; i < fe.list.size ; i++) {
            local tag0 = fe.game_info (Info.Category,i, (fe.filters.len()!=0 ? - fe.list.filter_index:0))
            local catarr = split(tag0, ",")
            foreach (tag in catarr) catlist.push(tag);
        }
        catlist = array_unique(catlist)
        catlist.sort()
        if(!catlist.len()) return false

        ::overlay_title.y = flh*0.317
        ::overlay_title.set_rgb(255, 10, 10);
        ::SetListBox(::overlay_list, {visible = true, rows = 6, sel_rgba = [255,0,0,255], bg_alpha = 125, selbg_alpha = 190, charsize = auto_size(42) })
        local selected = ::fe.overlay.list_dialog(catlist, "Category list");
        if(selected > -1){
            search_text.msg = catlist[selected]
            text = catlist[selected]
        }
        update_rule();
    }

    function update_selected_option(direction) {
        local filter_options = sub_rows[sub_index][3];
        sub_rows[sub_index][4] += direction;
        if (sub_rows[sub_index][4] < 0) {
            sub_rows[sub_index][4] = filter_options.len() - 1;
        } else if (sub_rows[sub_index][4] >= filter_options.len()) {
            sub_rows[sub_index][4] = 0;
        }
        sub_rows[sub_index][1].msg = filter_options[sub_rows[sub_index][4]];

        if(filter_options[sub_rows[sub_index][4]] == "Category" || filter_options[sub_rows[sub_index][4]] == "Tags" || filter_options[sub_rows[sub_index][4]] == "Manufacturer"){
            clear()
            sub_rows[1][1].style = Style.Bold;
            sub_rows[1][1].charsize = auto_size(40)
        }else{
            sub_rows[1][1].style = Style.Regular;
            sub_rows[1][1].charsize = auto_size(35)
        }

        update_rule();
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