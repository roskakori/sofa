indexing
	description: "Sofa related internal stuff.";
	usage: "Use SHARED_SOFA_TOOLS instead.";

class SOFA_TOOLS

creation {ANY} 
	make_or_die

feature {ANY} -- Initialization

	make_or_die is 
		-- Global sofa initializations.
		once 
			if resource_tracking_make then 
				running := true;
			else 
				sofa_die_screaming(("cannot create basic resource tracking environment").to_external);
			end; 
		ensure 
			running: running; 
		end -- make_or_die

feature {ANY} -- Access

	running: BOOLEAN;
	
	pool_handle: POINTER is 
		-- resource pool handle for resources to be released at exit.
		-- (mapped to global C variable `sofa_pool_handle').
		external "C"
		alias "sofa_pool_handle"
		end -- pool_handle

feature {ANY} -- Conversion

	pointer_to_integer(some: POINTER): INTEGER is 
		-- Integer representation of `some'.
		external "C"
		end -- pointer_to_integer
	
	integer_to_pointer(some: INTEGER): POINTER is 
		-- Pointer representation of `some'.
		external "C"
		end -- integer_to_pointer

feature {ANY} -- Various

	die_screaming(message: STRING) is 
		-- View `message' with prefix "Serious problem" in requester or
		-- console and terminate program calling C's exit().
		--
		-- `message' can have multiple lines separated by '%N', though
		-- the line length should not be too big; around 40-60 characters
		-- would be best.
		--
		-- The first letter of `message' should be lower case. If the
		-- `message' is viewed in a requester, the first letter is turned
		-- to upper case.
		require 
			message_not_void: message /= Void; 
		do  
			sofa_die_screaming(message.to_external);
		end -- die_screaming

	Exceptions: EXCEPTIONS is 
		-- exception handle
		once 
			!!Result;
		ensure 
			Result /= Void; 
		end -- Exceptions

feature {NONE} 
	-- Implementation

	sofa_die_screaming(message: POINTER) is 
		-- View message and terminate using C's exit().
		external "C"
		end -- sofa_die_screaming
	
	resource_tracking_make: BOOLEAN is 
		-- Prepare resource tracking.
		external "C_WithoutCurrent"
		end -- resource_tracking_make

end -- class SOFA_TOOLS
