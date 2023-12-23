#!/bin/sh

BUFFER=$(cat)
WIDTH=$(echo $BUFFER | grep -ob ' ' | head -n1 | cut -d\: -f1)
BUFFER=$(echo $BUFFER | tr -d ' ')
SIZE=$(echo -n $BUFFER | wc -c)

DIR=$(mktemp -d)
mkdir -p $DIR
VERTICES=$DIR/vertices
LINKS=$DIR/links
PATH_LIST=$DIR/path_list

move() {
	case "$1" in
	u)
		echo $(($2 - WIDTH))
		;;
	d)
		echo $(($2 + WIDTH))
		;;
	r)
		echo $(($2 + 1))
		;;
	l)
		echo $(($2 - 1))
		;;
	*)
		echo $2
		;;
	esac
}

get_char_at() {
	[ -n "$1" ] && [ "$1" -ge 0 -a "$1" -lt "$SIZE" ] && echo $BUFFER | cut -c $(($1 + 1))
}

dir_from_arrow() {
	echo -n "$1" | tr '^v<>' 'udlr'
}

find_link() {
	POS=$1
	COST=0
	PREV=
	[ "$(get_char_at "$POS")" = "#" ] && return 1
	POS=$(move $(dir_from_arrow $(get_char_at $POS)) $POS)
	NEXT=$1
	while [ "$POS" = "$NEXT" ]; do
		for DIRECTION in u d l r; do
			NEXT=$(move $DIRECTION $POS)
			[ "$NEXT" = "$PREV" ] && continue
			[ "$(dir_from_arrow $(get_char_at $NEXT) | tr 'dulr' 'udrl')" = "$DIRECTION" ] && continue
			case $(get_char_at $NEXT) in
			".")
				PREV=$POS
				POS=$NEXT
				: $((COST += 1))
				break
				;;
			"v" | "^" | "<" | ">")
				PREV=$POS
				POS=$(move $DIRECTION $NEXT)
				: $((COST += 2))
				break 2
				;;
			esac
		done
	done
	echo $POS $COST

}

explore() {
	QUEUE=$(mktemp)
	SWAP=$(mktemp)

	echo 1 d >>$QUEUE
	echo 1 >>$VERTICES
	while [ -s "$QUEUE" ]; do
		while read BEGINNING DIRECTION; do
			if [ $BEGINNING != "1" ]; then
				TMP=$(move $DIRECTION $BEGINNING)
				TMP=$(move $(dir_from_arrow $(get_char_at $TMP)) $TMP)
				COST=2
			else
				TMP=$BEGINNING
				COST=0
			fi
			[ -z "$TMP" ] && continue
			END=$(find_link $TMP)
			[ -z "$END" ] && continue
			: $((COST += $(echo $END | cut -d\  -f2)))
			END=$(echo $END | cut -d\  -f1)
			[ "$END" != "$BEGINNING" ] && {
				echo $BEGINNING $END $COST >>$LINKS
				grep -q "^$END$" <$VERTICES || {
					echo $END >>$VERTICES
					for DIRECTION in u d l r; do
						TRUC="$(dir_from_arrow $(get_char_at $(move $DIRECTION $END)) | tr 'udlr' 'durl')"
						[ -n "$TRUC" -a "$TRUC" != "$DIRECTION" ] && echo $END $DIRECTION
					done
				}
			}
		done <$QUEUE >$SWAP
		cat <$SWAP >$QUEUE
	done
}

print_coords() {
	echo $(($1 % WIDTH)) $(($1 / WIDTH))
}

[ -s $VERTICES ] || explore

>$PATH_LIST

find_path() {
	SWAP=$(mktemp)
	(
		echo -n "0 "
		head -n1 $VERTICES
	) >$SWAP
	>$PATH_LIST
	until cmp -s $SWAP $PATH_LIST; do
		cat <$SWAP >$PATH_LIST
		while read CURRENT_COST LINE; do
			echo $LINE | tr ' ' '\n' | tail -n1 | {
				read LAST
				[ "$LAST" = "$((SIZE - 2))" ] && echo $CURRENT_COST $LINE >&3
				grep "^$LAST " <$LINKS | while read _ DST COST; do
					echo $LINE | grep -Eq "(^| )$DST( |$)" || {
						echo $((CURRENT_COST + COST)) $LINE $DST
					}
				done
			}
		done <$PATH_LIST >$SWAP
	done
} 3>&1

find_path | cut -d\  -f 1 | sort -n | tail -n 1
