indexing
	description: "Argument parser generator";

class READARGHH

inherit 
	OPTION_TYPES;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		do  
			!!parser.make("to/k/a,template/a,description,quiet/s");
			parser.parse;
			if parser.is_parsed then 
				source_name := parser.item_as_string(1);
				template := parser.item_as_string(2);
				description := parser.item_as_string(3);
				verbose := not parser.item_as_boolean(4);
				if description = Void then
					description := "Argument parser."
				end
				if verbose then 
					print(version);
				end; 
				generate_source_name;
				extract_options;
				if not has_error then 
					consalidate_template;
					debug ("READARGHH")
						print("new template=%"");
						print(template);
						print("%"%N");
					end; 
				end; 
				if not has_error then 
					generate_source;
					write_source;
				end; 
				if has_error then 
					print_error;
					die_with_code(10);
				elseif verbose then
					print("Wrote ");
					print(class_name);
					print(" to ");
					print(source_name);
					print(" (");
					print(source.count);
					print(" bytes)%N");
				end; 
			else 
				print("argument error: ");
				print(parser.error_description);
				print('%N');
				die_with_code(10);
			end; 
		end -- make

feature {NONE} 
	-- Implementation

	version: STRING is "Readarghh -- Generate Eiffel argument parser.%N%
							 %Version 1.0. Freeware, use at your own risk.%N";
	
	parser: SOFA_ARGUMENT_PARSER;
	
	options: ARRAY[OPTION];
	
	template: STRING;
	
	description: STRING;
		-- description used in indexing clause of `source'
	
	verbose: BOOLEAN;
		-- verbose status output ?
	
	source_name: STRING;
	
	class_name: STRING;
		-- Name of class to be stored in `source_name'
	
	option_exists(some: STRING): BOOLEAN is 
		-- Is option named `some' already in `options' ?
		local 
			i: INTEGER;
		do  
			from 
				i := 1;
			variant 
				options.count - i
			until 
				Result or i > options.count
			loop 
				Result := some.is_equal(options.item(i).name);
				i := i + 1;
			end; 
		end -- option_exists

feature {NONE} 
	-- Implementation

	generate_source_name is 
		-- Add ".e" to `source_name' if not there already,
		-- compute `class_name'.
		local 
			i: INTEGER;
			dot_index: INTEGER;
			dir_index: INTEGER;
			temp: STRING;
			suffix: STRING;
		do  
			from 
				i := 1;
					-- variant
					-- source_name.count - i
				
			until 
				i > source_name.count
			loop 
				inspect 
					source_name.item(i)
				when '/',':' then 
						dir_index := i;
						dot_index := 0
				when '.' then 
						if dot_index = 0 then 
							dot_index := i
						end 
				else  do_nothing;
				end; 
				i := i + 1;
			end; 
			if dot_index = 0 then 
				source_name.append(".e");
				dot_index := source_name.count - 1;
			else 
				suffix := source_name.substring(dot_index,source_name.count);
				if not suffix.is_equal(".e") then 
					!!temp.make(0);
					temp.append("suffix %"");
					temp.append(suffix);
					temp.append("%" must be replaced by %".e%"");
					set_error_without_position(temp);
				end; 
			end; 
			from
				i := dir_index + 1
			until
				i > source_name.count
			loop
				source_name.put(source_name.item(i).to_lower, i)
				i := i + 1
			end
			class_name := source_name.substring(dir_index + 1,dot_index - 1);
			class_name.to_upper;
			debug ("READARGHH")
				print(source_name);
				print(" -> ");
				print(class_name);
				print("%N");
			end; 
		end -- generate_source_name

feature {NONE} 
	-- Implementation

	extract_options is 
		-- Extract `options' from `template'.
		require 
			template /= Void; 
		local 
			i: INTEGER;
			name: STRING;
			name_position: INTEGER;
			type: CHARACTER;
			type_set_position: INTEGER;
			is_keyword, is_required: BOOLEAN;
			after_slash, after_name, complete: BOOLEAN;
			rider: CHARACTER;
			temp: STRING;
			new_option: OPTION;
		do  
			from 
				!!options.make(1,0);
				!!name.make(0);
				type := String_type;
				i := 1;
			until 
				i > template.count or has_error
			loop 
				rider := template.item(i);
				if after_name then 
					if after_slash then 
						after_slash := false;
						inspect 
							rider
						when 'a' then 
								is_required := true
						when 'k' then 
								is_keyword := true
						when 'f','m','n','s','t' then 
								if type_set_position = 0 then 
									type := rider;
									type_set_position := i
								else 
									!!temp.make(0);
									temp.append("type for option %"");
									temp.append(name);
									temp.append("%" has already been set to %"/");
									temp.extend(type);
									temp.extend('%"');
									set_error_with_second_position(temp,i,type_set_position)
								end 
						else  !!temp.make(0);
								temp.append("unknown flag: %"/");
								temp.extend(rider);
								temp.extend('%"');
								set_error(temp,i);
						end; 
					elseif rider = '/' then 
						after_slash := true;
					elseif rider = ',' then 
						complete := true;
					else 
						set_error("%"/%" with new flag or %",%" with new option expected",i);
					end; 
				elseif rider = '/' then 
					after_name := true;
					after_slash := true;
				elseif rider = ',' then 
					complete := true;
				elseif rider = '=' then 
					set_error("cannot deal with with %"=%" yet (known bug)",i);
				elseif not rider.is_separator then 
					name.extend(rider);
					if name_position = 0 then 
						name_position := i;
						if rider.is_digit or rider = '_' then 
							set_error("first character of option name must be a letter",i);
						end; 
					elseif not (rider.is_letter or rider.is_digit or rider = '_') then 
						!!temp.make(0);
						temp.extend('%"');
						temp.extend(rider);
						temp.append("%" must be replaced by letter, digit or %"_%"");
						set_error(temp,i);
					end; 
				end; 
				if i = template.count then 
					complete := true;
				end; 
				if complete then 
					if not option_exists(name) then 
						!!new_option.make(name,type,is_keyword,is_required);
						options.add_last(new_option);
						!!name.make(0);
						type := String_type;
						type_set_position := 0;
						is_keyword := false;
						is_required := false;
						complete := false;
						after_slash := false;
						after_name := false;
					else 
						!!temp.make(0);
						temp.append("option %"/");
						temp.append(name);
						temp.append("%" must be defined only once");
						set_error(temp,name_position);
					end; 
				end; 
				i := i + 1;
			end; 
		ensure 
			options /= Void; 
		end -- extract_options
	
	consalidate_template is 
		-- Re-create `template' from `options'.
		local 
			i: INTEGER;
		do  
			from 
				i := 1;
				template.clear;
			variant 
				options.count - i
			until 
				i > options.count
			loop 
				template.append(options.item(i).to_template);
				if i < options.count then 
					template.extend(',');
				end; 
				i := i + 1;
			end; 
		end -- consalidate_template

feature {NONE} 
	-- Implementation

	source: STRING;
		-- generated Eiffel source
	
	generate_source is 
		-- Generate Eiffel source to output in `source'.
		require
			description /= Void
			class_name /= Void
		local 
			i: INTEGER;
		do  
			!!source.make(1024);
			source.append("indexing%N");
			source.append("%Tdescription: %"");
			source.append(description);
			source.append("%"%N");
			source.append("%Tgenerator: %"readarghh%"%N%N");
			source.append("class ");
			source.append(class_name);
			source.append("%N%N");
			source.append("creation%N");
			source.append("%Tmake%N%N");
			source.append("feature -- Initialization%N%N");
			source.append("%Tmake is%N");
			source.append("%T%Tdo%N");
			source.append("%T%T%T!!parser.make(Template)%N");
			source.append("%T%Tend -- make%N%N");
			source.append("feature -- Access%N%N");
			from 
				i := 1;
			until 
				i > options.count
			loop 
				source.append(options.item(i).to_eiffel(i));
				i := i + 1;
			end; 
			source.append("feature -- Status change%N%N");
			source.append("%Tparse is%N");
			source.append("%T%T%T-- Parse arguments from CLI and set corresponding attributes.%N");
			source.append("%T%Trequire%N");
			source.append("%T%T%Tnot_yet_parsed: not is_parsed%N");
			source.append("%T%Tdo%N");
			source.append("%T%T%Tparser.parse%N");
			source.append("%T%Tend%N%N");
			source.append("%Treset is%N");
			source.append("%T%T%T-- Prepare for another `parse'.%N");
			source.append("%T%Tdo%N");
			source.append("%T%T%Tparser.parse%N");
			source.append("%T%Tensure%N");
			source.append("%T%T%Tnot_parsed: not is_parsed%N");
			source.append("%T%Tend%N%N");
			source.append("feature -- Status report%N%N");
			source.append("%Tis_parsed:BOOLEAN is%N");
			source.append("%T%T%T-- Has `parse' been called already ?%N");
			source.append("%T%Tdo%N");
			source.append("%T%T%TResult := parser.is_parsed%N");
			source.append("%T%Tend%N%N");
			source.append("%Thas_error: BOOLEAN is%N");
			source.append("%T%T%T-- Did `parse' cause an error ?%N");
			source.append("%T%Tdo%N");
			source.append("%T%T%TResult := parser.has_error%N");
			source.append("%T%Tend%N%N");
			source.append("%Terror_description: STRING is%N");
			source.append("%T%T%T-- description of last error to be shown to end user%N");
			source.append("%T%Tdo%N");
			source.append("%T%T%TResult := parser.error_description%N");
			source.append("%T%Tend%N%N");
			source.append("feature {NONE} -- Implementation%N%N");
			source.append("%TTemplate: STRING is %"");
			source.append(template);
			source.append("%"%N");
			source.append("%T%T%T-- template passed to ReadArgs()%N%N");
			source.append("%Tparser: SOFA_ARGUMENT_PARSER%N");
			source.append("%T%T%T-- actual parser%N%N");
			source.append("invariant%N%N");
			source.append("%Tconsistent_parsed: is_parsed implies not has_error%N");
			source.append("%Tconsistent_error: has_error implies error_description /= Void%N%N");
			source.append("end -- class ");
			source.append(class_name);
			source.append("%N");
		end -- generate_source
	
	write_source is 
		-- Write `source' to `source_name'.
		require 
			source_not_void: source /= Void; 
		local 
			file: STD_FILE_WRITE;
			temp: STRING;
		do  
			!!file.connect_to(source_name);
			if file.is_connected then 
				file.put_string(source);
				file.disconnect;
			else 
				!!temp.make(0);
				temp.append("cannot write to file %"");
				temp.append(source_name);
				temp.extend('%"');
				set_error_without_position(temp);
			end; 
		end -- write_source

feature {NONE} 
	-- Error handling

	set_error(new_description: STRING; position: INTEGER) is 
		do  
			set_error_with_second_position(new_description,position,0);
		end -- set_error
	
	set_error_with_second_position(new_description: STRING; position, second_position: INTEGER) is 
		do  
			has_error := true;
			error_description := new_description;
			error_position := position;
			error_second_position := second_position;
		end -- set_error_with_second_position
	
	set_error_without_position(new_description: STRING) is 
		do  
			set_error_with_second_position(new_description,0,0);
		end -- set_error_without_position
	
	has_error: BOOLEAN;
	
	error_description: STRING;
	
	error_position: INTEGER;
		-- optional position in `template' that caused error,
		-- or 0 if none
	
	error_second_position: INTEGER;
		-- optional second position in `template' that caused error,
		-- or 0 if none
	
	print_error is 
		-- Print error message to `std_error'. If `position' is greater
		-- than 0, also print `template' and mark offending position(s)
		-- using '^'.
		require 
			has_error; 
		local 
			i: INTEGER;
		do  
			if error_position > 0 then 
				std_error.put_string(template);
				std_error.put_character('%N');
				from 
					i := 1;
				until 
					i > template.count
				loop 
					if i = error_position or i = error_second_position then 
						std_error.put_character('^');
					else 
						std_error.put_character(' ');
					end; 
					i := i + 1;
				end; 
				std_error.put_character('%N');
				std_error.put_string("error in template: ");
			end; 
			std_error.put_string(error_description);
			std_error.put_character('%N');
		end -- print_error

invariant 
	
	consistent_error: has_error implies error_description /= Void; 

end -- class READARGHH
