indexing
   description: "Test SOFA_TOOLS";

class TEST_SOFA_TOOLS

inherit 
   SHARED_SOFA_TOOLS;
   
creation {ANY} 
   make

feature {ANY} -- Initialization

   make is 
      do  
         test_pointer_conversion;
         Sofa_tools.die_screaming("just testing die_screaming...");
      end -- make

feature {NONE} 
   -- Implementation

   test_pointer_conversion is 
      -- TODO: for some reason, the printed stuff does not reflect the
      -- actual pointer values. Nevertheless, checking it with the
      -- C-debugger, things seem to be ok.
      local 
         text: STRING;
         text_external: POINTER;
         text_pointer: POINTER;
         text_integer: INTEGER;
      do  
         text := clone("some text");
         text_external := text.to_external;
         text_integer := Sofa_tools.pointer_to_integer(text_external.item);
         text_pointer := Sofa_tools.integer_to_pointer(text_integer);
         print("text_external      = ");
         print(text_external);
         print('%N');
         print("text_external.item = ");
         print(text_external.item);
         print('%N');
         print("text_integer       = #");
         print(text_integer.to_hexadecimal);
         print('%N');
         print("text_pointer       = ");
         print(text_pointer.item);
         print('%N');
      end -- test_pointer_conversion

end -- class TEST_SOFA_TOOLS
