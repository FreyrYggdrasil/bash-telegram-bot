#!/bin/bash
FILES="$@"

cnvrt() {
    # Take screenshot    
    # echo 'ffmpeg -ss 00:00:01 -i "$in_file" -vframes 1 -q:v 2 "$output_dir/$output_file"'
    ffmpeg -ss 00:00:01 -i "$in_file" -vframes 1 -q:v 2 "$output_dir/$output_file" > /dev/null
}

for i in $FILES
do
  file=`basename $i`
  filext="${file##*.}"
  fileext=`echo $filext | tr [:upper:] [:lower:]`
  # echo $fileext
  ismovie=0
  list='mov mp4 3gp aac'
  ismovieext='no'
  ismovieext=`[[ $list =~ (^|[[:space:]])$filext($|[[:space:]]) ]] && echo 'yes' || echo 'no'`
  
  if [ $ismovieext = 'yes' ]; then
    ismovie=1
    if ! test -f "./thumb/thumb_$file.png"; then
      in_file=${i}
      output_dir=$PWD./thumb
      output_file=thumb_${file%filext}.png
      # cnvrt $in_file $output_dir $output_file
    fi
  fi
  
  if [ $ismovie -eq 0 ]; then
    list='jpg gif jpeg png'
    isimageext='no'
    isimageext=`[[ $list =~ (^|[[:space:]])$filext($|[[:space:]]) ]] && echo 'yes' || echo 'no'`
    
    if [ $isimageext = 'yes' ]; then
      if ! test -f "./thumb/thumb_$file"; then
        /bin/convert -thumbnail 250 $i ./thumb/thumb_$file
      fi

      if test -f "./thumb/thumb_$file"; then
        echo ./thumb/thumb_$file
      fi
    fi
  fi
done

