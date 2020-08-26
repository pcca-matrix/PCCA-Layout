keyboard-search
-
The search surface will be shown and control input when the search key is pressed. It will stop taking input when the
search key is pressed again, or the back button is pressed.

The text_pos (search text) and key_pos (keys positioning) are screen percentages, ranging from 0 to 1.

Usage:

You can use the default settings for the module by just providing it a surface to put the search on:
```
fe.load_module("objects/keyboard-search");
local search_surface = fe.add_surface(fe.layout.width, fe.layout.height)
KeyboardSearch(search_surface).init()
```        

You can customize any or all of the following additional chained setter functions:
```
fe.load_module("objects/keyboard-search");
local search_surface = fe.add_surface(fe.layout.width, fe.layout.height)
KeyboardSearch(search_surface)
    .bg( "images/pixel.png" )
    .bg_color( config[layout].search.red, config[layout].search.green, config[layout].search.blue, 200 )
    .key_delay( 100 )
    .repeat_key_delay( 250 )
    .text_pos( config[layout].search.text_pos )
    .text_color( [ 255, 0, 255, 255 ] )
    .text_font( config[layout].search.font )
    .keys_image_folder( "images/keyboard" )
    .keys_pos( config[layout].search.key_pos )
    .keys_rows( [ "1234567890", "abcdefghi", "jklmnopqr", "stuvwxyz<" ] )
    .keys_color( [ 255, 255, 255, 255 ] )
    .keys_selected_color( [ 255, 50, 255, 255 ] )
    .keys_selected( 0, 0 )
    .preset(name)
.init()
```

You can easily add user config options for the search key (or other keyboard config options):

```
class UserConfig {
    </ label="Search Key", help="Choose the key to initiate a search", options="custom1,custom2,custom3,custom4,custom5,custom6,up,down,left,right", order=14 />
    user_search_key="custom1";
    </ label="Search Results", help="Choose the search method", options="show_results,next_match", order=15 />
    user_search_method="show_results";
}

local search_surface = fe.add_surface(fe.layout.width, fe.layout.height)
KeyboardSearch(search_surface)
    .search_key( user_config["user_search_key"] )
    .mode( user_config["user_search_method"] )
    .init()
```
