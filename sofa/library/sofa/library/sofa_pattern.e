indexing
	description: "AmigaDOS pattern";

class SOFA_PATTERN

inherit 
	SHARED_SOFA_TOOLS;
	SHARED_AMIGA_DOS;
	MEMORY
		redefine dispose
		end; 
	
creation {ANY} 
	make, make_case_sensitive

feature {ANY} -- Initialization

	make(new_pattern: STRING) is 
		require 
			pattern_not_void: new_pattern /= Void; 
		do  
			internal_make(new_pattern,false);
		ensure 
			pattern = new_pattern; 
		end -- make
	
	make_case_sensitive(new_pattern: STRING) is 
		require 
			pattern_not_void: new_pattern /= Void; 
		do  
			internal_make(new_pattern,true);
		ensure 
			pattern = new_pattern; 
		end -- make_case_sensitive

feature {ANY} -- Access

	pattern: STRING;
		-- the actual pattern
	
	has_wild_card: BOOLEAN;
		-- does `pattern' use wild cards ?
	
feature {ANY} -- Comparison

	matches(some: STRING): BOOLEAN is 
		-- Does `pattern' match with `some' ?
		require 
			some_not_void: some /= Void; 
		do  
			Result := dos_pattern_matches(context,some.to_external);
		end -- matches

feature {ANY} -- Cleanup

	dispose is 
		-- Cleanup.
		do  
			dos_pattern_dispose(context);
		end -- dispose

feature {NONE} 
	-- Implementation

	context: POINTER;
	
	Maximum_pattern_count: INTEGER is 
		-- maximum number of characters in a pattern text
		once 
			Result := Maximum_integer // 2 - 2;
		ensure 
			sensible: Result > 0; 
		end -- Maximum_pattern_count
	
	internal_make(new_pattern: STRING; case_sensitive: BOOLEAN) is 
		require 
			pattern_not_void: new_pattern /= Void; 
		local 
			message: STRING;
		do  
			if new_pattern.count < Maximum_pattern_count then 
				context := dos_pattern_make(new_pattern.to_external,case_sensitive);
				if context.is_not_null then 
					pattern := new_pattern;
					has_wild_card := dos_pattern_has_wild_card(context);
				else 
					message := clone("cannot parse pattern %"");
					message.append(new_pattern);
					message.append("%": ");
					message.append(Amiga_dos.last_error_description);
					Sofa_tools.Exceptions.raise(message);
				end; 
			else 
				message := clone("pattern must be shorter than ");
				message.append(Maximum_pattern_count.to_string);
				message.append(" characters");
				Sofa_tools.Exceptions.raise(message);
			end; 
		ensure 
			pattern = new_pattern; 
		end -- internal_make
	
	dos_pattern_make(new_pattern: POINTER; case_sensitive: BOOLEAN): POINTER is 
		external "C"
		end -- dos_pattern_make
	
	dos_pattern_dispose(context_pointer: POINTER) is 
		external "C"
		end -- dos_pattern_dispose
	
	dos_pattern_matches(context_pointer, some_pointer: POINTER): BOOLEAN is 
		external "C"
		end -- dos_pattern_matches
	
	dos_pattern_has_wild_card(context_pointer: POINTER): BOOLEAN is 
		external "C"
		end -- dos_pattern_has_wild_card

end -- class SOFA_PATTERN
