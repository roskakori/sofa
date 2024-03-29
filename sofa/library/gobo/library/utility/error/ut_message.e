indexing

	description:

		"General messages"

	library:    "Gobo Eiffel Utility Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 14:12:28 $"
	revision:   "$Revision: 1.2 $"

class UT_MESSAGE

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (msg: STRING) is
			-- Create a new message object.
		require
			msg_not_void: msg /= Void
		do
			!! parameters.make (1, 1)
			parameters.put (msg, 1)
		end

feature -- Access

	default_template: STRING is "$1"
			-- Default template used to built the error message

	code: STRING is "UT0008"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = message

end -- class UT_MESSAGE
