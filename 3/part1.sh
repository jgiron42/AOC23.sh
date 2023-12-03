#!/bin/sh

F1=$(mktemp)
F2=$(mktemp)
cat >$F1

LSIZE=$(($(head -n1 <$F1 | wc -c) - 1))
SYM="[-+=*/#@$%&]"

get_regex() {
	NSIZE=$1
	echo "($SYM.{0,$((NSIZE + 1))}.{$((LSIZE - NSIZE - 1))}|$SYM)([0-9]{$NSIZE})|([0-9]{$NSIZE})($SYM|.{$((LSIZE - NSIZE - 1))}.{0,$((NSIZE + 1))}$SYM)"
}

MAX_NSIZE=3

for i in $(seq $MAX_NSIZE -1 1); do
	REGEX=$(get_regex $i)
	>$F2
	until cmp -s $F1 $F2; do
		cat $F1 | tr -d '\n' | sed -E "s/$REGEX/\1[\2\3]\4/g" | tee $F2 | grep -oE '\[[0-9]{'$i'}\]' | sed -E 's/\[([0-9]+)\]/\1/g'
		sed -E -e 's/\[[0-9]+\]/'$(printf %$i"s" | tr ' ' '.')'/g' <$F2 >$F1
	done
done |
	{
		SUM=0
		while read n; do
			: $((SUM += n))
		done
		echo $SUM
	}
