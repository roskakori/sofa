indexing
	description: "Minimal interface to ReadArgs().";

class SOFA_ARGUMENT_PARSER

inherit 
	SHARED_SOFA_TOOLS;
	SHARED_AMIGA_DOS;
	MEMORY
		redefine dispose
		end; 
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make(new_template: STRING) is 
		-- Make parser for ReadArgs() template `new_template'.
		require 
			template_not_void: new_template /= Void; 
		local 
			i: INTEGER;
			rider: CHARACTER;
			last_type: CHARACTER;
			after_slash: BOOLEAN;
		do  
			!!type.make(1,0);
			template := new_template;
			from 
				count := 1;
				i := 1;
				last_type := Text_type;
			until 
				i > template.count
			loop 
				rider := template.item(i);
				if after_slash then 
					inspect 
						rider.to_lower
					when 'a','k' then 
							do_nothing
					when 'f' then 
							last_type := Text_type
					when 'm' then 
							last_type := Multiple_type
					when 'n' then 
							last_type := Number_type
					when 's','t' then 
							last_type := Flag_type
					else  debug ("SOFA_ARGUMENT_PARSER")
								print("unknown flag %"/");
								print(rider);
								print("%" for template at position ");
								print(i);
							end; 
					end; 
					after_slash := false;
				elseif rider = '/' then 
					after_slash := true;
				elseif rider = ',' then 
					type.add_last(last_type);
					last_type := Text_type;
					count := count + 1;
				end; 
				i := i + 1;
			end; 
			type.add_last(last_type);
			context := internal_make(template.to_external,count);
			if context.is_null then 
				Sofa_tools.Exceptions.raise(Amiga_dos.last_error_description);
			end; 
		ensure 
			template_stored: template = new_template; 
		end -- make

feature {SOFA_ARGUMENT_PARSER}
	-- cleanup

	dispose is 
		do  
			internal_dispose(context);
		end -- dispose

feature {ANY} -- Status report

	count: INTEGER;
		-- number of arguments
	
	template: STRING;
		-- internal ReadArgs() template
	
	prompt: BOOLEAN;
		-- Prompt user for arguments if none given ?
	
	help_text: STRING;
		-- extended help text displayed if user types "?" upon prompt
	
feature {ANY} -- Element change

	is_parsed: BOOLEAN;
		-- Have arguments been parsed ?
	
	parse is 
		-- Parse CLI arguments.
		require 
			not_yet_parsed: not is_parsed; 
			consistent_help: not prompt implies help_text = Void; 
		local 
			help_dummy: STRING;
		do  
			if help_text = Void then 
				help_dummy := "";
			else 
				help_dummy := help_text;
			end; 
			is_parsed := internal_parse_from_cli(context,help_dummy.to_external,prompt);
			if not is_parsed then 
				has_error := true;
				error_description := Amiga_dos.last_error_description;
			end; 
		ensure 
			is_parsed: not has_error = is_parsed; 
		end -- parse
	
	parse_from(line: STRING) is 
		-- Parse arguments from `line'.
		require 
			line_not_void: line /= Void; 
		do  
			check 
				false; 
			end;
		end -- parse_from

feature {NONE} 
	-- Implementation

	type: ARRAY[CHARACTER];
	
	Number_type: CHARACTER is 'n';
	
	Text_type: CHARACTER is 't';
	
	Flag_type: CHARACTER is 'f';
	
	Multiple_type: CHARACTER is 'm';

feature {ANY} 
	
	is_boolean(index: INTEGER): BOOLEAN is 
		require 
			index_in_range: index >= 1 and index <= count; 
		do  
			Result := type.item(index) = Flag_type;
		end -- is_boolean
	
	is_integer(index: INTEGER): BOOLEAN is 
		require 
			index_in_range: index >= 1 and index <= count; 
		do  
			Result := type.item(index) = Number_type;
		end -- is_integer
	
	is_string(index: INTEGER): BOOLEAN is 
		require 
			index_in_range: index >= 1 and index <= count; 
		do  
			Result := type.item(index) = Text_type;
		end -- is_string
	
	is_array(index: INTEGER): BOOLEAN is 
		require 
			index_in_range: index >= 1 and index <= count; 
		do  
			Result := type.item(index) = Multiple_type;
		end -- is_array

feature {ANY} -- Access

	item_as_boolean(index: INTEGER): BOOLEAN is 
		-- value of argument number `index'
		require 
			is_parsed: is_parsed; 
			index_in_range: index >= 1 and index <= count; 
			is_boolean: is_boolean(index); 
		do  
			Result := internal_item_as_boolean(context,index - 1);
		end -- item_as_boolean
	
	item_as_integer(index: INTEGER): INTEGER is 
		-- value of argument number `index', or 0 if not set
		require 
			is_parsed: is_parsed; 
			index_in_range: index >= 1 and index <= count; 
			is_integer: is_integer(index); 
		do  
			Result := item_as_integer_or_default(index,0);
		end -- item_as_integer
	
	item_as_integer_or_default(index, default_value: INTEGER): INTEGER is 
		-- value of argument number `index', or `default_value' if not set
		require 
			is_parsed: is_parsed; 
			index_in_range: index >= 1 and index <= count; 
			is_integer: is_integer(index); 
		do  
			Result := internal_item_as_integer(context,index - 1,default_value);
		end -- item_as_integer_or_default
	
	item_as_string(index: INTEGER): STRING is 
		-- value of argument number `index', or `Void' if not set
		--
		-- Always returns a new object.
		require 
			is_parsed: is_parsed; 
			index_in_range: index >= 1 and index <= count; 
			is_string: is_string(index); 
		local 
			item_pointer: POINTER;
		do  
			item_pointer := internal_item_as_string(context,index - 1);
			if item_pointer.is_not_null then 
				!!Result.from_external_copy(item_pointer);
			end; 
		end -- item_as_string
	
	item_as_string_or_default(index: INTEGER; default_value: STRING): STRING is 
		-- value of argument number `index', or `default_value' if not set
		--
		-- Always returns a new object (even for `default_value').
		require 
			is_parsed: is_parsed; 
			index_in_range: index >= 1 and index <= count; 
			is_string: is_string(index); 
		do  
			Result := item_as_string(index);
			if Result = Void then 
				Result := clone(default_value);
			end; 
		ensure 
			result_not_void: Result /= Void; 
		end -- item_as_string_or_default
	
	item_as_array(index: INTEGER): ARRAY[STRING] is 
		-- value of argument number `index'
		--
		-- Always returns a new object.
		require 
			is_parsed: is_parsed; 
			index_in_range: index >= 1 and index <= count; 
			is_array: is_array(index); 
		local 
			i: INTEGER;
			item_pointer: POINTER;
			item_string: STRING;
		do  
			!!Result.make(1,0);
			from 
				i := 0;
				item_pointer := internal_item_as_multiple_string(context,index - 1,i);
			variant 
				count - i
			until 
				item_pointer.is_null
			loop 
				!!item_string.from_external_copy(item_pointer);
				Result.add_last(item_string);
				i := i + 1;
				item_pointer := internal_item_as_multiple_string(context,index - 1,i);
			end; 
		ensure 
			result_not_void: Result /= Void; 
			count_in_range: Result.count <= count; 
		end -- item_as_array

feature {NONE} 
	-- Status setting

	set_prompt(new_prompt: BOOLEAN) is 
		-- Set `prompt' to `new_prompt'.
		do  
			prompt := new_prompt;
		end -- set_prompt
	
	set_help(new_help: STRING) is 
		-- Set `help_text' to `new_help'.
		-- `Void' means no help.
		require 
			prompt: prompt; 
		do  
			help_text := new_help;
		end -- set_help

feature {ANY} -- Error reporting

	has_error: BOOLEAN;
		-- Did `parse' cause an error ?
	
	error_description: STRING;
		-- description of last error to be shown to end user


feature {NONE} 
	-- Implementation

	context: POINTER;
		-- RDArgs C structure
	
	internal_make(new_template: POINTER; new_count: INTEGER): POINTER is 
		external "C"
		alias "readargs_context_make"
		end -- internal_make
	
	internal_parse_from_cli(context_pointer, help_pointer: POINTER; prompt_flag: BOOLEAN): BOOLEAN is 
		external "C"
		alias "readargs_parse_from_cli"
		end -- internal_parse_from_cli
	
	internal_dispose(context_pointer: POINTER) is 
		external "C"
		alias "readargs_context_dispose"
		end -- internal_dispose
	
	internal_item_as_boolean(context_pointer: POINTER; index: INTEGER): BOOLEAN is 
		-- value in `context_pointer' at `index'
		external "C"
		alias "readargs_item_as_boolean"
		end -- internal_item_as_boolean
	
	internal_item_as_integer(context_pointer: POINTER; index, default_value: INTEGER): INTEGER is
		-- value in `context_pointer' at `index',
		-- or `default_value' if not set.
		external "C"
		alias "readargs_item_as_integer"
		end -- internal_item_as_integer
	
	internal_item_as_string(context_pointer: POINTER; index: INTEGER): POINTER is 
		-- value in `context_pointer' at `index'
		external "C"
		alias "readargs_item_as_string"
		end -- internal_item_as_string
	
	internal_item_as_multiple_string(context_pointer: POINTER; index, at: INTEGER): POINTER is 
		-- value in `context_pointer' at `index', with array position `at'
		external "C"
		alias "readargs_item_as_multiple_string"
		end -- internal_item_as_multiple_string

invariant 
	
	template_not_void: template /= Void; 
	
	context_not_null: context.is_not_null; 
	
	count_positive: count > 0; 
	
	consistent_parsed: is_parsed implies not has_error; 
	
	consistent_error: has_error implies error_description /= Void; 

end -- class SOFA_ARGUMENT_PARSER
