indexing
	description: "BumpRev for Eiffel";

class MAKE_SOFA_VERSION

creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		do  
			!!info.make
			!!options.make;
			options.parse;
			if not options.has_error then 
				print_info;
				generate_source_name;
				make_source;
				if not has_error then 
					write_source;
				end; 
				if has_error then 
					std_error.put_string(error_description);
					std_error.put_string("%N");
					die_with_code(10);
				end; 
			else 
				std_error.put_string("error in arguments: ");
				std_error.put_string(options.error_description);
				std_error.put_string("%N");
				die_with_code(10);
			end; 
		end -- make

feature {NONE} 
	-- Implementation

	options: MAKE_SOFA_VERSION_OPTIONS;
	
	info: MAKE_SOFA_VERSION_INFO;
	
	source: STRING;
		-- source of Eiffel class to create
	
	source_name: STRING;
		-- full file name of Eiffel class
	
	class_name: STRING;
		-- name of Eiffel class
	
feature {NONE} 
	-- Implementation

	basic_time: BASIC_TIME;
	
	today: STRING is 
		-- .
		local 
			year_text: STRING;
		once 
			basic_time.update;
			!!Result.make(0);
			Result.append(basic_time.day.to_string);
			Result.extend('.');
			Result.append(basic_time.month.to_string);
			Result.extend('.');
			!!year_text.make(3);
			year_text := clone(basic_time.year.to_string);
			year_text.prepend("0");
			year_text.tail(2);
			Result.append(year_text);
		ensure 
			result_not_void: Result /= Void; 
		end -- today

feature {NONE} 
	-- Implementation

	generate_source_name is 
		-- Compute `source_name' and `class_name'.
		local 
			i: INTEGER;
			dot_index: INTEGER;
			dir_index: INTEGER;
			temp: STRING;
			suffix: STRING;
		do  
			source_name := options.to;
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
					set_error(temp);
				end; 
			end; 
			class_name := source_name.substring(dir_index + 1,dot_index - 1);
			class_name.to_upper;
			debug ("MAKE_SOFA_VERSION")
				print(source_name);
				print(" -> ");
				print(class_name);
				print("%N");
			end; 
		ensure 
			source_name /= Void; 
			class_name /= Void; 
		end -- generate_source_name
	
	make_source is 
		-- Generate `source'.
		do  
			!!source.make(0);
			source.append("indexing%N");
			source.append("%Tdescription: %"");
			source.append(options.description);
			source.append("%"%N");
			source.append("%Tgenerator: %"make_sofa_version%"%N%N");
			source.append("class ");
			source.append(class_name);
			source.append("%N%N");
			source.append("creation%N");
			source.append("%Tmake%N%N");
			source.append("feature -- Initialization%N%N");
			source.append("%Tmake is%N");
			source.append("%T%Tdo%N");
			source.append("%T%T%Tamiga_version_tag.clear%N");
			source.append("%T%T%T%T-- Make `amiga_version_tag' alive, so that%N");
			source.append("%T%T%T%T-- `compile' won't remove it from executable.%N");
			source.append("%T%Tend -- make%N%N");
			source.append("feature -- Access%N%N");
			source.append("%Tversion: INTEGER is ");
			source.append(options.version.to_string);
			source.append("%N%T%T%T-- version number%N%N");
			source.append("%Trevision: INTEGER is ");
			source.append(options.revision.to_string);
			source.append("%N%T%T%T-- revision number%N%N");
			source.append("%Tdate: STRING is %"");
			source.append(today);
			source.append("%"%N%T%T%T-- date of last change%N%N");
			source.append("%Tapplication: STRING is %"");
			source.append(options.application);
			source.append("%"%N");
			source.append("%T%T%T-- name of application%N%N");
			source.append("%Tdescription: STRING is %"");
			source.append(options.description);
			source.append("%"%N");
			source.append("%T%T%T-- short description of `application'%N%N");
			source.append("feature {NONE} -- Implementation%N%N")
			source.append("%Tamiga_version_tag: STRING is %"$")
			source.append("VER: ");
			source.append(options.application);
			source.extend(' ');
			source.append(options.version.to_string);
			source.extend('.');
			source.append(options.revision.to_string);
			source.append(" (");
			source.append(today);
			source.append(")%"%N%T%T%T-- tag for AmigaOS %"version%" command%N%N");
			source.append("end -- ");
			source.append(class_name);
			source.extend('%N');
		ensure 
			source /= Void; 
		end -- make_source
	
	write_source is 
		-- Write `source' to `source_name'.
		require 
			source_name /= Void; 
			source /= Void; 
		local 
			file: STD_FILE_WRITE;
			temp: STRING;
		do  
			!!file.connect_to(source_name);
			if file.is_connected then 
				file.put_string(source);
				file.disconnect;
				if not options.quiet then 
					print("Wrote ");
					print(class_name);
					print(" to %"");
					print(source_name);
					print("%" (");
					print(source.count);
					print(" bytes)%N");
				end; 
			else 
				!!temp.make(0);
				temp.append("cannot write %"");
				temp.append(source_name);
				temp.extend('%"');
				set_error(temp);
			end; 
		end -- write_source

feature {NONE} 
	-- Implementation

	print_info is 
		-- Print application info.
		do  
			if not options.quiet then 
				print(options.application);
				print(" -- ");
				print(options.description);
				print('%N');
				print("version ");
				print(info.version);
				print('.');
				print(info.revision);
				print(" (");
				print(info.date);
				print(")%N");
			end; 
		end -- print_info

feature {NONE} 
	-- Error reporting

	set_error(new_description: STRING) is 
		do  
			has_error := true;
			error_description := new_description;
		end -- set_error
	
	has_error: BOOLEAN;
		-- Did `parse' cause an error ?
	
	error_description: STRING;
		-- description of last error to be shown to end user
	
end -- class MAKE_SOFA_VERSION
