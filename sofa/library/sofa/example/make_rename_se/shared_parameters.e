indexing
	description: "Shared command line parameters.";

class SHARED_PARAMETERS

inherit 
	SHARED_ERROR

feature {ANY} -- Status report

	archive_path: STRING is 
		-- Name of archive that contains full class names
		do  
			Result := parameters.archive_path;
		end -- archive_path
	
	quiet: BOOLEAN is 
		-- Don't display status messages?
		do  
			Result := parameters.quiet;
		end -- quiet
	
	short_count: INTEGER is 
		-- Maximum count of a shortened class name
		do  
			Result := parameters.short_count;
		end -- short_count

feature {NONE} 
	-- Implementation

	parameters: PARAMETERS is 
		-- Private parameters shared among all classes.
		once 
			!!Result;
		ensure 
			not_void: Result /= Void; 
		end -- parameters

feature {ANY} -- Access

	set_parameters is 
		-- Set `archive_path' and `quiet' according to arguments.
		local 
			index: INTEGER;
			parameter: STRING;
			lower_parameter: STRING;
		do  
			parameters.set_short_count(8);
			from 
				index := 1;
			variant 
			argument_count - index + 1
			until 
				index > argument_count or else has_error
			loop 
				parameter := argument(index);
				lower_parameter := clone(parameter);
				lower_parameter.to_lower;
				if lower_parameter.is_equal("quiet") then 
					parameters.set_quiet(true);
				elseif lower_parameter.is_equal("amiga") then
					parameters.set_short_count(28);
				elseif lower_parameter.is_equal("dos") then
					parameters.set_short_count(8);
				elseif lower_parameter.is_equal("mac") then
					parameters.set_short_count(29);
				elseif lower_parameter.is_equal("length") then 
					index := index + 1;
					if index <= argument_count then 
						parameter := argument(index);
						if parameter.is_integer and then parameter.to_integer > 2 then 
							parameters.set_short_count(parameter.to_integer - 2);
						else 
							set_error_message("`length' must be an integer number greater than 2");
						end; 
					else 
						set_error_message("value for `length' must be specified");
					end; 
				elseif archive_path = Void then 
					parameters.set_archive_path(parameter);
				else 
					set_error_message("archive must be specified only once");
				end; 
				index := index + 1;
			end; 
			if not has_error and then archive_path = Void then 
				set_error_message("archive must be specified");
			end; 
		ensure 
			required_arguments_set: not has_error implies archive_path /= Void; 
		end -- set_parameters

	set_quiet(new_quiet: BOOLEAN) is
		-- Set `quiet' to `new_quiet'.
		do
			parameters.set_quiet(new_quiet)
		ensure
			quiet_set: quiet = new_quiet
		end;

end -- class SHARED_PARAMETERS
