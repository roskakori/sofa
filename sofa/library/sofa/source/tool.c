/* tool.c -- various support routines */

#include "global.h"

#include <ctype.h>
#include <string.h>

#include <rexx/errors.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>

export EIF_INTEGER
pointer_to_integer(EIF_POINTER value)
{
   return (EIF_INTEGER) value;
}

export EIF_POINTER
integer_to_pointer(EIF_INTEGER value)
{
   return (EIF_POINTER) value;
}

/* Same as strdup() (which is not an ANSI C function) */
export char *
clone_string(char *some)
{
   char *result;

   result = (char *) malloc(strlen(some) + 1);
   if (result != NULL) {
      strcpy(result, some);
   }
   return result;
}

/* Allocate `size' bytes using malloc() and set them to 0. */
export void *cmalloc(size_t size)
{
   return calloc(1, size);
}

export struct IntuitionBase *IntuitionBase = NULL;

export void
sofa_die_screaming(EIF_POINTER message)
{
   BOOL intuition_opened = FALSE;
   char *message_text = (char *) message;
   char first_char = message_text[0];

   if (IntuitionBase == NULL) {
      IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 0);
      intuition_opened = (IntuitionBase != NULL);
   }
   if (IntuitionBase != NULL) {
      struct EasyStruct requester =
      {
         sizeof(struct EasyStruct),
         0,
         "Serious problem",
         NULL,
         "Abort"
      };

      requester.es_TextFormat = message;
      message_text[0] = toupper(message_text[0]);
      EasyRequestArgs(NULL, &requester, NULL, NULL);
      message_text[0] = first_char;
      /* TODO: use DisplayAlert() if requester fails */
   } else {
      FPuts(Output(), "serious problem: ");
      FPuts(Output(), message);
      FPutC(Output(), '\n');
      Flush(Output());
   }

   exit(RC_FATAL);
}
