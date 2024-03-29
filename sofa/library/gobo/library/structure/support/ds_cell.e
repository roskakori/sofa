indexing

	description:

		"Cells containing an item"

	library:    "Gobo Eiffel Structure Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/09/01 12:52:20 $"
	revision:   "$Revision: 1.3 $"

class DS_CELL [G]

creation

	make

feature -- Access

	item: G 
			-- Content of cell

feature -- Element change

	put, make (v: G) is
			-- Insert `v' in cell.
		do
			item := v
		ensure
			inserted: item = v
		end

end -- class DS_CELL
