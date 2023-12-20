#!/bin/sh

F=$(mktemp)
PULSES=$(mktemp)
ALL_PULSES=$(mktemp)
DIR=$(mktemp -d)
TMP=$(mktemp)
SWAP=$(mktemp)
SWAP2=$(mktemp)

cat >$F

parse_line() {
	sed -E -e 's/^([%&]?)([a-z]+) -> ([a-z]+(, [a-z]+)*)$/\1 \2 \3/g' | tr -d ',' | tr ' ' '\n'
}

get_line_of() {
	grep -E "^[%&]?$1 " <$F | parse_line
}

while read LINE; do
	echo $LINE | parse_line |
		{
			read TYPE
			read NAME
			if [ "$TYPE" = "%" ]; then
				echo off >$DIR/$NAME
			fi
			while read OUT; do
				get_line_of $OUT | {
					read TYPE
					if [ "$TYPE" = "&" ]; then
						echo $NAME 0 >>$DIR/$OUT
					fi
				}
			done
		}
done <$F

for i in $(seq 1000); do
	printf '%d\r' $i >&2
	echo "button broadcaster 0" >>$PULSES
	while [ $(wc -l <$PULSES) -gt 0 ]; do
		cat $PULSES
		cat $PULSES | while read FROM TO VALUE; do
			get_line_of $TO >$TMP
			{
				read TYPE
				read NAME
				if [ "$TYPE" = "&" ]; then
					cat $DIR/$TO | sed -E "s/^$FROM [01]$/$FROM $VALUE/g" >$SWAP2
					cat <$SWAP2 >$DIR/$TO
					if grep -q 0 <$DIR/$TO; then
						OUT_SIG=1
					else
						OUT_SIG=0
					fi
				elif [ "$TYPE" = "%" ]; then
					if [ "$VALUE" = 1 ]; then
						continue
					fi
					if [ "$(cat $DIR/$TO)" = "on" ]; then
						echo "off" >$DIR/$TO
						OUT_SIG=0
					else
						echo "on" >$DIR/$TO
						OUT_SIG=1
					fi
				else
					OUT_SIG=$VALUE
				fi
				while read OUT; do
					echo $TO $OUT $OUT_SIG
				done
			} <$TMP
		done >$SWAP
		cat <$SWAP >$PULSES
	done
done >$ALL_PULSES
echo $(($(grep -c '0' <$ALL_PULSES) * $(grep -c '1' <$ALL_PULSES)))
