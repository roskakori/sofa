indexing

	description:

		"Error: Default rule can be matched %
		%despite the nodefault or -s option"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:51:11 $"
	revision:   "$Revision: 1.3 $"

class LX_DEFAULT_RULE_CAN_BE_MATCHED_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (filename: STRING) is
			-- Create a new error reporting that the rule
			-- default can be matched despite the "nodefault"
			-- or -s option.
		require
			filename_not_void: filename /= Void
		do
			!! parameters.make (1, 1)
			parameters.put (filename, 1)
		end

feature -- Access

	default_template: STRING is
		"Warning, %"$1%": nodefault or -s option given but default rule can be matched"
			-- Default template used to built the error message

	code: STRING is "LX0031"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename

end -- class LX_DEFAULT_RULE_CAN_BE_MATCHED_ERROR
