class EXAMPLE
   --
   -- The Eiffel program is running first, then call the C program
   -- which is in charge to call the Eiffel feature `show_values' of
   -- this EXAMPLE class.
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
         values := <<1,2,3>>;
         call_c_prog(Current);
      end;

   show_values is
      local
         i: INTEGER;
      do
         from
            i := values.lower;
         until
            i > values.upper
         loop
            io.put_integer(values.item(i));
            io.put_new_line;
            i := i + 1;
         end;
      end;

feature {NONE}

   values: ARRAY[INTEGER];

   call_c_prog(current_object: like Current) is
      external "C"
      alias "c_prog"
      end;

end -- EXAMPLE
