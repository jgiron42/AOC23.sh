#!/bin/sh

STEPS=26501365
F=$(mktemp)
SEDF=$(mktemp)

cat >$F

WIDTH=$(head <$F -n1 | tr -d '\n' | wc -c)

cat <<EOF >$SEDF
:loop
s/\.O/OO/g
s/O\./OO/g
s/\.(.{$((WIDTH - 1))})O/O\1O/g
s/O(.{$((WIDTH - 1))})\./O\1O/g
t loop
EOF

get_diamonds() {
	for i in $(seq $WIDTH); do
		read LINE
		if [ "$i" -le "$((WIDTH / 2))" ]; then
			BEGIN=$((WIDTH / 2 - i + 2))
			END=$((WIDTH / 2 + i))
		else
			BEGIN=$((WIDTH / 2 - ($WIDTH - i) + 1))
			END=$((WIDTH / 2 + (WIDTH - i) + 1))
		fi
		printf "%*s%*s\n" $END "$(echo $LINE | cut -c$BEGIN-$END)" "$((WIDTH / 2 + 1 - i))"
		if [ "$BEGIN" -gt 1 ]; then
			printf "%-*s%s\n" $END "$(echo $LINE | cut -c1-$((BEGIN - 1)))" "$(echo $LINE | cut -c$((END + 1))-$WIDTH)" >&3
		else
			printf "%*s\n" $WIDTH " " >&3
		fi
	done
} 3>&3

A=$(mktemp)
B=$(mktemp)

tr <$F -d '\n' | tr 'S' 'O' | sed -E -f $SEDF | fold -w $WIDTH | get_diamonds >$A 3>$B

A1=$(cat $A | tr -d '\n' | sed -E 's/(.)(.|$)/\1 /g' | tr -d -c 'O' | wc -c)
A2=$(cat $A | tr -d '\n' | sed -E 's/(.)(.|$)/ \2/g' | tr -d -c 'O' | wc -c)

B1=$(cat $B | tr -d '\n' | sed -E 's/(.)(.|$)/\1 /g' | tr -d -c 'O' | wc -c)
B2=$(cat $B | tr -d '\n' | sed -E 's/(.)(.|$)/ \2/g' | tr -d -c 'O' | wc -c)

N=$((((STEPS - (WIDTH - 1) / 2) / WIDTH) * 2 + 1))

: $((NA1 = (N / 2) % 2 == 0 ? (N / 2 + 1) * (N / 2 + 1) : (N / 2) * (N / 2)))
: $((NA2 = (N / 2) % 2 == 1 ? (N / 2 + 1) * (N / 2 + 1) : (N / 2) * (N / 2)))

: $((NB = (N * N) / 2))

if [ $((STEPS % 2)) = "0" ]; then
	echo $((NA1 * A1 + NA2 * A2 + NB / 2 * (B1 + B2)))
else
	echo $((NA1 * A2 + NA2 * A1 + NB / 2 * (B2 + B1)))
fi

rm $F $SEDF $A $B
