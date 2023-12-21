#!/bin/sh

STEPS=64
F=$(mktemp)
SEDF=$(mktemp)
SWAP=$(mktemp)

cat >$F

WIDTH=$(head <$F -n1 | tr -d '\n' | wc -c)

cat <<EOF >$SEDF
:loop
s/\.O/NO/g
s/O\./ON/g
s/\.(.{$((WIDTH - 1))})O/N\1O/g
s/O(.{$((WIDTH - 1))})\./O\1N/g
t loop
EOF

do_step() {
	tr -d '\n' | tr 'S' 'O' | sed -E -f $SEDF | tr 'ON' '.O' | fold -w $WIDTH
}

f() {
	if [ "$1" -gt 0 ]; then
		do_step | f $(($1 - 1))
	else
		cat
	fi
}

f <$F $STEPS | tr -d -c 'O' | wc -c

rm $F $SEDF $SWAP
