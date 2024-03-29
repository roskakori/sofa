indexing

	description:

		"General finite-state automata"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:49:31 $"
	revision:   "$Revision: 1.3 $"

deferred class LX_AUTOMATON

feature -- Access

	start_state: LX_STATE is
			-- Automaton's start state
		deferred
		ensure
			start_state_not_void: Result /= Void
		end

end -- class LX_AUTOMATON
