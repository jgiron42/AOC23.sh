#!/bin/sh

F=$(mktemp)
cat >$F

[ -z "$EXPANSION" ] && EXPANSION=2

WIDTH=$(head <$F -n1 | tr -d '\n' | wc -c)
HEIGHT=$(wc <$F -l)

SEDF=$(mktemp)

echo "s/^(\.{$WIDTH})$/=/g" >>$SEDF
i=0
while [ "$i" -lt $WIDTH ]; do
	MATCH=$(tr <$F -d '\n' | cut -c$((i + 1))- | grep -boE "^(\.(.{$((WIDTH - 1))}|.{,$WIDTH}$))*$" | cut -d\: -f1)
	if [ -n "$MATCH" ]; then
		echo "s/^(.{$((MATCH + i))})(\.)(.*)$/\1I\3/g" >>$SEDF
		: $((i += MATCH))
	fi
	: $((i += 1))
done

COORDS=$(mktemp)

sed -Ef $SEDF <$F |
	grep -nE "#|=" | {
	YOFF=0
	while read LINE; do
		if echo $LINE | grep -q "="; then
			: $((YOFF += 1))
		else
			Y=$(echo $LINE | cut -d\: -f 1)
			echo $LINE | cut -d\: -f2 | fold -w1 | grep -nE '#|I' | {
				XOFF=0
				while read CHAR; do
					if [ $(echo $CHAR | cut -d\: -f2) = "I" ]; then
						: $((XOFF += 1))
					else
						X=$(echo $CHAR | cut -d\: -f 1)
						echo $((XOFF * (EXPANSION - 1) + X)) $((YOFF * (EXPANSION - 1) + Y))
					fi
				done
			}
		fi
	done
} >$COORDS

for i in $(seq $(wc -l <$COORDS)); do
	A=$(sed <$COORDS "$i""q;d")
	tail <$COORDS -n+$((i + 1)) | while read B; do
		echo $A $B
	done
done | while read XA YA XB YB; do
	echo $(((XA > XB ? XA - XB : XB - XA) + (YA > YB ? YA - YB : YB - YA)))
done | {
	SUM=0
	while read n; do
		: $((SUM += n))
	done
	echo $SUM
}
