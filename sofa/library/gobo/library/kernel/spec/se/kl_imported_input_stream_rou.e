indexing

	description:

		"Imported routines that ought to be in class INPUT_STREAM"

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:46:00 $"
	revision:   "$Revision: 1.3 $"

class KL_IMPORTED_INPUT_STREAM_ROUTINES

feature -- Access

	INPUT_STREAM_: KL_INPUT_STREAM_ROUTINES is
			-- Routines that ought to be in class INPUT_STREAM
		once
			!! Result
		ensure
			input_stream_routines_not_void: Result /= Void
		end

feature -- Type anchors

	INPUT_STREAM_TYPE: INPUT_STREAM is do end
			-- Type anchor

end -- class KL_IMPORTED_INPUT_STREAM_ROUTINES
