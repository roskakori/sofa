/* test_c_server.c -- Test ARexx server using SimpleRexx */

#include <exec/types.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <rexx/storage.h>
#include <rexx/rxslib.h>
#include <rexx/errors.h>

#include <stdio.h>
#include <string.h>

#include "SimpleRexx.h"

int main(int argc, char *argv[])
{
   AREXXCONTEXT RexxStuff = InitARexx("TEST", "test");
   BOOL quit = FALSE;

   printf("running at port \"%s\" with mask %ld\n",
          ARexxName(RexxStuff), ARexxSignal(RexxStuff));

   do {
      ULONG signals = ARexxSignal(RexxStuff);
      struct RexxMsg *message = NULL;
      STRPTR result = NULL;

      signals = Wait(signals);
      message = GetARexxMsg(RexxStuff);
      while (message != NULL) {
         STRPTR command = NULL;

         printf("message = %p\n", message);

         command = ARG0(message);

         printf("command = %p \"%s\"\n", command, command);

         if (!stricmp(command, "quit")) {
            printf("Quitting.\n");
            quit = TRUE;
         }
         ReplyARexxMsg(RexxStuff, message, result, RC_OK);
         message = GetARexxMsg(RexxStuff);
      }
   }
   while (!quit);

   FreeARexx(RexxStuff);
}

