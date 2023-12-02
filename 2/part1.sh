#!/bin/sh

SUM=0

while read line; do
	ID=$(echo $line | sed -E 's/^Game ([[:digit:]]+):.*$/\1/g')

	[ -n "$line" ] && echo $line | cut -d\  -f3- | tr ';' '\n' |
		while read SET; do
			echo $SET | tr ',' '\n' |
				while read N COLOR; do
					echo $COLOR a $N
					[ $COLOR = "red" -a $N -gt 12 ] && echo KO
					[ $COLOR = "green" -a $N -gt 13 ] && echo KO
					[ $COLOR = "blue" -a $N -gt 14 ] && echo KO
				done
		done | grep KO || : $((SUM += ID))
done

echo $SUM
