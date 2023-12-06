#!/bin/sh

sqrt() {
	OLD=-1
	CURRENT=1
	while [ "$OLD" != "$CURRENT" ]; do
		OLD="$CURRENT"
		: $((CURRENT = (CURRENT + ($1 / CURRENT)) / 2))
	done
	echo $CURRENT
}

f() {
	read T RT
	read D RD

	DELTA=$((T * T - 4 * D))
	RT1=$(((T * 10 - $(sqrt $((DELTA * 100)))) / 2))
	RT2=$(((T * 10 + $(sqrt $((DELTA * 100)))) / 2))
	: $((RT1 /= 10))
	: $((RT2 = RT2 % 10 == 0 ? RT2 / 10 - 1 : RT2 / 10))

	echo $((RT2 - RT1))

	[ -n "$RT" ] && printf "%s\n%s\n" "$RT" "$RD" | f
}

prod() {
	echo $(($(
		tr '\n' '*'
		echo 1
	)))
}

sed -E 's/[^0-9]*([0-9]+ ) */\1/g' | f | prod
