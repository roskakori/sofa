indexing

	description:

		"Filesystem's directories"

	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 2000/02/02 10:22:07 $"
	revision:   "$Revision: 1.1 $"

class KL_DIRECTORY

inherit

	FIND_FILES
		rename
			make as ve_make
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make (a_name: STRING) is
			-- Create a new directory object.
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: not a_name.empty
		local
			a_mask: STRING
		do
			name := a_name
			a_mask := clone (a_name)
			a_mask.append_string (Slash_star)
			ve_make (a_mask, False, True, False, False)
		ensure
			name_set: name = a_name
		end

feature -- Access

	name: STRING
			-- Directory name

	last_entry: STRING is
			-- Last entry (file or subdirectory name) read
		require
			is_open_read: is_open_read
			not_end_of_input: not end_of_input
		do
			if position < filenames.lower then
					-- `read_entry' not called yet!!
				Result := ""
			else
				Result := filenames.item (position)
			end
		ensure
			last_entry_not_void: Result /= Void
		end

feature -- Status report

	is_open_read: BOOLEAN is
			-- Has directory been opened in read mode?
		do
			Result := filenames /= Void
		ensure
			not_closed: Result implies not is_closed
		end

	is_closed: BOOLEAN is
			-- Is directory closed?
		do
			Result := filenames = Void
		end

	end_of_input: BOOLEAN is
			-- Have all entries been read?
		require
			is_open_read: is_open_read
		do
			Result := position > filenames.upper
		end

feature -- Basic operations

	open_read is
			-- Try to open directory in read mode.  Set `is_open_read'
			-- to true and is ready to read first entry in directory
			-- if operation was successful.
		require
			closed: is_closed
		local
			rescued: BOOLEAN
		do
			if not rescued then
				filenames := files
				if filenames = Void then
					filenames := Empty_filenames
				end
				position := filenames.lower - 1
			elseif not is_closed then
				close
			end
		ensure
			not_end_of_input: is_open_read implies not end_of_input
		rescue
			if not rescued then
				rescued := True
				retry
			end
		end

	close is
			-- Close directory.
		require
			not_closed: not is_closed
		do
			filenames := Void
		ensure
			closed: is_closed
		end

feature -- Cursor movement

	read_entry is
			-- Read next entry in directory.
			-- Make result available in `last_entry'.
		require
			is_open_read: is_open_read
			not_end_of_input: not end_of_input
		do
			position := position + 1
		end

feature {NONE} -- Implementation

	filenames: ARRAY [STRING]
			-- Filenames in directory

	position: INTEGER
			-- Current position in `filenames'

	Slash_star: STRING is "/*"
			-- Mask suffix

	Empty_filenames: ARRAY [STRING] is
			-- Empty array of filenames
		once
			!! Result.make (1, 0)
		ensure
			Empty_filenames_not_void: Result /= Void
		end

invariant

	name_not_void: name /= Void
	name_not_empty: not name.empty

end -- class KL_DIRECTORY
