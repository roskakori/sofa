indexing
	description: "AmigaOS %"dos.libraray%" functions.";

class AMIGA_DOS

feature {ANY} -- Error handling

	set_error(new_code: INTEGER) is 
		-- Set IoErr() and thus `last_error' to `code'.
		external "C"
		alias "dos_set_error"
		end -- set_error
	
	clear_error is 
		-- Set `last_error' to 0, meaning no error.
		do  
			set_error(0);
		ensure 
			last_error_is_null: last_error = 0; 
		end -- clear_error
	
	has_error: BOOLEAN is 
		-- Did an error occur ?
		do  
			Result := last_error = 0;
		ensure 
			Result = (last_error = 0);
		end -- has_error
	
	last_error: INTEGER is 
		-- Value of IoErr().
		external "C"
		alias "dos_error"
		end -- last_error
	
	last_error_description: STRING is 
		-- Text describing `last_error' according to IoErr()
		--
		-- Note: on every invocation, a new STRING is allocated
		-- for the `Result'.
		do  
			Result := error_description(last_error);
		ensure 
			result_not_void: Result /= Void; 
		end -- last_error_description
	
	error_description(code: INTEGER): STRING is 
		-- Text describing dos error number `code'
		--
		-- This is similar to Fault(), but without leading ": ".
		--
		-- Note: on every invocation, a new STRING is allocated
		-- for the `Result'.
		do  
			!!Result.from_external_copy(dos_error_description(code));
		ensure 
			result_not_void: Result /= Void; 
		end -- error_description

feature {ANY} 
	
	delay(ticks: INTEGER) is 
		-- Wait for `ticks' ticks.
		--
		-- (One second has 50 ticks.)
		require 
			non_negative_ticks: ticks >= 0; 
		external "C"
		alias "dos_delay"
		end -- delay

feature {ANY} -- Return codes

	Return_ok: INTEGER is 0;
		-- No problems, success
	
	Return_warn: INTEGER is 5;
		-- A warning only
	
	Return_error: INTEGER is 10;
		-- Something wrong
	
	Return_fail: INTEGER is 20;
		-- Complete or severe failure
	
feature {NONE} 
	-- Implementation

	dos_error_description(code: INTEGER): POINTER is 
		external "C"
		end -- dos_error_description

end -- class AMIGA_DOS
