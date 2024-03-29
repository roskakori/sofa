indexing

	description:

		"Invalid use of $n in semantic action"

	library:    "Gobo Eiffel Parse Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 14:00:06 $"
	revision:   "$Revision: 1.2 $"

class PR_INVALID_DOLLAR_N_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING; line: INTEGER; n: INTEGER) is
			-- Create a new error reporting that $`n' has
			-- been used in a semantic action but `n' is
			-- not a valid index for the rhs of the
			-- corresponding rule.
		require
			filename_not_void: filename /= Void
		do
			!! parameters.make (1, 3)
			parameters.put (filename, 1)
			parameters.put (line.out, 2)
			parameters.put (n.out, 3)
		end

feature -- Access

	default_template: STRING is "%"$1%", line $2: invalid use of $$$3 in semantic action"
			-- Default template used to built the error message

	code: STRING is "PR0019"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename
	-- dollar2: $2 = line number
	-- dollar3: $3 = `n' (as in $n)

end -- class PR_INVALID_DOLLAR_N_ERROR
