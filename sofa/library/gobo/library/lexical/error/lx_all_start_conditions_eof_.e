indexing

	description:

		"Error: All start conditions already have EOF rules"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:50:31 $"
	revision:   "$Revision: 1.2 $"

class LX_ALL_START_CONDITIONS_EOF_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING; line: INTEGER) is
			-- Create a new error reporting that all
			-- start conditions already have EOF rules.
		require
			filename_not_void: filename /= Void
		do
			!! parameters.make (1, 2)
			parameters.put (filename, 1)
			parameters.put (line.out, 2)
		end

feature -- Access

	default_template: STRING is
		"Warning, %"$1%", line $2: all start conditions already have <<EOF>> rules"
			-- Default template used to built the error message

	code: STRING is "LX0002"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename
	-- dollar2: $2 = line number

end -- class LX_ALL_START_CONDITIONS_EOF_ERROR
