#!/bin/sh

SUM=0

while read line; do
	ID=$(echo $line | sed -E 's/^Game ([[:digit:]]+):.*$/\1/g')

	[ -n "$line" ] && : $((SUM += $(
		(
			echo $line | cut -d\  -f3- | tr ';,' '\n\n' | while read N C; do
				printf "%s %04d\n" $C $N
			done
			cat <<EOF
green 0000
red 0000
blue 0000
EOF
		) | sort -rn -k 1,2 | sort -u -k 1,1 | cut -d\  -f2 | sed 's/^0*//g' | tr '\n' '*'
		echo 1
	)))

done

echo $SUM
