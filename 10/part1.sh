#!/bin/sh

CONTENT=$(cat)
WIDTH=$(echo $CONTENT | tr ' ' '\n' | head -n1 | tr -d '\n' | wc -c)
CONTENT="$(printf '%*s' $WIDTH | tr ' ' '.') $CONTENT $(printf '%*s' $WIDTH | tr ' ' '.')"
: $((WIDTH += 2))
CONTENT=.$(echo $CONTENT | sed 's/ /../g').

get_char() {
	echo $CONTENT | cut -c "$(($2 * WIDTH + $1 + 1))"
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
	echo $DIR
	while [ $(get_char $X $Y) != "S" ]; do
		DIR=$(echo "$DIR$(get_char $X $Y)" | sed -E -e 's/U7|DJ|L-/L/g' -e 's/UF|DL|R-/R/g' -e 's/LL|RJ|U\|/U/g' -e 's/LF|R7|D\|/D/g')
		echo $DIR
		case "$DIR" in
		"U") : $((Y -= 1)) ;;
		"D") : $((Y += 1)) ;;
		"L") : $((X -= 1)) ;;
		"R") : $((X += 1)) ;;
		esac
	done
} | wc -l | {
	read N
	echo $((N / 2))
}
