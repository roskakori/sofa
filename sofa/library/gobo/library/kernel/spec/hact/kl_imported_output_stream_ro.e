indexing

	description:

		"Imported routines that ought to be in class OUTPUT_STREAM"

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:46:08 $"
	revision:   "$Revision: 1.3 $"

class KL_IMPORTED_OUTPUT_STREAM_ROUTINES

feature -- Access

	OUTPUT_STREAM_: KL_OUTPUT_STREAM_ROUTINES is
			-- Routines that ought to be in class OUTPUT_STREAM
		once
			!! Result
		ensure
			output_stream_routines_not_void: Result /= Void
		end

feature -- Type anchors

	OUTPUT_STREAM_TYPE: IO_MEDIUM is do end
			-- Type anchor

end -- class KL_IMPORTED_OUTPUT_STREAM_ROUTINES
