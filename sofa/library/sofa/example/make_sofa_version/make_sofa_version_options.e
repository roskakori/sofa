indexing
	description: "Argument parser."
	generator: "readarghh"

class MAKE_SOFA_VERSION_OPTIONS

creation
	make

feature -- Initialization

	make is
		do
			!!parser.make(Template)
		end -- make

feature -- Access

	to: STRING is
			-- value of argument "to"
		do
			Result := parser.item_as_string(1)
		end

	version: INTEGER is
			-- value of argument "version"
		do
			Result := parser.item_as_integer(2)
		end

	revision: INTEGER is
			-- value of argument "revision"
		do
			Result := parser.item_as_integer(3)
		end

	application: STRING is
			-- value of argument "application"
		do
			Result := parser.item_as_string(4)
		end

	description: STRING is
			-- value of argument "description"
		do
			Result := parser.item_as_string(5)
		end

	quiet: BOOLEAN is
			-- value of argument "quiet"
		do
			Result := parser.item_as_boolean(6)
		end

feature -- Status change

	parse is
			-- Parse arguments from CLI and set corresponding attributes.
		require
			not_yet_parsed: not is_parsed
		do
			parser.parse
		end

	reset is
			-- Prepare for another `parse'.
		do
			parser.parse
		ensure
			not_parsed: not is_parsed
		end

feature -- Status report

	is_parsed:BOOLEAN is
			-- Has `parse' been called already ?
		do
			Result := parser.is_parsed
		end

	has_error: BOOLEAN is
			-- Did `parse' cause an error ?
		do
			Result := parser.has_error
		end

	error_description: STRING is
			-- description of last error to be shown to end user
		do
			Result := parser.error_description
		end

feature {NONE} -- Implementation

	Template: STRING is "to/k/a,version/n/a,revision/n/a,application/a,description/a,quiet/s"
			-- template passed to ReadArgs()

	parser: AMIGA_ARGUMENT_PARSER
			-- actual parser

invariant

	consistent_parsed: is_parsed implies not has_error
	consistent_error: has_error implies error_description /= Void

end -- class MAKE_SOFA_VERSION_OPTIONS
