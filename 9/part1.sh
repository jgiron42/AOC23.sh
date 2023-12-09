#!/bin/sh

NEW=0
while read LINE; do
	{
		echo $LINE
		until echo $LINE | grep -q '^[0 ]*$'; do
			OLD=""
			LINE=$(echo $LINE | tr ' ' '\n' | while read N; do
				[ -n "$OLD" ] && [ -n "$N" ] && {
					echo $((N - OLD))
				}
				OLD=$N
			done | tr '\n' ' ')
			echo $LINE
		done
	} | tac
	echo
done |
	sed -E 's/^.* (-?[0-9]+)$/\1/g' |
	while read L; do
		if [ -z "$L" ]; then
			echo $NEW
			NEW=0
		else
			: $((NEW = L + NEW))
		fi
	done | {
	SUM=0
	while read N; do
		: $((SUM += N))
	done
	echo $SUM
}
