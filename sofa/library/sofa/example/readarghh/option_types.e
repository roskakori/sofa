indexing
   description: "Types for ReadArgs options";

class OPTION_TYPES

feature {ANY} -- Access

   is_type(some: CHARACTER): BOOLEAN is 
      do  
         inspect 
            some
         when Switch_type,Array_type,Number_type,String_type,Rest_type,Toggle_type then 
               Result := true
         else  Result := false;
         end; 
      end -- is_type
   
   type_to_eiffel(some: CHARACTER): STRING is 
      -- `some' as Eiffel source type.
      require 
         is_type: is_type(some); 
      do  
         inspect 
            some
         when String_type,Rest_type then 
               Result := "STRING"
         when Switch_type,Toggle_type then 
               Result := "BOOLEAN"
         when Array_type then 
               Result := "ARRAY[STRING]"
         when Number_type then 
               Result := "INTEGER"
         end; 
      ensure 
         valid_result: Result /= Void and then Result.count > 0; 
      end -- type_to_eiffel
   
   Switch_type: CHARACTER is 's';
      -- "/s"
   
   Toggle_type: CHARACTER is 't';
      -- "/t"
   
   Array_type: CHARACTER is 'm';
      -- "/m"
   
   Number_type: CHARACTER is 'n';
      -- "/n"
   
   String_type: CHARACTER is 'x';
      -- no explicit type
   
   Rest_type: CHARACTER is 'f';
      -- "/f"
   
end -- class OPTION_TYPES
