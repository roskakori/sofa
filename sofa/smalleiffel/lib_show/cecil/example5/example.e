class EXAMPLE
   --
   -- The Eiffel program is running first, then call the C program
   -- which is in charge to add two INTEGERs using the infix "+"
   -- feature of class INTEGER.
   --
   -- To compile this example, use command :
   --
   --         compile -cecil cecil.se example c_prog.c
   --

creation make

feature

   make is
      local
         i1, i2, sum: INTEGER;
      do
         i1 := 2;
         i2 := 3;
         io.put_integer(i1);
         io.put_string(" + ");
         io.put_integer(i2);
         io.put_string(" = ");
         sum := call_c_prog(i1,i2);
         io.put_integer(sum);
         io.put_string("%N");
      end;

feature {NONE}

   call_c_prog(i1, i2: INTEGER): INTEGER is
      external "C"
      alias "c_prog"
      end;

end -- EXAMPLE
