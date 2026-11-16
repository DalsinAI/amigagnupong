/* Included before Pong's pong.cpp in the Amiga build and the host tests
 * (-include): the 1999 C++ it is written in (cout without std::), and the
 * port's three calls that stand in for what Unix gave it
 * (amiga/pong_amiga.c, amiga/compat_amiga.c).
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Pong (gnupong). */
#ifndef AMIGA_PRELUDE_H
#define AMIGA_PRELUDE_H
#ifdef __cplusplus
#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;
extern "C" {
#endif
/* a key waiting? (kbhit's select() on the tty, 10 ms) */
int amiga_kbhit(void);
/* the bounce's sound: ding.wav beside the program (sox's play on Unix) */
void amiga_ding(void);
/* the score in the window, which closes as the game ends */
void amiga_game_over(int score);
#ifdef __cplusplus
}
#endif
#endif
