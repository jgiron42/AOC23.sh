#!/bin/sh

read INS

F=$(mktemp)
cat >$F

STATES=$(mktemp)

grep <$F '^..A' | sed -E 's/^(...) .*$/\1/' >$STATES

TRANS=$(mktemp)
echo ':loop' >$TRANS
grep -v '^..Z' <$F | sed -E 's/^(.{3}) = \((.{3}), (.{3})\)$/s\/^\1L\/\2\/g\ns\/^\1R\/\3\/g/g' >>$TRANS
echo 't loop' >>$TRANS

f() {
	STATE=$1
	I=0
	until echo $STATE | grep -q ZZZ; do
		STATE=$(echo $STATE$INS | sed -f $TRANS)
		: $((I += 1))
	done
	echo $(($I * $(echo -n $INS | wc -c) - $(echo $STATE | fold -w1 | tail -n+4 | wc -l)))
}

f AAA
