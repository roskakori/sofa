class EXAMPLE
   --
   -- The Eiffel program is running first, then call the C program
   -- which is in charge to print the contents of `values' using
   -- `item' of ARRAY[INTEGER].
   --
   -- To compile this example, use command :
   --
   --         compile -cecil cecil.se example c_prog.c
   --

creation make

feature

   make is
      do
         values := <<1,2,3>>;
         call_c_prog(values);
      end;

feature {NONE}

   values: ARRAY[INTEGER];

   call_c_prog(v: ARRAY[INTEGER]) is
      external "C"
      alias "c_prog"
      end;

end -- EXAMPLE
