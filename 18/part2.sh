#!/bin/sh

X=0
Y=0

MIN_X=0
MIN_Y=0
MAX_X=0
MAX_Y=0

move() {
	DIR=$1
	LEN=$2
	case "$DIR" in
	U)
		: $((Y -= LEN))
		: $((MIN_Y = Y < MIN_Y ? Y : MIN_Y))
		;;
	D)
		: $((Y += LEN))
		: $((MAX_Y = Y > MAX_Y ? Y : MAX_Y))
		;;
	L)
		: $((X -= LEN))
		: $((MIN_X = X < MIN_X ? X : MIN_X))
		;;
	R)
		: $((X += LEN))
		: $((MAX_X = X > MAX_X ? X : MAX_X))
		;;
	esac
}

TOTAL=0

SWAP=$(mktemp)

add_pair() {
	Y=$1
	X1=$2
	X2=$3
	PAIR_LIST=$4

	IDK=
	while read OY OX1 OX2; do
		if [ "$X1" -gt "$OX2" -o "$X2" -lt "$OX1" ]; then
			echo $OY $OX1 $OX2
			continue
		fi

		echo $(((Y - OY) * (OX2 - OX1 + 1))) >&3

		if [ "$OX2" = "$X1" ]; then
			IDK=true
			X1=$OX1
		elif [ "$OX1" = "$X2" ]; then
			IDK=true
			X2=$OX2
		elif [ "$OX1" = "$X1" -a "$OX2" = "$X2" ]; then
			echo $((X2 - X1 + 1)) >&3
		elif [ "$OX1" = "$X1" -a "$X2" -lt "$OX2" ]; then
			echo $((X2 - X1)) >&3
			echo $Y $X2 $OX2
		elif [ "$OX2" = "$X2" -a "$X1" -gt "$OX1" ]; then
			echo $((X2 - X1)) >&3
			echo $Y $OX1 $X1
		elif [ "$X1" -gt "$OX1" -a "$X2" -lt "$OX2" ]; then
			echo $((X2 - X1 - 1)) >&3
			echo $Y $OX1 $X1
			echo $Y $X2 $OX2
		fi
	done <$PAIR_LIST >$SWAP

	[ -n "$IDK" ] && echo $Y $X1 $X2 >>$SWAP

	if cmp -s $SWAP $PAIR_LIST; then
		echo $Y $X1 $X2 >>$PAIR_LIST
	else
		cat <$SWAP >$PAIR_LIST
	fi
} 3>&1

TMP=$(mktemp)

PAIR_LIST=$(mktemp)

while read DIR LEN COLOR; do
	DIR=$(echo $COLOR | cut -c8 | tr '0123' 'RDLU')
	LEN=$((0x$(echo $COLOR | cut -c3-7)))
	move $DIR $LEN
	echo $Y $X
done >$TMP
cat $TMP | while read Y X CHAR; do
	printf "%8d %8d\n" $((Y - MIN_Y)) $((X - MIN_X))
done |
	LC_ALL=C sort -n | while read Y X; do
	[ "$Y" != "$PREV_Y" ] && {
		[ -n "$PREV_Y" ] && echo
		echo -n "$((Y)) "
		PREV_Y=$Y
	}
	echo -n "$((X)) "
done | cut -c-1000 | while read Y POINTS; do
	echo $POINTS | sed -E 's/(-?[0-9]+) (-?[0-9]+) /\1 \2\n/g' | while read X1 X2; do
		add_pair "$Y" "$X1" "$X2" "$PAIR_LIST"
	done
done | {
	TOTAL=0
	while read N; do
		: $((TOTAL += N))
	done
	echo $TOTAL
}
