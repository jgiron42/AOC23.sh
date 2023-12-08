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
	until echo $STATE | grep -q ..Z; do
		STATE=$(echo $STATE$INS | sed -f $TRANS)
		: $((I += 1))
	done
	echo $(($I * $(echo -n $INS | wc -c) - $(echo $STATE | fold -w1 | tail -n+4 | wc -l)))
}

gcd() {
	A=$1
	B=$2
	while [ "$A" != "$B" ]; do
		if [ "$A" -lt "$B" ]; then
			: $((B -= A * 1000 < B ? A * 1000 : A))
		else
			: $((A -= B))
		fi
	done
	echo $A
}

lcm() {
	if [ -n "$3" ]; then
		A=$1
		shift
		lcm $A $(lcm $@)
	else
		echo $(($1 * ($2 / $(gcd $1 $2))))
	fi
}

lcm $(grep <$F -E '^..A' | sed -E 's/^(..A).*/\1/g' | while read S; do
	f $S
done | tr '\n' ' ')
