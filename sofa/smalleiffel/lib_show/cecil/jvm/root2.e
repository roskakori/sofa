class ROOT2

creation make

feature

   make is
         -- Dummy root procedure to make some live code.
      do
         put_string(get_string);
      end;

   get_string: STRING is
      do
         Result := "Hi from ROOT2%N"
      end;

   put_string(s: STRING) is
      do
         io.put_string(s);
      end;

end
