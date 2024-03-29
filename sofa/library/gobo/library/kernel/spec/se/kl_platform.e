indexing

	description:

		"Platform-dependent properties"

	usage:      "This class should not be used directly through %
				%inheritance and client/supplier relationship. %
				%Inherit from KL_SHARED_PLATFORM instead."
	pattern:    "Singleton"
	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:46:36 $"
	revision:   "$Revision: 1.4 $"

class KL_PLATFORM

inherit

	PLATFORM
		redefine
			Minimum_character_code,
			Maximum_character_code
		end

feature -- Access

	Minimum_character_code: INTEGER is 0
	Maximum_character_code: INTEGER is 255
			-- Smallest and largest supported codes for CHARACTER values

end -- class KL_PLATFORM
