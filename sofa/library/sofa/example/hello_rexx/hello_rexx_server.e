class HELLO_REXX_SERVER

inherit 
	SHARED_REXX_TOOLS;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		-- Launch server and execute commands until `quit' is set.
		local 
			command: STRING;
		do  
			Rexx_tools.make_or_die;
			!!server.make("HELLO");
			welcome;
			from 
			until 
				quit
			loop 
				server.wait;
				command := server.item;
				execute(command);
			end; 
			server.close;
		end -- make

feature {NONE} 
	-- Implementation

	help_text: STRING is "List of commands:%N%
								%QUIT - Shut down server%N%
								%HELLO - Greet server and make it greet back%N%
								%NOP - Do nothing, just wait for next command";
	
	server: SIMPLE_REXX_SERVER;
		-- the mighty server
	
	quit: BOOLEAN;
		-- Shut down server?
	
	welcome is 
		-- Display welcome message.
		do  
			print("Welcome to server %"");
			print(server.name);
			print("%"")
			debug ("HELLO_REXX_SERVER")
			print ("%N(mask = ");
			print(server.signal_mask);
			print(")");
			end
			print("%N%N");
			print(help_text);
			print("%N%Nwaiting for commands...%N%N");
		end -- welcome
	
	execute(command: STRING) is 
		-- Execute command and return result to client.
		local 
			answer: STRING;
			error: STRING;
		do  
			print("> ");
			print(command);
			print("%N");
			command.to_lower;
			if command.is_equal("quit") then 
				quit := true;
			elseif command.is_equal("hello") then 
				answer := "Hello, too.";
			elseif command.is_equal("nop") then 
				-- Do nothing
				
			else 
				error := "unknown command";
			end; 
			if answer = Void then 
				-- TODO: sucks
				answer := "";
			end; 
			if error = Void then 
				print("result = %"");
				print(answer);
				print("%"%N");
				server.remove_with_result(answer);
			else 
				print("error = %"");
				print(error);
				print("%"%N");
				server.remove_with_error_and_code(error,10);
			end; 
			if quit then 
				print("%Nquitting.%N");
			end; 
		end -- execute

end -- class HELLO_REXX_SERVER
