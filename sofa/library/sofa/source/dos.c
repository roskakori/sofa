/* dos.library support functions */

#include "global.h"

#include <sofa/assert.h>
#include <sofa/dos.h>

#include <exec/types.h>
#include <dos/dos.h>
#include <dos/rdargs.h>

#include <proto/dos.h>
#include <proto/sofa.h>

/*------------------------------------------------------------------------
 * Error reporting
 *----------------------------------------------------------------------*/

/* buffer to store result of Fault() */
#define FAULT_BUFFER_SIZE 100
static char fault_buffer[FAULT_BUFFER_SIZE];

export EIF_INTEGER dos_error(void)
{
	return (EIF_INTEGER) IoErr();
}
export void dos_set_error(EIF_INTEGER code)
{
	SetIoErr((LONG) code);
}

export EIF_POINTER
dos_error_description(EIF_INTEGER code)
{
	Fault((LONG) code, "", (STRPTR) fault_buffer, FAULT_BUFFER_SIZE);
	return (EIF_POINTER) &(fault_buffer[2]);    /* Skip ": " in buffer */
}

export void dos_delay(EIF_INTEGER ticks)
{
	require(ticks >= 0);
	Delay((ULONG) ticks);
}

/*------------------------------------------------------------------------
 * Pattern matching
 *----------------------------------------------------------------------*/

export EIF_POINTER
dos_pattern_make(EIF_POINTER source, EIF_BOOLEAN case_sensitive)
{
	struct dos_pattern_context *context;
	LONG pattern_length;
	BOOL has_error;

	has_error = TRUE;
	context = (struct dos_pattern_context *) malloc(sizeof(struct dos_pattern_context));
	if (context) {
		pattern_length = 2 * strlen(source) + 2;
		context->pattern = (char *) malloc((size_t) pattern_length);
		if (context->pattern) {
			strcpy(context->pattern, source);
			context->case_sensitive = case_sensitive;
			if (context->case_sensitive) {
				context->has_wild_card = ParsePattern(source, context->pattern, pattern_length);
			} else {
				context->has_wild_card = ParsePatternNoCase(source, context->pattern, pattern_length);
			}
			if (context->has_wild_card != -1) {
				has_error = FALSE;
			}
		} else {
			SetIoErr(ERROR_NO_FREE_STORE);
		}
	} else {
		SetIoErr(ERROR_NO_FREE_STORE);
	}

	/* in case of error, cleanup */
	if (has_error) {
		dos_pattern_dispose((EIF_POINTER) context);
		context = NULL;
	}
	return (EIF_POINTER) context;
}

export void
dos_pattern_dispose(EIF_POINTER context_pointer)
{
	struct dos_pattern_context *context = (struct dos_pattern_context *) context_pointer;
	if (context) {
		free(context->pattern);
		free(context);
	}
}

export EIF_BOOLEAN
dos_pattern_matches(EIF_POINTER context_pointer, EIF_POINTER some_pointer)
{
	EIF_BOOLEAN result;
	struct dos_pattern_context *context = (struct dos_pattern_context *) context_pointer;
	STRPTR some = (STRPTR) some_pointer;

	if (context->case_sensitive) {
		if (MatchPattern(context->pattern, some) == 0) {
			result = FALSE;
		} else {
			result = TRUE;
		}
	} else {
		if (MatchPatternNoCase(context->pattern, some) == 0) {
			result = FALSE;
		} else {
			result = TRUE;
		}
	}

	return result;
}

export EIF_BOOLEAN
dos_pattern_has_wild_card(EIF_POINTER context_pointer)
{
	struct dos_pattern_context *context = (struct dos_pattern_context *) context_pointer;
	return (EIF_BOOLEAN) context->has_wild_card;
}

/*------------------------------------------------------------------------
 * Argument parsing
 *----------------------------------------------------------------------*/

struct readargs_context {
	struct RDArgs *rdargs; /* internal handle for ReadArgs() */
	LONG *values;          /* where ReadArgs() stores extracted values */
	char *pohja;           /* template for ReadArgs()
									* ("template" would have been a a C++ keyword;
									* "pohja" simply means "template" in Finish) */
	EIF_INTEGER count;     /* number of different arguments */
	BOOL parsed;           /* has ReadArgs() already been applied ? */
};

export void readargs_context_dispose(EIF_POINTER context_pointer)
{
	/* TODO: remove from sofa_pool */
	struct readargs_context *context = (struct readargs_context *) context_pointer;

	/* Note: according to ANSI, `free(NULL)' does nothing */
	free(context->pohja);
	free(context->values);
	if (context->rdargs) {
		if (context->parsed) {
			FreeArgs(context->rdargs);
		}
		FreeDosObject(DOS_RDARGS, context->rdargs);
	}
	free(context);
}

#if 0
/* TODO: alloc new dosobj.; handle out of memory; add "export" */
EIF_BOOLEAN readargs_reset(EIF_POINTER context_pointer)
{
	struct readargs_context *context = (struct readargs_context *) context_pointer;

	if (context->rdargs != NULL) {
		if (context->parsed) {
			FreeArgs(context->rdargs);
		}
	}
	context->parsed = FALSE;
}
#endif

export EIF_POINTER readargs_context_make(EIF_POINTER pohja, EIF_INTEGER count)
{
	/* TODO: add to sofa_pool */
	struct readargs_context *context;

	require(pohja != NULL);
	require(count >= 0);
	require(IoErr() == 0);

	context = (struct readargs_context *) cmalloc(sizeof(struct readargs_context));
	if (context != NULL) {
		BOOL ok = FALSE;

		context->pohja = clone_string(pohja);
		if (context->pohja != NULL) {
			context->values = (LONG *) malloc(sizeof(LONG) * count);
			if (context->values != NULL) {
				context->rdargs = (struct RDArgs *) AllocDosObject(DOS_RDARGS, NULL);
				if (context->rdargs != NULL) {
					context->count = count;
					ok = TRUE;
				} else {
					SetIoErr(ERROR_NO_FREE_STORE);
				}
			} else {
				SetIoErr(ERROR_NO_FREE_STORE);
			}
		} else {
			SetIoErr(ERROR_NO_FREE_STORE);
		}

		/* cleanup */
		if (!ok) {
			readargs_context_dispose(context);
			context = NULL;
		}
	}
	return context;
}

static EIF_BOOLEAN readargs_parse(EIF_POINTER context_pointer, EIF_POINTER help_pointer, EIF_BOOLEAN prompt, EIF_POINTER source_pointer)
{
	struct readargs_context *context = (struct readargs_context *) context_pointer;
#if 0
	STRPTR help = (STRPTR) help_pointer;
	STRPTR source = (STRPTR) source_pointer;
#endif
	struct RDArgs *result;

	require(context != NULL);
	require(!context->parsed);

	memset((void *) context->values, 0, sizeof(LONG) * context->count);
	result = ReadArgs(context->pohja, context->values, context->rdargs);

	return (EIF_BOOLEAN) (result != NULL);
}

export EIF_BOOLEAN readargs_parse_from_cli(EIF_POINTER context_pointer, EIF_POINTER help, EIF_BOOLEAN prompt)
{
	return readargs_parse(context_pointer, help, prompt, NULL);
}

export EIF_BOOLEAN readargs_parse_from_string(EIF_POINTER context_pointer, EIF_POINTER help, EIF_BOOLEAN prompt, EIF_POINTER source)
{
	return readargs_parse(context_pointer, help, prompt, source);
}


export EIF_POINTER readargs_item_as_string(EIF_POINTER context, EIF_INTEGER index)
{
	return ((EIF_POINTER) ((struct readargs_context *) context)->values[index]);
}

export EIF_POINTER readargs_item_as_multiple_string(EIF_POINTER context, EIF_INTEGER index, EIF_INTEGER at)
{
	STRPTR result = NULL;
	STRPTR *where = (STRPTR *) ((struct readargs_context *) context)->values[index];

	if (where != NULL) {
		result = where[at];
	}

	return ((EIF_POINTER) result);
}

export EIF_BOOLEAN readargs_item_as_boolean(EIF_POINTER context, EIF_INTEGER index)
{
	return ((EIF_BOOLEAN) ((struct readargs_context *) context)->values[index]);
}

export EIF_INTEGER readargs_item_as_integer(EIF_POINTER context, EIF_INTEGER index, EIF_INTEGER default_value)
{
	/* Note: ReadArgs() does not return numbers by value rather by
	 * reference. That way, you can check if it has been set at all. */
	LONG result = default_value;
	LONG *where = (LONG *) (((struct readargs_context *) context)->values[index]);

	if (where != NULL) {
		result = *where;
	}

	return ((EIF_INTEGER) result);
}


#if 0
EIF_POINTER make_rdargs(EIF_POINTER ra_template, EIF_POINTER argument_string, EIF_POINTER help, EIF_BOOLEAN prompt)
{
	struct readargs_context *result;
	BOOL ok;
	size_t argument_string_length;
	size_t argument_count;
	STRPTR rider;

	assert(IoErr() == 0);


	ok = TRUE;
	result = (struct readargs_context *) cmalloc(sizeof(struct readargs_context);
	if (result != NULL) {
		/* if there is an `argument_string', duplicate it into
		 * `result->argument_string' with a "\n" appended to work around
		 * bug in ReadArgs() */
		if (argument_string) {

			scan_length = (LONG) strlen(ra_string) + 2;
			result->argument_string = (STRPTR) malloc(scan_length);

			if (scan_buffer != NULL) {
				strcpy(scan_buffer, ra_string);
				scan_buffer[length - 2] = '\n';
				scan_buffer[length - 1] = '\0';
			} else {
				SetIoErr(ERROR_NO_FREE_STORE);
				ok = FALSE;
			}
		}

		/* prepare RDArgs structure */
		if (ok) {
			result->rdargs = (struct RDArgs *) AllocDosObject(DOS_RDARGS, NULL);
			if (result->rdargs != NULL) {
				if (result->argument_string) {
					result->RDA_Source.CS_Buffer = argument_string;
					result->RDA_Source.CS_Length = argument_string_length;
				}
				if (prompt) {
					result->RDA_Flags = result->RDAFlags | RDAF_NOPROMPT;
				}
				if (help != NULL) {
					result->RDA_ExtHelp = (STRPTR) help);
				}
			} else {
				ok = FALSE;
			}
		}

		/* count number of arguments by scanning for commas (,) */
		argument_count = 1;
		rider = ra_template;
		while (*rider) {
			if (*rider == ',') {
				argument_count += 1;
			}
			rider += 1 ;
		}
		result->result = (LONG *) malloc(sizeof(LONG) * argument_count);
		if (result == NULL) {
				SetIoErr(ERROR_NO_FREE_STORE);
				ok = FALSE;
		}

		/* cleanup */
		if (!ok) {
			dispose_readargs_context(result);
			result = NULL;
		}
	}
	return result;
}

void dispose_readargs_context(EIF_POINTER context)
{
	/* Note: according to ANSI, `free(NULL)' does nothing */
	free(context->ra_template);
	free(context->argument_string);
	free(context->help);
	free(context->values);
	if (context->rdargs) {
		FreeDosObject(rdargs);
	}
}

void
internal_parse_cli_arguments(EIF_POINTER eif_target, EIF_POINTER eif_template)
{
	LONG *ra_target = (LONG *) eif_target;
	STRPTR ra_template = (STRPTR) eif_template;
	struct RDArgs ra_state;

	ra_state = (struct RDArgs *) AllocDosObject(DOS_RDARGS, NULL);
	if (ra_state != NULL) {
		FreeDosObject(ra_state);
	}
}

#endif

/*------------------------------------------------------------------------
 * File info
 *----------------------------------------------------------------------*/

EIF_POINTER file_info_make(EIF_POINTER name)
{
	EIF_POINTER result = NULL;
	BPTR lock = Lock((STRPTR) name, ACCESS_READ);

	if (lock) {
		struct FileInfoBlock *info  = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, NULL);

		if (info) {
			if (Examine(lock, info)) {
				result = (EIF_POINTER) info;
			} else {
				FreeDosObject(DOS_FIB, (void *) info);
			}
		}
		UnLock(lock);
	}

	return (EIF_POINTER) result;
}

export void file_info_dispose(void *file_info)
{
	FreeDosObject(DOS_FIB, file_info);
}

export EIF_POINTER file_info_name(EIF_POINTER info)
{
	return (EIF_POINTER) (((struct FileInfoBlock *) info)->fib_FileName);
}

export EIF_BOOLEAN file_info_is_directory(EIF_POINTER info)
{
	LONG entry_type = ((struct FileInfoBlock *) info)->fib_DirEntryType;

	return (EIF_BOOLEAN) ((entry_type >= 0) && (entry_type != ST_SOFTLINK));
}

export EIF_POINTER file_info_comment(EIF_POINTER info)
{
	return (EIF_POINTER) (((struct FileInfoBlock *) info)->fib_Comment);
}

export EIF_INTEGER file_info_size(EIF_POINTER info)
{
	return (EIF_INTEGER) (((struct FileInfoBlock *) info)->fib_Size);
}

export EIF_INTEGER file_info_block_count(EIF_POINTER info)
{
	return (EIF_INTEGER) (((struct FileInfoBlock *) info)->fib_NumBlocks);
}

export EIF_INTEGER file_info_user(EIF_POINTER info)
{
	return (EIF_INTEGER) (((struct FileInfoBlock *) info)->fib_OwnerUID);
}

export EIF_INTEGER file_info_group(EIF_POINTER info)
{
	return (EIF_INTEGER) (((struct FileInfoBlock *) info)->fib_OwnerGID);
}

static const char *access1 = "--------hsparwed";
static const char *access0 = "rwedrwed--------";

#if 0
static BOOL internal_dos_protection_has_error = TRUE;

dos_set_protection(EIF_POINTER filename, EIF_INTEGER mask)
{
	internal_dos_protection_has_error = TRUE;
	if (SetProtection((STRPTR) filename, (LONG) mask)) {
		internal_dos_protection_has_error = FALSE;
	}
}

EIF_INTEGER
dos_protection(EIF_POINTER filename)
{
	LONG result = 0;
	BPTR lock = Lock((STRPTR) filename, ACCESS_READ);

	internal_dos_protection_has_error = TRUE;
	if (lock == ZERO) {
		struct FileInfoBlock *info  = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, NULL);

		if (info != NULL) {
			if (Examine(lock, info)) {
				result = info->fib_Protection;
				internal_dos_protection_has_error = FALSE;
			}
			FreeDosObject(DOS_FIB, (void *) info);
		}
		UnLock(lock);
	}

	return (EIF_INTEGER) result;
}
#endif

