indexing

	description:

		"Error: Bad iteration values"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:50:49 $"
	revision:   "$Revision: 1.2 $"

class LX_BAD_ITERATION_VALUES_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING; line: INTEGER) is
			-- Create a new error reporting that the iteration
			-- values in a regular expression are bad.
		require
			filename_not_void: filename /= Void
		do
			!! parameters.make (1, 2)
			parameters.put (filename, 1)
			parameters.put (line.out, 2)
		end

feature -- Access

	default_template: STRING is "%"$1%", line $2: bad iteration values"
			-- Default template used to built the error message

	code: STRING is "LX0006"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename
	-- dollar2: $2 = line number

end -- class LX_BAD_ITERATION_VALUES_ERROR
