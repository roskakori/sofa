indexing

	description:

		"Equality testers"

	library:    "Gobo Eiffel Structure Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/09/01 12:52:05 $"
	revision:   "$Revision: 1.1 $"

class DS_EQUALITY_TESTER [G]

feature -- Status report

	test (v, u: G): BOOLEAN is
			-- Are `v' and `u' considered equal?
			-- (Use `equal' by default.)
		do
			Result := equal (v, u)
		end

end -- class DS_EQUALITY_TESTER
