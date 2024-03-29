indexing

	description:

		"Symbol types used when no type has been specified"

	library:    "Gobo Eiffel Parse Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 14:05:31 $"
	revision:   "$Revision: 1.2 $"

class PR_NO_TYPE

inherit

	PR_TYPE
		redefine
			append_dollar_n_to_string,
			append_dollar_dollar_to_string,
			print_dollar_dollar_declaration,
			print_dollar_dollar_initialization,
			print_dollar_dollar_finalization,
			print_conversion_routine
		end

creation

	make

feature -- Output

	append_dollar_n_to_string (n: INTEGER; nb_rhs: INTEGER; a_string: STRING) is
			-- Append typed version of $`n' to `a_string'.
		do
			append_untyped_dollar_n_to_string (n, nb_rhs, a_string)
		end

	append_dollar_dollar_to_string (a_string: STRING) is
			-- Append typed version of $$ to `a_string'.
		do
			append_untyped_dollar_dollar_to_string (a_string)
		end

	print_conversion_routine (a_file: like OUTPUT_STREAM_TYPE) is
			-- Print conversion routine ANY->`name' to `a_file'.
		do
		end

	print_dollar_dollar_declaration (a_file: like OUTPUT_STREAM_TYPE) is
			-- Print $$ declaration to `a_file'.
		do
		end

	print_dollar_dollar_initialization (a_file: like OUTPUT_STREAM_TYPE) is
			-- Print $$ initialization to `a_file'.
		do
				-- Add a semicolon just in case the next user-defined
				-- instruction starts with an open-parenthesis.
			a_file.put_string ("%T%T%Tyyval := yyval_default;")
		end

	print_dollar_dollar_finalization (a_file: like OUTPUT_STREAM_TYPE) is
			-- Print $$ finalization to `a_file'.
		do
		end

end -- class PR_NO_TYPE
