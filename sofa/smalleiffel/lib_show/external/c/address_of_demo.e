class ADDRESS_OF_DEMO
   --
   -- How to use the Eiffel $ operator.
   -- This operator can be used to pass the address of an Eiffel
   -- feature (usefull to implement callbacks);
   --
   -- You can compile this file doing :
   --       compile address_of_demo address_of_src.c
   -- or doing :
   --       compile address_of_demo address_of_src.o
   --
   -- Execution should gives output like `address_of_demo.out'.
   -- This is a good test to check this on your platform.
   --
creation make

feature

   make is
      local
         v: INTEGER;
      do
         -- When a C function need to write some attribute :
         io.put_string("Example #0%N");
         write_integer_attribute($integer_attribute);
         io.put_integer(integer_attribute);
         io.put_new_line;

         -- Call back of `routine1' :
         io.put_string("Example #1%N");
         call_back1($routine1);

         -- Call back of `routine2' :
         io.put_string("Example #2%N");
         io.put_integer(call_back2($routine2));
         io.put_new_line;

         -- Call back of `routine3' :
         io.put_string("Example #3%N");
         io.put_integer(call_back3($routine3,"Eiffel STRING%N"));
         io.put_new_line;

         -- Call back of `routine4' :
         io.put_string("Example #4%N");
         io.put_integer(call_back4($routine4,"Eiffel STRIN"));
         io.put_new_line;

         -- Call back of `routine5' :
         io.put_string("Example #5%N");
         call_back5($routine5);
         io.put_new_line;

         -- Call back of `once_routine6' :
         io.put_string("Example #6%N");
         call_back6($once_routine6);
         call_back6($once_routine6);
         call_back6($once_routine6);
         call_back6($once_routine6);
         check
            integer_attribute = 6
         end;

         -- Call back of `once_routine7' :
         io.put_string("Example #7%N");
         v := call_back7($once_routine7);
         check
            v = 10
         end;
         v := call_back7($once_routine7);
         check
            v = 10
         end;
         io.put_integer(v);
         io.put_new_line;

         -- Call back of `once_routine8' :
         io.put_string("Example #8%N");
         v := call_back7($once_routine8);
         check
            v = 10
         end;
         v := call_back7($once_routine8);
         check
            v = 10
         end;
         io.put_integer(v);
         io.put_new_line;
      end;

feature {ANY}

   integer_attribute: INTEGER;

feature {NONE}

   write_integer_attribute(integer_pointer: POINTER) is
      external "C"
      end;

   routine1 is
         -- A procedure which only needs `Current'.
      do
         io.put_string("From `routine' :%N");
         io.put_integer(integer_attribute);
         io.put_new_line;
      end;

   call_back1(a_routine: POINTER) is
      external "C_WithCurrent"
      end;

   routine2: INTEGER is
         -- A function which only needs `Current'.
      do
         Result := integer_attribute + 1;
      end;

   call_back2(a_routine: POINTER): INTEGER is
      external "C_WithCurrent"
      end;

   routine3(s: STRING): INTEGER is
         -- A function which needs `Current' and a STRING as argument.
      require
         s.count > 0
      do
         io.put_string(s);
         Result := integer_attribute + s.count;
      end;

   call_back3(a_routine: POINTER; str: STRING): INTEGER is
      external "C_WithCurrent"
      end;

   routine4(s: STRING; c: CHARACTER): INTEGER is
         -- A function which needs two arguments.
      require
         s.count > 0
      do
         s.extend(c);
         s.extend('%N');
         io.put_string(s);
         Result := s.count;
      end;

   call_back4(a_routine: POINTER; str: STRING): INTEGER is
      external "C_WithCurrent"
      end;

   routine5(other: like Current) is
         -- A procedure.
      require
         other = Current
      do
         io.put_integer(integer_attribute + other.integer_attribute);
      end;

   call_back5(a_routine: POINTER) is
      external "C_WithCurrent"
      end;

   once_routine6 is
      once
         integer_attribute := integer_attribute + 4;
         io.put_string("Only once routine6.%N");
      end;

   call_back6(a_routine: POINTER) is
      external "C_WithCurrent"
      end;

   once_routine7: INTEGER is
      once
         Result := integer_attribute + 4;
      end;

   call_back7(a_routine: POINTER): INTEGER is
      external "C_WithCurrent"
      end;

   once_routine8: INTEGER is
         -- Just to check that such a pre-computable once
         -- function causes no pain.
      once
         Result := 10;
      end;

end -- ADDRESS_OF_DEMO

