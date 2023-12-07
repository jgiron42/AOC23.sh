#!/bin/sh

# a -> five of a kind, b -> four of a kind, c ->full house, d -> three of a kind, e -> two pair, f -> one pair, g -> high card
tag() {
	fold -w1 | sort | tr -d '\n' |
		sed -E -e 's/([0-9AKQJT])\1\1\1\1/g/g' -e 's/([0-9AKQJT])\1\1\1/f/g' -e 's/([0-9AKQJT])\1\1/d/g' -e 's/([0-9AKQJT])\1/b/g' |
		fold -w1 | sort | tr -d '\n' |
		sed -E -e 's/bd/e/g' -e 's/bb/c/g' -e 's/[0-9AKQJT]{5}/a/g' |
		tr -d '0-9AKQJT'
}

echo $(($(
	grep -v '^$' | while read line; do
		echo $line | cut -d\  -f1 | tag
		echo $line | tr 'TJQKA' 'ABCDE'
	done | sort | cut -d\  -f2 | cat -n | sed -E 's/^[^0-9]*([0-9]+)\t+([0-9]+).*$/\1*\2+/g' | tr -d '\n'
	echo 0
)))
