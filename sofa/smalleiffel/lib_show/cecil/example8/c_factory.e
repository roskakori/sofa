class C_FACTORY

feature

   string_make(c_string: NATIVE_ARRAY[CHARACTER]): STRING is
         -- Creates a new Eiffel STRING using `c_string' contents as
         -- a model (for the contents of the new STRING).
      require
         c_string.is_not_null
      local
         count, i: INTEGER;
      do
         -- Compute the length of the `c_string' in `count' :
         from
         until
            c_string.item(count) = '%U'
         loop
            count := count + 1;
         end;
         count := count + 1;

         -- Allocate a new Eiffel STRING with the appropriate
         -- capacity :
         !!Result.make(count);

         -- To copy the `c_string' contents in the `Result' :
         from
         until
            count = i
         loop
            Result.add_last(c_string.item(i));
            i := i + 1;
         end;
      end;

end --  C_FACTORY
