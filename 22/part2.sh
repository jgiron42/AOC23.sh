#!/bin/sh

DIR=$(mktemp -d)
LIST=$DIR/list
DEPENDENCIES=$DIR/dep

mkdir -p $DIR

get_obstacles() {
	for X in $(seq $X1 $X2); do
		for Y in $(seq $Y1 $Y2); do
			for Z in $(seq $Z1 $Z2); do
				[ -r $DIR/$((Z - 1))/$Y/$X ] && cat "$DIR/$((Z - 1))/$Y/$X"
			done
		done
	done
}

can_fall() {
	[ "$Z1" -gt 1 ] && [ "$(get_obstacles | wc -l)" = 0 ]
}

save_pos() {
	for X in $(seq $X1 $X2); do
		for Y in $(seq $Y1 $Y2); do
			for Z in $(seq $Z1 $Z2); do
				mkdir -p "$DIR/$Z/$Y"
				echo $N >"$DIR/$Z/$Y/$X"
			done
		done
	done
}

get_dependencies() {
	for X in $(seq $X1 $X2); do
		for Y in $(seq $Y1 $Y2); do
			for Z in $(seq $Z1 $Z2); do
				[ -r $DIR/$((Z + 1))/$Y/$X ] && {
					N2=$(cat "$DIR/$((Z + 1))/$Y/$X")
					[ $N2 = $N ] && continue
					echo $N2
				}
			done
		done
	done | sort -u | grep -v "^$N$" | {
		echo -n "$N "
		tr '\n' ' '
		echo
	}
}

[ -r "$LIST" ] || {
	tr ',~' '  ' | while read X1 Y1 Z1 X2 Y2 Z2; do
		echo $Z1 $Y1 $X1 $Z2 $Y2 $X2
	done | sort -n | cat -n | while read N Z1 Y1 X1 Z2 Y2 X2; do
		while can_fall; do
			: $((Z1 -= 1))
			: $((Z2 -= 1))
		done
		echo $N $Z1 $Y1 $X1 $Z2 $Y2 $X2
		save_pos
	done >$LIST
}

[ -r "$DEPENDENCIES" ] || {
	BASE=
	while read N Z1 Y1 X1 Z2 Y2 X2; do
		[ "$Z1" = "1" ] && BASE="$BASE $N"
		get_dependencies
	done <$LIST
	echo 0 $BASE' '
} >$DEPENDENCIES

chain() {
	TMP=$(mktemp)
	SWAP=$(mktemp)
	DELETE=$(mktemp)
	sed -E "s/ $B / /g" <$DEPENDENCIES >$TMP
	i=0
	AFFECTED=$1
	while true; do
		for B in $AFFECTED; do
			grep -q " $B " <$TMP || [ "$B" = 0 ] || echo $B
		done | sort -u >$DELETE
		AFFECTED="$(grep <$TMP -E "^($(cat <$DELETE | tr '\n' '|')) " | cut -d\  -f2- | tr '\n' ' ')"
		cat $DELETE
		[ "$(wc -l <$DELETE)" = 0 ] && break
		grep -Ev "^($(cat <$DELETE | tr '\n' '|')) " <$TMP >$SWAP
		cat $SWAP >$TMP
		: $((i += 1))
	done
	rm $TMP $SWAP $DELETE
} 3>&1

while read B DEPS; do
	[ "$B" = 0 ] && continue
	chain $B | wc -l
done <$DEPENDENCIES | {
	SUM=0
	while read N; do
		: $((SUM += N - 1))
	done
	echo $SUM
}

rm -rf $DIR
