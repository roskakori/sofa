class HELLO_REXX_CLIENT

inherit 
	SHARED_REXX_TOOLS;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		-- Send test commands.
		do  
			Rexx_tools.make_or_die;
			!!test.connect_to("HELLO.1");
			put_and_print("nop");
			put_and_print("hello");
			put_and_print("this_should_be_unknown");
			put_and_print("quit");
			test.disconnect;
		end -- make

feature {NONE} 
	-- Implementation

	test: SIMPLE_REXX_CLIENT;
		-- The mighty client

	put_and_print(command: STRING) is
			-- Put `command' to `test' and print RC, result or error.
		require
			command_not_void: command /= Void
		do
			test.put(command);
			print (test.last_rc)
			print (": ")
			if not test.has_error then
				if test.last_result /= Void then
					print("result=%"");
					print(test.last_result)
					print("%"")
				else
					print ("no result")
				end
			else
				if test.has_error_message then
					print("error=%"");
					print(test.error_message)
					print("%"")
				else
					print ("no error description")
				end
			end
			print ("%N")

		end;
end -- class HELLO_REXX_CLIENT
