indexing
	description: "Shared Rexx tools";
	pattern: "Singleton";

class SHARED_REXX_TOOLS

inherit 
	SHARED_SOFA_TOOLS
	
feature {ANY} -- Access

	Rexx_tools: REXX_TOOLS is 
		-- Shared Rexx tools.
		--
		-- When access the first time, an attempt is made to initialize
		-- Rexx. Check `Rexx_tools.running' if it worked out.
		--
		-- Also consider calling `Rexx_tools.make_or_die' if Rexx is a
		-- basic requirement of your program.
		once 
			Sofa_tools.make_or_die;
			!!Result.make;
		ensure 
			not_void: Result /= Void; 
		end -- Rexx_tools

end -- class SHARED_REXX_TOOLS
