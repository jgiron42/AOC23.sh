#!/bin/sh

SUM=0
NUMBER="(one|two|three|four|five|six|seven|eight|nine|ten|[0-9])"

substitute_words() {
	sed \
		-e 's/one/1/g' \
		-e 's/two/2/g' \
		-e 's/three/3/g' \
		-e 's/four/4/g' \
		-e 's/five/5/g' \
		-e 's/six/6/g' \
		-e 's/seven/7/g' \
		-e 's/eight/8/g' \
		-e 's/nine/9/g'
}

while read line; do
	L=$(echo $line | grep -oE "$NUMBER.*" | sed -E "s/$NUMBER.*/\1/" | substitute_words)
	R=$(echo $line | grep -oE ".*$NUMBER" | sed -E "s/.*$NUMBER/\1/" | substitute_words)
	[ -n "$L$R" ] && : $((SUM = SUM + $L$R))
done

echo "$SUM"
