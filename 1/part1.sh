#!/bin/sh

SUM=0

while read line; do
	L=$(echo $line | sed -E 's/^[^0-9]*([0-9]).*/\1/g')
	R=$(echo $line | sed -E 's/.*([0-9])[^0-9]*$/\1/g')
	[ -n "$L$R" ] && : $((SUM = SUM + $L$R))
done

echo "$SUM"
