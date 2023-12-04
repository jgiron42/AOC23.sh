#!/bin/sh

F=$(mktemp)
F2=$(mktemp)
cut -d\: -f2 | tr -d \| >$F

COUNT=$(head -n1 <$F | wc -w)

sum() {
	echo $(($(tr ' ' '+')))
}

while read line; do
	[ -n "$line" ] && echo $((COUNT - $(echo $line | head -n1 | tr ' ' '\n' | sort -u | wc -w)))
done <$F |
	{
		cat >$F2
		while true; do
			read WINNING Q <$F2
			[ -z "$WINNING" ] && break
			echo $(echo -n $Q '1' | sum)
			tail -n+2 <$F2 | (yes $(echo -n $Q '1' | sum) | head -n "$WINNING" | paste -d\  /dev/fd/4 -) 4<&0 >$F
			cat $F >$F2
		done
	} | tr '\n' ' ' | sed 's/ $//' | sum
