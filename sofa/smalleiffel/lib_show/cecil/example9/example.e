class EXAMPLE
--
-- This example shows how simulate `eif_adopt' and `eif_wean' as
-- they are described in ETL.
--
-- Note: it is not necessary to use these features when passing to 
-- the C side the address of an Eiffel object which remains 
-- referenced in the Eiffel side (and thus will not be garbage 
-- collected).
--
-- To compile this example, use command :
--
--         compile -cecil cecil.se example c_prog.c
--

creation make

feature

   make is
      local
         string: STRING;
         memory: MEMORY;
         i: INTEGER;
      do
         call_c_code(Current);
         -- Just play to remove or to add comments for the following
         -- two lines (one or both) :
         call_eif_adopt_from_c;
--         call_eif_wean_from_c;


         -- The following loop should trigger the GC a few times (use
         -- the -gc_info option to be sure that the GC is called).
         -- As the allocated STRING in the following loop ("bar%N") has 
         -- exactely the same size as the one allocated on the C side 
         -- ("foo%N"), the former should overwrite the latter.
         from
            i := 100_000;
         until
            i = 0
         loop
            string := ("bar%N").twin;
            i := i - 1;
         end;
         string := string_back_to_eiffel;
         -- Should print "foo%N" or "bar%N".
         io.put_string(string);
      end;

   new_string(c_string: POINTER): STRING is
      do
         !!Result.from_external_copy(c_string);
      end

   call_c_code(factory: like Current) is
      external "C"
      end;

   string_back_to_eiffel: STRING is
      external "C"
      end;

   call_eif_adopt_from_c is
      external "C"
      end;

   call_eif_wean_from_c is
      external "C"
      end;

end -- EXAMPLE
