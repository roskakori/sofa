indexing
	description: "BumpRev for Eiffel"
	generator: "make_sofa_version"

class MAKE_SOFA_VERSION_INFO

creation
	make

feature -- Initialization

	make is
		do
			amiga_version_tag.clear
				-- Make `amiga_version_tag' alive, so that
				-- `compile' won't remove it from executable.
		end -- make

feature -- Access

	version: INTEGER is 1
			-- version number

	revision: INTEGER is 0
			-- revision number

	date: STRING is "30.3.00"
			-- date of last change

	application: STRING is "make_sofa_version"
			-- name of application

	description: STRING is "BumpRev for Eiffel"
			-- short description of `application'

feature {NONE} -- Implementation

	amiga_version_tag: STRING is "$VER: make_sofa_version 1.0 (30.3.00)"
			-- tag for AmigaOS "version" command

end -- MAKE_SOFA_VERSION_INFO
