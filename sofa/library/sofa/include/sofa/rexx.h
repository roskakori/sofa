/* rexx.h -- Sofa rexx server and client functions */
#ifndef  SOFA_REXX_H
#define  SOFA_REXX_H

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/ports.h>

#include <rexx/storage.h>
#include <rexx/rxslib.h>
#include <rexx/errors.h>
#include <rexx/rxslib.h>

/* Error codes */
#define ARexx_find_port (-1)
#define ARexx_create_message (-2)
#define ARexx_create_argument (-3)
#define ARexx_malloc (-4)

/* Rexx handler context */
struct ARexxContext {
	struct MsgPort *ARexxPort;   /* port messages come in at */
	long Outstanding;            /* count of outstanding ARexx messages */
	char PortName[24];           /* port name */
	char ErrorName[28];          /* name of varaible the <base>.LASTERROR... */
	char Extension[8];           /* default file name suffix */
};

#endif   /* SOFA_REXX_H */
