#!/bin/bash

PARAMS="$@"

if [[ $1 =~ "dp_nasa" ]]; then
  # init
  msg="Thanks for your order! Here are some pictures hand picked from the <b>Picture of the day</b> feed from "
  
  if [ $1 = "dp_nasa_eo" ]; then
    msg=${msg}"<a fref='https://earthobservatory.nasa.gov/feeds/image-of-the-day.rss'>NASA Earth Observatory</a>."
    rssurl="https://earthobservatory.nasa.gov/feeds/image-of-the-day.rss"
  elif [ $1 = "dp_nasa_mn" ]; then
    msg=${msg}"<a fref='https://earthobservatory.nasa.gov/feeds/image-of-the-day.rss'>NASA Main Gallery page</a>."
    rssurl="https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss"
  elif [ $1 = "dp_nasa_pj" ]; then
    msg=${msg}"<a fref='https://earthobservatory.nasa.gov/feeds/image-of-the-day.rss'>JPL Photo Journal</a>."
    rssurl="https://photojournal.jpl.nasa.gov/rss/new"
  fi
  msg=${msg}" More picture feeds /dp_nasa_eo, /dp_nasa_mn, /dp_nasa_pj and ofcourse /memories."
    
  # refresh list
  # echo Refreshing RSS feed from nasa
  wget -O $4/image-of-the-day.rss $rssurl
  
  if [[ $1 = "dp_nasa_eo" ]]; then
    imagelist=`cat "$4"/image-of-the-day.rss | tr -s ' ' | grep src | tr -s '=' ' ' | gawk -F\" '{ print $2 }'`
  elif [[ $1 = "dp_nasa_mn" ]]; then
    imagelist=`cat "$4"/image-of-the-day.rss | tr -s ' ' | grep enclosure | gawk -F\" '{ print $2 }'`
  elif [[ $1 = "dp_nasa_pj" ]]; then
    imagelist=`cat "$4"/image-of-the-day.rss | tr -s ' ' | grep hiresJpeg | gawk -F\[ '{ print $3 }' | gawk -F] '{ print $1 }' | awk '{print$1}'`
  fi
  count=0

  a=0;
  for s in $imagelist; do
    ((a=a+1));
  done
  
  pictures="shuf -i 1-${a} -n 4"
  pictures=$($pictures)

  # greet user
  msg=$msg" I have selected from a list of ${a} pictures."
  CMDOUTPUT=$msg
  CHATID=$2
  BASEURL="https://api.telegram.org/bot"$3
  curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}&parse_mode=html" "$BASEURL/sendMessage" > /dev/null


  for p in $pictures; do
    for i in $imagelist; do
      ((count=$count+1))
      if [ $count -eq $p ]; then
        url="https://api.telegram.org/bot"$3"/sendPhoto?chat_id="$2"&photo="$i;
        curl -s $url
      fi
    done
  count=0
  done
  
elif [[ $1 =~ "nws_" ]]; then
  # init
  msg="Wanna read some news? Here are some articles hand picked from the <b>news</b> feed from "
  if [ $1 = "nws_hackernews" ]; then
    msg=${msg}"<a fref='https://news.ycombinator.com/rss'>HACKERNEWS</a>."
    rssurl="https://news.ycombinator.com/rss"
  fi
  
  wget -O $4/newsarticles.rss $rssurl

  if [[ $1 = "nws_hackernews" ]]; then
    newslist=`cat "$4"/newsarticles.rss | tr -s ' ' | grep src | tr -s '=' ' ' | gawk -F\" '{ print $2 }'`
  fi
  
  a=0;
  for s in $newslist; do
    ((a=a+1));
  done
    
  newslist="shuf -i 1-${a} -n 4"
  newslist=$($newslist)
  
  # greet user
  msg=$msg" I have selected from a list of ${a} articles."
  CMDOUTPUT=$msg
  CHATID=$2
  BASEURL="https://api.telegram.org/bot"$3
  curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}&parse_mode=html" "$BASEURL/sendMessage" > /dev/null
  
fi

