/* resource.h -- Sofa resource tracking */
#ifndef SOFA_RESOURCE_H
#define SOFA_RESOURCE_H

#include <exec/nodes.h>
#include <exec/lists.h>

struct tracked_resource_kind {
   struct MinNode node;
   char *name;
   void (*dispose) (void *resource);
};

struct tracked_pool {
   struct MinNode node;
   struct MinList resources;
   struct tracked_resource *next_resource;
};

struct tracked_resource {
   struct MinNode node;
   struct tracked_resource_kind *kind;
   void *resource;
};

#endif /* SOFA_RESOURCE_H */

