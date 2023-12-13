#!/bin/sh

REG=$(mktemp)
printf 's/\.*#{17,}([.$0-9a-f]+)/h\\1/g\n' >>$REG
printf 's/\.*#{16}([.$0-9a-f]+)/g\\1/g\n' >>$REG
for i in $(seq 15 -1 1); do
	printf 's/\.*#{%d}([.$0-9a-f]+)/%x\\1/g\n' $i $i >>$REG
done

my_uniq() {
	CURRENT=
	CURRENT_COUNT=0
	while read N LINE; do
		if [ "$CURRENT" = "$LINE" ]; then
			: $((CURRENT_COUNT += N))
		else
			echo $CURRENT_COUNT "$CURRENT"
			CURRENT_COUNT=$N
			CURRENT=$LINE
		fi
	done
	echo $CURRENT_COUNT "$CURRENT"
}

emulate() {
	B=$1
	S=$2

	sed -E -f $REG | tr -d '.$' | grep -E "^[0-9]+ +$B[#.]*$" |
		sort -k2,2 |
		my_uniq |
		if [ -n "$S" ]; then
			CHAR=$(echo $S | cut -c1)
			if [ "$CHAR" = "?" ]; then
				sed -E 's/^(.*)$/\1#\n\1./g'
			else
				sed -E 's/^(.*)$/\1'"$CHAR"'/g'
			fi | emulate $B $(echo $S | cut -c2-)
		else
			cat
		fi
}

F=$(mktemp)
F2=$(mktemp)

f() {
	OUT_DIR=out
	mkdir -p $OUT_DIR
	find $OUT_DIR -size 0 -delete
	i=0
	processes=0
	while read N A B; do
		[ -t 1 ] && printf "$i\r"
		until [ $(ls -s $OUT_DIR | cut -d\  -f1 | grep '^0$' | wc -l) -lt 20 ]; do
			sleep 0.1
		done
		[ -f $OUT_DIR/"$i" ] || {
			B2=$(printf '%s%*s' "$(echo "$B" | sed -E 's/(.)/(\1/g')" "$(echo -n "$B" | wc -c)" | sed 's/ /)?/g')
			S="$A?$A?$A?$A?$A$"
			(echo "1 " | emulate "$B2" "$S" | grep -E "^[0-9]+ +$B[.]*$" | cut -d\  -f1 >$OUT_DIR/$i) &
			: $((processes += 1))
		}
		: $((i += 1))
	done
	wait
	SUM=0
	for file in $(ls $OUT_DIR/); do
		[ -n "$(cat $OUT_DIR/$file)" ] && : $((SUM += $(cat $OUT_DIR/$file)))
	done
	echo $SUM
	rm -rf $OUT_DIR
}

while read A B; do
	B=$(echo "$B" | sed -e 's/10/a/g' -e 's/11/b/g' -e 's/12/c/g' -e 's/13/d/g' -e 's/14/e/g' -e 's/15/f/g' -e 's/16/g/g' | tr -d ',')
	echo $(echo -n "$A" | wc -c) "$A" "$B$B$B$B$B"
done | f
