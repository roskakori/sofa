indexing
	description: "Scan archive for .e files with too long names, create a %
					 %rename.se file from it and rename all filenames that %
					 %have been cut to have fitting names.";

class MAKE_RENAME_SE

inherit 
	SHARED_PARAMETERS;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		do  
			set_parameters;
			if not has_error then 
				list_archive;
			end; 
			if not has_error then 
				read_list;
			end; 
			if not has_error then 
				generate_short_names;
			end; 
			if not has_error then 
				rename_directory_list;
			end; 
			if has_error then 
				set_quiet(false);
				print_status_line(error_message)
			end 
			file_tools.delete(Temporary_filename)
				-- rescue
				--    if exceptions.is_signal then
				--       print("*** Break%N")
				--       file_tools.delete(Temporary_filename)
				--    end
			
		end -- make

feature {NONE} 
	-- Implementation

	directory_list: DICTIONARY[CLASS_DIRECTORY,STRING];
	
	exceptions: expanded EXCEPTIONS;

feature {NONE} 
	-- Implementation

	Temporary_filename: STRING is "mkrnse.tmp";
	
	list_archive is 
		-- Write names of file containes in `archive_path' to
		-- `Temporary_filename'.
		require 
			valid_archive: archive_path /= Void and then archive_path.count > 5 and then archive_path.has_suffix(".zip"); 
		local 
			unzip: STRING;
		do  
			unzip := "unzip -l >";
			unzip.append(Temporary_filename);
			unzip.append(" %"");
			unzip.append(archive_path);
			unzip.append("%"");
			print_status_line(unzip);
			system(unzip);
		end -- list_archive
	
	read_list is 
		-- Read list from `Temporary_filename' to `name'.
		local 
			list: STD_FILE_READ;
			line: STRING;
			full_name: STRING;
		do  
			!!list.connect_to(Temporary_filename);
			if list.is_connected then 
				print_status_line("read archive list");
				from 
					!!directory_list.make;
				until 
					list.end_of_input
				loop 
					list.read_line;
					if not list.end_of_input then 
						line := clone(list.last_string);
						full_name := eiffel_class_filename(line);
						if full_name /= Void then 
							debug ("MAKE_RENAME_SE")
								print_status(full_name);
							end; 
							add_to_class_list(full_name);
						end; 
					end; 
				end; 
				list.disconnect;
				print_status("");
			else 
				set_error_message("cannot read archive list from %"" + archive_path + "%"");
			end; 
		ensure 
			directory_created: not has_error implies directory_list /= Void; 
		end -- read_list
	
	add_to_class_list(full_name: STRING) is 
		-- Add class `name' to `directory'. If necessary, create new
		-- `CLASS_DIRECTORY' first.
		require 
			valid_full_name: full_name /= Void and then full_name.count >= 3; 
		local 
			class_directory: CLASS_DIRECTORY;
			class_file: CLASS_FILE;
			directory: STRING;
			name: STRING;
			last_slash: INTEGER;
		do  
			from 
				last_slash := full_name.count;
			until 
				last_slash = 0 or else full_name.item(last_slash) = '/'
			loop 
				last_slash := last_slash - 1;
			end; 
			if last_slash = 0 then 
				directory := "";
				name := clone(full_name);
			else 
				directory := full_name.substring(1,last_slash);
				name := full_name.substring(last_slash + 1,full_name.count);
			end; 
			name.head(name.count - 2);
			debug ("MAKE_RENAME_SE")
				print_status_line(full_name);
				print_status_line("   " + directory);
				print_status_line("   " + name);
			end; 
			if not directory_list.has(directory) then 
				!!class_directory.make(directory);
				directory_list.put(class_directory,directory);
			else 
				class_directory := directory_list.at(directory);
			end; 
			if not class_directory.class_list.has(name) then 
				!!class_file.make(name);
				class_directory.class_list.put(class_file,name);
			else 
				set_error_message("class %"" + name + "%" must be unique within directory %"" + directory + "%"");
			end; 
			check 
				directory_list.has(directory); 
				directory_list.at(directory).class_list.has(name); 
			end;
		end -- add_to_class_list
	
	eiffel_class_filename(line: STRING): STRING is 
		-- Full filename if `line' contains a ".e" file or Void if not.
		require 
			valid_line: line /= Void; 
		local 
			e_index: INTEGER;
			start_index: INTEGER;
			end_index: INTEGER;
			is_class_filename: BOOLEAN;
			found_start: BOOLEAN;
		do  
			-- index where ".e" is located in `line'
			-- index of first letter part of full filename
			-- index of last letter part of full filename
			-- Does `line' contain a full filename somewhere?
			e_index := line.index_of_string(".e");
			if e_index < line.count then 
				end_index := e_index + 1;
				if end_index = line.count then 
					is_class_filename := true;
				else 
					is_class_filename := line.item(end_index + 1).is_separator;
				end; 
			end; 
			if is_class_filename then 
				from 
					start_index := e_index;
				until 
					found_start
				loop 
					start_index := start_index - 1;
					found_start := line.item(start_index).is_separator;
					if found_start then 
						start_index := start_index + 1;
					else 
						found_start := start_index = 1;
					end; 
				end; 
				Result := line.substring(start_index,end_index);
			end; 
		ensure 
			valid_result: Result /= Void implies Result.has_suffix(".e") and then Result.count >= 3; 
		end -- eiffel_class_filename
	
	is_eiffel_name(name: STRING): BOOLEAN is 
		-- Is `name' a valid Eiffel name?
		require 
			valid_name: name /= Void; 
		local 
			index: INTEGER;
			letter: CHARACTER;
		do  
			if name.count > 0 and then name.item(1).is_letter then 
				Result := true;
				from 
					index := 2;
				variant 
				name.count - index
				until 
					index > name.count
				loop 
					letter := name.item(index);
					if not (letter.is_letter or else letter.is_digit or else letter = '_') then 
						Result := false;
					end; 
					index := index + 1;
				end; 
			end; 
		end -- is_eiffel_name

feature {NONE} 
	-- Generate short names

	unique_short_name(directory: CLASS_DIRECTORY; name: STRING): STRING is 
		-- Shortend name of `name' that is unique within `directory'.
		require --valid_directory: directory =/ Void and then directory_list.at(directory.name) = directory
			valid_name: name /= Void and then directory.class_list.has(name); 
		local 
			unique_count: INTEGER;
			short_name: STRING;
			class_directory: CLASS_DIRECTORY;
			unique_suffix: STRING;
			short_stem_count: INTEGER;
		do  
			debug ("MAKE_RENAME_SE")
				print_status_line("   unique_short_name (" + directory.name + ", " + name + ")");
			end; 
			from 
				class_directory := directory_list.at(directory.name);
				short_name := clone(name);
				short_name.head(short_count);
			variant 
			directory.class_list.count - unique_count
			until 
				not class_directory.has_short_name(short_name) or else has_error
			loop 
				debug ("MAKE_RENAME_SE")
					print_status("   try with " + unique_count.to_string);
				end; 
				unique_count := unique_count + 1;
				unique_suffix := unique_count.to_string;
				unique_suffix.precede('_');
				short_stem_count := short_count - unique_suffix.count;
				if short_stem_count > 0 then 
					short_name := clone(name);
					short_name.head(short_stem_count);
					short_name.append(unique_suffix);
					print_status_line("  -> " + short_name);
				else 
					set_error_message("length must be at least " + (short_count + 1).to_string);
				end; 
			end; 
			Result := short_name;
		ensure 
			valid_result: Result /= Void; 
			valid_eiffel: is_eiffel_name(Result.substring(1,Result.count)); 
			valid_count: Result.count <= short_count; 
			no_duplicate: not directory_list.at(directory.name).has_short_name(Result); 
		end -- unique_short_name
	
	generate_short_names is 
		-- Generate short names for all classes with too long names. For all
		-- other classes, the original name is used.
		require 
			valid_directory_list: directory_list /= Void; 
		local 
			directory_index: INTEGER;
			class_index: INTEGER;
			class_file: CLASS_FILE;
			directory: CLASS_DIRECTORY;
			pass: INTEGER;
			short_name: STRING;
		do  
			print_status_line("analyze");
			from 
				directory_index := 1;
			variant 
			directory_list.count - directory_index
			until 
				directory_index > directory_list.count or else has_error
			loop 
				directory := directory_list.item(directory_index);
				print_status_line("   " + directory.name);
				from 
					pass := 0;
				variant 
				1 - pass
				until 
					pass > 1 or else has_error
				loop 
					from 
						class_index := 1;
					variant 
					directory.class_list.count - class_index
					until 
						class_index > directory.class_list.count or else has_error
					loop 
						class_file := directory.class_list.item(class_index);
						inspect 
							pass
						when 0 then 
								if class_file.name.count <= short_count - 1 then 
									class_file.set_short_name(class_file.name)
								end 
						when 1 then 
								if class_file.short_name = Void then 
									debug ("MAKE_RENAME_SE")
										print_status_line("SHORTEN " + directory.name + class_file.name)
									end; 
									short_name := clone(unique_short_name(directory,class_file.name));
									debug ("MAKE_RENAME_SE")
										print_status_line(short_name + " <- " + class_file.name)
									end; 
									class_file.set_short_name(short_name);
									class_file.set_extraction_needed(true);
									directory.increase_shortened_count
								end 
						end; 
						class_index := class_index + 1;
					end; 
					pass := pass + 1;
				end; 
				directory_index := directory_index + 1;
			end; 
		end -- generate_short_names

feature {NONE} 
	-- Extract and rename

	rename_directory(directory: CLASS_DIRECTORY) is 
		-- Extract shortend classes in `directory' from `archive_path',
		-- rename them to shortened name and
		--
		-- This is done in two passes: pass 1 extracts and renames all files
		-- for which shortened names have to be created. Pass 2 extracts all
		-- files whose name has exactly `size_count' characters. The second
		-- pass is necessary to guarantee that pass 2 files have not been
		-- accidentally overwritten when extracting the pass 1 files whose
		-- name has been cut-off by the file system.
		require 
			valid_directory: directory /= Void; 
			necessary: directory.shortened_count > 0; 
		local 
			class_file: CLASS_FILE;
			class_index: INTEGER;
			pass: INTEGER;
			names_equal: BOOLEAN;
			class_extracted: BOOLEAN;
			rename_se_path: STRING;
			rename_se_file: STD_FILE_WRITE;
			rename_line: STRING;
			short_name: STRING
			long_name: STRING
		do  
			print_status_line("rename " + directory.name);
			rename_se_path := directory.name + "rename.se";
			!!rename_se_file.connect_to(rename_se_path);
			if rename_se_file.is_connected then 
				from 
					pass := 1;
				until 
					pass > 2 or else has_error
				loop 
					from 
						class_index := 1;
					variant 
					directory.class_list.count - class_index
					until 
						class_index > directory.class_list.count or else has_error
					loop 
						class_file := directory.class_list.item(class_index);
						if class_file.extraction_needed then 
							names_equal := class_file.name.is_equal(class_file.short_name);
							long_name := directory.name + class_file.name + ".e"
							short_name := directory.name + class_file.short_name + ".e"
							class_extracted := false;
							inspect 
								pass
							when 1 then 
									if not names_equal then 
										print("   " + class_file.short_name + ".e <- " + class_file.name + ".e%N")
										file_tools.delete(long_name)
										class_file.extract_as_shortened(directory.name);
										class_extracted := true
									end 
							when 2 then 
									if names_equal then 
										print("   " + class_file.name + ".e%N")
										class_file.extract(directory.name);
										class_extracted := true
									end 
							end; 
							if class_extracted then 
								if class_file.extracted then 
									if pass = 1 then 
										rename_line := class_file.name + ".e " + class_file.short_name + ".e%N";
										rename_se_file.put_string(rename_line);
									end; 
								else 
									set_error_message("cannot extract %"" + class_file.old_path + "%" as %"" + class_file.new_path + "%" from %"" + archive_path + "%"");
								end; 
							end; 
						end; 
						class_index := class_index + 1;
					end; 
					pass := pass + 1;
				end; 
				rename_se_file.disconnect;
			else 
				set_error_message("cannot write %"" + rename_se_path + "%"");
			end; 
		end -- rename_directory
	
	rename_directory_list is 
		-- Extract and rename all shortened classes in all directories in
		-- `directory_list'.
		require 
			valid_list: directory_list /= Void; 
		local 
			directory_index: INTEGER;
			directory: CLASS_DIRECTORY;
			directories_renamed: INTEGER;
		do  
			from 
				directory_index := 1;
			variant 
			directory_list.count - directory_index
			until 
				directory_index > directory_list.count or else has_error
			loop 
				directory := directory_list.item(directory_index);
				if directory.shortened_count > 0 then 
					rename_directory(directory);
					directories_renamed := directories_renamed + 1;
				end; 
				directory_index := directory_index + 1;
			end; 
			if not has_error and then directories_renamed = 0 then 
				print_status_line("no classes to rename");
			end; 
		end -- rename_directory_list

feature {NONE} 
	-- Status message

	maximum_status_count: INTEGER;
	
	print_status(text: STRING) is 
		-- Print `text' in status line and set cursor at beginning of it.
		require 
			valid_text: text /= Void; 
		local 
			blanks: STRING;
		do  
			if not quiet then 
				if maximum_status_count < text.count then 
					maximum_status_count := text.count;
				end; 
				!!blanks.blank(maximum_status_count - text.count);
				print(text);
				print(blanks);
				print("%R");
				std_output.flush;
			end; 
		ensure 
			updated: not quiet implies maximum_status_count >= text.count; 
		end -- print_status
	
	print_status_line(text: STRING) is 
		-- Print `text' in status line and goto next line.
		require 
			valid_text: text /= Void; 
		do  
			if not quiet then 
				clear_status;
				print(text);
				print('%N');
			end; 
		end -- print_status_line
	
	clear_status is 
		-- Clear status line.
		do  
			if not quiet then 
				print_status("");
				maximum_status_count := 0;
			end; 
		ensure 
			cleared: maximum_status_count = 0; 
		end -- clear_status

end -- class MAKE_RENAME_SE
