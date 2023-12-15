#!/bin/sh

hash() {
	od -A n -t d1 | fold -w5 | {
		RET=0
		while read CHAR; do
			: $((RET += $CHAR))
			: $((RET *= 17))
			: $((RET %= 256))
		done
		echo $RET
	}
}

sum() {
	RET=0
	while read N; do
		: $((RET += N))
	done
	echo $RET
}

tr ',' '\n' | while read S; do
	echo -n $S | hash
done | sum
