#/bin/bash

#root photo folder
ROOT=""
DAY=`date +%d`
MONTH=`date +%m`
yearsWithout=""
yearsWithoutNumber=0
yearsWith=""
yearsWithNumber=0
totalResult=0
fileList=()
for f in $ROOT*; do
    if [ -d "$f" ]; then
        YEAR=$f
        files=`ls $f/$MONTH/$DAY 2> /dev/null`
        if [ -z "$files" ]; then
          yearsWithout=$yearsWithout";$YEAR"
          ((yearsWithoutNumber=yearsWithoutNumber+1))
        else
          yearsWith=$yearsWith";$YEAR"
          ((yearsWithNumber=yearsWithNumber+1))
          a=0;
          for s in $files; do
            ((a=a+1));
            ((totalResult=totalResult+1))
            fileList=$fileList" "$f/$MONTH/$DAY/$s" "
          done
        fi
    fi
done

pictures="shuf -i 1-"$totalResult" -n 5"
pictures=$($pictures)
count=0
thumbnaillist=()

for p in $pictures; do
  for i in $fileList; do
    ((count=count+1))
    if [ $count = $p ]; then
      thumbnaillist=$thumbnaillist" "$i
    fi
  done
  count=0
done

thumbnail="./scripts/thumbs.sh "$thumbnaillist
thumbnail=$($thumbnail)
count=0
for w in $thumbnail; do
  ((count=$count+1))
  curl -s -X POST "https://api.telegram.org/bot"$2"/sendPhoto" -F chat_id=$1 -F photo=@$PWD/$w 
done

echo \^There you have it, $count memories for this day from the archives. Message the \<a href=\"tg://user?id=number\"\>/msgadmin\<\/a\> when something is wrong.


