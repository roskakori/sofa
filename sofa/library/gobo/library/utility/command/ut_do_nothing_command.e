indexing

	description:

		"Commands that do nothing"

	library:    "Gobo Eiffel Utility Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 14:12:05 $"
	revision:   "$Revision: 1.3 $"

class UT_DO_NOTHING_COMMAND

inherit

	UT_COMMAND

creation

	make

feature {NONE} -- Initialization

	make is
			-- Create a new command.
		do
		end

feature -- Execution

	execute is
			-- Execute current command.
		do
			-- Do nothing.
		end

end -- class UT_DO_NOTHING_COMMAND
