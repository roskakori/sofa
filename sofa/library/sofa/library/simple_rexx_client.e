indexing
   description: "Simple Rexx client.";

class SIMPLE_REXX_CLIENT

inherit 
   SHARED_REXX_TOOLS;
   
creation {ANY} 
   connect_to

feature {ANY} -- Access

   connect_to(target_port: STRING) is 
      -- Connect to Rexx port `target_port'.
      require 
         valid_port: target_port /= Void and then not target_port.is_empty; 
         rexx_running: Rexx_tools.running; 
      do  
         port := clone(target_port);
      ensure 
         valid_port: target_port.is_equal(port) and then not port.is_empty; 
      end -- connect_to
   
   disconnect is 
      -- Disconnect from `port' and cleanup.
      do  
      end -- disconnect

feature {ANY} -- Status report

   port: STRING;
      -- name of port connected to
   
   last_rc: INTEGER;
      -- Rexx return code (RC) of last `put'. 0 means ok, 5 warning,
      -- other values indicate errors.
   
   last_result: STRING;
      -- result of last `put'; can be `Void' if there was no result
      -- or an error
   
   error_message: STRING is 
      -- English text describing last error (or `Void')
      require 
         has_error: has_error; 
      do  
         Result := private_error_message;
      ensure 
         valid_error_message: Result /= Void implies not Result.is_empty; 
      end -- error_message
   
   has_error: BOOLEAN is 
      -- Does `last_rc' indicate and error ?
      do  
         Result := last_rc >= 10;
      ensure 
         Result = (last_rc >= 10); 
      end -- has_error
   
   has_error_message: BOOLEAN is 
      -- Is a description of last error available ?
      require 
         has_error: has_error; 
      do  
         Result := error_message /= Void;
      ensure 
         Result = (error_message /= Void); 
      end -- has_error_message

feature {REXX_CLIENT} 
   -- Implementation

   set_error_message(message: STRING) is 
      -- Set `error_message' to `message'.
      require 
         valid_message: message /= Void and then not message.is_empty; 
      do  
         private_error_message := clone(message);
      ensure 
         valid_error_message: error_message /= Void; 
      end -- set_error_message

feature {ANY} -- Access

   put(command: STRING) is 
      -- Send `command' to Rexx port `port'.
      require 
         valid_command: command /= Void; 
      do  
         debug ("REXX_CLIENT")
            print("Send to %"");
            print(port);
            print("%": %"");
            print(command);
            print("%"%N");
         end; 
         last_rc := rexx_client_send_command(port.to_external,command.to_external);
         inspect 
            last_rc
         when -1 then 
               Exceptions.raise("cannot find Rexx port")
         else  if last_rc = 0 then 
                  if rexx_client_last_result.is_not_null then 
                     !!last_result.from_external_copy(rexx_client_last_result);
                     rexx_client_dispose_last_result;
                  else 
                     last_result := Void;
                  end; 
                  debug ("REXX_CLIENT")
                     print("  rc = ");
                     print(last_rc);
                     print("  result = %"");
                     if last_result /= Void then 
                        print(last_result);
                     else 
                        print("<Void>");
                     end; 
                     print("%"%N");
                  end; 
               elseif last_rc < 0 then 
                  Exceptions.raise("cannot send Rexx command");
               end; 
         end; 
      end -- put

feature {NONE} 
   -- Implementation

   private_error_message: STRING;
   
   Exceptions: EXCEPTIONS is 
      once 
         !!Result;
      end -- Exceptions
   
   rexx_client_send_command(port_name, command: POINTER): INTEGER is 
      external "C"
      end -- rexx_client_send_command
   
   rexx_client_last_result: POINTER is 
      external "C"
      end -- rexx_client_last_result
   
   rexx_client_dispose_last_result is 
      external "C"
      end -- rexx_client_dispose_last_result

invariant 
   
   port_not_void: port /= Void; 

end -- class SIMPLE_REXX_CLIENT
