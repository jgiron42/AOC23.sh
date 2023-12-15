#!/bin/sh

hash() {
	od -A n -t d1 | fold -w5 | {
		RET=0
		while read CHAR; do
			: $((RET += $CHAR))
			: $((RET *= 17))
			: $((RET %= 256))
		done
		echo $RET
	}
}

sum() {
	RET=0
	while read N; do
		: $((RET += N))
	done
	echo $RET
}

DB=$(mktemp -d)

tr ',' '\n' | sed -E -e 's/([a-z]+)-/delete \1/g' -e 's/([a-z]+)\=([0-9]+)/insert \1 \2/g' | while read INS KEY VAL; do
	HASH=$(echo -n $KEY | hash)
	if [ "$INS" = insert ]; then
		mkdir -p $DB/$HASH
		echo $VAL >$DB/$HASH/$KEY
	else
		rm $DB/$HASH/$KEY 2>/dev/null
	fi
done

for BOX in $DB/*; do
	SLOT_INDEX=1
	ls -rt --time creation $BOX | while read SLOT; do
		echo $((($(basename $BOX) + 1) * $SLOT_INDEX * $(cat $BOX/$SLOT)))
		: $((SLOT_INDEX += 1))
	done
done | sum

rm -rf $DB
