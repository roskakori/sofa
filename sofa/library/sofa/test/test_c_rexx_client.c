#include <runtime/base.h>
#include <sofa/rexx.h>

#include <proto/sofa.h>

static void
test_command(char * port, char * command)
{
   ULONG rc;
   STRPTR result = NULL;

   printf("Send to \"%s\": \"%s\"\n", port, command);

   rc = rexx_client_send_command(port, command);
   printf("rc = %ld\n", rc);

   result = (STRPTR) rexx_client_last_result();
   if (result) {
      printf("result = \"%s\"\n", result);
   } else {
      printf("no result\n", rc);
   }

   rexx_client_dispose_last_result();
}

int
main(int argc, char *argv[])
{
   make_resource_tracking();
   rexx_make(36);

   test_command("TEST.1", "hello");
   test_command("REXX", "Say 'hello from rexx'");
   test_command("GOLDED.1", "open ask");
   test_command("?Unknown?", "should not work");
   test_command("TEST.1", "hello again");

   exit(0);
}

