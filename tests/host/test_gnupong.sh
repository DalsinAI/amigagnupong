#!/bin/sh
# Host tests for the Amiga port of Pong (gnupong): upstream's game
# (amiga/patches applied, __amigaos__ set, so the Amiga's code paths are
# the ones built) with amiga/curses.c over a plain terminal
# (tests/host/console_host.c), played with scripted keys; tests/host/vt.py
# reads back the screen as the Amiga's console would show it:
#  - ungetch: a key given back comes first, flushinp drops it;
#  - the paddle (###) at the bottom, in the middle; l and a move it, and
#    -left/-right choose other keys;
#  - the ball (O) falls from the top while no key comes (the 10 ms waits
#    through curses are the game's clock);
#  - p pauses until p again; q ends the game and the score shows in the
#    window until a key; the window's close ends it too;
#  - -dumpkeys lists the keys (C++ iostream after endwin).
# Needs a C and a C++ compiler and python3; skipped without them.
#   UP=/path/to/gnupong (patched) sh tests/host/test_gnupong.sh
# Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Pong (gnupong).
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/../.." && pwd)
UP=${UP:?UP=upstream source}
CC=${HOSTCC:-cc}
CXX=${HOSTCXX:-c++}
command -v "$CC" >/dev/null 2>&1 && command -v "$CXX" >/dev/null 2>&1 ||
    { echo "host tests: skipped (no C or C++ compiler)"; exit 0; }
T=$(mktemp -d "${TMPDIR:-/tmp}/gnupong-host.XXXXXX")
[ -n "${TEST_KEEP:-}" ] || trap 'rm -rf "$T"' EXIT INT TERM
cd "$ROOT"

MINE="-std=gnu99 -Wall -Werror -D_XOPEN_SOURCE=600 -D_DEFAULT_SOURCE -Iamiga/include -Iamiga"
for f in curses keys pong_amiga; do $CC $MINE -c -o "$T/$f.o" "amiga/$f.c"; done
$CC $MINE -c -o "$T/con.o" tests/host/console_host.c
$CC $MINE -c -o "$T/ding.o" tests/host/ding_host.c
$CXX -fpermissive -w -D__amigaos__ -include amiga/include/amiga_prelude.h -Iamiga/include -Iamiga \
    -c -o "$T/pong.o" "$UP/pong.cpp"
$CXX -o "$T/pong" "$T/pong.o" "$T/curses.o" "$T/keys.o" "$T/pong_amiga.o" "$T/con.o" "$T/ding.o"

fails=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fails=$((fails + 1)); }

cat > "$T/units.c" <<'C'
#include <stdio.h>
#include "curses.h"
int main(void)
{
	int bad = 0, c;
	initscr();
	ungetch('x'); ungetch('y');
	if ((c = getch()) != 'y') { printf("first: %d\n", c); bad = 1; }
	if ((c = getch()) != 'x') { printf("second: %d\n", c); bad = 1; }
	ungetch('z'); flushinp();
	timeout(0);
	if ((c = getch()) != ERR) { printf("after flushinp: %d\n", c); bad = 1; }
	endwin();
	return bad;
}
C
$CC $MINE -o "$T/units" "$T/units.c" "$T/curses.o" "$T/keys.o" "$T/con.o"
if sleep 1 | "$T/units" > "$T/units.out"; then ok "ungetch: last in, first out; flushinp drops"; else bad "ungetch"; cat "$T/units.out"; fi

play() {	# keys (printf format), output, [args]
    keys=$1; out=$2; shift 2
    (cd "$T" && printf "$keys" | timeout 30 ./pong "$@" > "$out" 2> "$out.err")
}
row() {		# output, row (1-based): that line of the screen
    python3 "$HERE/vt.py" "$1" | sed -n "${2}p"
}
col() {		# the column (0-based) of the paddle's middle on row 23
    row "$1" 23 | awk '{ i = index($0, "###"); print i ? i : -1 }'
}

if play '' "$T/start.out"; then ok "the window's close ends the game"; else bad "the end of the input did not end it"; fi
[ "$(col "$T/start.out")" = 40 ] && ok "the paddle in the middle at the bottom" || bad "paddle at $(col "$T/start.out")"
play 'lll' "$T/right.out"
[ "$(col "$T/right.out")" = 43 ] && ok "l moves the paddle right" || bad "l: paddle at $(col "$T/right.out")"
play 'aa' "$T/left.out"
[ "$(col "$T/left.out")" = 38 ] && ok "a moves it left" || bad "a: paddle at $(col "$T/left.out")"
play 'kk' "$T/keys.out" -left j -right k
[ "$(col "$T/keys.out")" = 42 ] && ok "-right k chooses another key" || bad "-right k: paddle at $(col "$T/keys.out")"

# the ball falls while no key comes: 0.25 s is about five steps from row 5
(cd "$T" && sleep 0.25 | timeout 30 ./pong > "$T/ball.out" 2>/dev/null) || true
by=$(python3 "$HERE/vt.py" "$T/ball.out" | awk '/O/ { print NR - 1; exit }')
if [ -n "$by" ] && [ "$by" -gt 6 ] && [ "$by" -lt 20 ]; then ok "the ball falls on the game's clock (row $by)"; else bad "the ball: row ${by:-none}"; python3 "$HERE/vt.py" "$T/ball.out"; fi
want() { name=$1; out=$2; shift 2
    if python3 "$HERE/vt.py" "$out" "$@" > "$T/vt.txt"; then ok "$name"; else bad "$name"; cat "$T/vt.txt"; fi; }
play 'q' "$T/quit.out"
want "q: the score in the window until a key" "$T/quit.out" --want "End of Game - Your score: 0" --want "Press a key"
play 'pq' "$T/paused.out"
if python3 "$HERE/vt.py" "$T/paused.out" | grep -q "End of Game"; then bad "p did not pause"; else ok "p pauses: q is not taken"; fi
play 'ppq' "$T/unpaused.out"
want "p again goes on: q ends it" "$T/unpaused.out" --want "End of Game"
play '' "$T/dump.out" -dumpkeys
if grep -q "Right	l	Left	a" "$T/dump.out" && grep -q "Quit	q" "$T/dump.out"; then ok "-dumpkeys lists the keys"; else bad "-dumpkeys"; cat "$T/dump.out"; fi

if [ "$fails" = 0 ]; then echo "host tests: all passed"; else echo "host tests: $fails failed"; exit 1; fi
