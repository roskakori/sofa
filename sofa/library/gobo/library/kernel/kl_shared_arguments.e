indexing

	description:

		"Shared command-line arguments"

	pattern:    "Singleton"
	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:46:40 $"
	revision:   "$Revision: 1.2 $"

class KL_SHARED_ARGUMENTS

feature -- Access

	Arguments: KL_ARGUMENTS is
			-- Command-line arguments
		once
			!! Result.make
		ensure
			arguments_not_void: Result /= Void
		end

end -- class KL_SHARED_ARGUMENTS
