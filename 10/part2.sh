#!/bin/sh

CONTENT=$(cat)
WIDTH=$(echo $CONTENT | tr ' ' '\n' | head -n1 | tr -d '\n' | wc -c)
CONTENT="$(printf '%*s' $WIDTH | tr ' ' '.') $CONTENT $(printf '%*s' $WIDTH | tr ' ' '.')"
: $((WIDTH += 2))
CONTENT=.$(echo $CONTENT | sed 's/ /../g').

get_char() {
	echo $CONTENT | cut -c "$(($2 * WIDTH + $1 + 1))"
}
set_char() {
	#	echo "$(($2 * WIDTH + $1))"
	echo -n $CONTENT | cut -c "-$(($2 * WIDTH + $1))" | tr -d '\n'
	echo -n $3
	echo $CONTENT | cut -c "$(($2 * WIDTH + $1 + 2))-"
}

OFFSET=$(echo $CONTENT | grep -bo S | cut -d\: -f1)

X=$((OFFSET % WIDTH))
Y=$((OFFSET / WIDTH))

DIR=
if [ $(get_char $((X - 1)) $Y) = "L" ] || [ $(get_char $((X - 1)) $Y) = "-" ] || [ $(get_char $((X - 1)) $Y) = "F" ]; then
	DIR="L"
	: $((X -= 1))
elif [ $(get_char $((X + 1)) $Y) = "J" ] || [ $(get_char $((X + 1)) $Y) = "-" ] || [ $(get_char $((X + 1)) $Y) = "7" ]; then
	DIR="R"
	: $((X += 1))
elif [ $(get_char $X $((Y - 1))) = "7" ] || [ $(get_char $X $((Y - 1))) = "|" ] || [ $(get_char $X $((Y - 1))) = "F" ]; then
	DIR="U"
	: $((Y -= 1))
elif [ $(get_char $X $((Y + 1))) = "J" ] || [ $(get_char $X $((Y + 1))) = "|" ] || [ $(get_char $X $((Y + 1))) = "L" ]; then
	DIR="D"
	: $((Y += 1))
fi

{
	IDIR=$DIR
	while [ $(get_char $X $Y) != "S" ]; do
		DIR=$(echo "$DIR$(get_char $X $Y)" | sed -E -e 's/U7|DJ|L-/L/g' -e 's/UF|DL|R-/R/g' -e 's/LL|RJ|U\|/U/g' -e 's/LF|R7|D\|/D/g')
		printf "%05d %05d %c\n" $Y $X $(get_char $X $Y)
		case "$DIR" in
		"U") : $((Y -= 1)) ;;
		"D") : $((Y += 1)) ;;
		"L") : $((X -= 1)) ;;
		"R") : $((X += 1)) ;;
		esac
	done
	printf "%05d %05d %c\n" $Y $X $(echo $IDIR$DIR | sed -E -e 's/LL|RR/-/g' -e 's/UL|RD/L/g' -e 's/RU|DL/F/g' -e 's/UR|LD/J/g' -e 's/LU|DR/7/g' -e 's/UU|DD/|/g')

} | sort | sed -E 's/0*([1-9][0-9]*)/\1/g' | {
	CY=0
	CX=0
	while read Y X CHAR; do
		Y=$((Y))
		X=$((X))
		while [ $Y != $CY ] && [ $X != $CX ]; do
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
} | sed -E -e "s/(F-*7|L-*J)//g" -e "s/F-*J|L-*7/|/g" -e 's/[^|]*$//g' -e 's/[^|]*\|([^|]*)\|/\1/g' | tr -d '\n' | wc -c
