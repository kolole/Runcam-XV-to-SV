#!/bin/bash

#this script takes a 16:9 Runcam video (XV) and converts it into 4:3
#then it "superviews" it by using derperview

args="$@"

start=$(date +%s.%N)

for filename in ${args};do
  echo ""
  echo "Input file:" $filename
  echo ""
  echo ""
  echo "Converting to 4:3 aspect ratio"
  echo ""
  echo ""

  #getting information about input video file
  size=$(ffprobe -v error -select_streams v:0 \
            -show_entries stream=width,height -of csv=s=x:p=0 \
            $filename )
  width=$(echo $size | cut -d'x' -f1)
  height=$(echo $size | cut -d'x' -f2)

  #bitrate video will not be entirely correct on output
  bitrate_video=$(ffprobe -v error -select_streams v:0 \
            -show_entries stream=bit_rate -of csv=s=x:p=0 \
            $filename)
  bitrate_audio=$(ffprobe -v error -select_streams a:0 \
            -show_entries stream=bit_rate -of csv=s=x:p=0 \
            $filename)

  asp43=$(bc -l <<< "4/3")

  #find the new width
  width_new=$(bc -l <<< "$asp43 * $height" | awk '{print ($0-int($0)<0.499)?int($0):int($0)+1}')

  #make filename for the 4:3 converted video
  filename_43=$filename"_43_.MP4"

  #convert the original video to 4:3
  #ffmpeg -i $filename -vf scale=$width_new:$height -hide_banner -loglevel warning -threads 0 -vcodec libx264 -b:v $bitrate_video -b:a $bitrate_audio $filename_43 
  ffmpeg-bar -i $filename -vf scale=$width_new:$height -threads 0 -vcodec libx264 -b:v $bitrate_video -b:a $bitrate_audio $filename_43 

  filename_derped=$filename"_derped.MP4"

  #non-linear stretch using derperview
  echo ""
  echo "Derperviewing the 4:3 converted video back to 16:9"
  echo ""
  echo ""
  derperview -q $filename_43 -o $filename_derped

  #delete the 4:3 converted video
  echo ""
  echo "Deleting the 4:3 converted video"
  echo ""
  echo ""
  rm $filename_43
done

end=$(date +%s.%N)

diff=$(echo "$end - $start" | bc)

echo ""
echo ""
echo "Total time of operation"
echo $diff
echo ""
#filesize
#du -m $filename | cut -f1
#do something like filesize/total_time to get mb/min as a way to see how fast the process was. Or slow. Mostly how slow it was.
