# bash-telegram-bot
A telegram bot completely written in bash. Version 2.0.

# introduction
I got the inspiration from https://github.com/rauhmaru/BaTbot who created a simple telegram-bot for bash (tx!). A lot of other telegram-bot apps were incompatible with my Synology DS413j (allthough I did manage to get https://github.com/tropicoo/hikvision-camera-bot working), so I resorted to this basic bash script for some services running on the Synology.

# setup
The following directory structure is used by the script:

folder | use
------------- | ------------- 
./ | root folder with batbot.help, batbot2.sh and runbot.sh
./conf | configuration for commands, alloweduserids and adminids
./log | log folder
./response | folder in which responses are downloaded, e.g. RSS feeds
./scripts | folder with scripts used by the commands
./thumbs | folder in which thumbnails are saved when posting images

# configuration
## runbot.sh
Using the shell script runbot.sh the bot can be started. This script takes four positional parameters "show" "kill" "run" "force". When started as _"./runbot.sh show kill run"_ the script will check if the bot is already running, if so kill it, and launch a new session. The script uses the following environment variables:

var | use
------------- | ------------- 
TELEGRAMTOKEN | The token of your Telegram bot
BOTHOSTNAME | The name of your host or bot to enable multiple bots running concurrently
BOTNAME | The bot handle on Telegram
REFRESHINT | The refresh interval

In the published version **batbot2** is launched by **runbot.sh** as follows:
<code>nohup /go/packages/batbot/batbot2.sh -f -c $REFRESHINT -t $TELEGRAMTOKEN -session "$currentTime" &>$currentLog &</code>
var | use
------------- | --------------
currentTime | `date +%Y%m%d_%H%M%S`
logfolder | `pwd`
currentLog | `$logfolder'/log/batbot_'$HOSTNAME'_'$currentTime'.log'`

## batbot2.sh
The main script. This script takes the following parameters:

parameter | use
------------- | ------------- 
-h | Show help
-f | Use fixed logfile with name ./log/batbot.log
-v | Enable verbose logging (default is false)
-t <token> | Telegram token to use
-c <seconds> | The refresh interval in seconds (defaults to 10)
-n <name> | The name for the bot, used for concurrent running of multiple bots
-s <folder> | The scripts folder to use (defaults to ./scripts)

The following files are necessary for the bot to be able to work:
folder | file | use
------------- | ------------- | -------------
./conf | BOTNAME_botcommands.conf | Holds the commands used by the bot. Syntax ["/command"]='command', e.g. ["/myid"]='echo Your user id is: <b>@USERID</b>'. Commands marked with a * are allowed for admins only, e.g. ["/refreshcmds*"]='botcmds'
./conf | BOTNAME_alloweduserids.conf | The userids of Telegram users that are allowed to talk to the bot. Syntax [userid]='username'.
./conf | BOTNAME_allowedadminids.conf | The userids of Telegram users that are allowed to perform admin tasks. Syntax [userid]='username'.

## commands
The following commands are embedded in the script:
command | use
-------- | --------
/myid | echo Your user id is: <b>@USERID</b>
/myuser | echo Your username is: <b>@USERNAME</b>
/hello | echo Hi @FIRSTNAME, pleased to meet you :)
/msgadmin | echo The admin has received a message
/refreshcmds* | botcmds
/refreshusers* | userids
/refreshadmins* | adminids

## scripts
The following scripts are included:
script | activated with command | use
-------- | -------- | --------
/commands | @FOLDERSCRIPTS/cat.sh @BOTCOMMANDSLIST | will sent the list of active commands to the user
/memories | @FOLDERSCRIPTS/memories.sh @CHATID @TELEGRAMTOKEN | will iterate a folder structure in the format YEAR/MONTH/DAY with pictures, select at random 1-4 pictures from previous years from the same month and day and sent them to the requesting user
/dp_nasa_eo | @FOLDERSCRIPTS/utils.sh dp_nasa_eo @CHATID @TELEGRAMTOKEN @FOLDERRESPONSE | will download the NASA EO rss feed, randomly select 1-4 images and sent them to the requesting user
/dp_nasa_mn | @FOLDERSCRIPTS/utils.sh dp_nasa_mn @CHATID @TELEGRAMTOKEN @FOLDERRESPONSE | will download the NASA MN rss feed, randomly select 1-4 images and sent them to the requesting user
/dp_nasa_pj | @FOLDERSCRIPTS/utils.sh dp_nasa_pj @CHATID @TELEGRAMTOKEN @FOLDERRESPONSE | will download the NASA PJ rss feed, randomly select 1-4 images and sent them to the requesting user
/help | @FOLDERSCRIPTS/cat.sh ./batbot.help | shows the file ./batbot.help to the requesting user
/kill* | @FOLDERSCRIPTS/killbot.sh @CURRENTLOG | kill the bot (only admins)
/nws_hackernews | @FOLDERSCRIPTS/utils.sh nws_hackernews @CHATID @TELEGRAMTOKEN @FOLDERRESPONSE | download the hackernews rss feed and randomly present 1-4 news articles
/restart* | ./runbot.sh show kill run force | restart the bot (only admins)
/start | @FOLDERSCRIPTS/cat.sh ./batbot.help | activate bot and show the help file
/uptime | @FOLDERSCRIPTS/uptime.sh @currentDatetime | show the current uptime of the server and the bot

## runtime
When running the script will create two files in the folder ./response with the names BOTID.lastmsg and BOTID.updateid. These files hold the last msgid number and the last updateid number and are used when retrieving updates from the Telegram server.

## supporting commands
command | used
-------- | --------
cat | to display file contents
ps | process list
grep | content selection
gawk | string manipulation
awk | string manipulation
convert | thumbnail generation
wget | download rss feeds
curl | communicate with Telegram API

## support
The script is running Linux 2.6.32.12 on an armv5tel (Marvel Kirkwood) GNU/Linux synology_88f6282_413j. OPKG is used and has installed the following packages:
package | version
-------- | --------
ar | 2.27-1
binutils | 2.27-1
ca-certificates | 20170717
entware-opt | 222108-5
findutils | 4.6.0-1
gcc | 6.3.0-1a
ldconfig | 2.23-6
ldd | 2.23-6
libbfd | 2.27-1
libblkid | 2.30.2-1
libc | 2.23-6
libevent2 | 2.0.22-1
libexslt | 1.1.31-1
libffi | 3.2.1-3
libgcc | 6.3.0-6
libiconv-full | 1.11.1-3
libintl-full | 0.19.8.1-1
libjpeg | 9a-1
libopcodes | 2.27-1
libopenssl | 1.0.2n-1
libpthread | 2.23-6
libreadline | 7.0-1
librt | 2.23-6
libssp | 6.3.0-6
libstdcpp | 6.3.0-6
libuuid | 2.30.2-1
libuv | 1.11.0-1
libxml2 | 2.9.7-1
libxslt | 1.1.31-1
locales | 2.23-6
make | 4.2.1-2
mediainfo | 17.10-1
node_legacy | v0.10.48-1
objdump | 2.27-1
opkg | 2011-04-08-9c97d5ec-17a
rename | 2.30.2-1
terminfo | 6.0-1c
wipefs | 2.30.2-1
xmlstarlet | 1.6.1-1
zlib | 1.2.11-1
zlib-dev | 1.2.11-1

