class EXAMPLE
   --
   -- The Eiffel program is running first, create an empty STRING
   -- which is passed to the C world.
   -- The C program then modify the Eiffel STRING calling the Eiffel
   -- feature `extend' of class STRING.
   -- Finally, the modified STRING is printed.
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
      local
         string: STRING;
      do
         !!string.make(0);
         call_c_prog(string);
         io.put_string(string);
      end;

feature {NONE}

   call_c_prog(str: STRING) is
      external "C"
      alias "c_prog"
      end;

end -- EXAMPLE
