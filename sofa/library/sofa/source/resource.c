/* resource.c -- resource tracking functions */

#include <exec/types.h>
#include <exec/lists.h>
#include <exec/nodes.h>

#include <sofa/assert.h>
#include <sofa/resource.h>

#include "global.h"

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>

/* Debugging */
#if 0
#define D(x) x
#define bug printf
#else
#define D(x)                    /* nothing */
#endif

static struct MinList resource_kinds;

static struct MinList tracked_pools;

/* Sofa pool, where all resource can be allocated that will not be released
 * before the program ends. Used by `tracked_sofa_resource_make'. */
static struct tracked_pool *sofa_pool = NULL;

export EIF_POINTER sofa_pool_handle(void)
{
	return sofa_pool;
}

/* Allocate `next_resource' for `pool' so that it can be guaranteed that
 * `tracked_resource_make' always can add its `resource' to the pool. */
static void
malloc_next_resource(struct tracked_pool *pool)
{
	pool->next_resource = (struct tracked_resource *) malloc(sizeof(struct tracked_resource));
	if (pool->next_resource == NULL) {
		SetIoErr(ERROR_NO_FREE_STORE);
	}
}

/* Dispose all pools, resource kinds and resource tracking internal.
 * Declared static because passed to atexit() and called automatically. */
static void
resource_tracking_dispose(void)
{
	struct MinNode *node, *next_node;

	/* dispose all pools (including `sofa_pool' */
	node = tracked_pools.mlh_Head;
	next_node = node->mln_Succ;
	while (next_node != NULL) {
		tracked_pool_dispose((struct tracked_pool *) node);
		node = next_node;
		next_node = node->mln_Succ;
	}

	/* dispose resource kinds */
	node = resource_kinds.mlh_Head;
	next_node = node->mln_Succ;
	while (next_node != NULL) {
		resource_kind_dispose((struct tracked_resource_kind *) node);
		node = next_node;
		next_node = node->mln_Succ;
	}
}

/* Setup resource tracking.
 * On error, set IoErr(). */
export void
resource_tracking_make(void)
{
	NewList((struct List *) &resource_kinds);
	NewList((struct List *) &tracked_pools);
	if (atexit(resource_tracking_dispose) == 0) {
		basic_resource_kinds_make();
		if (!IoErr()) {
			sofa_pool = tracked_pool_make();
		}
	} else {
		SetIoErr(ERROR_OBJECT_TOO_LARGE);
	}
}

export struct tracked_resource_kind *
resource_kind_make(char *name, void (*dispose) (void *resource))
{
	struct tracked_resource_kind *result;

	require(name != NULL);
	require(dispose != NULL);

	result = (struct tracked_resource_kind *) malloc(sizeof(struct tracked_resource_kind));
	if (result) {
		result->name = name;
		result->dispose = dispose;
		AddHead((struct List *) &resource_kinds, (struct Node *) result);
	} else {
		SetIoErr(ERROR_NO_FREE_STORE);
	}

	return result;
}

export void
resource_kind_dispose(struct tracked_resource_kind *some)
{
	Remove((struct Node *) some);
	free(some);
}

export struct tracked_pool *
tracked_pool_make(void)
{
	struct tracked_pool *result;

	result = (struct tracked_pool *) malloc(sizeof(struct tracked_pool));
	if (result) {
		malloc_next_resource(result);
		if (result->next_resource != NULL) {
			NewList((struct List *) &(result->resources));
			AddHead((struct List *) &tracked_pools, (struct Node *) result);
		} else {
			free(result);
			result = NULL;
		}
	} else {
		SetIoErr(ERROR_NO_FREE_STORE);
	}

	return result;
}

export void
tracked_pool_dispose(struct tracked_pool *pool)
{
	struct MinNode *node, *next_node;

	require(pool != NULL);

	D(bug("tracked_pool_dispose at %p\n", (void *) pool));

	free(pool->next_resource);
	Remove((struct Node *) pool);

	node = pool->resources.mlh_Head;
	next_node = node->mln_Succ;
	while (next_node != NULL) {
		tracked_resource_dispose_by_node(pool, (struct tracked_resource *) node);
		node = next_node;
		next_node = node->mln_Succ;
	}

	free(pool);
}

export struct tracked_resource *
tracked_resource_make(struct tracked_pool *pool, void *resource, struct tracked_resource_kind *kind)
{
	struct tracked_resource *result;

	require(pool != NULL);
	require(resource != NULL);
	require(kind != NULL);

	/* If the previous attempt to allocate `pool->next_resource' failed, the
	 * `pool' must not be used anymore ! */
	require(pool->next_resource != NULL);

	result = pool->next_resource;
	result->resource = resource;
	result->kind = kind;
	AddHead((struct List *) &(pool->resources), (struct Node *) result);

	malloc_next_resource(pool);
	if (pool->next_resource == NULL) {
		/* Fail, if no next resource can be allocated. However, `resource'
		 * still is in the pool because it used the previoulsy allocated
		 * `next_resource'. That way, it is guaranteed that `resource' will
		 * be disposed during `tracked_pool_dispose', even if this routine
		 * fails. */
		result = NULL;
	}
	return result;
}


export struct tracked_resource *
tracked_sofa_resource_make(void *resource, struct tracked_resource_kind *kind)
{
	return tracked_resource_make(sofa_pool, resource, kind);
}

export void
tracked_resource_dispose_by_node(struct tracked_pool *pool, void *some_resource_node)
{
	struct MinNode *node;
	struct tracked_resource *resource;

	require(pool != NULL);
	require(some_resource_node != NULL);

	/* find `some_resource_node' in `pool' */
	resource = NULL;
	node = pool->resources.mlh_Head;
	while ((resource == NULL) && (node->mln_Succ != NULL)) {
		if (node == (struct MinNode *) some_resource_node) {
			resource = (struct tracked_resource *) node;
		} else {
			node = node->mln_Succ;
		}
	}

	if (resource != NULL) {
		assert(resource->kind != NULL);
		assert(resource->resource != NULL);
		D(bug("   dispose \"%s\" at %p\n", resource->kind->name, (void *) resource));
		(*resource->kind->dispose) (resource->resource);
		Remove((struct Node *) resource);
		free(resource);
	} else {
		D(bug("tracked_resource_dispose: pool %p must contain node %s at %p\n",
				(void *) pool,
				((struct tracked_resource *) some_resource_node)->kind->name,
				(void *) some_resource_node));
	}
}

export void
tracked_resource_dispose_by_resource(struct tracked_pool *pool, void *some_resource)
{
	struct MinNode *node;
	struct tracked_resource *resource;

	require(pool != NULL);
	require(some_resource != NULL);

	/* find `some_resource' in `pool' */
	resource = NULL;
	node = pool->resources.mlh_Head;
	while ((resource == NULL) && (node->mln_Succ != NULL)) {
		resource = (struct tracked_resource *) node;
		if (resource->resource !=  some_resource) {
			resource = NULL;
			node = node->mln_Succ;
		}
	}

	if (resource != NULL) {
		assert(resource->kind != NULL);
		assert(resource->resource != NULL);
		D(bug("   dispose \"%s\" at %p\n", resource->kind->name, (void *) resource));
		(*resource->kind->dispose) (resource->resource);
		Remove((struct Node *) resource);
		free(resource);
	} else {
		D(bug("tracked_resource_dispose: pool %p must contain resource %s at %p\n",
				(void *) pool,
				((struct tracked_resource *) some_resource)->kind->name,
				(void *) some_resource));
	}
}

/*------------------------------------------------------------------------
 * Basic standard resources
 *----------------------------------------------------------------------*/
static void
dispose_port(void *port)
{
	/* TODO: reply pending messages */
	DeletePort((struct MsgPort *) port);
}

static void
dispose_window(void *window)
{
	/* TODO: messing with messages etc like in CloseWindowSafely() ??? */
	CloseWindow((struct Window *) window);
}

static void
dispose_library(void *library)
{
	CloseLibrary((struct Library *) library);
}

export struct tracked_resource_kind *port_kind = NULL;
export struct tracked_resource_kind *window_kind = NULL;
export struct tracked_resource_kind *library_kind = NULL;
export struct tracked_resource_kind *pool_kind = NULL;
export struct tracked_resource_kind *file_info_kind = NULL;

/* TODO: Currently, this is called by resource_tracking_make(). Maybe
 * there could be a better place in `Sofa_tools.make'. */
export EIF_BOOLEAN
basic_resource_kinds_make(void)
{
	return (EIF_BOOLEAN)
		((port_kind = resource_kind_make("exec message port", dispose_port))
	&& (window_kind = resource_kind_make("intuition window", dispose_window))
		 && (library_kind = resource_kind_make("exec library", dispose_library))
		 && (file_info_kind = resource_kind_make("file info", file_info_dispose))
		 && (pool_kind = resource_kind_make("tracked resource pool", (void (*)(void *)) tracked_pool_dispose)
		 ));
}

