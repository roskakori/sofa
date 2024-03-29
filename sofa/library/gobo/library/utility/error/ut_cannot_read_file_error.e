indexing

	description:

		"Error: Cannot read file"

	library:    "Gobo Eiffel Utility Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 14:12:11 $"
	revision:   "$Revision: 1.2 $"

class UT_CANNOT_READ_FILE_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING) is
			-- Create a new error reporting that file
			-- `filename' cannot be opened in read mode.
		require
			filename_not_void: filename /= Void
		do
			!! parameters.make (1, 1)
			parameters.put (filename, 1)
		end

feature -- Access

	default_template: STRING is "$0: cannot read '$1'"
			-- Default template used to built the error message

	code: STRING is "UT0003"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename

end -- class UT_CANNOT_READ_FILE_ERROR
