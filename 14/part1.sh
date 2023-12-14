#!/bin/sh

transpose() {
	TRANSPOSE_TMP=$(mktemp)
	cat >$TRANSPOSE_TMP
	for i in $(seq $(($(head <$TRANSPOSE_TMP -n1 | wc -c) - 1))); do
		cut <$TRANSPOSE_TMP -c$i | tr -d '\n'
		echo
	done
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

tilt_north() {
	transpose | sed -E -e ':loop' -e 's/((#|^)O*)(\.+)O/\1O\3/g' -e 't loop' | transpose
}

tilt_north | load
