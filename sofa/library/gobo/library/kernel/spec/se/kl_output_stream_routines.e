indexing

	description:

		"Routines that ought to be in class OUTPUT_STREAM"

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 2000/04/16 13:54:09 $"
	revision:   "$Revision: 1.6 $"

class KL_OUTPUT_STREAM_ROUTINES

inherit

	KL_IMPORTED_OUTPUT_STREAM_ROUTINES

feature -- Initialization

	make_file_open_write (a_filename: STRING): like OUTPUT_STREAM_TYPE is
			-- Create a new file object with `a_filename' as
			-- file name and try to open it in write-only mode.
			-- `is_open_write (Result)' is set to True
			-- if operation was successful.
		require
			a_filename_not_void: a_filename /= Void
			a_filename_not_empty: a_filename.count > 0
		local
			rescued: BOOLEAN
			a_file: STD_FILE_WRITE
		do
			if not rescued then
				!! a_file.make
				Result := a_file
				a_file.connect_to (a_filename)
			elseif a_file.is_connected then
				a_file.disconnect
			end
		ensure
			file_not_void: Result /= Void
		rescue
			if not rescued then
				rescued := True
				retry
			end
		end

feature -- Status report

	is_open_write (a_stream: like OUTPUT_STREAM_TYPE): BOOLEAN is
			-- Is `a_stream' open in write mode?
		require
			a_stream_void: a_stream /= Void
		do
			Result := a_stream.is_connected
		end

	is_closed (a_stream: like OUTPUT_STREAM_TYPE): BOOLEAN is
			-- Is `a_stream' closed?
		require
			a_stream_void: a_stream /= Void
		do
			Result := not a_stream.is_connected
		end

feature -- Status setting

	close (a_stream: like OUTPUT_STREAM_TYPE) is
			-- Close `a_stream' if it is closable,
			-- let it open otherwise.
		require
			a_stream_not_void: a_stream /= Void
			not_closed: not is_closed (a_stream)
		local
			a_file: STD_FILE_WRITE
		do
			a_file ?= a_stream
			if a_file /= Void then
				a_file.disconnect
			end
		end

end -- class KL_OUTPUT_STREAM_ROUTINES
