indexing

	description:

		"Error: Missing characters"

	library:    "Gobo Eiffel Parse Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 14:00:14 $"
	revision:   "$Revision: 1.2 $"

class PR_MISSING_CHARACTERS_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING; line: INTEGER; chars: STRING) is
			-- Create a new error reporting that
			-- `chars' is missing.
		require
			filename_not_void: filename /= Void
			chars_not_void: chars /= Void
		do
			!! parameters.make (1, 3)
			parameters.put (filename, 1)
			parameters.put (line.out, 2)
			parameters.put (chars, 3)
		end

feature -- Access

	default_template: STRING is "%"$1%", line $2: missing $3"
			-- Default template used to built the error message

	code: STRING is "PR0001"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename
	-- dollar2: $2 = line number
	-- dollar3: $3 = missing characters

end -- class PR_MISSING_CHARACTERS_ERROR
