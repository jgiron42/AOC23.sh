#!/bin/sh

F=$(mktemp)
SWAP=$(mktemp)

cat >$F

TMP=$(mktemp)

transpose() {
	TRANSPOSE_TMP=$(mktemp)
	cat >$TRANSPOSE_TMP
	for i in $(seq $(($(head <$TRANSPOSE_TMP -n1 | wc -c) - 1))); do
		cut <$TRANSPOSE_TMP -c$i | tr -d '\n'
		echo
	done
}

find_reflection() {
	FA=$(mktemp)
	FB=$(mktemp)
	cat >$TMP
	HEIGHT=$(wc -l <$TMP)
	for i in $(seq $((HEIGHT - 1))); do
		SIZE=$((i < HEIGHT - i ? i : HEIGHT - i))
		head <$TMP -n $i | tail -n$SIZE | tr -d '\n' | fold -w1 >$FA
		tail <$TMP -n+$((i + 1)) | head -n$SIZE | tac | tr -d '\n' | fold -w1 >$FB
		[ $(cmp -l $FA $FB | wc -l) = 1 ] && echo $i
		echo
	done
}

while [ $(wc -l <$F) -gt 0 ]; do
	BLOCK_END=$(grep <$F -n -m1 '^$' | cut -d: -f1)
	[ -z "$BLOCK_END" ] && BLOCK_END=$(wc -l <$F)
	H=$(head <$F -n"$((BLOCK_END - 1))" | find_reflection)
	V=$(head <$F -n"$((BLOCK_END - 1))" | transpose | find_reflection)
	echo $V+$((H * 100))
	tail <$F -n+"$((BLOCK_END + 1))" >$SWAP
	cat <$SWAP >$F
done |
	{
		SUM=0
		while read N; do
			: $((SUM += N))
		done
		echo $SUM
	}
