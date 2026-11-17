Pong (gnupong) 0.14 for GFOS
============================

Jeffrey W. Starr's Pong for curses (1999): keep the ball in play with a
paddle of three blocks at the bottom of the screen; every bounce off the
paddle scores a point, and a ball that gets past ends the game.

a and l move the paddle, p pauses (p again goes on), + and - change the
speed, _ slows it right down, q ends the game. The score shows in the
window until a key. From a Shell, -left, -right, -pause, -quit, -faster,
-slower and -realslow choose other keys (pong -left j -right k), -nosound
turns the bounce's sound off, -dumpkeys lists the keys.

What it needs
-------------
GFOS (AmigaOS 3.2 with GFOpenUp) on a 68040 or 68060; no FPU. The game
runs in an 80 x 24 console window: no SDL, no ACGame, no GFOpenGPU. The
bounce's sound is ding.wav through datatypes.library (a WAVE datatype);
without one the game is silent.

How it was ported
-----------------
The game (C++) is built from upstream's release as it is, with our
curses, GFOpenCurses (DalsinAI/gfopencurses, the library our console
ports share). Upstream's clock is kbhit(): a
10 ms select() on the terminal for a key; amiga/pong_amiga.c waits those
10 ms through curses (wgetch with a timeout, dos.library WaitForChar) and
gives the key back for the getch() that follows. The bounce's sound,
sox's play on Unix, is ding.wav loaded once as a datatypes sound object
and triggered (amiga/compat_amiga.c). GFOpenCurses opens the window and
reads the keys.

The one patch, amiga/patches/0001: kbhit() through curses, the sound
through its datatype, and the score shown in the window before it closes
(upstream prints it on the terminal after endwin()).

Tests: tests/host/test_gnupong.sh builds the game on the build machine
over a plain terminal with the Amiga code paths, plays it with scripted
keys and reads back the screen (the paddle, a and l, -right k, the ball
falling on the game's clock, p, q and the score, the window's close,
-dumpkeys), and checks ungetch().

Credits
-------
Pong (c) 1998-1999 Jeffrey W. Starr, GPL-2.0-or-later (COPYING.txt).
Amiga port: Designed, tested and delivered by The AmiCradle Team.
Copyright (c) 2026 AmiCradle Team, GPL-2.0-or-later like Pong.
