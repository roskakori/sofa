indexing

	description:

		"States of finite automata"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:49:59 $"
	revision:   "$Revision: 1.3 $"

deferred class LX_STATE

feature -- Status report

	is_accepting: BOOLEAN is
			-- Is current state an accepting state?
		deferred
		end

end -- class LX_STATE
