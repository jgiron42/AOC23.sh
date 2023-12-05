#!/bin/sh

F=$(mktemp)
F2=$(mktemp)
F3=$(mktemp)
cat >$F
cat $F | head -n1 | cut -d\: -f2 | tr ' ' '\n' | grep -v '^$' | {
	while read seed; do
		cat <$F >$F2
		export seed
		while [ "$(wc -w <$F2)" -gt 0 ]; do
			grep <$F2 -A1000 -m1 -E '^$' | tail -n+3 >$F3
			seed=$(grep <$F3 -B1000 -m1 -E '^$' | {
				while read B A SIZE; do
					[ $((seed >= A && seed < A + SIZE)) = "1" ] && {
						: $((seed = seed - A + B))
						break
					}
				done
				echo $seed
			})
			cat <$F3 >$F2
		done
		echo $seed
	done
} | sort -n | head -n1
