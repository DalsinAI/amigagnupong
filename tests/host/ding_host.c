/* amiga_ding() for the host tests: the bounce's sound as a line on stderr,
 * so a test can count the bounces.
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Pong (gnupong). */
#include <stdio.h>
void amiga_ding(void) { fputs("ding\n", stderr); }
