class EXAMPLE
   --
   -- This example shows how to create Eiffel objects from C.
   --
   -- To compile this example, use command :
   --
   --         compile -cecil cecil.se example c_prog.c
   --

creation make

feature

   make is
      local
         c_factory: C_FACTORY;
         string: STRING;
      do
         !!c_factory;
         string := call_c_prog(c_factory);
         io.put_string(string);
         io.put_new_line;
      end;

   call_c_prog(c_factory: C_FACTORY): STRING is
      external "C"
      alias "c_prog"
      end;

end -- EXAMPLE
