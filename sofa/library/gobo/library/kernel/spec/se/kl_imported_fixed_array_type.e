indexing

	description:

		"Imported type anchor for FIXED_ARRAY [G]. %
		%A fixed array is a zero-based indexed sequence of values, %
		%equipped with features `put', `item' and `count'."

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 2000/02/02 10:25:59 $"
	revision:   "$Revision: 1.3 $"

class KL_IMPORTED_FIXED_ARRAY_TYPE [G]

feature -- Type anchors

	FIXED_ARRAY_TYPE: FIXED_ARRAY [G] is do end
			-- Type anchor

end -- class KL_IMPORTED_FIXED_ARRAY_TYPE
