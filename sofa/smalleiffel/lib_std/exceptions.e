-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT 
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of 
-- another product.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr 
--                       http://SmallEiffel.loria.fr
--
class EXCEPTIONS
   --
   -- Facilities for adapting the exception handling mechanism.
   -- This class may be used as ancestor by classes needing its 
   -- facilities.
   --

feature -- Various exceptions codes :

   Check_instruction: INTEGER is 1;
         -- Exception code for violated check.

   Class_invariant: INTEGER is 2;
         -- Exception code for violated class invariant.

   Developer_exception: INTEGER is 3;
         -- Exception code for developer exception.

   Incorrect_inspect_value: INTEGER is 4;
         -- Exception code for inspect value which is not one
         -- of the inspect constants, if there is no Else_part

   Loop_invariant: INTEGER is 5;
         -- Exception code for violated loop invariant

   Loop_variant: INTEGER is 6;
         -- Exception code for non-decreased loop variant

   No_more_memory: INTEGER is 7;
         -- Exception code for failed memory allocation

   Postcondition: INTEGER is 8;
         -- Exception code for violated postcondition.

   Precondition: INTEGER is 9;
         -- Exception code for violated precondition.

   Routine_failure: INTEGER is 10;
         -- Exception code for failed routine.

   Os_signal: INTEGER is 11;
         -- Exception code for a signal received from the OS.

   Void_attached_to_expanded: INTEGER is 12;
         -- Exception code for attachment of void value
         -- to expanded entity.

   Void_call_target: INTEGER is 13;
         -- Exception code for feature applied to void reference

feature

   developer_exception_name: STRING is
         -- Name of last developer-raised exception.
      require
         applicable: is_developer_exception
      do
         Result := developer_exception_name_memory.item;
      end;

   is_developer_exception: BOOLEAN is
         -- Is the last exception originally due to
         -- a developer exception?
      do
         Result := exception = Developer_exception;
      end;

   is_developer_exception_of_name (name: STRING): BOOLEAN is
         -- Is the last exception originally due to a developer
         -- exception of name `name'?
      do
         if is_developer_exception then
            Result := name.is_equal(developer_exception_name);
         end;
      end;

feature -- Status report :

   assertion_violation: BOOLEAN is
         -- Is last exception originally due to a violated
         -- assertion or non-decreasing variant?
      do
         inspect 
            exception
         when Check_instruction, Class_invariant, Loop_invariant,
              Loop_variant, Postcondition, Precondition then
            Result := true;
         else
         end;
      end;

   exception: INTEGER is
         -- Code of last exception that occurred.
      external "SmallEiffel"
      end;

   is_signal: BOOLEAN is
         -- Is last exception originally due to an external
         -- event (operating system signal) ?
      do
         Result := signal_number /= 0;
      end;

feature -- Basic operations :

   die(code: INTEGER) is
         -- Terminate execution with exit status code,
         -- without triggering an exception.
      do
         die_with_code(code);
      end;

   raise(name: STRING) is
         -- Raise a developer exception of name name.
      do
         developer_exception_name_memory.set_item(name);
         raise_exception(Developer_exception);
      end;

feature -- Non-Standard Extensions :

   signal_number: INTEGER is
         -- Signal Number received from OS.  Zero if exception
         -- is not an OS signal.
      external "SmallEiffel"
      end;

   developer_exception_name_memory: MEMO[STRING] is
      once
         !!Result;
      end;

   raise_exception(code: INTEGER) is
      external "SmallEiffel"
      end;

end -- EXCEPTIONS
