indexing
	description: "Private parameters to be used as shared object by `PARAMETERS'.";

class PARAMETERS

feature {SHARED_PARAMETERS} 
	-- Status report

	archive_path: STRING;
		-- Name of archive that contains full class names
	
	quiet: BOOLEAN;
		-- Don't display status messages?
	
	short_count: INTEGER;
		-- Maximum count of a shortened class name
	
feature {SHARED_PARAMETERS} 
	-- Access

	set_archive_path(new_path: STRING) is 
		require 
			valid_path: new_path /= Void; 
		do  
			archive_path := clone(new_path);
		ensure 
			archive_path_set: archive_path.is_equal(new_path); 
		end -- set_archive_path
	
	set_quiet(new_quiet: BOOLEAN) is 
		do  
			quiet := new_quiet;
		ensure 
			quiet_set: quiet = new_quiet; 
		end -- set_quiet
	
	set_short_count(new_count: INTEGER) is 
		require 
			new_count >= 3; 
		do  
			short_count := new_count;
		ensure 
			short_count_set: short_count = new_count; 
		end -- set_short_count

end -- class PARAMETERS
