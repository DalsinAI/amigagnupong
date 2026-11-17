# Pong (gnupong) for GFOS

The AmiCradle Team's port of Jeffrey W. Starr's curses Pong (gnupong 0.14)
to GFOS: AmigaOS 3.2 with GFOpenUp, 68040/68060. It runs in its own 80 x 24
console window, with the bounce's sound through datatypes.library: no SDL,
no ACGame and no GFOpenGPU. It ships as a release archive with an
Installer and as the GFOpenUp part Parts/GnuPong.

Upstream's 0.14 release is fetched at build time and checked
(package/gnupong.lock) and patched (amiga/patches); this repository holds
only the Amiga port. See [AMIGA_PORT.md](AMIGA_PORT.md).

GPL-2.0-or-later, like Pong. Copyright (c) 2026 AmiCradle Team.
