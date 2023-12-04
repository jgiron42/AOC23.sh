#!/bin/sh

F=$(mktemp)
cut -d\: -f2 | tr -d \| >$F

COUNT=$(head -n1 <$F | wc -w)

while read line; do
	[ -n "$line" ] && echo $line | head -n1 | tr ' ' '\n' | sort -u | wc -w
done <$F | {
	SUM=0
	while read n; do
		: $((SUM += n < COUNT ? 1 << (COUNT - n) - 1 : 0))
	done
	echo $SUM
}
