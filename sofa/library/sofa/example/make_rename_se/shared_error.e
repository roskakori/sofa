indexing
   description: "Shared error reporting.";

class SHARED_ERROR

feature {ANY} -- Status report

   error_message: STRING is 
      -- Text of error message if `has_error'.
      require 
         has_error: has_error; 
      do  
         Result := private_error.error_message;
      end -- error_message
   
   has_error: BOOLEAN is 
      -- Has an error occured?
      do  
         Result := private_error.has_error;
      end -- has_error

feature {ANY} -- Access

   set_error_message(new_message: STRING) is 
      require 
         valid_message: new_message /= Void; 
      do  
         private_error.set_error_message(new_message);
      ensure 
         has_error: has_error; 
         error_message_set: error_message.is_equal(new_message); 
      end -- set_error_message

feature {NONE} 
   -- Implementation

   private_error: ERROR is 
      once 
         !!Result;
      ensure 
         non_void: Result /= Void; 
      end -- private_error

end -- class SHARED_ERROR
