#!/bin/bash

# batbot current version
VERSION="2.0"

# default token and chatid
# or run batbot with option: -t <token>
TELEGRAMTOKEN="";

# how many seconds between check for new messages
# or run batbot with option: -c <seconds>
CHECKNEWMSG=10;

# env
BOTPATH="`dirname \"$0\"`";
BOTPID=$$;

# PREPARE logging
currentDatetime=`date +%Y%m%d%H%M%S`;
currentLog=$BOTPATH/log/batbot_${currentDatetime}.log;
VERBOSELOGGING="False";
FOLDERSCRIPTS="./scripts";
FOLDERRESPONSE="./response";
FOLDERCONF="./conf";
BOTSESSIONNAME="name";

while getopts :hfvt:c: OPTION; do
  case $OPTION in
    h)
      echo "batbot: bash telegram bot "$VERSION;
      echo "+"
      echo "Usage: ${0} [-f] [-v] [-t <token>] [-c <seconds>] [n <name>] [-s <folder>]"
      exit;
    ;;
    f)
      SHAREDLOG=$BOTPATH/log/batbot.log;
      echo "Arguments: using fixed log file "$SHAREDLOG;
    ;;
    v)
      echo "Arguments: verbose logging including response Telegram servers (SPAM)";
      VERBOSELOGGING="True";
    ;;
    t)
      echo "Arguments: set Token to: ${OPTARG}";
      TELEGRAMTOKEN=$OPTARG;
    ;;
    c)
      echo "Arguments: check for new messages every: ${OPTARG} seconds";
      CHECKNEWMSG=$OPTARG;
    ;;
    n)
      echo "Arguments: using ${OPTARG} as session name for the bot. This has influence on the available botcommands, allowed users and admins.";
      BOTSESSIONNAME=$OPTARG;
    ;;
    s)
      echo "Arguments: using scripts folder: ${OPTARG}";
      FOLDERSCRIPTS=$OPTARG;
    ;;
  esac
done

# ######### #
# Functions #
# ######### #
logthis() {
    echo "$(date +%Y-%m-%dT%H:%M:%S) -- $@" >> "$currentLog";
    #"$@" 2>> "$currentLog";
}

# ####################################### #
# alloweduserids                          #
# script with the alloweduserids          #
# ####################################### #
declare -A alloweduserids
userids() {

  configfileuserids="${FOLDERCONF}/${BOTSESSIONNAME}_alloweduserids.conf"
  
  logthis "Using alloweduserids source file "$configfileuserids
  if [ -f ${configfileuseruids} ]; then
      msg="Initialization: reading alloweduserids configuration for "${BOTSESSIONNAME}" from "${configfileuserids}
      echo $msg
      logthis $msg
      source $configfileuserids
  else
      msg="There is no configuration file called "${configfileuserids}
      echo $msg
      logthis $msg 
      exit 1
  fi
}

# ####################################### #
# adminids                                #
# script with the alloweduserids          #
# ####################################### #
declare -A adminuserids
adminids() {

  configfileadminids="${FOLDERCONF}/${BOTSESSIONNAME}_allowedadminids.conf"
  logthis "Using adminids source file "$configfileadminids
  if [ -f ${configfileadminids} ]; then
      msg="Initialization: reading adminids configuration for "${BOTSESSIONNAME}" from "${configfileadminids}
      echo $msg
      logthis $msg
      source $configfileadminids
  else
      msg="There is no configuration file called "${configfileadminids}
      echo $msg
      logthis $msg 
  fi
}

# ####################################### #
# Commands                                #
# ["/mycommand"]='<system command>'       #
# shell scripts can be used and should    #
# be put in ./scripts                     #
# script stdout will be sent to the user  #
# ####################################### #
declare -A botcommands
botcmds(){
  
  configfile="${FOLDERCONF}/${BOTSESSIONNAME}_botcommands.conf"
  logthis "Using botcommands source file "$configfile
  
  if [ -f ${configfile} ]; then
      msg="Initialization: reading botcommands configuration for "${BOTSESSIONNAME}" from "${configfile}
      echo $msg
      logthis $msg
      source $configfile
      
      BOTCOMMANDSLIST="${BOTPATH}/${FOLDERRESPONSE}/${currentDatetime}_${BOTPID}_botcommands.list"

      logthis "Initialization: setting up command listing for "${#botcommands[@]}" in "${BOTCOMMANDSLIST}
      
      logthis "Initialization: sourced botcommands, results as follows"
      
      # sort list
      KEYS=$(
      for KEY in ${!botcommands[@]}; do
        echo "${botcommands[$KEY]}:::$KEY" 
      done | sort | awk -F::: '{print $2}' 
      )
      IFS=$'\n' sorted=($(sort <<<"${KEYS[*]}"))
      unset IFS
      printf "[%s]\n" "${sorted[@]}"
      logthis `printf "[%s]\n" "${sorted[@]}"`
      
      echo "<b>The following "${#botcommands[@]}" botcommands for pid "${BOTPID}" are installed</b>" > $BOTCOMMANDSLIST; 
      
      printf "[%s]\n" "${sorted[@]}" >> $BOTCOMMANDSLIST; 
      
      echo "Commands with <b>*</b> require an administrator role." >> $BOTCOMMANDSLIST; 
      
  else
      msg="There is no configuration file called "${configfile}
      echo $msg
      logthis $msg 
  fi
}

# Init log session #
if [ -z $SHAREDLOG ]; then
  msg="Log from argument: "$currentLog
else
  msg="Log from argument: "$SHAREDLOG
fi
currentLog=${SHAREDLOG}
logthis "Initializing batbot v"${VERSION}
logthis $msg
logthis "Using token: "$TELEGRAMTOKEN
logthis "Checking for messages every: "$CHECKNEWMSG seconds
logthis "Using logfile: "$currentLog
logthis "Using loglevel VERBOSELOGGING: "$VERBOSELOGGING

# Read botcommands configuration for this bot
botcmds
userids
adminids


for s in "${!alloweduserids[@]}"; do
  logthis alloweduserid: "${s}";
done

for s in "${!adminuserids[@]}"; do
  logthis adminuserid: "${s}";
done

firsttime=0;
logthis "Bot is running from folder: ${BOTPATH}";
BASEURL="https://api.telegram.org/bot${TELEGRAMTOKEN}"

echo -e "\nInitializing batbot v${VERSION}"
ABOUTME=`curl -s "$BASEURL/getMe"`
if [[ "$VERBOSELOGGING" = "True" ]]; then
  logthis 'curl -s "'${BASEURL}'/getMe"'
fi

if [[ "$ABOUTME" =~ \"ok\"\:true\, ]]; then
  if [[ "$ABOUTME" =~ \"username\"\:\"([^\"]+)\" ]]; then
    echo "Bot username: ${BASH_REMATCH[1]}";
    logthis "Bot username: ${BASH_REMATCH[1]}";
  fi

  if [[ "$ABOUTME" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
    echo "Bot firstname: ${BASH_REMATCH[1]}";
    logthis "Bot firstname: ${BASH_REMATCH[1]}";
  fi

  if [[ "$ABOUTME" =~ \"id\"\:([0-9\-]+), ]]; then
    echo "Bot ID: ${BASH_REMATCH[1]}";
    BOTID=${BASH_REMATCH[1]};
    logthis "Bot ID number: ${BOTID}";
  fi
  
else
  echo "Error: maybe wrong token... check log $currentLog, exit.";
  logthis "Wrong token? No response from server $ABOUTME";
  exit;
fi

if [ -e "${BOTPATH}/response/${BOTID}.lastmsg" ]; then
  FIRSTTIME=0;
else
  touch ${BOTPATH}/response/${BOTID}.lastmsg;
  FIRSTTIME=1;
fi

echo -e "Done. Waiting for new messages...\n"
logthis "Initializing complete, waiting for new messages.";

while true; do
  _varnow=`date --iso-8601=seconds`

  LASTUPDATEID=$(cat "${BOTPATH}/${FOLDERRESPONSE}/${BOTID}.updateid");
  ((LASTUPDATEID=$LASTUPDATEID+1))
  
  MSGOUTPUT='curl -s -d "offset='${LASTUPDATEID}'" "'${BASEURL}'/getUpdates"';
  
  if [[ "$VERBOSELOGGING" = "True" ]]; then
    logthis ${MSGOUTPUT};
  fi
  
  MSGOUTPUT=$(curl -s -d "offset=${LASTUPDATEID}" "$BASEURL/getUpdates");
  
  if [[ "$VERBOSELOGGING" = "True" ]]; then
    logthis ${MSGOUTPUT};
  fi
  
  MSGID=0;
  TEXT=0;
  FIRSTNAME="";
  LASTNAME="";

  echo "${MSGOUTPUT}" | while read -r line ; do
    if [[ "$line" =~ \"chat\"\:\{\"id\"\:([\-0-9]+)\, ]]; then
      CHATID=${BASH_REMATCH[1]};
      logthis "Response  CHATID: "$CHATID;
    fi

    if [[ "$line" =~ \"message\_id\"\:([0-9]+)\, ]]; then
      MSGID=${BASH_REMATCH[1]};
      logthis "Response  MSGID: "$MSGID;
    fi

    if [[ "$line" =~ \"text\"\:\"([^\"]+)\" ]]; then
      TEXT=${BASH_REMATCH[1]};
      logthis "Response  TEXT: "$TEXT;
    fi

    if [[ "$line" =~ \"username\"\:\"([^\"]+)\" ]]; then
      USERNAME=${BASH_REMATCH[1]};
      logthis "Response  USERNAME: "$USERNAME;
    fi

    if [[ "$line" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
      FIRSTNAME=${BASH_REMATCH[1]};
      logthis "Response  FIRSTNAME: "$FIRSTNAME;
    fi

    if [[ "$line" =~ \"last_name\"\:\"([^\"]+)\" ]]; then
      LASTNAME=${BASH_REMATCH[1]};
      logthis "Response  LASTNAME: "$LASTNAME;
    fi

    if [[ "$line" =~ \"from\"\:\{\"id\"\:([0-9\-]+), ]]; then
      FROMID=${BASH_REMATCH[1]};
      logthis "Response  FROMID: "$FROMID;
    fi

    if [[ "$line" =~ \"update_id\"\:([0-9]+)\, ]]; then
      UPDATEID=${BASH_REMATCH[1]};
      logthis "Response  UPDATEID: "$UPDATEID;
      echo $UPDATEID > "${BOTPATH}/${FOLDERRESPONSE}/${BOTID}.updateid";
    fi
    
    if [[ $MSGID -ne 0 && $CHATID -ne 0 ]]; then
      LASTMSGID=$(cat "${BOTPATH}/${FOLDERRESPONSE}/${BOTID}.lastmsg");
      if [[ $MSGID -gt $LASTMSGID ]]; then
        echo -n "[chat ${CHATID}, from <${USERNAME} - ${FIRSTNAME} ${LASTNAME}>] ${TEXT}";
        
        if [[ "$VERBOSELOGGING" = "True" ]]; then
          logthis "$MSGOUTPUT"
        fi
        
        logthis "[chat ${CHATID}, from <${USERNAME} - ${FIRSTNAME} ${LASTNAME}>] ${TEXT}";
        
        echo $MSGID > "${BOTPATH}/${FOLDERRESPONSE}/${BOTID}.lastmsg";
        
        for s in "${!botcommands[@]}"; do
          if [[ "$TEXT" =~ ${s} ]]; then
            if [[ "$VERBOSELOGGING" = "True" ]]; then
              logthis "Command "$TEXT" found in command list with defined action "${botcommands["$s"]};
            fi
            # setup environment
            CMDORIG=${botcommands["$s"]};
            CMDORIG=${CMDORIG//@TELEGRAMTOKEN/$TELEGRAMTOKEN};
            CMDORIG=${CMDORIG//@FOLDERSCRIPTS/$FOLDERSCRIPTS};
            CMDORIG=${CMDORIG//@FOLDERRESPONSE/$FOLDERRESPONSE};
            CMDORIG=${CMDORIG//@BOTCOMMANDSLIST/$BOTCOMMANDSLIST};
            CMDORIG=${CMDORIG//@USERID/$FROMID};
            CMDORIG=${CMDORIG//@USERNAME/$USERNAME};
            CMDORIG=${CMDORIG//@FIRSTNAME/$FIRSTNAME};
            CMDORIG=${CMDORIG//@LASTNAME/$LASTNAME};
            CMDORIG=${CMDORIG//@CHATID/$CHATID};
            CMDORIG=${CMDORIG//@MSGID/$MSGID};
            CMDORIG=${CMDORIG//@TEXT/$TEXT};
            CMDORIG=${CMDORIG//@FROMID/$FROMID};
            CMDORIG=${CMDORIG//@R1/${BASH_REMATCH[1]}};
            CMDORIG=${CMDORIG//@R2/${BASH_REMATCH[2]}};
            CMDORIG=${CMDORIG//@R3/${BASH_REMATCH[3]}};
            CMDORIG=${CMDORIG//@currentDatetime/$currentDatetime};
            
            permission=0;
            
            for u in "${!alloweduserids[@]}"; do
              if [[ "$FROMID" =~ ${u} ]]; then
                permission=1;
                break
              else
                permission=0;
              fi
            done
            
            echo 
            if [ "${s: -1}" = "*" ]; then
              logthis "The command ${s} needs administrative permissions "
              for u in "${!adminuserids[@]}"; do
                if [[ "$FROMID" =~ ${u} ]]; then
                  logthis "User ${FROMID} is in the administrators group. Access GRANTED."
                  permission=1;
                  break
                else
                  logthis "User ${FROMID} is NOT in the administrators group. Access DENIED."
                  permission=0;
                fi
              done
            fi
            
            if [ $permission -eq 0 ];
            then
              echo "User ${FROMID} has no permission to run cmd: ${CMDORIG}";
              logthis "User "${FROMID}" has no permission to run cmd: "${CMDORIG};
            elif [ $permission -eq 1 ]; 
            then              
              echo " command received through ${CHATID} from allowed user ${u}. Running cmd: ${CMDORIG}";
              
              logthis "Command ${s} received through ${CHATID} from allowed user "${u}", running cmd: "${CMDORIG};

              CMDOUTPUT=`$CMDORIG`;

              if [[ "$VERBOSELOGGING" = "True" ]]; then
                logthis "Response from command: "$CMDOUTPUT;
              fi

              if [ ${s} = "/memories" ]; 
              then
                # IMAGES ARE ALREADY SENT WITH MEMORIES.SH
                # setup response text for Telegram based on
                # return value (set in ./scripts/memories.sh)
                msg=`echo $CMDOUTPUT | gawk -F\\^ '{ print $2 }'`
                echo $msg
                curl -s -d "text=${msg}&chat_id=${CHATID}&parse_mode=html" "$BASEURL/sendMessage" > /dev/null

              elif [ ${s} = "/dp_nasa_mn" ]; 
              then
                if [ '$CMDOUTPUT' = 'False' ]; 
                then
                  logthis "Command failed "$CMDORIG
                elif [ '$CMDOUTPUT' = 'True' ]; 
                then
                  logthis "Command succeeded "$CMDORIG
                fi

              elif [ ${s} = "/dp_nasa_pj" ]; 
              then
                if [ '$CMDOUTPUT' = 'False' ]; 
                then
                  logthis "Command failed "$CMDORIG
                elif [ '$CMDOUTPUT' = 'True' ]; 
                then
                  logthis "Command succeeded "$CMDORIG
                fi

              elif [ ${s} = "/dp_nasa_eo" ]; 
              then
                if [ '$CMDOUTPUT' = 'False' ]; 
                then
                  logthis "Command failed "$CMDORIG
                elif [ '$CMDOUTPUT' = 'True' ]; 
                then
                  logthis "Command succeeded "$CMDORIG
                fi

              else
                if [ $FIRSTTIME -eq 1 ]; 
                then
                  echo "old message, i will not send any answer to user.";
                else
                  curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}&parse_mode=html" "${BASEURL}/sendMessage" > /dev/null
                  logthis 'curl -d "text='${CMDOUTPUT}'&chat_id='${CHATID}'&parse_mode=html" "'${BASEURL}'/sendMessage"'
                fi
              fi
            fi
          fi
        done
      fi
    fi
  done

  FIRSTTIME=0;

  sleep $CHECKNEWMSG
  answer=$CHECKNEWMSG
  
  if [[ "$answer" =~ ^\.msg.([\-0-9]+).(.*) ]]; then
    CHATID=${BASH_REMATCH[1]};
    MSGSEND=${BASH_REMATCH[2]};
    if [[ "$VERBOSELOGGING" = "True" ]]; then
      logthis "[0] "$answer
    fi
    curl -s -d "text=${MSGSEND}&chat_id=${CHATID}&parse_mode=html" "${BASEURL}/sendMessage" > /dev/null;
    
  elif [[ "$answer" =~ ^\.msg.([a-zA-Z]+).(.*) ]]; then
    CHATID=${BASH_REMATCH[1]};
    MSGSEND=${BASH_REMATCH[2]};
    if [[ "$VERBOSELOGGING" = "True" ]]; then
      logthis "[1] "$answer
    fi
    curl -s -d "text=${MSGSEND}&chat_id=@${CHATID}&parse_mode=html" "${BASEURL}/sendMessage" > /dev/null;
  fi

done

exit 0
