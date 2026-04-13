# Figura Based Hex Importer for Hexcasting

This is a hex importer for the minecraft mod hexcasting, that is meant to run on figura, another minecraft mod.

It has quite a few features, such as:
- Support for multiple importation methods (Such as moreiotas, or mediatransport)
- Hexparty and github integration (If you wish to host your .hexpattern files on the internet)
- Per world pattern auto replacement based on server/world
- Custom syntax definition
- Function definition and unfolding upon importation
- ...And more

This importer is meant to work with the [vscode addon for hexcasting](https://marketplace.visualstudio.com/items?itemName=object-Object.hex-casting), by [object-Object](https://github.com/object-Object), and its format .hexpattern\
(Sorry hexparse enjoyers)

## Disclaimer

This project is a personal project of mine first, and something I am releasing to the world second. It has rather ugly sections, commented out parts, sometimes hard to read code, and is rather hard to configure and implement. It is absolutely not a plug and play thing, and I do not plan upon making it such anytime soon (Or ever. The amount of work and polish needed for that is quite overrunning my overall motivation for this project, but we'll see.)

So expect bugs, and a decent bit of debugging and rewriting sections of code, if you plan on using this thing for a good while.

Thus, I would absolutely recommend a decent amount of knowledge in regards to lua (And also some knowledge on figura scripting too). If you do not already have that, PLEASE, go acquire it, as many features of this thing require additions and edits to the code itself.

Also, because of this, please feel free to improve upon this in whatever capacity you want. Feel free to publish any improvement aswell, credit would be appreciated but not necessary. 

## Setup

This setup guide assumes, 1. you have figura, and 2. you know how to use it and make an avatar with it, so if you dont, go get it and learn how to do so.

### Step 1:

First, set up the avatar.

Figura by default executes any lua files it has in the avatar folder in a random order. This will very much break the importer, so what we have to do is, use [a specific](https://figura-wiki.pages.dev/tutorials/Avatar-Metadata#autoscripts--string) function of figura, to call specifically geodesicinit.lua, and nothing else from geodesic.

I am so sorry if you are grafting this onto an already built avatar, as many avatars dont use this functionality. You will simply have to manually put everything else in there aswell to make them execute again. I would execute geodesicinit.lua last compared to everything if you are doing this, due to step 3.

If you are making an avatar just for this however, I would highly recommend adding a lua file, executed before geodesicinit.lua, to initialize an action wheel page, for the 3rd step.

### Step 2:

Second, put all the relevant files into the figura/data/ folder. Two of them are already included in this repo, and they are conveniently in a similarly named folder on this repo, Data/

patternsbig.json is a huge json of hexcasting patterns (obtained from [here](https://book.hexxy.media/v/latest/main/registry.json)). This json is what the importer uses to recognize patterns, albeit it may have some outdated parts, so feel free to modify it if necessary (The importer caches the result after parsing patternsbig.json, so in jsonpatternparser.lua there is two functions that can be executed with /figura run at runtime to flush the cached result)

perworldconfig.json includes everything relevant to configuring the importer for each world/server. It has a template, and then defaults for servers and singleplayer worlds. Guides later on will go deeper into configuring this, but for now just include it.

Finally, you need to include a folder, which contains your .hexpattern files, which gets read from to import them.

### Step 3:

Next is configuring some variables in the lua files to get this thing to a minimally working state, enough to run with no errors.

In filemapper.lua, on line 119 and 120 are two variables, named "Hex_repository", and "file_system_location".
Hex_repository's value should be set to the name of the folder in figura/data that contains your .hexpattern files, the one you just put in there.
file_system_location's value should be set to the action wheel page, in which the relevant geodesic pages get created.

In jsonpatternparser.lua, on line 3 is a local variable, "patterns_json". By default it is set to the patternsbig.json, the file we just put in the previous step, HOWEVER, if you have changed the name of this file, or are using a custom / different file, update this variable as necessary.

Fill in all of these with the relevant values.

### Step 4:

Configure the perworldconfig.json

In perworldconfig.json, each server or world has a config field, and in this field are 5 variables. These variables have defaults in hexporterfigura.lua, from line 85 to line 89, and their functionalities are explained there too, but I will put the same explanations here aswell to make this easier.

- max_part: Max partitions allowed, somewhat useless
- part_size: Max size of an individual partition 
- part_delay: Tick delay between each batch that gets sent
- batch_size: How many partitions should be sent each batch
- return_delay: Tick delay before the hexporter marks itself as ready to import again, after finishing the current importation

To fully explain what these variables do, I have to quickly touch upon the hexporter. Most methods of sending information to be picked up and converted into a hex, cannot transport infinite data. They have limits, and thus, any hex large enough needs to be partitioned. These variables have to do with how we send these partitions over.

Thus, it is crucial to configure the hexporter for the importation method being used. I included some workeable examples for both of the importation methods / endpoints currently implemented in the importer (mediatransport and moreiotas), in perworldconfig.json, but feel free to mess around with them.

Next, we have to configure the endpoint, which relates to perworldendpoints.lua, this script is what allows us to have different importation methods for each server/world. Simply put the name of the endpoint you want to use in the server/worlds "endpoint" field.

(A few notes for moreiotas, you need to enable figuras chatting settings, to allow the importer to send chat messages for you to be able to import with it. Aside from that, this importer assumes you will be using sifters gambit, so on perworldendpoints.lua, line 71, there is a sifters gambit prefix. Change this to whatever sifters gambit prefix you use, or make it an empty string if you do not use sifters)

Finally, configuring the patterns. The template has an example for this, simply fill it out and put it in the patterns field of your server/world. This can be used to replace non per world patterns too, as it has no check for that. Feel free to use it for this purpose if you wish, although I would not recommend.

### Step 5:

As mentioned earlier, the importer is usually unable to send the hexes in a single piece. For this purpose, you need to pick up a few last bits of computation on the hex side, and stitch together the "stream" the importer sends in.

I will include a few examples in this repo, but I would highly recommend implementing your own method, mines are kinda messy and not very well documented. 

For the hex side of the importer, you might also want to bootstrap it through an "easier to set up right away" sorta importer, such as a CC one with ducky periphs, or through the everbook. 

I am leaving this mostly open ended, since there is no one size fits all solution here. 

### Step 6:

The importer should be in a working, functional state now. But there is quite a few more features to this thing, so please do read the next sections aswell. Aside from that, enjoy your new importer!

## Features

The importer has quite a few misc features to aid in the importation of hexes, so this section should help with using them.

### The Map Recalculation Button:

In the main geodesic menu, there is a button with a filled map as its icon. When clicked, this button recalculates the file map, allowing for any changes, such as deletions or new files, to be added to the action wheel menu.

Aside from this, it gives a few misc information, such as whether the importer is currently busy or not, the name of the last file that was imported, and the amount of files in the file system, that also shows the amount of duplicate files, in red next to the main count.

### The Button Functions:

Clicking on a folder will simply open it, in the main geodesic menu, this happens instantly, while in the auxilliaries, you have to wait a second for the web request.

Clicking a file will attempt to import it, (hopefully) erroring if not. (Trust me, do not try to import an mp4 file.)

Right clicking a file instead attempts to read it, printing the raw text result (With a few changes such as new lines being removed) onto the chat.

### The Auxilliaries:

You probably noticed that, aside from the main scripts of the importer, there is 3 more in the Auxilliaries folder. These serve to provide additional "inputs" to the hexporter, and allow you to pull .hexpattern files not just from your computer, but from the internet aswell.

Using these requires enabling the networking settings of figura. 

The hexparty one directly connects to the copyparty site that hexxy4 (The semi official hexcasting minecraft server in hexcasting's official discord) uses for hex importation with CC, while the github one takes in any repo, in the form of a table that can have multiple repos added to it. 

Both of these should be easy to change as the relevant variables are right at the start of the scripts. Additionally, feel free to host the files on another site, and import from there. The process to do that is quite involved, but should not be too hard to do.

Of note is a few things. Both of the auxilliaries use 2 functions defined in hexparty-aux.lua, request() and parseresponsedata(). Without these two functions, github-aux.lua cannot function, and thus, if you want to keep the github auxilliary but get rid of hexparty, you need to either put those functions into their own script, or make hexparty-aux.lua not initialize its auxilliary.

As these auxilliaries both use the internet, sometimes they receive a bad response, or no response at all. When this happens, the script prints "Traversal Failed" into the chat, which could either mean that the response didnt come fast enough, or that there was an error. After this, you can simply try again.

If this keeps happening, check the figura networking settings, and if they are good, make the pcall() for the requests print its error message. Additionally, in request(), there is a local variable named "limit", on line 24. This should roughly correspond to the miliseconds that the loop should run for, but there is a hard coded delimiter to ensure that it doesnt run forever. Change the limit if needed.

### Custom Patterns:

In customdefinitions.lua, are 4 tables, the first two of which is relevant for this section. The tables are identical in functionality and get merged at runtime, but they are kept seperate in code for the sake of organization.

The first table, "custom_pattern_list", is meant for registering custom patterns. There is a handy example pattern included in it for this purpose.

The second table, "replacement_pattern_list", does the same thing but is meant for any hexcasting patterns that you want to replace. This probably will not be needed, but is included regardless.

### Functions & Custom Function Definition:

Continuing the previous section is the next 2 tables, which are used to define functions. These functions get flattened into the hex at runtime, and are not actual function calls hexcasting side (For that, use hexicals grimoires I think).

"inline_function_list" is meant for defining "inline functions", as in, all the components of the function is defined in the lua script itself. To make it work this way, the field "ismultipleiotas" needs to be true, and all the components included as an indexed list with no gaps. There is an example included, but nonetheless.

"external_function_list" is meant for calling seperate .hexpattern files as functions. These files are processed the same way as all others, and then the result is put into the hex at the spot of the function call, somewhat akin to flattening a list. Once again, there is an example included, the field "isexternalfunction" needs to be true, and the location of the file needs to go into "functionlocation", starting from the figura/data folder but not including it.

For the external functions, the possibility of infinite recursive calls exists, which would crash your game (Well, freeze it indefinitely). To stop this from happening, a recursion limiter is implemented in hexpattoanglesig.lua, at line 101, it is 1 by default. Feel free to change this to allow for any depth of recursion wanted.

### Custom Syntax:

The custom syntax is defined in customsyntax.lua, in a table similar to the custom patterns and functions, but is not merged with the main pattern_list. This is due to how it functions, as instead of using raw names and matching exactly, the definitions here can utilize luas matching functions. While not as versatile as regex (Lua has no regex... \:heartbreak_emoji: \:sad_emoji: \:cry_emoji:), these functions can still be utilized to implement some simple syntax. 

A few examples, from my own use of the importer:

`["%(.*%)"] = {dir = "EAST", anglesig = "", ishexpattern = true}`\
This matches any *"(text here)"*, and replaces it with **bookkeepers: -**, a simple placeholder syntax.

`["^%(//"] = {ishexpattern = false}`\
`["^%)//"] = {ishexpattern = false}`\
These specifically match *"(//"*, and *")//"* at the beginning of a line, and simply delete them. I use them to denote the beginnings and ends of optional sections of hexes.

### The Endpoints:

To understand and implement new endpoints, I would highly recommend reading The Importation Pipeline Section, to understand how the importer works. 

Aside from that, the way the endpoints work is, when a server with the given endpoint is detected, perworldconfig.lua goes over the specific endpoint table, and replaces all the functions with functions defined in it. You can replace any function through this, but I would recommend sticking to ones in hexporterfigura.lua

By default, the functions in hexporterfigura.lua are configured for mediatransport. In the perworldendpoints.lua file, the mediatransport functions are thus simply assigned to themselves, so while they do get replaced, they do not get changed in any way when the mediatransport endpoint is being used.

### Custom Icons:

At the start of filemapper.lua, there is a table, named "folder_icons". This table can be used to give your folders specific icons, to make recognizing them ingame more easier. There is an example included.

### UI Sounds:

In UIsounds.lua are a few sound functions, which act as "sound effects" for the UI of the importer. They are only played on your side, but if they bother you, feel free to empty them, or simply excise any calls of them in filemapper.lua, hexparty-aux.lua and github-aux.lua. You could also change the sounds, its up to you.

## Performance

The exact performance depends upon the endpoint and file input used, but it ranges from adequate to outstanding.

Its biggest strength is the time and effort it takes, from creating and saving a new .hexpattern file, to importing it in.\
In this regard, it is simply the fastest and easiest importer, requiring you to save the file, probably in vscode, go back to the game, click one button to recalculate the file map if its a new file, and then simply click on it to import it.\
The overall process takes, if we ignore the time taken by the actual importation itself, usually less than 10 seconds, with just a few clicks, no copying needed, no typing needed.\
The fact that it pulls files from your own computer, rather than the internet, makes this process as simple and fast as possible.

In regards to the time it takes to import a file, from clicking upon it in the UI to it being ingame, it varies.

In the best case scenario, with mediatransport and allowing lists to be sent, it can send 60kb of data per tick, with each pattern being 6 + (amount of strokes) bytes, it can easily send max size (1024) hexes in a single tick, provided there is not too many overly huge patterns in the list.

With moreiotas, its limited to roughly a single message per 2 ticks due to compensation for information loss due to lag, and the default message limit being 256, and each pattern taking 2 + (amount of strokes) characters, the overall rate of importation is rather slow, 2500~ characters, somewhat equivalent to bytes from mediatransport, per second.

Mediatransport without lists has the worst performance out of the three possibilities, compensating for lag, it allows only 30 patterns per second to be sent through realistically, with the theoretical maximum of 120 per second almost impossible to reach due to latency and lag.

## Limitations

The biggest limitation of the importer is its inability to send non pattern iotas, requiring any such embedded iota to be created at runtime, or inserted in later. While mediatransport could theoretically cover a few of the bases, such as strings, I have not implemented this functionality yet. Thus, any non pattern iota (Which in .hexpattern files looks like \<insert iota here>) is currently converted into **bookkeepers: -**

Another, minor limitation is figura itself. While figura is entirely client side, there is still times where you cant simply place it into a modpack. This usually does not cause a problem, but it is worthwhile to mention nonetheless.

## How The Importer Works

This section will roughly outline the inner workings of the importer, to make it easier to modify if needed.

### The Initialization:

The first thing to get initialized is filemapper.lua. This creates the main geodesic action wheel page, but does not initialize the action wheel file system just yet. It instead does so the first time the main page's button is clicked, reducing init instruction count, and also making the avatar not lag a bit every time you reload it, which might be slightly annoying.

After that, jsonpatternparser.lua is ran. It first checks if the result, parsed from patternsbig.json, has been cached. If it has not, it parses the file, and then caches the result, if it has, it simply reloads the result from the cache. The parsed result is far smaller than the original file, and thus far less laggier to load, which is why the script caches it.\
Everything else after this, from the custom definitions to per world patterns, is not cached and simply re-added to the pattern_list table each time at initialization.

After this, the patternlistadjust.lua, customdefinitions.lua, and customsyntax.lua runs. The first merely adds some key syntax which is found in .hexpattern formats regular syntax, to pattern_list, while the second adds the custom defined patterns and functions, and finally the third initializes its own table.

After those main steps of initialization, the importer itself is initialized, with hexpattoanglesig.lua and hexporterfigura.lua being called, before perworldendpoints.lua and perworldconfig.lua is called, to finally initialize the server/world specific aspects of the importer.

### The Importation Pipeline:

The importation starts at one of the anonymous functions of the file actions in either the main geodesic, or the auxilliary menus. These functions first attempt to read the file, either through a web request or figuras own file reading API. Notably, they do this in pcall(), luas exception handling mechanism, so if an error happens, the avatar doesnt crash instantly. 

If they succeed, they pass the raw text result to another pcall(), this time calling the aptly named caller(). This function, defined in hexporterfigura.lua, is the main entry point to the importers internals. 

The caller does two things, first, it checks if the importer is busy, if it is, it returns false to signal that importation cannot currently happen. But if it is not busy, then secondly, it initializes a few of the hexporters variables with values needed for its importation, calling the prepper() on the raw text result it has been given to do so.

The prepper acts merely as a wrapper for two functions, hexpattoanglesig(), and partitioner(). 

The first of the two, hexpattoanglesig(), is a wrapper for everything in the similarly named hexpattoanglesig.lua, and is the heart of the importer. This function first checks for unwanted recursion, erroring if so, before calling two functions, hexpattrimmed(), which is the pre processing step for the raw text that gets rid of comments, changes some syntax, and puts all the lines into an indexed table with no gaps, before handing it off to hextrimmedtopatterns(), which replaces every pattern name with its angle signature and direction, aswell as handling the special handlers, and performing any function flattening or calling (This last part is where the recursion check is truly used, as the same hexpattoanglesig() function is called for any external function calls). 

After this rather complex process, its result is partitioned by the second call of the prepper, the partitioner(), and then the final, partitioned result is assigned to the variable request_partition by the caller, which is used by the hexporter to import hexes.

After this process, the hexporter notices it has a new request, marks itself as busy, and starts importing according to its configuration, using our final function, sender(), to do so (Once again in pcall()). After it is finished, it flushes the relevant variables assigned by the caller to their defaults, and marks itself as ready once again.

### A few key notes on the importation pipeline & the importer

The hexporter itself, that gets configured and then utilizes an endpoint to do the actual information transmission, does not (usually) do any checks on if a specific entry on the table it is given is a valid iota or not. Thus, I would highly recommend doing such checks in the processing stage in hexpattoanglesig() (And its file hexpattoanglesig.lua), or potentially in the partitioner. 

While the "preprocessor" for the mediatransport sender function, hexpatserializer(), does have an "ishexpattern" check, this was implemented primarily because mediatransport can send more than just patterns, and I wanted to potentially use it in the future.

The current number special handler that is used (illegalnumgen()) is capable of generating arbitrary numbers, but its results are often bulky, and simply impossible to create by hand more often than not. While solving this issue for decimals is a huge difficulty, the patternsbig.json does have roughly 2000 precomputed integer numerical reflections, covering +1000 to -1000. These are currently not brought into pattern_list, but the code blocks necessary is still there in jsonpatternparser.lua, so feel free to do so. Simply uncomment the code blocks, and then refresh the cached list with emptypatlist(), and reloading your avatar (Or reparsepatlist(), which does the whole process again rather than simply emptying the cached result).