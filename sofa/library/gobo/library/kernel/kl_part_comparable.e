indexing

	description:

		"Objects that may be compared according to a partial order relation"

	note:      "The basic operation is < (less than); others %
	            %are defined in terms of this operation and is_equal."
	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 2000, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 2000/04/16 13:00:03 $"
	revision:   "$Revision: 1.1 $"

deferred class KL_PART_COMPARABLE

feature -- Comparison

	infix "<" (other: like Current): BOOLEAN is
			-- Is current object less than `other'?
		require
			other_not_void: other /= Void
		deferred
		end

	infix "<=" (other: like Current): BOOLEAN is
			-- Is current object less than or equal to `other'?
		require
			other_not_void: other /= Void
		do
			Result := (Current < other) or is_equal (other)
		ensure
			definition: Result = ((Current < other) or is_equal (other))
		end

	infix ">" (other: like Current): BOOLEAN is
			-- Is current object greater than `other'?
		require
			other_not_void: other /= Void
		do
			Result := other < Current
		ensure
			definition: Result = (other < Current)
		end

	infix ">=" (other: like Current): BOOLEAN is
			-- Is current object greater than or equal to `other'?
		require
			other_not_void: other /= Void
		do
			Result := (other < Current) or is_equal (other)
		ensure
			definition: Result = ((other < Current) or is_equal (other))
		end

end -- class KL_PART_COMPARABLE
