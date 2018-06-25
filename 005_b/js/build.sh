#!/bin/bash

shaders="../shaders/simple.vert ../shaders/screen.frag ../shaders/fbm_05.frag"

while inotifywait -e close_write *.coffee $shaders
do
    > shaders.coffee
    for s in $shaders
    do
       fn=$(basename -- "$s")
       ext=${fn##*.}
       fn=${fn%.*}
       (echo "# $s"; echo "${ext}_${fn}=" '"""';cat $s; echo '"""'; echo '') >> shaders.coffee
    done
    cat *.coffee \
	| coffee --compile --bare --stdio \
	> main.js
done
