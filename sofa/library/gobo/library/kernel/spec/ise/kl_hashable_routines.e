indexing

	description:

		"Routines that ought to be in class HASHABLE"

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:45:37 $"
	revision:   "$Revision: 1.3 $"

class KL_HASHABLE_ROUTINES

feature -- Access

	hash_value (an_any: ANY): INTEGER is
			-- Hash code value
		require
			an_any_not_void: an_any /= Void
		local
			hashable: HASHABLE
		do
			hashable ?= an_any
			if hashable /= Void then
				Result := hashable.hash_code
			else
				Result := generator.hash_code
			end
		ensure
			hash_value_positive: Result >= 0
		end

end -- class KL_HASHABLE_ROUTINES
