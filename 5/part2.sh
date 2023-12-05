#!/bin/sh

f() {
	SSTART=$1
	SSIZE=$2

	while read DST SRC SIZE; do
		if [ $((SSTART < SRC + SIZE && (SSTART + SSIZE) > SRC)) = "1" ]; then
			if [ $((SSTART < SRC)) = 1 ]; then
				echo $SSTART $((SRC - SSTART)) >&3
				OUT_START=$DST
			else
				OUT_START=$((SSTART - SRC + DST))
			fi
			if [ $((SSTART + SSIZE > SRC + SIZE)) = 1 ]; then
				echo $((SRC + SIZE)) $(((SSTART + SSIZE) - (SRC + SIZE))) >&3
				echo $OUT_START $((DST + SIZE - $OUT_START))
			else
				echo $OUT_START $((SSTART + SSIZE - SRC + DST - OUT_START))
			fi
			return
		fi
	done
	echo $SSTART $SSIZE
}

F=$(mktemp)
REMAINING_TRANSITIONS=$(mktemp)
F3=$(mktemp)
SEEDS=$(mktemp)
NEXT_SEEDS=$(mktemp)
SWAP=$(mktemp)
cat >$F

cat $F | head -n1 | cut -d\: -f2 | sed -E 's/[0-9]+ [0-9]+ ?/\0\n/g' | grep -v '^$' >$SEEDS

cat <$F >$REMAINING_TRANSITIONS
while [ "$(wc -w <$REMAINING_TRANSITIONS)" -gt 0 ]; do
	grep <$REMAINING_TRANSITIONS -A1000 -m1 -E '^$' | tail -n+3 >$F3
	>$NEXT_SEEDS
	while [ $(wc -l <$SEEDS) -gt 0 ]; do
		while read START SIZE; do
			grep <$F3 -B1000 -m1 -E '^$' | f $START $SIZE
		done <$SEEDS 3>$SWAP >>$NEXT_SEEDS
		cat <$SWAP >$SEEDS
	done
	cat <$F3 >$REMAINING_TRANSITIONS
	cat <$NEXT_SEEDS >$SEEDS
done
cat $NEXT_SEEDS | sort -n | head -n1 | cut -d\  -f1
