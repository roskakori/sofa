/* exec.c - Exec support functions */

#include "global.h"

#include <exec/memory.h>
#include <exec/libraries.h>
#include <sofa/assert.h>

#include <proto/exec.h>
#include <proto/sofa.h>

extern struct ExecBase *SysBase;

export void
exec_forbid(void)
{
	Forbid();
}

export void
exec_permit(void)
{
	Permit();
}

export EIF_INTEGER
exec_task_id(void)
{
	return (EIF_INTEGER) FindTask(NULL);
}

export EIF_BOOLEAN
exec_has_port(EIF_POINTER name)
{
	return (EIF_BOOLEAN) (FindPort((STRPTR) name) != NULL);
}

static internal_last_wait_result;

export EIF_INTEGER
exec_last_wait_result(void)
{
	return internal_last_wait_result;
}

export void
exec_wait(EIF_INTEGER mask)
{
	internal_last_wait_result = Wait((ULONG) mask);
}

export void
exec_flush_cpu_cache(void)
{
	CacheClearU();
}

/*-------------------------------------------------------------------
 * Memory management
 *-----------------------------------------------------------------*/

export EIF_INTEGER
exec_memory_available(void)
{
	return ((EIF_INTEGER) AvailMem(MEMF_ANY));
}

export EIF_INTEGER
exec_largest_memory_available(void)
{
	return ((EIF_INTEGER) AvailMem(MEMF_ANY | MEMF_LARGEST));
}

export void
exec_flush_memory(void)
{
	void *memory = AllocMem(0x7fffff00, MEMF_ANY);
	assert(memory == NULL);
}

/*-------------------------------------------------------------------
 * Library handling
 *-----------------------------------------------------------------*/

export EIF_POINTER
open_library(EIF_POINTER name, EIF_INTEGER version)
{
	return (EIF_POINTER) OpenLibrary((STRPTR) name, (ULONG) version);
}

export void
close_library(EIF_POINTER library)
{
	CloseLibrary((struct Library *) library);
}

export EIF_INTEGER
library_version(EIF_POINTER library)
{
	return (EIF_INTEGER) (((struct Library *) library)->lib_Version);
}
