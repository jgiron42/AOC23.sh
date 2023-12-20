#!/bin/sh

F=$(mktemp)

cat >$F

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

parse_line() {
	sed -E -e 's/^([%&]?)([a-z]+) -> ([a-z]+(, [a-z]+)*)$/\1 \2 \3/g' | tr -d ',' | tr ' ' '\n'
}

get_line_of() {
	grep -E "^[%&]?$1 " <$F | parse_line
}

get_childs_of() {
	get_line_of $1 | {
		read
		read
		cat
	}
}

get_parents_of() {
	grep -E " $1" <$F | sed -E 's/[%&]?([a-z]+).*/\1/g'
}

get_number() {
	d=$1
	for p in $(get_parents_of $d); do
		[ "$(get_childs_of $p)" = "$d" ] && current=$p
	done
	RET=0
	while [ "$current" != "broadcaster" ]; do
		: $((RET *= 2))
		get_childs_of $current | grep -q $d && : $((RET += 1))
		current=$(get_parents_of $current | grep -v $d)
	done
	echo $RET
}

for d in $(get_parents_of $(get_parents_of "rx")); do
	get_number $(get_parents_of $d)
done | lcm $(cat)
