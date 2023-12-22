#!/bin/sh

TMP=$(mktemp -u)
DIR=$(mktemp -d)

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

can_remove() {
	! for X in $(seq $X1 $X2); do
		for Y in $(seq $Y1 $Y2); do
			for Z in $(seq $Z1 $Z2); do
				[ -r $DIR/$((Z + 1))/$Y/$X ] && {
					N2=$(cat "$DIR/$((Z + 1))/$Y/$X")
					[ $N2 = $N ] && continue
					grep -E "^$N2 " <$TMP | {
						#					echo N2: $N2 >&2
						read N Z1 Y1 X1 Z2 Y2 X2
						for X in $(seq $X1 $X2); do
							for Y in $(seq $Y1 $Y2); do
								for Z in $(seq $Z1 $Z2); do
									get_obstacles
								done
							done
						done | sort -u | grep -v "^$N2$" | wc -l
					}
				}
			done
		done
	done | grep -q "^1$"
}

[ -r "$TMP" ] || {
	tr ',~' '  ' | while read X1 Y1 Z1 X2 Y2 Z2; do
		echo $Z1 $Y1 $X1 $Z2 $Y2 $X2
	done | sort -n | cat -n | while read N Z1 Y1 X1 Z2 Y2 X2; do
		while can_fall; do
			: $((Z1 -= 1))
			: $((Z2 -= 1))
		done
		echo $N $Z1 $Y1 $X1 $Z2 $Y2 $X2
		save_pos
	done >$TMP
}
TOTAL=0
while read N Z1 Y1 X1 Z2 Y2 X2; do
	can_remove && : $((TOTAL += 1))
done <$TMP
echo $TOTAL
