# PCCA Hyperspin theme conversion for Attract-Mode

### Version 1.02 beta
This script is intended to work with Attract-Mode http://attractmode.org/ , it intends to reproduce the real hyperspin experience in HD as precise as possible using the same themes and folder structure as a real Hyperspin setup.

Hypertheme can be used to build new themes or you can build your own with a higher resolution than hyperspin's default 1024x768.

## Video
[![Theme PCCA](http://img.youtube.com/vi/tQFLZIega1M/0.jpg)](https://youtu.be/tQFLZIega1M "Theme PCCA")

## Restrictions
It is MANDATORY to set in Attract-Mode options: General->Startup Mode to 'Show Display Menu' and 'Allow Exit' from 'Display Menu' to No.

## Theme.xml
It's possible to add to your artwork xml tags: width and height for auto resizing media artwork.

example:
`<artwork3 w="550" h="280" x="777" y="417" time="0.7" delay ="0" type="ease" start="right" rest="none"/>`

These options keeps the aspect ratio and the picture is flipped according to its orientation (P or L).
Using this technique, you don't need to resize all your media everytime.

An additional xml tag is `<hd lw="1920" lh="1080" />`
It informs the script that you are using a real HD theme, 'lw' and 'lh' must be the resolution at which the theme was created.

Bezel and background stretch have no ifluence if 'hd' tag is present.

Unified video themes can be used. Place videos named as system name / rom name in their respective folders and the unified video will be diplayed in full-screen.
 

# Layouts Options

### Animated Backgrounds
Enable or disable bakgrounds transitions.

### Aspect
Stretched or centered theme.

### Bezels
Display or hide bezel.

### Bezels On Top
Put bezel on top of the theme background or below.

### Background Stretch
'Yes': Strecth Background only (some themes with video frame in background may look distorted with this option enabled).

'Main Menu': Stretch background only when you are in main menu wheel.

### Game Info Coordinates
Provide x,y coordinates for game info surface display. If empty, game info is positioned at the bottom left (default).

### Language

Select your language for some text translation present in game info. 
'En' or 'Fr', English and French are currently supported.

### Override Transitions (Yes / No)

Use flv transition videos placed in folder -> \Media\Frontend\Video\Transitions

If you think a certain transtion would look great for a certain game, then you can make a copy that transition to 
your \Media\{SYSTEME NAME}\Video\Override Transitions folder and rename the video to the name of the rom you would like to see the transition on.

If you give a transition the same name as one of your genre categories you will see the transtion when a game match the category if no other transition is available for this game.


### Themes Wait For Override 
Themes load after Override Transition has played ( Not implemented yet)

### Media Path
This should point to your hyperspin media path. If empty, the media folder must be in the 'pcca' layout directory.

example:

If you use HyperSpin installation is on c: ,media path should be:
 
`C:/Hyperspin/Media`

If want to put hyperspin media in the 'pcca' layout folder, leave the media path opption empty and themes will look for media at:

`C:/attract-mode/layouts/pcca/Media`

## Media


### Folders structure
Identical to Hyperspin.

### Bezels

Bezels need to be placed in images/bezel of 'pcca' layout folder, named as the system name you want the bezel for.

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


Background Music is played if an mp3 file is found anywhere in theme.zip, no matter how it is named or in the media folder Sound/Background Music/ named as the rom name of the game you want music.

If Background Music if found in theme and folder, the theme Background Music is used.
When background music is played, video snap sound is automaticly muted.

### Tags
2 tags as predefined with picture, completed and fail,  but you can add your own png named as your tag name in pcca/images/tags , (must be .png)


## Known Issues:
- axis rotation for video snap (AM does not have z-axis property for axis rotation ).

- particles animation is missing

- crash sometime occurs with some swf backgrounds, it's due to a buggy swf implementation in Attract-Mode, not the pcca script itself.

- special artworks is missing


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





# Donations
* XMR: `44ZD1s12j8M6upWXGUS1R2YzXKiKpVmTzYKbrLYSp6pDWvW7C4ALfQ2VNyg6pt2tvA94Tu5kbcDLcLbTvjJBYk6zLFYmWM3`
* BTC: `1F2UpGsQETpyCCnMEBLFc5whDFAhgXJVU1`

