indexing
	description: "Describes all class files of a certain directory";

class CLASS_DIRECTORY

inherit
	SHARED_PARAMETERS

creation {ANY} 
	make

feature {ANY} -- Initialization

	make(new_name: STRING) is 
		require 
			valid_name: new_name /= Void; 
		do  
			name := clone(new_name);
			!!class_list.make;
		end -- make

feature {ANY} 
	
	name: STRING;
	
	class_list: DICTIONARY[CLASS_FILE,STRING];
	
	has_short_name(short_name: STRING): BOOLEAN is 
		-- Is a class with `short_name' stored in `class_list'?
		require 
			valid_short_name: short_name /= Void and then short_name.count >= 1; 
		local 
			index: INTEGER;
			class_file: CLASS_FILE;
		do  
			from 
				index := 1;
			variant 
			class_list.count - index
			until 
				Result or else index > class_list.count
			loop 
				class_file := class_list.item(index);
				if class_file.short_name /= Void then 
					Result := class_file.short_name.is_equal(short_name);
				end; 
				index := index + 1;
			end; 
		end -- has_short_name
	
	shortened_count: INTEGER;
	
	increase_shortened_count is 
		-- Increase `shortened_count' by 1.
		do  
			shortened_count := shortened_count + 1;
		ensure 
			increased: shortened_count = old shortened_count + 1; 
			positive: shortened_count >= 1; 
		end -- increase_shortened_count
	
	reset_shortened_count is 
		-- Reset `shortened_count'.
		do  
			shortened_count := 0;
		ensure 
			reseted: shortened_count = 0; 
		end -- reset_shortened_count

invariant 
	
	valid_shortened_count: shortened_count >= 0; 

end -- class CLASS_DIRECTORY
