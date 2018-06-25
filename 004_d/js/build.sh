#!/bin/bash
while inotifywait -e close_write *.coffee
do
	cat *.coffee \
	| coffee --compile --bare --stdio \
	> main.js
done
