indexing

	description:

		"Imported routines that ought to be in class HASHABLE"

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:45:55 $"
	revision:   "$Revision: 1.2 $"

class KL_IMPORTED_HASHABLE_ROUTINES

feature -- Access

	HASHABLE_: KL_HASHABLE_ROUTINES is
			-- Routines that ought to be in class HASHABLE
		once
			!! Result
		ensure
			hashable_routines_not_void: Result /= Void
		end

end -- class KL_IMPORTED_HASHABLE_ROUTINES
