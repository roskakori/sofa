indexing

	description:

		"Error: The use of variable trailing context is %
		%incompatible with full tables"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:51:27 $"
	revision:   "$Revision: 1.2 $"

class LX_FULL_AND_VARIABLE_TRAILING_CONTEXT_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make is
			-- Create a new error reporting that the use
			-- of variable trailing context is incompatible
			-- with full tables.
		do
			!! parameters.make (1, 0)
		end

feature -- Access

	default_template: STRING is
		"$0: variable trailing context rules cannot be used with -f"
			-- Default template used to built the error message

	code: STRING is "LX0029"
			-- Error code

invariant

	-- dollar0: $0 = program name

end -- class LX_FULL_AND_VARIABLE_TRAILING_CONTEXT_ERROR
