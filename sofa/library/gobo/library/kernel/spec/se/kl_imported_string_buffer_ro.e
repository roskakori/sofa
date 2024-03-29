indexing

	description:

		"Imported routines that ought to be in class STRING_BUFFER. %
		%A string buffer is a sequence of characters equipped with %
		%features `put', `item' and `count'."

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:46:13 $"
	revision:   "$Revision: 1.2 $"

class KL_IMPORTED_STRING_BUFFER_ROUTINES

feature -- Access

	STRING_BUFFER_: KL_STRING_BUFFER_ROUTINES is
			-- Routines that ought to be in class STRING_BUFFER
		once
			!! Result
		ensure
			string_buffer_routines_not_void: Result /= Void
		end

feature -- Type anchors

	STRING_BUFFER_TYPE: STRING is do end
			-- Type anchor

end -- class KL_IMPORTED_STRING_BUFFER_ROUTINES
