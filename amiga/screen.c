/* The game's console window title, set before its initscr(): GFOpenCurses
 * opens the window titled acurses_title (the program's name otherwise).
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Pong (gnupong). */
#include "curses.h"

#ifndef GAME_TITLE
#define GAME_TITLE "Pong VERSIONMARK"
#endif

__attribute__((constructor)) static void game_screen(void)
{
	acurses_title = GAME_TITLE;
}
