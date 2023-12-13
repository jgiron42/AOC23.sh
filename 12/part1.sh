#!/bin/sh

get_comb() {
	if [ "$1" = "0" ]; then
		echo
		return
	fi
	if [ ! -f ".comb_$1" ]; then
		get_comb $(($1 - 1)) | sed -E 's/^(.*)$/\1#\n\1./g' >".comb_$1"
	fi
	cat ".comb_$1"
}
sed -E -e 's/([0-9]+)/#{\1}/g' -e 's/,/\\.+/g' |
	while read A B; do
		echo $(echo -n $A | wc -c) $A $B
	done |
	sed -E -e 's/\./\\\\./g' -e 's/\?/[.#]/g' |
	while read N A B; do
		get_comb $N | grep -E "^$A$" | grep -E "^\.*$B\.*$" | wc -l
	done | {
	SUM=0
	while read n; do
		: $((SUM += n))
	done
	echo $SUM
}
