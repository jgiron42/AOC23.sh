#!/bin/sh

F=$(mktemp)
INS=$(mktemp)
SWAP=$(mktemp)
TMP=$(mktemp)

build() {
	SET=$1
	CATEGORY=$2
	VALUE=$3

	[ $CATEGORY != "x" ] && echo $SET | cut -d\  -f1-$(echo $CATEGORY | tr 'mas' '123') | tr -d '\n'
	echo -n " $VALUE "
	[ $CATEGORY != "s" ] && echo $SET | cut -d\  -f$(echo $CATEGORY | tr 'xma' '234')-4 | tr -d '\n'
}

match() {
	COND=$1
	SET=$2

	CATEGORY=$(echo $COND | cut -c1)
	OPERATOR=$(echo $COND | cut -c2)
	OPERAND=$(echo $COND | cut -c3-)

	echo $SET | cut -d\  -f$(echo $CATEGORY | tr 'xmas' '1234') | tr ' -' '\n ' >$TMP
	read A B <$TMP
	if [ "$OPERATOR" = '<' ]; then
		if [ $A -lt "$OPERAND" ]; then
			if [ "$B" -lt "$OPERAND" ]; then
				MATCHING="$SET"
				NON_MATCHING=
			else
				MATCHING="$(build "$SET" $CATEGORY "$A-$((OPERAND - 1))")"
				NON_MATCHING="$(build "$SET" $CATEGORY "$OPERAND-$B")"
			fi
		else
			MATCHING=
			NON_MATCHING="$SET"
		fi
	else
		if [ "$B" -gt "$OPERAND" ]; then
			if [ "$A" -gt "$OPERAND" ]; then
				MATCHING="$SET"
				NON_MATCHING=
			else
				MATCHING="$(build "$SET" $CATEGORY "$((OPERAND + 1))-$B")"
				NON_MATCHING="$(build "$SET" $CATEGORY "$A-$OPERAND")"
			fi
		else
			MATCHING=
			NON_MATCHING="$SET"
		fi
	fi
}

grep -B1000000 '^$' | tr '{},' '   ' >$F

echo in 1-4000 1-4000 1-4000 1-4000 >$SWAP

until cmp -s "$SWAP" "$INS"; do
	cat <$SWAP >$INS
	cat $INS | while read FUN SET; do
		grep "^$FUN " <$F | cut -d\  -f2- | tr ' :' '\n ' | grep -v '^$' | while read condition next; do
			if [ -z "$next" ]; then
				if [ "$condition" = "A" ]; then
					echo $SET >&3
				elif [ "$condition" != "R" ]; then
					echo $condition $SET
				fi
			else
				match $condition "$SET"
				if [ -n "$MATCHING" ]; then
					if [ $next = "A" ]; then
						echo $MATCHING >&3
					elif [ $next != "R" ]; then
						echo $next $MATCHING
					fi
				fi
				if [ -n "$NON_MATCHING" ]; then
					SET="$NON_MATCHING"
				else
					break
				fi
			fi
		done
	done >$SWAP
done 3>&1 | {
	SUM=0
	while read SET; do
		: $((SUM += $(echo $SET | tr ' ' '*' | sed -E 's/([0-9]+)-([0-9]+)/(\2 - \1 + 1)/g' | bc)))
	done
	echo $SUM
}
