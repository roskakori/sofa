indexing
   description: "Error reporting.";

class ERROR

feature {NONE} 
   -- Implementation

   private_message: STRING;

feature {SHARED_ERROR} 
   -- Status report

   error_message: STRING is 
      -- Text of error message if `has_error'.
      require 
         has_error: has_error; 
      do  
         Result := private_message;
      end -- error_message
   
   has_error: BOOLEAN is 
      -- Has an error occured?
      do  
         Result := private_message /= Void;
      end -- has_error

feature {SHARED_ERROR} 
   -- Access

   set_error_message(new_message: STRING) is 
      require 
         valid_message: new_message /= Void; 
      do  
         private_message := clone(new_message);
      ensure 
         has_error: has_error; 
         error_message_set: error_message.is_equal(new_message); 
      end -- set_error_message

end -- class ERROR
