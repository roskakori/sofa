class EXTERNAL_DEMO
   --
   -- How to use external (calling C from Eiffel);
   --
   -- You can compile this file doing :
   --       compile external_demo make external_src.c
   -- or doing :
   --       compile external_demo make external_src.o
   --
   -- Execution should gives output like `external_demo.out'.
   --
creation make

feature

   make is
      do
         integer2c(6);
         character2c('a');
         boolean2c(true);
         real2c(3.5);
         double2c((3.5).to_double);
         double2c(3.5);
         string2c(("Hi C World %N").to_external);
         any2c(Current);
         any2c("Hi");
         current2c;
         std_output.put_integer(integer2eiffel);
         std_output.put_character(character2eiffel);

         -- When a C function need to write some attribute :
         write_integer_attribute($integer_attribute);
         std_output.put_integer(integer_attribute);
         std_output.put_new_line;
      end;

feature {NONE}

   integer_attribute: INTEGER;

   integer2c(i: INTEGER) is
         -- Send an INTEGER to C
      external "C"
      end;

   character2c(c: CHARACTER) is
         -- Send a CHARACTER to C
      external "C"
      end;

   boolean2c(b: BOOLEAN) is
         -- Send a BOOLEAN to C
      external "C"
      end;

   real2c(r: REAL) is
         -- Send a REAL to C
      external "C"
      end;

   double2c(d: DOUBLE) is
         -- Send a DOUBLE to C
      external "C"
      end;

   string2c(s: POINTER) is
         -- Send a STRING to C
      external "C"
      end;

   any2c(a: ANY) is
         -- Send a reference to C
      external "C"
      end;

   current2c is
         -- Also send Current to C.
      external "C_WithCurrent"
      end;

   integer2eiffel: INTEGER is
         -- Receive an INTEGER from C
      external "C"
      end;

   character2eiffel: CHARACTER is
         -- Receive a CHARACTER from C
      external "C"
      end;

   write_integer_attribute(integer_pointer: POINTER) is
      external "C"
      end;

end -- EXTERNAL_DEMO

