indexing

	description:

		"Imported routines that ought to be in class FIXED_ARRAY. %
		%A fixed array is a zero-based indexed sequence of values, %
		%equipped with features `put', `item' and `count'."

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 2000/02/02 10:25:29 $"
	revision:   "$Revision: 1.3 $"

class KL_IMPORTED_FIXED_ARRAY_ROUTINES

feature -- Access

	FIXED_ANY_ARRAY_: KL_FIXED_ARRAY_ROUTINES [ANY] is
			-- Routines that ought to be in class FIXED_ARRAY
		once
			!! Result
		ensure
			fixed_any_array_routines_not_void: Result /= Void
		end

	FIXED_BOOLEAN_ARRAY_: KL_FIXED_ARRAY_ROUTINES [BOOLEAN] is
			-- Routines that ought to be in class FIXED_ARRAY
		once
			!! Result
		ensure
			fixed_boolean_array_routines_not_void: Result /= Void
		end

	FIXED_INTEGER_ARRAY_: KL_FIXED_ARRAY_ROUTINES [INTEGER] is
			-- Routines that ought to be in class FIXED_ARRAY
		once
			!! Result
		ensure
			fixed_integer_array_routines_not_void: Result /= Void
		end

	FIXED_STRING_ARRAY_: KL_FIXED_ARRAY_ROUTINES [STRING] is
			-- Routines that ought to be in class FIXED_ARRAY
		once
			!! Result
		ensure
			fixed_string_array_routines_not_void: Result /= Void
		end

feature -- Type anchors

	FIXED_ANY_ARRAY_TYPE: ARRAY [ANY] is do end
	FIXED_BOOLEAN_ARRAY_TYPE: ARRAY [BOOLEAN] is do end
	FIXED_INTEGER_ARRAY_TYPE: ARRAY [INTEGER] is do end
	FIXED_STRING_ARRAY_TYPE: ARRAY [STRING] is do end
			-- Type anchors

end -- class KL_IMPORTED_FIXED_ARRAY_ROUTINES
