indexing

	description:

		"Error: Undefined symbol"

	library:    "Gobo Eiffel Parse Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 14:01:09 $"
	revision:   "$Revision: 1.2 $"

class PR_UNDEFINED_SYMBOL_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING; a_name: STRING) is
			-- Create a new error reporting that the symbol
			-- `a_name' has not been defined as a token or
			-- in a rule.
		require
			filename_not_void: filename /= Void
			a_name_not_void: a_name /= Void
		do
			!! parameters.make (1, 2)
			parameters.put (filename, 1)
			parameters.put (a_name, 2)
		end

feature -- Access

	default_template: STRING is "%"$1%": undefined symbol $2"
			-- Default template used to built the error message

	code: STRING is "PR0010"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename
	-- dollar2: $2 = symbol name

end -- class PR_UNDEFINED_SYMBOL_ERROR
