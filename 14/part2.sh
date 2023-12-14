#!/bin/sh

transpose() {
	TRANSPOSE_TMP=$(mktemp)
	cat >$TRANSPOSE_TMP
	for i in $(seq $(($(head <$TRANSPOSE_TMP -n1 | wc -c) - 1))); do
		cut <$TRANSPOSE_TMP -c$i | tr -d '\n'
		echo
	done
	rm $TRANSPOSE_TMP
}

load() {
	tr -d '.#' | tac | cat -n | {
		SUM=0
		while read n line; do
			: $((SUM += n * $(echo -n $line | wc -c)))
		done
		echo $SUM
	}
}

tilt_west() {
	sed -E -e ':loop' -e 's/((#|^)O*)(\.+)O/\1O\3/g' -e 't loop'
}

tilt_north() {
	transpose | tilt_west | transpose
}

tilt_east() {
	sed -E -e ':loop' -e 's/O(\.+)(O*(#|$))/\1O\2/g' -e 't loop'
}

tilt_south() {
	transpose | tilt_east | transpose
}

F=$(mktemp)
SWAP=$(mktemp)
TMPDIR=$(mktemp -d)
LOADS=$(mktemp)

CYCLE=1000000000

cat >$F
i=0
while true; do
	printf '%d\r' $((i += 1)) >&2
	LOAD=$(tilt_north <$F | tilt_west | tilt_south | tilt_east | tee $SWAP | load)
	cat <$SWAP >$F
	grep -q $LOAD $LOADS &&
		for STATE in $TMPDIR/*; do
			#	echo $STATE
			cmp -s $STATE $F && {
				echo $(basename $STATE) $i
				break 2
			}
		done
	echo $LOAD >>$LOADS
	cat <$F >$TMPDIR/$i
done | {
	read A B
	INDEX=$((A + (CYCLE - A) % (B - A)))
	head -n $INDEX $LOADS | tail -n1
}

rm -rf $TMPDIR $F $SWAP $LOADS
