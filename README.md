# PCCA Hyperspin theme conversion for Attract-Mode

### Version 1.0 beta
This script is intended to work with Attract-Mode http://attractmode.org/ , it try to reproduce the real hyperspin experience in HD as precise as possible using the same themes and folder structure then a real Hyperspin.

Hypertheme can be used to build new theme or you can build your own with higher resolution than the hyperspin default 1024x768

<iframe width="560" height="315" src="https://www.youtube.com/embed/tQFLZIega1M" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Restrictions
you should set startup mode to "display menu" in AM config.

you MUST put in layout option your display menu prompt value (default is "Select System").


## Theme.xml
It's possible to add to your artwork xml tag , width and height for auto resizing artworks medias 

ex:
`<artwork3 w="550" h="280" x="777" y="417" time="0.7" delay ="0" type="ease" start="right" rest="none"/>`

it keep aspect ratio and picture is flipped accordingly to its orientation (P or L).
this way , you dont need to resize all your medias everytime.

another xml tag is `<hd lw="1920" lh="1080" />`
this tells the script you are using a  real HD theme, lw and lh must be the resolution at which the theme was created.

bezel and background stretch have no ifluences if hd tag is present.

unified video theme can be used , put video named as system name / rom name in their respective folders and the unified video will be diplayed in full-screen.
 

# Layouts Options

### Animated Backgrounds
Enable or disable bakgrounds transitions

### Aspect
Stretched or centered theme

### Bezels
Display bezel or not

### Bezels On Top
Put bezel on top of the theme background or below

### Background Stretch
Yes, Strecth Background only (some theme with video frame in background look distorted with this option)

Main Menu, Stretch background only when you are in main menu wheel.

### Infos Coord
give x,y coord for game infos surface display , if empty, game infos is positioned at the bottom left (default).

### Language

choose your language for some text translation present on game infos. 
En and Fr right now 

### Override Transitions (Yes / No)

Use flv transitions videos present in folder -> \Media\Frontend\Video\Transitions

If you think a certain transtion would look great for a certain game then you can make a copy of that transition and copy it to 
your \Media\{SYSTEME NAME}\Video\Override Transitions folder and rename the video to the name of the rom you would like to see the transition on.

If you name a transition the same name as one of your genre category you will see the transtion when a game match category if no others transition is available for this game.


### Themes Wait For Override 
(Themes load after Override Transition has played) ( Not implemented )

### Medias Path
should point to your hyperspin media path or if empty, the media folder  must be in pcca layout directory.

## Medias


### Folders structure
like hyperspin

### Bezels

Bezels need to be put in images/bezel of pcca layout folder , named as the systeme name you want the bezel.

### Backgrounds

Background should be named as your roms/system and placed in media/Background folder
If background is found in your theme.zip , the theme backgrouns is used, and not the one in media folder.

### Sounds
like hyperspin.

Enable Wheel Game Sounds - These are the short game sounds played everytime you turn the wheel.

Enable Wheel Click Sound - There is a small wheel click sound that also plays when you turn the wheel.

these song are played when :

Sound_Letter_Click = when you press prev_letter or next_letter

Sound_Screen_Click = when you change selection on a screen overlay (Exit, tags, favorites, filters)

Sound_Screen_In = When you enter screen overlay (Exit, tags, favorites, filters)

Sound_Screen_Out = When you exit screen overlay (Exit, tags, favorites, filters)

Sound_Wheel_In = when you enter new systeme (ToNewList)

Sound_Wheel_Out = when you exit systeme (StartLayout)

Sound_Wheel_Jump = when you use prev_page or next_page


Background Music is played if an mp3 is found anywhere in theme.zip no matter how it is named , or in the media folder Sound/Background Music/ named as the rom name of the game you want music.

if Background Music if found in theme and folder , the theme Background Music is used
when background music is played , video snap sound is automaticly muted.

### Tags
2 tags as predefined with picture , completed and fail,  but you can add your own png named as your tag name in pcca/images/tags , (must be .png)


## Known Issues:
axis rotation for video snap (AM does not have z-axis property for axis rotation ).

particles animation is missing

crash sometime with some swf background , it's due to a buggy swf implementation in AM, not the script itself.

special artworks is missing


## TODO:
Keyboard search

separate config settings per systeme

trying to fix AM crash with swf, misalignment and strange behavior...

trying to implement video snap z-axis rotation with pinch and skew property.

new outlined font for displaying game informations

glyph for category

particles animations

rain float animation

special artworks ( must first understand how hyperspin manages the alignment of swf )

screensaver that random trough all your games when your are on main menu, displaying systeme and game wheel logo.





#Donations
* XMR: `44ZD1s12j8M6upWXGUS1R2YzXKiKpVmTzYKbrLYSp6pDWvW7C4ALfQ2VNyg6pt2tvA94Tu5kbcDLcLbTvjJBYk6zLFYmWM3`
* BTC: `1F2UpGsQETpyCCnMEBLFc5whDFAhgXJVU1`

