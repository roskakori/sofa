indexing

	description:

		"Linkable cells with a reference to their right neighbor"

	library:    "Gobo Eiffel Structure Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/09/01 12:52:26 $"
	revision:   "$Revision: 1.3 $"

class DS_LINKABLE [G]

inherit

	DS_CELL [G]

creation

	make

feature -- Access

	right: like Current
			-- Right neighbor

feature -- Element change

	put_right (other: like Current) is
			-- Put `other' to right of cell.
		require
			other_not_void: other /= Void
		do
			right := other
		ensure
			linked: right = other
		end

	forget_right is
			-- Remove right neighbor.
		do
			right := Void
		ensure
			forgotten: right = Void
		end

end -- class DS_LINKABLE
