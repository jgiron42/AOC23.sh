#!/bin/sh

F=$(mktemp)

sed -E 's/^|$/  /g' >$F
SED=$(mktemp)

WIDTH=$(head <$F -n1 | tr -d '\n' | wc -c)

#     v
# A:  \h
#
#
# B: h\
#     v
#
#
# C:  /h
#     v
#
#     v
# D: h/
#
#
#     v
# E:  |
#     v
#
#     v
# F: h|
#     v
#
#     v
# G:  |h
#     v
#
#
# H: h-h
#
#
# I: h-h
#     v
#
#     v
# J: h-h
#
#     v
# K: h+h
#     v
#

TOP='[vcBCEFGI]'
BOT='[vcADEFGJ]'
LEFT='[hcACGHIJ]'
RIGHT='[hcBDFHIJ]'

cat >$SED <<EOF
:loop
s/($TOP.{$((WIDTH - 1))})\.|\.(.{$((WIDTH - 1))}$BOT)/\1v\2/g
s/($TOP.{$((WIDTH - 1))})h|h(.{$((WIDTH - 1))}$BOT)/\1c\2/g

s/($LEFT)\.|\.($RIGHT)/\1h\2/g
s/($LEFT)v|v($RIGHT)/\1c\2/g

s/($TOP.{$((WIDTH - 1))})\\\\|\\\\($RIGHT)/\1A\2/g

s/($LEFT)\\\\|\\\\(.{$((WIDTH - 1))}$BOT)/\1B\2/g

s/\/($RIGHT|.{$((WIDTH - 1))}$BOT)/C\1/g

s/($LEFT|$TOP.{$((WIDTH - 1))})\//\1D/g

s/($TOP.{$((WIDTH - 1))})\||\|(.{$((WIDTH - 1))}$BOT)/\1E\2/g

s/($LEFT)[|E]/\1F/g

s/[|E]($RIGHT)/G\1/g

s/($LEFT)-|-($RIGHT)/\1H\2/g

s/[H-](.{$((WIDTH - 1))}$BOT)/I\1/g

s/($TOP.{$((WIDTH - 1))})[-H]/\1J/g

s/($TOP.{$((WIDTH - 1))})[BCI]/\1c/g 
s/[ADJ](.{$((WIDTH - 1))}$BOT)/c\1/g
s/($LEFT)[ACG]/\1c/g
s/[BDF]($RIGHT)/c\1/g

t loop
EOF

tr <$F -d '\n' | sed 's/^  / h/g' | tee /dev/stderr | sed -Ef $SED | sed 's/^ h/  /g' | fold -w $WIDTH | tee /dev/stderr | tr -c -d 'A-Jhvc' | wc -c
