indexing

	description:

		"Error: Name defined twice"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:51:52 $"
	revision:   "$Revision: 1.2 $"

class LX_NAME_DEFINED_TWICE_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING; line: INTEGER; name: STRING) is
			-- Create a new error reporting that
			-- `name' has been defined twice.
		require
			filename_not_void: filename /= Void
			name_not_void: name /= Void
		do
			!! parameters.make (1, 3)
			parameters.put (filename, 1)
			parameters.put (line.out, 2)
			parameters.put (name, 3)
		end

feature -- Access

	default_template: STRING is "%"$1%", line $2: name '$3' defined twice"
			-- Default template used to built the error message

	code: STRING is "LX0015"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename
	-- dollar2: $2 = line number
	-- dollar3: $3 = name

end -- class LX_NAME_DEFINED_TWICE_ERROR
