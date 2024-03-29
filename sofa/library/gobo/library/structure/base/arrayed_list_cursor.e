indexing

	description:

		"EiffelBase ARRAYED_LIST_CURSOR class interface"

	library:    "Gobo Eiffel Structure Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/09/01 12:25:10 $"
	revision:   "$Revision: 1.1 $"

class ARRAYED_LIST_CURSOR

inherit

	CURSOR

creation

	make

feature {NONE} -- Initialization

	make (p: INTEGER) is
			-- Set `position' to `p'.
		do
			position := p
		ensure
			position_set: position = p
		end

feature -- Access

	position: INTEGER
			-- Internal position in arrayed list

end -- class ARRAYED_LIST_CURSOR
