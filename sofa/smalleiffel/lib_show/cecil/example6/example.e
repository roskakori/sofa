class EXAMPLE
   --
   -- The Eiffel program is running first, then call the C program
   -- which is in charge to call the Eiffel feature `show_values'.
   -- Note that the Eiffel root object is not explicitely passed to
   -- the C world (external "C_WithoutCurrent").
   -- Thus, the C code uses predefined `eiffel_root_object' to access
   -- the very first created Eiffel object.
   --
   -- To compile this example, use command :
   --
   --         compile -cecil cecil.se example c_prog.c
   --
   -- Is is also possible to do :
   --
   --         gcc -c c_prog.c
   --         compile -cecil cecil.se example c_prog.o
   --

creation make

feature

   make is
      do
         do_it;
         call_c_prog;
      end;

   do_it is
      do
         io.put_string("Hi from Eiffel world.%N");
      end;


feature {NONE}

   call_c_prog is
      external "C"
      alias "c_prog"
      end;

end -- EXAMPLE
