#!/bin/bash

# token
TELEGRAMTOKEN=""
BOTHOSTNAME=$HOSTNAME
BOTNAME=""
REFRESHINT=10

# is batbot running?
hvcbpids=`ps -eo pid,args | grep batbot | awk '{print $2;}' | grep /bin/bash`

if [ "${1}" = "show" ]; then
  all=`ps -eo pid,args | grep batbot | awk '{print $0;}' | grep /bin/bash`
  echo -n $all
  pidrunningbot=`ps -eo pid,args | grep batbot | awk '{print $0;}' | grep /bin/bash | awk '{print $1;}'`
  if [ ! -z ${pidrunningbot} ]; then
    echo -n  " -> a bot with pid ${pidrunningbot} "
  else
    echo -n  " A new batbot with name "
  fi 
elif [ "${1}" = "pidlog" ]; then
    first=`ps -eo pid,args | grep batbot | awk '{print $0;}'`
    second='ps -eo pid,args | grep '${2}
    second=$($second)
    echo -n  "Bot ${2}: "$second
    exit 0
fi

if [ "${2}" = "kill" ]; then
  if [ ! -z ${pidrunningbot} ]; then
    echo -n " is already running -> pid ${pidrunningbot} placed on kill list"
    kill ${pidrunningbot}
    killresult=`ps -eo pid,args | grep batbot | awk '{print $0;}' | grep /bin/bash | awk '{print $1;}'`
    if [ -z ${killresult} ]; then
      echo ", and killed."
      if [ ! "${3}" = "run" ]; then
        exit 0
      else
        hvcbpids=
      fi
    else
      echo ", but kill failed (are there more running? $killresult)."
      if [ ! "${3}" = "run" ]; then
        exit 1
      else
        hvcbpids=
      fi
    fi
  fi
fi

startbot() {
  currentTime=`date +%Y%m%d_%H%M%S`
  logfolder=`pwd`
  
  # switch following lines to always create session specific stdout log
  # currentLog=$logfolder'/log/batbot_'$HOSTNAME'.log'
  currentLog=$logfolder'/log/batbot_'$HOSTNAME'_'$currentTime'.log'
  
  # With writing to the log file currentLog for stdout messages
  nohup /go/packages/batbot/batbot2.sh -f -c $REFRESHINT -t $TELEGRAMTOKEN -session "$currentTime" &>$currentLog &
}

if [ -z "${hvcbpids}" ] # if var not assigned
then
  startbot
  echo $BOTNAME" started with -f -c "$REFRESHINT" and log" $currentLog
else
  if [ "${4}" = "force" ]; then
    startbot
  else
    echo " is already running, check "$BOTNAME" or start runbot.sh with parameters 'show kill' to always kill the running process. Use 'show kill run' to start and add 'force' to enable multiple concurrend sessions."
  fi
fi

