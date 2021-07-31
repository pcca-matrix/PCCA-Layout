# PCCA Hyperspin theme conversion for Attract-Mode

### Version 1.11 beta
This script is intended to work with Attract-Mode http://attractmode.org/ , it intends to reproduce the real hyperspin experience in HD as precise as possible using the same themes and folder structure as a real Hyperspin setup.

Hypertheme can be used to build new themes or you can build your own with a higher resolution than hyperspin's default 1024x768.

## Video
[![Theme PCCA](http://img.youtube.com/vi/tQFLZIega1M/0.jpg)](https://youtu.be/tQFLZIega1M "Theme PCCA")

## Restrictions
It is MANDATORY to set in Attract-Mode options: General->Startup Mode to 'Show Display Menu' and Displays->'Display Menu Options->'Allow Exit from 'Display Menu' to 'No'.


## Theme.xml
It's possible to add to your artwork xml tags: width and height for auto resizing media artwork.

example:
`<artwork3 w="550" h="280" x="777" y="417" time="0.7" delay ="0" type="ease" start="right" rest="none"/>`

These options keeps the aspect ratio and the picture is flipped according to its orientation (P or L).
Using this technique, you don't need to resize all your media everytime.

An additional xml tag is `<hd lw="1920" lh="1080" />`
It informs the script that you are using a real HD theme, 'lw' and 'lh' must be the resolution at which the theme was created.

Bezel and background stretch have no ifluence if 'hd' tag is present.

Unified video themes can be used. Place videos named as system name / rom name in their respective Themes folders and the unified video will be diplayed in full-screen.
 

# Layouts and ini Options
Settings can be defined per system in pcca/Settings/{SYSTEME NAME}.ini , and for main menu,  pcca/Settings/Main Menu.ini
Real Hyperspin Settings ini can be used as is by copying it to the pcca layout Settings folder.
If no .ini is found or an option is not present , the attract-mode "layout option setting" will be applied.

### Animated Backgrounds (Yes / No)
Enable or disable bakgrounds transitions.
Ini: 
[themes] 
animated_backgrounds=true or false

### Aspect
Stretched or centered theme.
Ini: 
[themes] 
aspect=center or stretch

### Bezels
Display or hide bezel.
Ini:
[themes] 
bezels=true or false

### Bezels On Top (Yes / No)
Put bezel on top of the theme background or below.
Ini:
[themes] 
bezels_on_top=true or false

### Background Stretch
'Yes': Strecth Background only (some themes with video frame in background may look distorted with this option enabled).

'Main Menu': Stretch background only when you are in main menu wheel.
Ini:
[themes] 
background_stretch=true or false

### Game Info Coordinates (x,y)
Provide x,y coordinates for game info surface display. If empty, game info is positioned at the bottom left (default).
Ini:
[themes]
infos_coord = x,y

### Language

Select your language for some text translation present in game info. 
'En' or 'Fr', English and French are currently supported.

### Override Transitions (Yes / No)

Use flv transition videos placed in folder -> \Media\Frontend\Video\Transitions

If you think a certain transtion would look great for a certain game, then you can make a copy of that transition to 
your \Media\{SYSTEME NAME}\Video\Override Transitions folder and rename the video with the same name of the rom you would like to see the transition on.

If you give a transition the same name as one of your genre categories you will see the transtion when a game match the category if no other transition is available for that game.

Ini:
[themes]
override_transitions = true or false

### Themes Wait For Override 
Themes load after Override Transition has played ( Not implemented yet)

### Media Path
This option should point to your hyperspin media path. If empty, the media folder must be in the 'pcca' layout directory.

example:

If your HyperSpin installation is on c: ,media path should be:
 
`C:/Hyperspin/Media`

If want to put hyperspin media in the 'pcca' layout folder, leave the media path opption empty and themes will look for media at:

`C:/attract-mode/layouts/pcca/Media`

## Media


### Folders structure
Identical to Hyperspin.

### Bezels

Bezels need to be placed in images/bezel of 'pcca' layout folder, named as the system you want the bezel for.

### Backgrounds

Background should be named as your roms/system and placed in media/Background folder.
If background is found in your theme.zip, the theme background is used, and not the one in the media folder.

### Sounds
Identical to Hyperspin.

Enable Wheel Game Sounds - These are the short game sounds played everytime you navigate the wheel.

Enable Wheel Click Sound - There is a small wheel click sound that also plays when you navigate the wheel.

these sounds are played when:

Sound_Letter_Click = when you press prev_letter or next_letter

Sound_Screen_Click = when you change selection on a screen overlay (Exit, tags, favorites, filters)

Sound_Screen_In = When you enter screen overlay (Exit, tags, favorites, filters)

Sound_Screen_Out = When you exit screen overlay (Exit, tags, favorites, filters)

Sound_Wheel_In = when you enter a new system (ToNewList)

Sound_Wheel_Out = when you exit a system (StartLayout)

Sound_Wheel_Jump = when you use prev_page or next_page


Background Music is played if an mp3 file is found anywhere in theme.zip, no matter how it is named or in the media folder Sound/Background Music/ named as the rom name of the game you want music for.

if Background Music is found in the theme.zip file or the Sound/Background Music folder ("C:\Hyperspin\Media\Atari 2600\Sound\Background Music\Vanguard.mp3" for example), the theme Background Music is used and video snap sound is automaticly muted.

Ini:
[sounds]
game_sounds=true or false
wheel_click=true or false

### Specials Artwork

Identical to Hyperspin.
pcca layout use special artworks placed in folder -> \Media\{SYSTEME NAME}\Images\Special

Special artwork media should be named :
SpecialA1 , SpecialA2, ...
SpecialB1 , SpecialB2, ...

Special artwork settings is defined in pcca/Settings/{SYSTEME NAME}.ini , and for main menu,  pcca/Settings/Main Menu.ini

Real Hyperspin Settings ini can be used as is by copying it to the pcca layout Settings folder.

```
[Special Art A] // the name of the special artwork collection (A or B)
default=false    -> When in system use default artworks from main menu
active=true      -> enabled (true) or disabled (false)
x=512            -> x alignement ( if width and height are specified , then it's real coord , if not, it's hyperspin default 1024x768 scaled for your screen resolution)
y=720            -> y alignement ( if width and height are specified , then it's real coord , if not, it's hyperspin default 1024x768 scaled for your screen resolution)
in=0.4           -> Time it takes the artworks to animate in  position (in seconds).
out=0.4          -> Time it takes the artworks to animate out  position (in seconds).
length=3         -> The length of time the artwork stays in position before animating out (in seconds).
delay=0          -> The amount of time to wait between animations (in seconds).
type=normal      -> The style of animation you want to use (normal = linear, fade, bounce)
start=bottom     -> The side of the screen from which animations enter. (bottom, top , left , right)
/* Added for Attract-mode (not mandatory) */
w=500            -> width of your special artwork
h=100            -> height of your special artwork
ext=png          -> extension of your special artwork (you can use any media extension (video, swf, or any image supported by Attract-mode)
```
If no .ini file is found but you have special artwork inside your images/Special folder , the default settings will be applied.

The special artworks defaults settings is:

###Special A

```
active=true 
in=0.5
out=0.5
length=3
delay=0
type=normal
start=bottom
```

###Special B
```
active=true 
in=0.5
out=0.5
length=3
delay=0
type=fade
start=none
```

default media extension is swf, as in hyperspin.
default alignement is bottom center.

### Tags
2 tags are available: 'completed' and 'fail'. These tags are displayed in the on-screen game info area (bottom left corner by default). You can add your own png file named as your tag name in pcca/images/tags (must be in .png format).

## Known Issues:
- axis rotation for video snap (AM does not have z-axis property for axis rotation ).

- particles animation is missing

- crash sometime occurs with some swf backgrounds, it's due to a buggy swf implementation in Attract-Mode, not the pcca script itself.

### Extras Artworks 
Extra Artworks Key : key to open extra artworks overlay layout 

Extra artworks must be put in folder -> \Media\{SYSTEME NAME}\Images\Artwork\{ROM NAME}\any_name.{jpg,png,mp4}
this folder can contain an unlimited number of medias related to the game.
it can be viewed when Extra Artworks Key is pressed.
you can navigate trough the medias in the Artwork folder with the controls mapped in AM to next_display and prev_display.
if your media folder contains more than one media , a double arrow will be displayed below the media currently displayed.

## TODO:

trying to fix AM crash with swf, misalignment and strange behavior...

trying to implement video snap z-axis rotation with pinch and skew property.

new outlined font for displaying game informations

glyph for category

particles animations




# Donations
* XMR: `44ZD1s12j8M6upWXGUS1R2YzXKiKpVmTzYKbrLYSp6pDWvW7C4ALfQ2VNyg6pt2tvA94Tu5kbcDLcLbTvjJBYk6zLFYmWM3`
* BTC: `1F2UpGsQETpyCCnMEBLFc5whDFAhgXJVU1`

