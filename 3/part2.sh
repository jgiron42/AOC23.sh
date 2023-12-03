#!/bin/sh

F1=$(mktemp)
F2=$(mktemp)
cat >$F1

LINE_NUMBER=$(wc -l <$F1)
yes .. | head -n$LINE_NUMBER | paste -d. $F1 - >$F2
cat >$F1 <$F2
>$F2

LSIZE=$(($(head -n1 <$F1 | wc -c) - 1))

SQUARE="((.{7}).{$((LSIZE - 7))}(.{3}))\*((.{3}).{$((LSIZE - 7))}(.{7}))"

REG_LEFT='^(.*[^ 0-9])?*([0-9]{0,3})'
REG_RIGHT='([0-9]{0,3})([^ 0-9].*)?$'
REG_UP_DOWN="^(([0-9]{3})|.([0-9]{2})|..([0-9]))?\.(([0-9]{3})|([0-9]{2}).|([0-9])..)$"
REG_THREE="^([^ ]*[^ 0-9])?([0-9]{3})([^0-9 ][^ ]*)?$"
REG_TWO="^[^ ]*[^0-9 ]([0-9]{2})[^0-9 ][^ ]*$"
REG_ONE="^[^ ]{1,}[^0-9 ]([0-9])[^0-9 ][^ ]{1,}$"

until cmp -s $F1 $F2; do
	cat $F1 | tr -d '\n' | sed -E "s/$SQUARE/[\2 \3 \5 \6]/g" | grep -oE '\[[^]]+\]' | while read match; do
		echo $match | sed -E 's/\[(.*) (.*) (.*) (.*)\]/\1\n\2 \3\n\4/g' | {
			read l1
			read l2
			read l3
			echo $l1 | sed -E -e 's/'"$REG_UP_DOWN"'/ [\2 \3 \4 \6 \7 \8] /g' -e "s/$REG_THREE/ [\2] /g" -e "s/$REG_TWO/ [\1] /g" -e "s/$REG_ONE/ [\1] /g"
			echo $l2 | sed -E 's/'"$REG_LEFT $REG_RIGHT"'/ [\2 \3] /g'
			echo $l3 | sed -E -e 's/'"$REG_UP_DOWN"'/ [\2 \3 \4 \6 \7 \8] /g' -e "s/$REG_THREE/ [\2] /g" -e "s/$REG_TWO/ [\1] /g" -e "s/$REG_ONE/ [\1] /g"
		} | grep -oE '\[[^]]+\]' | tr '\n' ' ' | tr -d '][' | {
			read A B C
			[ -z "$C" -o -n "$B" ] && echo $((A * B))
		}
	done
	cat $F1 >$F2
	cat $F2 | tr -d '\n' | sed -E "s/$SQUARE/\1.\4/g" >$F1
done |
	{
		SUM=0
		while read N; do
			: $((SUM += N))
		done
		echo $SUM
	}
