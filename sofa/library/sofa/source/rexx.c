/* rexx.c -- Rexx server and client functions. */

#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "global.h"

#include <exec/memory.h>
#include <dos/dos.h>

#include <sofa/assert.h>
#include <sofa/rexx.h>
#include <sofa/resource.h>

#include <proto/exec.h>
#include <proto/rexxsyslib.h>

/* Debugging */
#if 0
#define D(x) x
#define bug printf
#else
#define D(x)                    /* nothing */
#endif

/*--------------------------------------------------------------------------
 * ARexx global variables
 *------------------------------------------------------------------------*/

struct Library *RexxSysBase = NULL;

export struct tracked_resource_kind *rexx_server_kind = NULL;

/*--------------------------------------------------------------------------
 * ARexx client
 *------------------------------------------------------------------------*/

static char *command_result = NULL;

export EIF_POINTER
rexx_client_last_result(void)
{
	return (EIF_POINTER) command_result;
}

/* Should be called after `rexx_client_last_result' to release the memory
 * allocated for `command_result' in `rexx_client_send_command'. */
export void
rexx_client_dispose_last_result(void)
{
	free(command_result);
	command_result = NULL;
}

/* Send `command' to ARexx port `portname', store possible
 * RESULT in `command_result' and return RC. */
export EIF_INTEGER
rexx_client_send_command(char *portname, char *command)
{
	struct MsgPort *reply_port = NULL;
	struct MsgPort *rexx_port = NULL;
	struct RexxMsg *rexx_message = NULL;
	EIF_INTEGER rc = RC_FATAL;

	require(RexxSysBase != NULL);

	command_result = NULL;

	if (reply_port = CreateMsgPort()) {
		BOOL sent = FALSE;

		/* Send message */
		Forbid();                 /* TODO: move Forbid/FindPort after CreateRexxMsg */
		if (rexx_port = FindPort(portname)) {
			if (rexx_message = CreateRexxMsg(reply_port, NULL, NULL)) {
				if (rexx_message->rm_Args[0] = CreateArgstring(command, (ULONG) strlen(command))) {
					rexx_message->rm_Action = RXCOMM | RXFF_RESULT;
					PutMsg(rexx_port, &rexx_message->rm_Node);
					sent = TRUE;
				} else {
					D(bug("CreateArgstring() failed\n"));
					rc = ARexx_create_argument;
				}
			} else {
				D(bug("CreateRexxMsg() failed\n"));
				rc = ARexx_create_message;
			}
		} else {
			D(bug("FindPort(\"%s\") failed\n", portname));
			rc = ARexx_find_port;
		}
		Permit();

		/* Wait for result */
		if (sent) {
			do {
				WaitPort(reply_port);
				if (rexx_message = (struct RexxMsg *) GetMsg(reply_port)) {
					rc = rexx_message->rm_Result1;
					if (rc == RC_OK) {
						STRPTR result2 = (STRPTR) rexx_message->rm_Result2;

						if (result2) {
							ULONG length = strlen(result2);
							command_result = malloc((size_t) length + 1);
							if (command_result) {
								strcpy(command_result, result2);
							} else {
								D(bug("malloc(\"%ld\") failed\n", length));
								rc = ARexx_malloc;
							}
						}
					}
				}
			}
			while (!rexx_message);
		}
		/* Cleanup */
		if (rexx_message) {
			if (rexx_message->rm_Result1 == RC_OK) {
				if (rexx_message->rm_Result2) {
					DeleteArgstring((UBYTE *) rexx_message->rm_Result2);
				}
			}
			if (ARG0(rexx_message)) {
				DeleteArgstring((UBYTE *) ARG0(rexx_message));
			}
			DeleteRexxMsg(rexx_message);
		}
		DeleteMsgPort(reply_port);
	} else {
		D(bug("CreateMsgPort() failed\n"));
	}

	return rc;
}

/*--------------------------------------------------------------------------
 * ARexx server (Implementation)
 *
 * Based on SimpleRexx by Michael Sinz (aminet:util/rexx/SimpleRexx.lha)
 *
 * NOTE: The style of the code below sucks. Partially, because SimpleRexx
 *       was done when there were no decent C compilers around and the
 *       includes were a chaos, partially because I didn't bother to fix
 *       all this, and partially because the prototypes are now conformant
 *       to the small amount of types available to Eiffel (ULONG is gone).
 *
 * Major differences to SimpleRexx are:
 *
 * - moved RexxSysBase from struct ARexxContext to global
 * - removed opening and closing of RexxSysBase; this now must be done
 *   by autoinit
 * - removed reentrant feature (because it relies on #pragma not supported
 *   by all C compilers)
 * - removed `register' keywords to make code more legible
 * - fixed some violent pointer/int conversion stuff that made dcc choke
 *------------------------------------------------------------------------*/

/* Result of `GetARexxMsg' if there was an error */
#define  REXX_RETURN_ERROR ((struct RexxMsg *)-1L)

/*
 * This function returns the port name of your ARexx port.
 * It will return NULL if there is no ARexx port...
 *
 * This string is *READ ONLY*  You *MUST NOT* modify it...
 */
static char *
ARexxName(struct ARexxContext *RexxContext)
{
	char *tmp = NULL;

	if (RexxContext)
		tmp = RexxContext->PortName;
	return (tmp);
}

/*
 * This function returns the signal mask that the Rexx port is
 * using.  It returns NULL if there is no signal...
 *
 * Use this signal bit in your Wait() loop...
 */
static ULONG
ARexxSignal(struct ARexxContext *RexxContext)
{
	ULONG tmp = 0;

	if (RexxContext)
		tmp = 1L << (RexxContext->ARexxPort->mp_SigBit);
	return (tmp);
}

/*
 * This function returns a structure that contains the commands sent from
 * ARexx...  You will need to parse it and return the structure back
 * so that the memory can be freed...
 *
 * This returns NULL if there was no message...
 */
static struct RexxMsg *
GetARexxMsg(struct ARexxContext *RexxContext)
{
	struct RexxMsg *tmp = NULL;
	short flag;

	if (RexxContext)
		if (tmp = (struct RexxMsg *) GetMsg(RexxContext->ARexxPort)) {
			if (tmp->rm_Node.mn_Node.ln_Type == NT_REPLYMSG) {
				/*
				 * If we had sent a command, it would come this way...
				 *
				 * Since we don't in this simple example, we just throw
				 * away anything that looks "strange"
				 */
				flag = FALSE;
				if (tmp->rm_Result1)
					flag = TRUE;

				/*
				 * Free the arguments and the message...
				 */
				DeleteArgstring(tmp->rm_Args[0]);
				DeleteRexxMsg(tmp);
				RexxContext->Outstanding -= 1;

				/*
				 * Return the error if there was one...
				 */
				tmp = flag ? REXX_RETURN_ERROR : NULL;
			}
		}
	return (tmp);
}

/*
 * Use this to return a ARexx message...
 *
 * If you wish to return something, it must be in the RString.
 * If you wish to return an Error, it must be in the Error.
 * If there is an error, the RString is ignored.
 */
static void
ReplyARexxMsg(struct ARexxContext *RexxContext, struct RexxMsg *rmsg, char *RString, EIF_INTEGER Error)
{
	if (RexxContext) {
		if (rmsg) {
			if (rmsg != REXX_RETURN_ERROR) {
				rmsg->rm_Result2 = 0;
				if (!(rmsg->rm_Result1 = Error)) {
					/*
					 * if you did not have an error we return the string
					 */
					if (rmsg->rm_Action & (1L << RXFB_RESULT)) {
						if (RString) {
							D(bug("result=`%s'\n", RString));
							rmsg->rm_Result2 = (LONG) CreateArgstring(RString,
																	 (LONG) strlen(RString));
						}
					}
				}
				/*
				 * Reply the message to ARexx...
				 */
				ReplyMsg((struct Message *) rmsg);
			}
		}
	}
}

/*
 * This function will set an error string for the ARexx
 * application in the variable defined as <appname>.LASTERROR
 *
 * Note that this can only happen if there is an ARexx message...
 *
 * This returns TRUE if it worked, FALSE if it did not...
 */
static BOOL
SetARexxLastError(struct ARexxContext *RexxContext, struct RexxMsg *rmsg,
						char *ErrorString)
{
	BOOL OkFlag = FALSE;

	if (RexxContext)
		if (rmsg)
			if (CheckRexxMsg((struct Message *) rmsg)) {
				/*
				 * Note that SetRexxVar() has more than just a TRUE/FALSE
				 * return code, but for this "basic" case, we just care if
				 * it works or not.
				 */
				if (!SetRexxVar((struct Message *) rmsg, RexxContext->ErrorName, ErrorString,
									 (long) strlen(ErrorString))) {
					OkFlag = TRUE;
				}
			}
	return (OkFlag);
}

/*
 * This function will send a string to ARexx...
 *
 * The default host port will be that of your task...
 *
 * If you set StringFile to TRUE, it will set that bit for the message...
 *
 * Returns TRUE if it send the message, FALSE if it did not...
 */
static BOOL
SendARexxMsg(struct ARexxContext *RexxContext, char *RString,
				 BOOL StringFile)
{
	struct MsgPort *RexxPort;
	struct RexxMsg *rmsg;
	BOOL flag = FALSE;

	if (RexxContext)
		if (RString) {
			if (rmsg = CreateRexxMsg(RexxContext->ARexxPort,
											 RexxContext->Extension,
											 RexxContext->PortName)) {
				rmsg->rm_Action = RXCOMM | (StringFile ?
													 (1L << RXFB_STRING) : 0);
				if (rmsg->rm_Args[0] = CreateArgstring(RString,
																	(LONG) strlen(RString))) {
					/*
					 * We need to find the RexxPort and this needs
					 * to be done in a Forbid()
					 */
					Forbid();
					if (RexxPort = FindPort(RXSDIR)) {
						/*
						 * We found the port, so put the
						 * message to ARexx...
						 */
						PutMsg(RexxPort, (struct Message *) rmsg);
						RexxContext->Outstanding += 1;
						flag = TRUE;
					} else {
						/*
						 * No port, so clean up...
						 */
						DeleteArgstring(rmsg->rm_Args[0]);
						DeleteRexxMsg(rmsg);
					}
					Permit();
				} else
					DeleteRexxMsg(rmsg);
			}
		}
	return (flag);
}

/*
 * This function closes down the ARexx context that was opened
 * with InitARexx...
 */
static void
FreeARexx(struct ARexxContext *RexxContext)
{
	struct RexxMsg *rmsg;

	if (RexxContext) {
		/*
		 * Clear port name so it can't be found...
		 */
		RexxContext->PortName[0] = '\0';

		/*
		 * Clean out any outstanding messages we had sent out...
		 */
		while (RexxContext->Outstanding) {
			WaitPort(RexxContext->ARexxPort);
			while (rmsg = GetARexxMsg(RexxContext)) {
				if (rmsg != REXX_RETURN_ERROR) {
					/*
					 * Any messages that come now are blown
					 * away...
					 */
					SetARexxLastError(RexxContext, rmsg,
											"99: Port Closed!");
					ReplyARexxMsg(RexxContext, rmsg,
									  NULL, 100);
				}
			}
		}

		/*
		 * Clean up the port and delete it...
		 */
		if (RexxContext->ARexxPort) {
			while (rmsg = GetARexxMsg(RexxContext)) {
				/*
				 * Any messages that still are coming in are
				 * "dead"  We just set the LASTERROR and
				 * reply an error of 100...
				 */
				SetARexxLastError(RexxContext, rmsg,
										"99: Port Closed!");
				ReplyARexxMsg(RexxContext, rmsg, NULL, 100);
			}
			DeletePort(RexxContext->ARexxPort);
		}
		/*
		 * Free the memory of the RexxContext
		 */
		FreeMem(RexxContext, sizeof(struct ARexxContext));
	}
}

/*
 * This routine initializes an ARexx port for your process
 * This should only be done once per process.  You must call it
 * with a valid application name and you must use the handle it
 * returns in all other calls...
 *
 * NOTE:  The AppName should not have spaces in it...
 *        Example AppNames:  "MyWord" or "FastCalc" etc...
 *        The name *MUST* be less that 16 characters...
 *        If it is not, it will be trimmed...
 *        The name will also be UPPER-CASED...
 *
 * NOTE:  The Default file name extension, if NULL will be
 *        "rexx"  (the "." is automatic)
 */
static struct ARexxContext *
InitARexx(char *AppName, char *Extension)
{
	struct ARexxContext *RexxContext = NULL;
	short loop;
	short count;
	char *tmp;

	RexxContext = AllocMem(sizeof(struct ARexxContext), MEMF_PUBLIC | MEMF_CLEAR);
	if (RexxContext) {
		if (RexxSysBase) {

			/*
			 * Set up the extension...
			 */
			if (!Extension)
				Extension = "rexx";
			tmp = RexxContext->Extension;
			for (loop = 0; (loop < 7) && (Extension[loop]); loop++) {
				*tmp++ = Extension[loop];
			}
			*tmp = '\0';

			/*
			 * Set up a port name...
			 *
			 * This is <appname>.<#>
			 */
			tmp = RexxContext->PortName;
			for (loop = 0; (loop < 16) && (AppName[loop]); loop++) {
				*tmp++ = toupper(AppName[loop]);
			}
			*tmp++ = '.';          /* append dot to basename */
			*tmp = '\0';

			/*
			 * Set up the last error RVI name...
			 *
			 * This is <appname>.LASTERROR
			 */
			strcpy(RexxContext->ErrorName, RexxContext->PortName);
			strcat(RexxContext->ErrorName, ".LASTERROR");

			/* We need to make a unique port name... */
			Forbid();
			for (count = 1, RexxContext->ARexxPort = (VOID *) 1;
				  RexxContext->ARexxPort; count++) {
				stci_d(tmp, count);
				RexxContext->ARexxPort =
					FindPort(RexxContext->PortName);
			}
			RexxContext->ARexxPort =
				CreatePort(RexxContext->PortName, 0);
			Permit();
		}
		if ((!(RexxSysBase))
			 || (!(RexxContext->ARexxPort))) {
			FreeARexx(RexxContext);
			RexxContext = NULL;
		}
	}

	return (RexxContext);
}

/*--------------------------------------------------------------------------
 * ARexx server (Eiffel interface)
 *------------------------------------------------------------------------*/

static void
rexx_server_dispose(void * context)
{
	FreeARexx((struct ARexxContext *) context);
}

export EIF_POINTER
rexx_server_make(EIF_POINTER base_name, EIF_POINTER suffix)
{
	EIF_POINTER context = (EIF_POINTER) InitARexx((char *) base_name, (char *) suffix);

	if (context != NULL) {
		if (tracked_sofa_resource_make((struct resource *) context, rexx_server_kind) == NULL) {
			context = NULL;
		}
	}

	return context;
}

export void
rexx_server_close(EIF_POINTER context)
{
	rexx_server_dispose((struct ARexxContext *) context);
}

export EIF_INTEGER
rexx_server_signal_mask(EIF_POINTER context)
{
	return (EIF_INTEGER) ARexxSignal((struct ARexxContext *) context);
}

export EIF_POINTER
rexx_server_name(EIF_POINTER context)
{
	return (EIF_POINTER) ARexxName((struct ARexxContext *) context);
}

export EIF_BOOLEAN
rexx_server_command(EIF_POINTER context, EIF_POINTER command)
{
	return (EIF_BOOLEAN) SendARexxMsg((struct ARexxContext *) context, (char *) command, FALSE);
}

export EIF_BOOLEAN
rexx_server_script(EIF_POINTER context, EIF_POINTER script)
{
	return (EIF_BOOLEAN) SendARexxMsg((struct ARexxContext *) context, (char *) script, TRUE);
}

export EIF_POINTER
rexx_server_get_message(EIF_POINTER context)
{
	return (EIF_POINTER) GetARexxMsg((struct ARexxContext *) context);
}

export EIF_BOOLEAN
rexx_server_is_message_in_error(EIF_POINTER message)
{
	return (EIF_BOOLEAN) (((struct RexxMsg *) message) == REXX_RETURN_ERROR);
}

export void
rexx_server_reply_message(EIF_POINTER context, EIF_POINTER message, EIF_POINTER result, EIF_INTEGER error)
{
	ReplyARexxMsg((struct ARexxContext *) context, (struct RexxMsg *) message, (char *) result, error);
}

export EIF_BOOLEAN
rexx_server_set_last_error(EIF_POINTER context, EIF_POINTER message, EIF_POINTER description)
{
	return (EIF_BOOLEAN) SetARexxLastError((struct ARexxContext *) context, (struct RexxMsg *) message, (char *) description);
}

export void
rexx_server_wait(EIF_POINTER context)
{
	(void) Wait(((ULONG) rexx_server_signal_mask(context)) | SIGBREAKF_CTRL_C);
}

export EIF_POINTER
rexx_server_item(EIF_POINTER message)
{
	return ((EIF_POINTER) ARG0(((struct RexxMsg*) message)));
	/* TODO: handle functions in ARG0...ARG15 */
}


/*--------------------------------------------------------------------------
 * ARexx (general)
 *------------------------------------------------------------------------*/

export EIF_BOOLEAN
rexx_make(void)
{
	require(RexxSysBase == NULL);

	RexxSysBase = OpenLibrary("rexxsyslib.library", 0);
	if (RexxSysBase != NULL) {
		rexx_server_kind = resource_kind_make("rexx server", rexx_server_dispose);
		if (rexx_server_kind != NULL) {
			tracked_sofa_resource_make(RexxSysBase, library_kind);
		} else {
			CloseLibrary(RexxSysBase);
			RexxSysBase = NULL;
		}
	}
	return (EIF_BOOLEAN) (RexxSysBase != NULL);
}

export EIF_INTEGER
rexx_library_version(void)
{
	return (EIF_INTEGER) RexxSysBase->lib_Version;
}


