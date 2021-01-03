#!/bin/bash

# before processing convert tga to png by installing ffmpeg and running this command
# for f in $(ls *.tga); do nn=$(echo "$f" | sed 's/\.tga$/.png/g' | sed 's/^Map//g'); ffmpeg -i "$f" "$nn"; done

width=$(echo "1024" | bc -l)
height=$(echo "888" | bc -l)

# map width is 5.5x the width of a single map
# map height is map width * [(3)^.5]/2
mapwidth=$(echo "$width * 5.5 + .999" | bc -l)
mapheight=$(echo "($mapwidth * sqrt(3) / 2) + .999" | bc -l)
mapwidth=$(echo "$mapwidth / 1" | bc)
mapheight=$(echo "$mapheight / 1" | bc)
echo "map size $mapwidth x $mapheight"
oy=$(echo "$mapheight / 2 " | bc -l)
ox=$(echo "$mapwidth/2 - $width /2 " | bc -l)
convert -size ${mapwidth}x${mapheight} xc:transparent map.png

for g in $(ls *.png); do
	f=$(echo "$g" | sed 's/\.png$//g' | sed 's/^Map//g')
	echo "$f"
	offsetx=""
	offsety=""
	if [ "$f" = "GodcroftsHex" ];  then offsety=$(echo ".5 * $height + $oy" | bc -l); offsetx=$(echo "2.25 * $width + $ox" | bc -l); fi
	if [ "$f" = "DeadlandsHex" ]; then offsety="$oy"; offsetx="$ox"; fi
	if [ "$f" = "ReachingTrailHex" ]; then offsety=$(echo "$oy + 2 * $height" | bc -l); offsetx="$ox"; fi
	if [ "$f" = "CallahansPassageHex" ]; then offsety=$(echo "$oy + $height" | bc -l); offsetx="$ox"; fi
	if [ "$f" = "MarbanHollow" ]; then offsety=$(echo "$oy + .5 * $height" | bc -l); offsetx=$(echo "$ox + .75 * $width" | bc -l); fi
	if [ "$f" = "UmbralWildwoodHex" ]; then offsety=$(echo "$oy - $height" | bc -l); offsetx="$ox"; fi
	if [ "$f" = "HeartlandsHex" ]; then offsety=$(echo "$oy - 1.5*$height" | bc -l); offsetx=$(echo "$ox - .75*$width" | bc -l); fi
	if [ "$f" = "LochMorHex" ]; then offsety=$(echo "$oy - .5 * $height" | bc -l); offsetx=$(echo "$ox - .75 * $width" | bc -l); fi
	if [ "$f" = "LinnMercyHex" ]; then offsety=$(echo "$oy + .5 * $height" | bc -l); offsetx=$(echo "$ox - .75 * $width" | bc -l); fi
	if [ "$f" = "StonecradleHex" ]; then offsety=$(echo "$oy + $height" | bc -l); offsetx=$(echo "$ox - 1.5 * $width" | bc -l); fi
	if [ "$f" = "FarranacCoastHex" ]; then offsety="$oy"; offsetx=$(echo "$ox - 1.5 * $width" | bc -l); fi
	if [ "$f" = "WestgateHex" ]; then offsety=$(echo "$oy - $height" | bc -l); offsetx=$(echo "$ox - 1.5 * $width" | bc -l); fi
	if [ "$f" = "FishermansRowHex" ]; then offsety=$(echo "$oy - .5 * $height" | bc -l); offsetx=$(echo "$ox - 2.25 * $width" | bc -l); fi
	if [ "$f" = "OarbreakerHex" ]; then offsety=$(echo "$oy + .5 * $height" | bc -l); offsetx=$(echo "$ox - 2.25 * $width" | bc -l); fi
	if [ "$f" = "GreatMarchHex" ]; then offsety=$(echo "$oy - 2 * $height" | bc -l); offsetx="$ox"; fi
	if [ "$f" = "TempestIslandHex" ]; then offsety=$(echo "$oy - .5 * $height" | bc -l); offsetx=$(echo "$ox + 2.25 * $width" | bc -l); fi
	if [ "$f" = "EndlessShoreHex" ]; then offsety="$oy"; offsetx=$(echo "$ox + 1.5 * $width" | bc -l); fi
	if [ "$f" = "AllodsBightHex" ]; then offsety=$(echo "$oy - $height" | bc -l); offsetx=$(echo "$ox + 1.5 * $width" | bc -l); fi
	if [ "$f" = "WeatheredExpanseHex" ]; then offsety=$(echo "$oy + $height" | bc -l); offsetx=$(echo "$ox + 1.5 * $width" | bc -l); fi
	if [ "$f" = "DrownedValeHex" ]; then offsety=$(echo "$oy - .5 * $height" | bc -l); offsetx=$(echo "$ox + .75 * $width" | bc -l); fi
	if [ "$f" = "ShackledChasmHex" ]; then offsety=$(echo "$oy - 1.5 * $height" | bc -l); offsetx=$(echo "$ox + .75 * $width" | bc -l); fi
	if [ "$f" = "ViperPitHex" ]; then offsety=$(echo "$oy + 1.5 * $height" | bc -l); offsetx=$(echo "$ox + .75 * $width" | bc -l); fi
	if [ "$f" = "MooringCountyHex" ]; then offsety=$(echo "$oy + 1.5 * $height" | bc -l); offsetx=$(echo "$ox - .75 * $width" | bc -l); fi

	if ! [ -z "$offsetx" ]; then
		if ! [ -z "$offsety" ]; then
			offsetx=$(echo "$offsetx" | bc -l)
			offsety=$(echo "$offsety" | bc -l)
			x=$(echo "$offsetx" | sed 's/^/+/g' | sed 's/^+-/-/g')
			y=$(echo "$mapheight - $offsety - $height / 2" | bc -l | sed 's/^/+/g' | sed 's/^+-/-/g')
			echo "composite -geometry $x$y \"$g\" map.png map.png"
			composite -geometry $x$y "$g" map.png map.png
		fi
	fi

done

