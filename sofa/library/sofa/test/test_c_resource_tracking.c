/* test resource tracking functions */

#include <stdio.h>

#include <exec/types.h>
#include <dos/dos.h>

#include <sofa/assert.h>
#include <sofa/resource_tracking.h>

#include <clib/alib_protos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/sofa.h>

#define PORTNAME "test_resource_tracking"

int main(int argc, char *argv)
{
   struct tracked_resource_kind *port_kind;
   struct tracked_pool *main_pool;
   struct tracked_resource *my_port_resource;
   struct MsgPort *my_port;

   make_resource_tracking();
   assert(!IoErr());

   port_kind = make_resource_kind("message port", (void(*)(void *)) DeletePort);
   assert(port_kind != NULL);

   main_pool = make_tracked_pool();
   assert(main_pool != NULL);

   my_port = CreatePort(PORTNAME,0);
   if (my_port != NULL) {
      my_port_resource = make_tracked_resource(main_pool, (void *) my_port, port_kind);
   } else {
      printf("cannot create port \"" PORTNAME "\"\n");
   }

   dispose_tracked_pool(main_pool);

   assert(FindPort(PORTNAME) == NULL);
   return 0;
}
