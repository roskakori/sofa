indexing
	description: "Read C source file(s) and create header file with %
					 %prototypes and externals for it.";

class MAKE_EXPORT_HEADER

creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		local 
			i: INTEGER;
		do  
			set_arguments;
			if not has_error then 
				!!declarations.make(1,0);
				from 
					i := 1;
				until 
					i > source_names.count or has_error
				loop 
					add_declarations_from(source_names.item(i));
					i := i + 1;
				end; 
				if not has_error then 
					write_proto_file;
				end; 
			end; 
			if has_error then 
				print(error_description);
				print('%N');
			end; 
		end -- make

feature {NONE} 
	-- Implementation

	declarations: ARRAY[STRING];
		-- all prototype declarations found so far
	
	add_prototype(new_prototype: STRING) is 
		-- Remove unneccessary blanks from `new_protype', then add it
		-- to `declarations'.
		local 
			i: INTEGER;
		do  
			new_prototype.left_adjust;
			new_prototype.right_adjust;
			from 
				i := 1;
			until 
				i > new_prototype.count - 1
			loop 
				if new_prototype.item(i) = ' ' and new_prototype.item(i + 1) = ' ' then 
					new_prototype.remove(i);
				else 
					i := i + 1;
				end; 
			end; 
			declarations.add_last(new_prototype);
			debug ("MAKE_EXPORT_HEADER")
				print("   ");
				print(new_prototype);
				print('%N');
			end; 
		end -- add_prototype

feature {NONE} 
	-- Implementation

	source: STD_FILE_READ;
		-- C source file currently scanning
	
	add_declarations_from(filename: STRING) is
		-- Scan `filename' for declarations and add them to `declarations'.
		require 
			filename /= Void; 
		local 
			word: STRING;
			in_word: BOOLEAN;
			in_prototype: BOOLEAN;
			merkki: CHARACTER;
			line: INTEGER;
			start_line: INTEGER
			after_slash: BOOLEAN;
		do  
			!!source.connect_to(filename);
			if source.is_connected then 
				print(filename);
				print('%N');
				from 
					!!word.make(128);
				until 
					source.end_of_input or has_error
				loop 
					source.read_character;
					if not source.end_of_input then 
						merkki := source.last_character;
						if merkki = '%N' then 
							line := line + 1;
						end; 
						if in_prototype then 
							inspect 
								merkki
							when '{',';','=' then 
									if merkki = '=' then 
										word.prepend("extern ")
									end 
									add_prototype(clone(word));
									in_prototype := false
							when '%N','%R','%T','%F' then 
									word.extend(' ');
									if merkki = '%N' then 
										line := line + 1
									end 
							else  word.extend(merkki);
							end; 
						elseif after_slash then 
							if merkki = '*' then 
								start_line := line
								skip_comment;
								skip_merkki_or_die("comment", start_line, "%"*/%"");
							elseif merkki = '/' then 
								skip_cpp_comment;
							end; 
							after_slash := false;
							in_word := false;
						elseif merkki = '"' then 
							start_line := line
							skip_string;
							skip_merkki_or_die("string", start_line, "double quote (%")");
							in_word := false;
						elseif in_word then 
							if merkki.is_letter then 
								word.extend(merkki.to_lower);
							else 
								if word.is_equal(export_keyword) then 
									in_prototype := true;
									word.clear;
								else 
									debug ("MAKE_EXPORT_HEADER")
										-- print("      skipped: %"");
										-- print(word);
										-- print("%"%N");
										
									end; 
									if after_slash then 
										if word.is_equal("*") then 
											skip_comment;
										elseif word.is_equal("/") then 
											skip_cpp_comment;
										end; 
										after_slash := false;
									elseif word.is_equal("%"") then 
										skip_string;
									end; 
								end; 
								in_word := false;
							end; 
						elseif merkki.is_letter then 
							word.clear;
							word.extend(merkki.to_lower);
							in_word := true;
						end; 
					end; 
				end; 
				if in_prototype then 
					add_prototype(clone(word));
				end; 
				source.disconnect;
			else 
				error_description := "cannot read %"" + filename + "%"";
			end; 
		end -- add_declarations_from
	
	skip_merkki_or_die(construct: STRING; start_line: INTEGER; must_end_with: STRING) is
		-- Skip next character in `source'.
		--
		-- If already `source.end_of_input', display error message of
		-- type "`construct' starting in line `start_line' must end
		-- before file". Then `die' with error exit code.
		--
		-- `construct' should have values like "string" or "comment".
		require 
			connected: source.is_connected; 
			construct_not_void: construct /= Void;
			line_not_negative: start_line >= 0;
			end_not_void: must_end_with /= Void
		do  
			if not source.end_of_input then 
				source.read_character;
			else 
				std_error.put_string(source.path);
				std_error.put_string(": ");
				std_error.put_string(construct);
				std_error.put_string(" starting in line ");
				std_error.put_integer(start_line);
				std_error.put_string(" must end with %N");
				std_error.put_string(must_end_with);
				std_error.put_string(" before end of file.%N");
				source.disconnect;
				die_with_code(exit_failure_code);
			end; 
		end -- skip_merkki_or_die
	
	skip_string is 
		-- Skip until string ends with (").
		require 
			connected: source.is_connected; 
		local 
			after_backslash: BOOLEAN;
			end_reached: BOOLEAN;
		do  
			from 
				debug ("MAKE_EXPORT_HEADER")
					print("      skipping string%N");
				end; 
			until 
				source.end_of_input or end_reached
			loop 
				source.read_character;
				if not source.end_of_input then 
					if after_backslash then 
						after_backslash := false;
					elseif source.last_character = '\' then 
						after_backslash := true;
					elseif source.last_character = '%"' then 
						end_reached := true;
					end; 
				end; 
			end; 
		ensure 
			connected: source.is_connected; 
		end -- skip_string
	
	skip_comment is 
		-- Skip until commend ends (*/).
		require 
			connected: source.is_connected; 
		local 
			after_star: BOOLEAN;
			end_reached: BOOLEAN;
		do  
			from 
				debug ("MAKE_EXPORT_HEADER")
					print("      skipping comment%N");
				end; 
			until 
				source.end_of_input or end_reached
			loop 
				source.read_character;
				if not source.end_of_input then 
					if after_star and source.last_character = '/' then 
						end_reached := true;
					end; 
					after_star := source.last_character = '*';
				end; 
			end; 
		ensure 
			connected: source.is_connected; 
		end -- skip_comment
	
	skip_cpp_comment is 
		-- Skip until C++ commend ends (end of line).
		require 
			connected: source.is_connected; 
		do  
			from 
				debug ("MAKE_EXPORT_HEADER")
					print("      skipping c++ comment%N");
				end; 
			until 
				source.end_of_input or else (source.last_character = '%N' or source.last_character = '%R')
			loop 
				source.read_character;
			end; 
		ensure 
			connected: source.is_connected; 
		end -- skip_cpp_comment

feature {NONE} 
	-- Implementation

	prototype_text: STRING is 
		-- `protypes' represented as C source.
		local 
			short_name: STRING;
			define: STRING;
			i, name_start: INTEGER;
		do  
			from 
				i := 1;
				name_start := 1;
			until 
				i > proto_name.count
			loop 
				if ("/:\").has(proto_name.item(i)) then 
					name_start := i + 1;
				end; 
				i := i + 1;
			end; 
			short_name := proto_name.substring(name_start,proto_name.count);
			define := clone(short_name);
			define.replace_all('.','_');
			define.to_upper;
			define.prepend("EXPORT_");
			!!Result.make(4096);
			Result.append("/*%N * ");
			Result.append(short_name);
			Result.append(" -- exported symbols%N");
			Result.append(" *%N * ");
			Result.append("Automatically generated by `");
			Result.append(Program_name);
			Result.append("'. Do not modify!%N");
			Result.append(" */%N%N");
			Result.append("#ifndef ");
			Result.append(define);
			Result.append("%N#define ");
			Result.append(define);
			Result.append("%N%N");
			from 
				i := 1;
			until 
				i > declarations.count
			loop 
				Result.append(declarations.item(i));
				Result.append(";%N");
				i := i + 1;
			end; 
			Result.append("%N#endif /* ");
			Result.append(define);
			Result.append(" */%N");
		ensure 
			Result /= Void; 
		end -- prototype_text
	
	file_contains(file_name, text: STRING): BOOLEAN is 
		-- Does file `file_name' contain exactly the text `text' ?
		require 
			text /= Void; 
		local 
			file_count: INTEGER;
			file: STD_FILE_READ;
			found_mismatch: BOOLEAN;
		do  
			!!file.connect_to(file_name);
			if file.is_connected then 
				from 
					file_count := 0;
				until 
					found_mismatch or file.end_of_input
				loop 
					file.read_character;
					if not file.end_of_input then 
						file_count := file_count + 1;
						found_mismatch := file_count > text.count;
						if found_mismatch then 
							debug ("MAKE_EXPORT_HEADER")
								print("   rewrite needed because file is longer than text%N");
							end; 
						else 
							found_mismatch := file.last_character /= text.item(file_count);
							debug ("MAKE_EXPORT_HEADER")
								if found_mismatch then 
									print("   rewrite needed because of mismatch at position ");
									print(file_count);
									print('%N');
								end; 
							end; 
						end; 
					else 
						found_mismatch := file_count < text.count;
						debug ("MAKE_EXPORT_HEADER")
							if found_mismatch then 
								print("   rewrite needed because file is longer than text%N");
							end; 
						end; 
					end; 
				end; 
				file.disconnect;
				Result := not found_mismatch;
			else 
				debug ("MAKE_EXPORT_HEADER")
					print("   rewrite needed because no old file exists%N");
				end; 
			end; 
		end -- file_contains
	
	write_proto_file is 
		-- Write `declarations' to header file.
		local 
			target: STD_FILE_WRITE;
			proto_text: STRING;
		do  
			print(proto_name);
			print('%N');
			proto_text := prototype_text;
			if not file_contains(proto_name,proto_text) then 
				!!target.connect_to(proto_name);
				if target.is_connected then 
					target.put_string(proto_text);
					target.disconnect;
					print("   ");
					print(declarations.count);
					print(" exportable symbols found%N");
				else 
					error_description := "cannot write %"" + proto_name + "%"";
				end; 
			else 
				print("   left untouched; all ");
				print(declarations.count);
				print(" symbols are up to date%N");
			end; 
		end -- write_proto_file

feature {NONE} 
	-- Implementation

	Program_name: STRING is "make_export_header";
		-- name of this program
	
	export_keyword: STRING is "export";
	
	source_names: ARRAY[STRING];
		-- name of C source file
	
	proto: STD_FILE_WRITE;
		-- prototype header file
	
	proto_name: STRING;
		-- name of prototype header file
	
	error_description: STRING;
		-- description of error
	
	has_error: BOOLEAN is 
		-- Did an error occur ?
		do  
			Result := error_description /= Void;
		ensure 
			Result = (error_description /= Void); 
		end -- has_error
	
	set_arguments is 
		-- Set `proto_name' and `source_names' according to command line.
		local 
			i: INTEGER;
		do  
			if argument_count >= 2 then 
				!!source_names.make(1,0);
				proto_name := argument(1);
				from 
					i := 2;
				until 
					i > argument_count
				loop 
					source_names.add_last(argument(i));
					i := i + 1;
				end; 
			else 
				!!error_description.make(0);
				error_description.append("usage: ");
				error_description.append(Program_name);
				error_description.append(" target.h source1.c source2.c ...");
			end; 
		ensure 
			not has_error implies source_names /= Void and then source_names.count > 0; 
			not has_error implies proto_name /= Void; 
		end -- set_arguments

end -- class MAKE_EXPORT_HEADER
