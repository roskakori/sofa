indexing

	description:

		"Imported type anchor for FIXED_ARRAY [G]. %
		%A fixed array is a zero-based indexed sequence of values, %
		%equipped with features `put', `item' and `count'."

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:45:50 $"
	revision:   "$Revision: 1.2 $"

class KL_IMPORTED_FIXED_ARRAY_TYPE [G]

feature -- Type anchors

	FIXED_ARRAY_TYPE: ARRAY [G] is do end
			-- Type anchor

end -- class KL_IMPORTED_FIXED_ARRAY_TYPE
