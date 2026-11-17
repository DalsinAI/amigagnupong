/* Pong's bounce sound on the Amiga: upstream runs sox's play on ding.wav
 * for each bounce off the paddle. Here datatypes.library loads
 * PROGDIR:ding.wav once as a sound object (the WAVE datatype; every
 * decoder is a datatype) and each bounce triggers it (DTM_TRIGGER
 * STM_PLAY), which plays without waiting. No datatype, no sound; -nosound
 * turns it off as upstream's does.
 * Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Pong (gnupong). */
#include <stdlib.h>

#include <exec/types.h>
#include <intuition/classusr.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/soundclass.h>
#include <proto/exec.h>
#include <proto/datatypes.h>

#include "amiga_prelude.h"

struct Library *DataTypesBase;
static Object *ding;
static int tried;

static void ding_end(void)
{
	if (ding) DisposeDTObject(ding);
	ding = NULL;
	if (DataTypesBase) CloseLibrary(DataTypesBase);
	DataTypesBase = NULL;
}

void amiga_ding(void)
{
	if (!tried) {
		tried = 1;
		DataTypesBase = OpenLibrary((CONST_STRPTR)"datatypes.library", 39);
		if (DataTypesBase)
			ding = NewDTObject((APTR)"PROGDIR:ding.wav", DTA_GroupID, GID_SOUND, TAG_DONE);
		atexit(ding_end);
	}
	if (ding) DoDTMethod(ding, NULL, NULL, DTM_TRIGGER, NULL, STM_PLAY, NULL);
}
