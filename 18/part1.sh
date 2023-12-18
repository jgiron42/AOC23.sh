#!/bin/sh

X=0
Y=0

MIN_X=1000000
MIN_Y=1000000
MAX_X=-1000000
MAX_Y=-1000000

PREV_DIR=

move() {
	DIR=$1
	case "$DIR" in
	U)
		: $((Y -= 1))
		: $((MIN_Y = Y < MIN_Y ? Y : MIN_Y))
		;;
	D)
		: $((Y += 1))
		: $((MAX_Y = Y > MAX_Y ? Y : MAX_Y))
		;;
	L)
		: $((X -= 1))
		: $((MIN_X = X < MIN_X ? X : MIN_X))
		;;
	R)
		: $((X += 1))
		: $((MAX_X = X > MAX_X ? X : MAX_X))
		;;
	esac
}

TMP=$(mktemp)

get_char() {
	case $1$2 in
	UL | RD) echo L ;;
	LU | DR) echo 7 ;;
	RU | DL) echo F ;;
	UR | LD) echo J ;;
	esac
}

while read DIR LEN COLOR; do
	[ -n "$PREV_DIR" ] && printf "%8d %8d %c\n" $Y $X $(get_char $DIR $PREV_DIR) || FIRST_DIR=$DIR
	move $DIR
	for i in $(seq $((LEN - 1))); do
		printf "%8d %8d #\n" $Y $X
		move $DIR
	done
	PREV_DIR=$DIR
done >$TMP

printf "%8d %8d %c\n" 0 0 $(get_char $FIRST_DIR $PREV_DIR) >>$TMP

WIDTH=$((MAX_X - MIN_X))

echo $(($(
	cat $TMP | while read Y X CHAR; do
		printf "%8d %8d %c\n" $((Y - MIN_Y)) $((X - MIN_X)) "$CHAR"
	done | LC_ALL=C sort | {
		CY=0
		CX=0
		while read Y X CHAR; do
			while [ $Y -gt $CY ] || [ $X -gt $CX ]; do
				: $((CX += 1))
				[ $CX -gt $WIDTH ] && {
					: $((CX = 0))
					echo
					: $((CY += 1))
				} || echo -n ' '
			done
			echo -n "$CHAR"
			: $((CX += 1))
			[ $CX -gt $WIDTH ] && {
				: $((CX = 0))
				echo
				: $((CY += 1))
			}
		done
	} | sed -E -e "s/(F#*7|L#*J)//g" -e "s/F#*J|L#*7/#/g" -e 's/[^#]*$//g' -e 's/[^#]*\#([^#]*)\#/\1/g' | tr -d '\n' | wc -c
) + $(wc -l <$TMP)))
