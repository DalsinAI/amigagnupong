/* What Pong asked of the Unix tty, through curses (Amiga and host tests):
 *  - amiga_kbhit(): upstream's kbhit() waits 10 ms in select() on stdin
 *    for a key, and the game's clock is that wait; here curses waits the
 *    10 ms (wgetch with a timeout: dos.library WaitForChar on the Amiga)
 *    and gives the key back (ungetch) for the getch() that follows;
 *  - amiga_game_over(): upstream prints the score after endwin(), on the
 *    terminal it ran in; the Amiga's window closes as the game ends, so the
 *    score shows in the window first, until a key.
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Pong (gnupong). */
#include <stdio.h>
#include <string.h>

#include "curses.h"
#include "amiga_prelude.h"

int amiga_kbhit(void)
{
	int c;

	wtimeout(stdscr, 10);
	c = wgetch(stdscr);
	wtimeout(stdscr, -1);
	if (c == ERR) return 0;
	ungetch(c);
	return 1;
}

void amiga_game_over(int score)
{
	char a[64], b[64];
	int w;

	snprintf(a, sizeof a, "  End of Game - Your score: %d  ", score);
	snprintf(b, sizeof b, "  Press a key  ");
	w = (int)strlen(a);
	attrset(A_REVERSE);
	mvaddstr(LINES / 2 - 1, (COLS - w) / 2, a);
	mvaddstr(LINES / 2, (COLS - w) / 2, "");
	{
		int i;
		for (i = 0; i < w; i++) addch(' ');
	}
	mvaddstr(LINES / 2, (COLS - (int)strlen(b)) / 2, b);
	attrset(A_NORMAL);
	flushinp();
	getch();
}
