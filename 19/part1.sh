#!/bin/sh

SEDF=$(mktemp)

cat <<EOF >$SEDF
s/([a-z]+)\{([^}]+)\}/\1()\n(\nif \2\nfi\n)\n/g
s/,(.[<>])/\nelif \1/g
s/,(.[^=])/\nelse\n\1/g
s/([xmas])([<>])([0-9]+):([ARa-z]+)/[ $\1 \2 \3 ]\nthen\n\4/g
s/([AR]\n)/echo \1/g
s/</-lt/g
s/>/-gt/g
s/\{//g
s/,/\n/g
s/\}/\n[ \$(in) = "A" ] \&\& echo \$((x + m + a + s)) /g
s/in/entrypoint/g
EOF

sed -E -f $SEDF | sh | {
	while read N; do
		: $((TOTAL += N))
	done
	echo $TOTAL
}
