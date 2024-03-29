indexing

	description:

		"Gobo Eiffel Grep"

	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/10 17:47:17 $"
	revision:   "$Revision: 1.9 $"

class GEGREP

inherit

	KL_SHARED_ARGUMENTS
	KL_SHARED_EXCEPTIONS
	KL_IMPORTED_INPUT_STREAM_ROUTINES
	KL_SHARED_STANDARD_FILES

creation

	execute

feature -- Execution

	execute is
			-- Start 'gegrep' execution.
		local
			i, nb: INTEGER
			a_file: like INPUT_STREAM_TYPE
			a_filename: STRING
			case_insensitive: BOOLEAN
		do
			if False then resurrect_code end

			nb := Arguments.argument_count
			if nb = 0 then
				std.error.put_string (Usage_message)
				std.error.put_character ('%N')
				Exceptions.die (1)
			else
				if Arguments.argument (1).is_equal ("-i") then
					case_insensitive := True
					if nb = 1 then
						std.error.put_string (Usage_message)
						std.error.put_character ('%N')
						Exceptions.die (1)
					end
					i := 2
				else
					i := 1
				end
				!! regexp.compile (Arguments.argument (i), case_insensitive)
				if not regexp.compiled then
					std.error.put_string ("gegrep: invalid regular expression%N")
					Exceptions.die (1)
				else
					i := i + 1
					inspect nb - i + 1
					when 0 then
						parse_file (std.input, Void)
					when 1 then
						a_filename := Arguments.argument (i)
						a_file := INPUT_STREAM_.make_file_open_read (a_filename)
						if INPUT_STREAM_.is_open_read (a_file) then
							parse_file (a_file, Void)
							INPUT_STREAM_.close (a_file)
						else
							std.error.put_string ("gegrep: cannot read %'")
							std.error.put_string (a_filename)
							std.error.put_string ("%'%N")
							Exceptions.die (1)
						end
					else
						from until i > nb loop
							a_filename := Arguments.argument (i)
							a_file := INPUT_STREAM_.make_file_open_read (a_filename)
							if INPUT_STREAM_.is_open_read (a_file) then
								parse_file (a_file, a_filename)
								INPUT_STREAM_.close (a_file)
							else
								std.error.put_string ("gegrep: cannot read %'")
								std.error.put_string (a_filename)
								std.error.put_string ("%'%N")
								Exceptions.die (1)
							end
							i := i + 1
						end
					end
				end
			end
		rescue
			std.error.put_string ("gegrep: internal error%N")
			Exceptions.die (1)
		end

feature -- Parsing

	parse_file (a_file: like INPUT_STREAM_TYPE; a_filename: STRING) is
			-- Parse `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: INPUT_STREAM_.is_open_read (a_file)
			regexp_not_void: regexp /= Void
			regexp_compiled: regexp.compiled
		local
			a_line: STRING
		do
			from
				a_file.read_line
			until
				INPUT_STREAM_.end_of_input (a_file)
			loop
				a_line := a_file.last_string
				if regexp.matches (a_line) then
					if a_filename /= Void then
						std.output.put_string (a_filename)
						std.output.put_string (": ")
					end
					std.output.put_string (a_line)
					std.output.put_character ('%N')
				end
				a_file.read_line
			end
		end

feature -- Access

	Usage_message: STRING is "usage: gegrep [-i] regexp [filename...]"

	regexp: LX_DFA_REGULAR_EXPRESSION
			-- Regular expression

feature {NONE} -- Implementation

	resurrect_code is
			-- Make sure that SmallEiffel does not complain about possible
			-- "calls on a Void target in the living Eiffel code".
		local
			et1: DS_EQUALITY_TESTER [LX_NFA_STATE]
			et2: DS_EQUALITY_TESTER [INTEGER]
			et3: DS_EQUALITY_TESTER [LX_NFA]
			et4: DS_EQUALITY_TESTER [LX_RULE]
			et5: DS_EQUALITY_TESTER [LX_START_CONDITION]
			et6: DS_EQUALITY_TESTER [LX_SYMBOL_CLASS]
			et7: DS_EQUALITY_TESTER [LX_DFA_STATE]
			et8: DS_EQUALITY_TESTER [STRING]
			fb: YY_FILE_BUFFER
		do
			!! et1
			!! et2
			!! et3
			!! et4
			!! et5
			!! et6
			!! et7
			!! et8
			!! fb.make (std.input)
		end

end -- class GEGREP
