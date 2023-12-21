#!/bin/sh

F=$(mktemp)

cat >$F

WIDTH=$(head -n1 <$F | tr -d '\n' | wc -c)
SIZE=$(tr <$F -d '\n' | wc -c)

get_trans() {
	STATE=$1
	FROM=$2
	TIMES=$3
	COST=$4
	PATH_=$5
	[ "$FROM" != "u" -a \( \( "$FROM" != "d" -a "$TIMES" -ge 4 \) -o \( "$FROM" == "d" -a "$TIMES" -lt 10 \) \) -a "$STATE" -gt $WIDTH ] && printf 'printf "%%10d %%s %%s %%08o %%s\\n" %d %s %s $((COST+%d)) ${PATH_}%s\n' $((STATE - WIDTH)) d $([ "$FROM" = d ] && echo $((TIMES + 1)) || echo 1) "$(tr -d '\n' <$F | cut -c $((STATE - WIDTH + 1)))" "u"
	[ "$FROM" != "d" -a \( \( "$FROM" != "u" -a "$TIMES" -ge 4 \) -o \( "$FROM" == "u" -a "$TIMES" -lt 10 \) \) -a "$((STATE + WIDTH))" -lt $SIZE ] && printf 'printf "%%10d %%s %%s %%08o %%s\\n" %d %s %s $((COST+%d)) ${PATH_}%s\n' $((STATE + WIDTH)) u $([ "$FROM" = u ] && echo $((TIMES + 1)) || echo 1) "$(tr -d '\n' <$F | cut -c $((STATE + WIDTH + 1)))" "d"
	[ "$FROM" != "l" -a \( \( "$FROM" != "r" -a "$TIMES" -ge 4 \) -o \( "$FROM" == "r" -a "$TIMES" -lt 10 \) \) -a "$((STATE % WIDTH))" != 0 ] && printf 'printf "%%10d %%s %%s %%08o %%s\\n" %d %s %s $((COST+%d)) ${PATH_}%s\n' $((STATE - 1)) r $([ "$FROM" = r ] && echo $((TIMES + 1)) || echo 1) "$(tr -d '\n' <$F | cut -c $((STATE - 1 + 1)))" "l"
	[ "$FROM" != "r" -a \( \( "$FROM" != "l" -a "$TIMES" -ge 4 \) -o \( "$FROM" == "l" -a "$TIMES" -lt 10 \) \) -a "$((STATE % WIDTH))" != $((WIDTH - 1)) ] && printf 'printf "%%10d %%s %%s %%08o %%s\\n" %d %s %s $((COST+%d)) ${PATH_}%s\n' $((STATE + 1)) l $([ "$FROM" = l ] && echo $((TIMES + 1)) || echo 1) "$(tr -d '\n' <$F | cut -c $((STATE + 1 + 1)))" "r"
}

DIR=$(mktemp -du)
if [ ! -d $DIR ]; then
	echo "compilation of transitions (you have the time to watch mahna mahna about 40 times)"
	for from in u d l r; do
		mkdir -p $DIR/$from
		for times in $(seq 10); do
			mkdir -p $DIR/$from/$times
			for i in $(seq 0 $SIZE); do
				get_trans $i $from $times >$DIR/$from/$times/$i
			done
		done
	done
fi
STATES=$(mktemp)
OLD=$(mktemp)
echo 0 l 1 0 >>$STATES
echo 0 u 1 0 >>$STATES
SWAP=$(mktemp)
SWAP2=$(mktemp)
CHANGES=$(mktemp)
cat >$CHANGES <$STATES
MIN_COST=$(($(cat <$F | tr -d '\n' | sed -E "s/(..).{$((WIDTH - 1))}/\1/g" | fold -w1 | tr '\n' '+')))
while [ $(wc -l <$CHANGES) != 0 ]; do
	while read S FROM TIMES COST PATH_; do
		[ $(($COST)) -ge $MIN_COST ] && continue
		[ $S = $((SIZE - 1)) -a "$TIMES" -ge 4 ] && {
			echo TIMES=$TIMES COST=$((COST)) $PATH_ >&2
			MIN_COST=$((COST))
			continue
		}
		source $DIR/$FROM/$TIMES/$S

	done <$CHANGES >$SWAP
	sort $SWAP | sort -m - $STATES | sort -u -k1,3 >$SWAP2
	cat <$SWAP2 >$STATES
	diff $STATES $OLD | grep '^<' | cut -c2- >$CHANGES
	cat <$STATES >$OLD
done

echo $MIN_COST

rm -rf $DIR
