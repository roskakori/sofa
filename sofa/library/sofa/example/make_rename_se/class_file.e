indexing
	description: "Describes one class.";

class CLASS_FILE

inherit 
	SHARED_PARAMETERS;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make(new_name: STRING) is 
		require 
			valid_new_name: new_name /= Void and then new_name.count >= 1 and then not new_name.has('.'); 
		do  
			name := clone(new_name);
		ensure 
			no_short_name: short_name = Void; 
		end -- make

feature {ANY} -- Status report

	name: STRING;
	
	short_name: STRING;
	
	shortened: BOOLEAN is 
		-- Is `short_name' different from `name'?
		require 
			has_short_name: short_name /= Void; 
		do  
			Result := name.is_equal(short_name);
		end -- shortened
	
	extraction_needed: BOOLEAN;
		-- Should `name' be extracted from archive?
	
feature {ANY} -- Access

	set_extraction_needed(new_extraction_needed: BOOLEAN) is 
		-- Set `extraction_needed' to `new_extraction_needed'.
		do  
			extraction_needed := new_extraction_needed;
		ensure 
			extraction_needed_set: extraction_needed.is_equal(new_extraction_needed); 
		end -- set_extraction_needed
	
	set_short_name(new_short_name: STRING) is 
		-- Set `short_name' to `new_short_name'.
		require 
			valid_short_name: new_short_name /= Void and then new_short_name.count >= 1 and then new_short_name.count <= name.count; 
		do  
			short_name := clone(new_short_name);
		ensure 
			short_name_set: new_short_name.is_equal(short_name); 
		end -- set_short_name

feature {ANY} -- Extraction

	extract(directory_path: STRING) is 
		-- Extract class `name' in directory `directory_path' from
		-- `archive_path'.
		local 
			unzip_command: STRING;
		do  
			old_path := clone(directory_path);
			old_path.append(name);
			old_path.append(".e");
			old_rename_path := Void;
			new_path := Void;
				-- useful unzip options:
				--
				-- -q  quiet mode (-qq => quieter)
				-- -a  auto-convert any text files
				-- -aa treat ALL files as text
				-- -o  overwrite files WITHOUT prompting
				-- -C  match filenames case-insensitively
				-- -N  restore comments as filenotes
			unzip_command := clone("unzip -o -N -aa");
			if true then 
				unzip_command.append(" -q");
			end; 
			unzip_command.append(" %"" + archive_path + "%" %"" + old_path + "%"");
			debug ("CLASS_FILE")
				print(unzip_command + "%N");
			end; 
			system(unzip_command);
			extracted := file_tools.is_readable(old_path);
		end -- extract
	
	extract_as_shortened(directory_path: STRING) is 
		-- Extract class `name' in directory `directory_path' from
		-- `archive_path' and rename it to `short_path'.
		require 
			necessary: extraction_needed; 
		do  
			extract(directory_path);
			old_rename_path := name + ".e";
			-- old_rename_path.head(short_count + 2);
			old_rename_path.prepend(directory_path);
			new_path := directory_path + short_name + ".e";
			debug ("CLASS_FILE")
				print("rename%N");
				print("   " + old_rename_path + "%N");
				print("   " + new_path + "%N");
			end; 
			file_tools.rename_to(old_rename_path,new_path);
			extracted := file_tools.is_readable(new_path);
		end -- extract_as_shortened
	
	old_path: STRING;
		-- Original path of class file in archive
	
	old_rename_path: STRING;
		-- Possible cut-off version of `old_path' file system created
	
	new_path: STRING;
		-- Path of renamed class file extracted
	
	extracted: BOOLEAN;
		-- Was last `extract' or `extract_as_shortened' successful?
	
invariant 
	
	valid_name: name /= Void and then not name.empty; 
	
	valid_short_name: short_name /= Void implies not short_name.empty; 
	
	consistent_name_count: short_name /= Void implies name.count >= short_name.count; 

end -- class CLASS_FILE
