class EXAMPLE
   --
   -- The Eiffel program is running first, then call the C program
   -- which is in charge to print the contents of `animals' using
   -- `lower'/`upper'/`item' of ARRAY[ANIMAL].
   --
   -- To compile this example, use command :
   --
   --         compile -cecil cecil.se example c_prog.c
   --

creation make

feature

   make is
      local
         cat: CAT;
         dog: DOG;
      do
         !!cat;
         !!dog;
         animals := <<cat,dog,cat>>;
         call_c_prog(animals);
      end;

feature {NONE}

   animals: ARRAY[ANIMAL];

   call_c_prog(a: like animals) is
      external "C"
      alias "c_prog"
      end;

end -- EXAMPLE
