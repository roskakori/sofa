indexing

	description:

		"Parser skeletons for lexical analyzer %
		%generators such as 'gelex'"

	library:    "Gobo Eiffel Lexical Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date: 1999/10/02 13:55:05 $"
	revision:   "$Revision: 1.5 $"

deferred class LX_LEX_PARSER_SKELETON

inherit

	YY_PARSER_SKELETON [ANY]
		rename
			make as make_parser_skeleton
		redefine
			report_error
		end

	LX_LEX_SCANNER_SKELETON
		rename
			make as make_lex_scanner,
			make_from_description as make_lex_scanner_from_description,
			reset as reset_lex_scanner
		end

feature {NONE} -- Initialization

	make (a_description: LX_DESCRIPTION; handler: like error_handler) is
			-- Create a new scanner description parser.
		require
			a_description_not_void: a_description /= Void
			handler_not_void: handler /= Void
		do
			make_lex_scanner (handler)
			make_parser_skeleton
			!! pending_rules.make (Initial_max_pending_rules)
			!! start_condition_stack.make (Initial_max_start_conditions)
			!! action_factory.make
		ensure
			error_handler_set: error_handler = handler
		end

	make_from_description
		(a_description: LX_DESCRIPTION; handler: like error_handler) is
			-- Create a new scanner description parser
			-- and initialize it with `a_description'.
		require
			a_description_not_void: a_description /= Void
			handler_not_void: handler /= Void
		do
			make_lex_scanner_from_description (a_description, handler)
			make_parser_skeleton
			!! pending_rules.make (Initial_max_pending_rules)
			!! start_condition_stack.make (Initial_max_start_conditions)
			!! action_factory.make
		ensure
			error_handler_set: error_handler = handler
		end

feature -- Initialization

	reset is
			-- Reset parser before parsing next input.
		do
			reset_lex_scanner
			pending_rules.wipe_out
			start_condition_stack.wipe_out
			equiv_classes := Void
		end

feature -- Parsing

	parse_file (a_file: like INPUT_STREAM_TYPE) is
			-- Parse scanner description from `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: INPUT_STREAM_.is_open_read (a_file)
		do
			set_input_buffer (new_file_buffer (a_file))
			parse
		end

	parse_string (a_string: STRING) is
			-- Parse scanner description from `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
			set_input_buffer (new_string_buffer (a_string))
			parse
		end

feature -- Access

	pending_rules: DS_ARRAYED_LIST [LX_RULE]
			-- Rules which share the same semantic action

	start_condition_stack: LX_START_CONDITIONS
			-- Start condition containing
			-- the rule currently being parsed

	action_factory: LX_ACTION_FACTORY
			-- Semantic action factory

feature -- Setting

	set_action_factory (a_factory: like action_factory) is
			-- Set `action_factory' to `a_factory'.
		require
			a_factory_not_void: a_factory /= Void
		do
			action_factory := a_factory
		ensure
			action_factory_set: action_factory = a_factory
		end

feature -- Status report

	variable_trail_rule: BOOLEAN
			-- Does the rule being parsed have a variable
			-- trailing context?

	variable_length: BOOLEAN
			-- Does the regular expression being parsed
			-- (either the head or trail of the rule)
			-- have a variable length? (In other words,
			-- may tokens recognized by that regexp have
			-- different sizes?)

	rule_length: INTEGER
			-- Length of the tokens recognized by the
			-- regexp being parsed when `variable_length'
			-- is false; undefined otherwise

	head_count: INTEGER
			-- Length of the tokens recognized by the
			-- the head part of the rule being parsed
			-- when this rule has a triling context and
			-- `variable_length' is false; 0 otherwise

	trail_count: INTEGER
			-- Length of the tokens recognized by the
			-- the trail part of the rule being parsed
			-- when this rule has a triling context and
			-- `variable_length' is false; 0 otherwise

	rule: LX_RULE
			-- Rule being parsed

	in_trail_context: BOOLEAN
			-- Is a trailing context being parsed?

feature {NONE} -- Factory

	new_symbol_nfa (symbol: INTEGER): LX_NFA is
			-- New NFA made of two states and a
			-- symbol transition labeled `symbol'
		local
			a_name: STRING
			a_character_class: LX_SYMBOL_CLASS
		do
			if equiv_classes /= Void then
					-- Use a transition with a character class
					-- containing only `symbol' instead of a
					-- simple symbol transition labeled `symbol'.
					-- This is to allow later symbol renumbering
					-- using equivalence classes.
				a_name := symbol.out
				if character_classes.has (a_name) then
					Result := new_symbol_class_nfa (character_classes.item (a_name))
				else
					!! a_character_class.make (1)
					a_character_class.put (symbol)
					equiv_classes.add (a_character_class)
					character_classes.force (a_character_class, a_name)
					Result := new_symbol_class_nfa (a_character_class)
				end
			else
				!! Result.make_symbol (symbol, in_trail_context)
			end
		ensure
			nfa_not_void: Result /= Void
		end

	new_epsilon_nfa: LX_NFA is
			-- New NFA made of two states and an epsilon transition
		do
			!! Result.make_epsilon (in_trail_context)
		ensure
			nfa_not_void: Result /= Void
		end

	new_symbol_class_nfa (symbols: LX_SYMBOL_CLASS): LX_NFA is
			-- New NFA made of two states and a symbol
			-- class transition labeled `symbols'
		require
			symbols_not_void: symbols /= Void
		do
			!! Result.make_symbol_class (symbols, in_trail_context)
		ensure
			nfa_not_void: Result /= Void
		end

	new_character_class: LX_SYMBOL_CLASS is
			-- New empty character class
		do
			!! Result.make (characters_count)
		ensure
			character_class_not_void: Result /= Void
		end

	new_nfa_from_character (a_char: INTEGER): LX_NFA is
			-- New NFA with a transition labeled `a_char'
			-- (Take case-sensitiveness into account.)
		local
			lower_char: INTEGER
			a_name: STRING
			a_character_class: LX_SYMBOL_CLASS
		do
			if case_insensitive then
				inspect a_char
				when Upper_a_code .. Upper_z_code then
					lower_char := a_char + Case_diff
					a_name := lower_char.out
					if character_classes.has (a_name) then
						Result := new_symbol_class_nfa
							(character_classes.item (a_name))
					else
						!! a_character_class.make (2)
						a_character_class.put (a_char)
						a_character_class.put (lower_char)
						if equiv_classes /= Void then
							equiv_classes.add (a_character_class)
						end
						character_classes.force (a_character_class, a_name)
						Result := new_symbol_class_nfa (a_character_class)
					end
				when Lower_a_code .. Lower_z_code then
					a_name := a_char.out
					if character_classes.has (a_name) then
						Result := new_symbol_class_nfa
							(character_classes.item (a_name))
					else
						!! a_character_class.make (2)
						a_character_class.put (a_char - Case_diff)
						a_character_class.put (a_char)
						if equiv_classes /= Void then
							equiv_classes.add (a_character_class)
						end
						character_classes.force (a_character_class, a_name)
						Result := new_symbol_class_nfa (a_character_class)
					end
				when 0 then
					Result := new_symbol_nfa (characters_count)
				else
					Result := new_symbol_nfa (a_char)
				end
			elseif a_char = 0 then
				Result := new_symbol_nfa (characters_count)
			else
				Result := new_symbol_nfa (a_char)
			end
		ensure
			nfa_not_void: Result /= Void
		end

	new_nfa_from_character_class (a_character_class: LX_SYMBOL_CLASS): LX_NFA is
			-- New NFA with a transition labeled with `a_character_class'
			-- (Sort symbols in `a_character_class' if necessary and
			-- eventually register to `equiv_classes'.)
		require
			a_character_class_not_void: a_character_class /= Void
		do
			if a_character_class.sort_needed then
				a_character_class.sort
			end
			if equiv_classes /= Void then
				equiv_classes.add (a_character_class)
			end
			Result := new_symbol_class_nfa (a_character_class)
		ensure
			nfa_not_void: Result /= Void
		end

	new_bounded_iteration_nfa (a_nfa: LX_NFA; i, j: INTEGER): LX_NFA is
			-- New NFA that matches whatever matched `a_nfa' from
			-- `i' number of times to `j' number of times
		require
			a_nfa_not_void: a_nfa /= Void
		do
			if i < 0 or i > j then
				report_bad_iteration_values_error
				Result := new_epsilon_nfa
			else
				if i = 0 then
					if j <= 0 then
						report_bad_iteration_values_error
						Result := new_epsilon_nfa
					else
						Result := |?| a_nfa.bounded_iteration (1, j)
					end
				else
					Result := a_nfa.bounded_iteration (i, j)
				end
			end
		ensure
			nfa_not_void: Result /= Void
		end

	new_unbounded_iteration_nfa (a_nfa: LX_NFA; i: INTEGER): LX_NFA is
			-- New NFA that matches `i' or more occurrences of `a_nfa'
		require
			a_nfa_not_void: a_nfa /= Void
		do
			if i <= 0 then
				report_iteration_not_positive_error
				Result := new_epsilon_nfa
			else
				Result := a_nfa |{n,}| i
			end
		ensure
			nfa_not_void: Result /= Void
		end

	new_iteration_nfa (a_nfa: LX_NFA; i: INTEGER): LX_NFA is
			-- New NFA that matches whatever `a_nfa'
			-- matched `i' number of times
		require
			a_nfa_not_void: a_nfa /= Void
		do
			if i <= 0 then
				report_iteration_not_positive_error
				Result := new_epsilon_nfa
			else
				Result := a_nfa |{n}| i
			end
		ensure
			nfa_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	push_start_condition (a_name: STRING; stack: LX_START_CONDITIONS) is
			-- Push start condition named `a_name' on top of `stack'.
			-- Do nothing if that start condition is already in `stack'.
		require
			a_name_not_void: a_name /= Void
			stack_not_void: stack /= Void
		do
			if start_conditions.has_start_condition (a_name) then
				if stack.has_start_condition (a_name) then
					report_start_condition_specified_twice_warning (a_name)
				else
					stack.put_last (start_conditions.start_condition (a_name))
				end
			else
				report_undeclared_start_condition_error (a_name)
			end
		end

	process_rule (a_nfa: LX_NFA) is
			-- Process a rule.
		require
			a_nfa_not_void: a_nfa /= Void
			rule_not_void: rule /= Void
		do
			a_nfa.set_accepted_rule (rule)
			rule.set_pattern (a_nfa)
			rules.force_last (rule)
			pending_rules.force_last (rule)
			rule.set_line_nb (rule_line_nb)
			rule.set_trail_context (variable_trail_rule, head_count, trail_count)
			if variable_trail_rule then
				variable_trail_context := True
			end
			if start_condition_stack.is_empty then
					-- Add `a_nfa' to all non-exclusive start condition,
					-- including the default (INITIAL) start condition.
				start_conditions.add_nfa_to_non_exclusive (a_nfa)
			else
				start_condition_stack.add_nfa_to_all (a_nfa)
			end
		end

	process_bol_rule (a_nfa: LX_NFA) is
			-- Process a beginning-of-line rule.
		require
			a_nfa_not_void: a_nfa /= Void
			rule_not_void: rule /= Void
		local
			a_state: LX_NFA_STATE
		do
			a_nfa.set_accepted_rule (rule)
			rule.set_pattern (a_nfa)
			rules.force_last (rule)
			pending_rules.force_last (rule)
			rule.set_line_nb (rule_line_nb)
			rule.set_trail_context (variable_trail_rule, head_count, trail_count)
			bol_needed := True
			if variable_trail_rule then
				variable_trail_context := True
			end
			if start_condition_stack.is_empty then
					-- Add `a_nfa' to all non-exclusive start condition,
					-- including the default (INITIAL) start condition.
				start_conditions.add_bol_nfa_to_non_exclusive (a_nfa)
			else
				start_condition_stack.add_bol_nfa_to_all (a_nfa)
			end
		end

	process_eof_rule is
			-- Process a "<<EOF>>" rule.
		do
			if start_condition_stack.is_empty then
					-- This EOF applies to all start conditions
					-- which don't already have EOF actions.
				start_condition_stack.append_non_eof_start_conditions (start_conditions)
				if start_condition_stack.is_empty then
					report_all_start_conditions_eof_warning
				else
					build_eof_action (start_condition_stack)
				end
			else
				build_eof_action (start_condition_stack)
			end
		end

	build_eof_action (stack: LX_START_CONDITIONS) is
			-- Build the "<<EOF>>" action for start conditions in `stack'.
		require
			stack_not_void: stack /= Void
			stack_not_empty: not stack.is_empty
		local
			a_rule: LX_RULE
			i, nb: INTEGER
			a_start_condition: LX_START_CONDITION
		do
			from
				i := 1
				nb := stack.count
			until
				i > nb
			loop
				a_start_condition := stack.item (i)
				if a_start_condition.has_eof then
					report_multiple_EOF_rules_error (a_start_condition.name)
				else
					a_start_condition.set_has_eof (True)
					!! a_rule.make_default (a_start_condition.id)
					a_rule.set_pattern (Eof_nfa)
						-- Save `rule' as an end-of-file rule.
					eof_rules.force_last (a_rule)
					pending_rules.force_last (a_rule)
					rule.set_line_nb (rule_line_nb)
				end
				i := i + 1
			end
		end

	process_default_rule is
			-- Process default rule.
		require
			rule_not_void: rule /= Void
		local
			a_character_class: LX_SYMBOL_CLASS
			a_nfa: LX_NFA
		do
			!! a_character_class.make (0)
			a_character_class.set_negated (True)
			a_nfa := new_symbol_class_nfa (a_character_class)
			a_nfa.set_accepted_rule (rule)
			rule.set_pattern (a_nfa)
			rules.force_last (rule)
			pending_rules.force_last (rule)
			rule.set_line_nb (0)
			rule.set_trail_context (False, 0, 0)
			start_conditions.add_nfa_to_all (a_nfa)
			if no_default_rule then
				set_action ("last_token := yyError_token%N%
					%fatal_error (%"scanner jammed%")")
			else
				set_action ("echo")
			end
		end

	append_character_to_string (a_char: INTEGER; a_string: LX_NFA): LX_NFA is
			-- Append character `a_char' at end of string `a_string'.
		require
			a_string_not_void: a_string /= Void
		local
			a_name: STRING
			lower_char: INTEGER
			a_character_class: LX_SYMBOL_CLASS
		do
			if case_insensitive then
				inspect a_char
				when Upper_a_code .. Upper_z_code then
					lower_char := a_char + Case_diff
					a_name := lower_char.out
					if character_classes.has (a_name) then
						Result := a_string & new_symbol_class_nfa
							(character_classes.item (a_name))
					else
						!! a_character_class.make (2)
						a_character_class.put (a_char)
						a_character_class.put (lower_char)
						if equiv_classes /= Void then
							equiv_classes.add (a_character_class)
						end
						character_classes.force (a_character_class, a_name)
						Result := a_string & new_symbol_class_nfa
							(a_character_class)
					end
				when Lower_a_code .. Lower_z_code then
					a_name := a_char.out
					if character_classes.has (a_name) then
						Result := a_string & new_symbol_class_nfa
							(character_classes.item (a_name))
					else
						!! a_character_class.make (2)
						a_character_class.put (a_char - Case_diff)
						a_character_class.put (a_char)
						if equiv_classes /= Void then
							equiv_classes.add (a_character_class)
						end
						character_classes.force (a_character_class, a_name)
						Result := a_string & new_symbol_class_nfa
							(a_character_class)
					end
				when 0 then
					Result := a_string & new_symbol_nfa (characters_count)
				else
					Result := a_string & new_symbol_nfa (a_char)
				end
			elseif a_char = 0 then
				Result := a_string & new_symbol_nfa (characters_count)
			else
				Result := a_string & new_symbol_nfa (a_char)
			end
		ensure
			string_set: Result = a_string
		end

	append_character_to_character_class (a_char: INTEGER;
		a_character_class: LX_SYMBOL_CLASS): LX_SYMBOL_CLASS is
			-- Append character `a_char' to `a_character_class'.
		require
			a_character_class_not_void: a_character_class /= Void
		do
			if case_insensitive then
				inspect a_char
				when Upper_a_code .. Upper_z_code then
					a_character_class.put (a_char)
					a_character_class.put (a_char + Case_diff)
				when Lower_a_code .. Lower_z_code then
					a_character_class.put (a_char - Case_diff)
					a_character_class.put (a_char)
				when 0 then
					a_character_class.put (characters_count)
				else
					a_character_class.put (a_char)
				end
			elseif a_char = 0 then
				a_character_class.put (characters_count)
			else
				a_character_class.put (a_char)
			end
			Result := a_character_class
		ensure
			character_class_set: Result = a_character_class
		end

	append_character_set_to_character_class (char1, char2: INTEGER;
		a_character_class: LX_SYMBOL_CLASS): LX_SYMBOL_CLASS is
			-- Append character set `char1'-`char2' to `a_character_class'.
		require
			a_character_class_not_void: a_character_class /= Void
		local
			a_char: INTEGER
		do
			if char1 > char2 then
				report_negative_range_in_character_class_error
			elseif case_insensitive then
				from a_char := char1 until a_char > char2 loop
					inspect a_char
					when Upper_a_code .. Upper_z_code then
						a_character_class.put (a_char)
						a_character_class.put (a_char + Case_diff)
					when Lower_a_code .. Lower_z_code then
						a_character_class.put (a_char - Case_diff)
						a_character_class.put (a_char)
					when 0 then
						a_character_class.put (characters_count)
					else
						a_character_class.put (a_char)
					end
					a_char := a_char + 1
				end
			else
				from a_char := char1 until a_char > char2 loop
					if a_char = 0 then
						a_character_class.put (characters_count)
					else
						a_character_class.put (a_char)
					end
					a_char := a_char + 1
				end
			end
			Result := a_character_class
		ensure
			character_class_set: Result = a_character_class
		end

	append_trail_context_to_regexp (a_trail, a_regexp: LX_NFA): LX_NFA is
			-- Append trailing context `a_trail'
			-- to regular expression `a_regexp'.
		require
			a_trail_not_void: a_trail /= Void
			a_regexp_not_void: a_regexp /= Void
		do
			a_trail.set_beginning_as_normal
			in_trail_context := False
			if variable_length and head_count = 0 then
					-- Variable trailing context rule.
				variable_trail_rule := True
					-- Mark the first part of the rule as the accepting
					-- "head" part of a trailing context rule.
				a_regexp.set_accepted_rule (rule)
			elseif not variable_length then
				trail_count := rule_length
			end
			Result := a_regexp & a_trail
		ensure
			regexp_set: Result = a_regexp
		end

	append_eol_to_regexp (a_regexp: LX_NFA): LX_NFA is
			-- Append end-of-line trailing context (i.e. "$")
			-- to regular expression `a_regexp'.
		require
			a_regexp_not_void: a_regexp /= Void
		do
			head_count := 0
			trail_count := 1
			rule_length := 1
			variable_length := False
			in_trail_context := True
			Result := a_regexp & new_epsilon_nfa &
					new_symbol_nfa (New_line_code)
		ensure
			regexp_set: Result = a_regexp
		end

	dot_character_class: LX_SYMBOL_CLASS is
			-- "." character class (i.e. all characters except new_line)
		local
			dot_string: STRING
		do
			dot_string := "."
			if character_classes.has (dot_string) then
				Result := character_classes.item (dot_string)
			else
				!! Result.make (1)
				Result.put (New_line_code)
				Result.set_negated (True)
				if equiv_classes /= Void then
					equiv_classes.add (Result)
				end
				character_classes.force (Result, dot_string)
			end
		ensure
			dot_character_class_not_void: Result /= Void
		end

	set_action (a_text: STRING) is
			-- Set pending rules' action using `a_text'.
		require
			a_text_not_void: a_text /= Void
		local
			i, nb: INTEGER
			action: UT_COMMAND
		do
			action := action_factory.new_action (a_text)
			nb := pending_rules.count
			from i := 1 until i > nb loop
				pending_rules.item (i).set_action (action)
				i := i + 1
			end
			pending_rules.wipe_out
		end

	build_equiv_classes is
			-- Build equivalence classes and renumber
			-- symbol and character class transitions.
		require
			equiv_classes_not_void: equiv_classes /= Void
		local
			cursor: DS_HASH_TABLE_CURSOR [LX_SYMBOL_CLASS, STRING]
		do
			equiv_classes.build
			cursor := character_classes.new_cursor
			from cursor.start until cursor.after loop
				cursor.item.convert (equiv_classes)
				cursor.forth
			end
		ensure
			built: equiv_classes.built
		end

	check_options is
			-- Check user-specified ptions.
		do
			if full_table then
				if meta_equiv_classes_used then
					report_full_and_meta_equiv_classes_error
				end
				if reject_used then
					report_full_and_reject_error
				elseif variable_trail_context then
					report_full_and_variable_trailing_context_error
				end
			end
		end

feature {NONE} -- Error handling

	report_error (a_message: STRING) is
			-- Report a syntax error.
		local
			an_error: UT_SYNTAX_ERROR
		do
			!! an_error.make (filename, line_nb)
			error_handler.report_error (an_error)
			successful := False
		ensure then
			not_successful: not successful
		end

	report_all_start_conditions_eof_warning is
			-- Report that all start conditions already
			-- have <<EOF>> rules.
		local
			an_error: LX_ALL_START_CONDITIONS_EOF_ERROR
		do
			if not no_warning then
				!! an_error.make (filename, line_nb)
				error_handler.report_warning (an_error)
			end
		end

	report_bad_start_condition_list_error is
			-- Report the presence of a bad start condition list.
		local
			an_error: LX_BAD_START_CONDITION_LIST_ERROR
		do
			!! an_error.make (filename, line_nb)
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_bad_iteration_values_error is
			-- Report the presence of bad iteration values.
		local
			an_error: LX_BAD_ITERATION_VALUES_ERROR
		do
			!! an_error.make (filename, line_nb)
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_iteration_not_positive_error is
			-- Report that the iteration in a regular
			-- expression must be positive.
		local
			an_error: LX_ITERATION_NOT_POSITIVE_ERROR
		do
			!! an_error.make (filename, line_nb)
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_multiple_EOF_rules_error (sc: STRING) is
			-- Report that there are multiple <<EOF>> rules for
			-- start condition `sc'. This error is not fatal
			-- (do not set `successful' to false).
		require
			sc_not_void: sc /= Void
		local
			an_error: LX_MULTIPLE_EOF_RULES_ERROR
		do
			!! an_error.make (filename, line_nb, sc)
			error_handler.report_error (an_error)
		end

	report_negative_range_in_character_class_error is
			-- Report that there is a negative range in character class.
		local
			an_error: LX_NEGATIVE_RANGE_IN_CHARACTER_CLASS_ERROR
		do
			!! an_error.make (filename, line_nb)
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_start_condition_specified_twice_warning (sc: STRING) is
			-- Report that `sc' has been specified twice.
		require
			sc_not_void: sc /= Void
		local
			an_error: LX_START_CONDITION_SPECIFIED_TWICE_ERROR
		do
			if not no_warning then
				!! an_error.make (filename, line_nb, sc)
				error_handler.report_warning (an_error)
			end
		end

	report_trailing_context_used_twice_error is
			-- Report that trailing context is used twice.
		local
			an_error: LX_TRAILING_CONTEXT_USED_TWICE_ERROR
		do
			!! an_error.make (filename, line_nb)
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_undeclared_start_condition_error (sc: STRING) is
			-- Report that `sc' has not been declared as a start condition.
			-- (do not set `successful' to false).
		require
			sc_not_void: sc /= Void
		local
			an_error: LX_UNDECLARED_START_CONDITION_ERROR
		do
			!! an_error.make (filename, line_nb, sc)
			error_handler.report_error (an_error)
		end

	report_unrecognized_rule_error is
			-- Report an unrecoginzed rule.
		local
			an_error: LX_UNRECOGNIZED_RULE_ERROR
		do
			!! an_error.make (filename, line_nb)
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_full_and_meta_equiv_classes_error is
			-- Report that the use of meta equivalence classes
			-- does not make sense with full tables.
		local
			an_error: LX_FULL_AND_META_ERROR
		do
			!! an_error.make
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_full_and_reject_error is
			-- Report that the use of reject is incompatible
			-- with full tables.
		local
			an_error: LX_FULL_AND_REJECT_ERROR
		do
			!! an_error.make
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

	report_full_and_variable_trailing_context_error is
			-- Report that the use of variable trailing context
			-- is incompatible with full tables.
		local
			an_error: LX_FULL_AND_VARIABLE_TRAILING_CONTEXT_ERROR
		do
			!! an_error.make
			error_handler.report_error (an_error)
			successful := False
		ensure
			not_successful: not successful
		end

feature {NONE} -- Constants

	Initial_max_pending_rules: INTEGER is 10
			-- Maximum number of pending rules

	Eof_nfa: LX_NFA is
			-- End-of-file NFA
		once
			!! Result.make_epsilon (False)
		ensure
			nfa_not_void: Result /= Void
		end

invariant

	pending_rules_not_void: pending_rules /= Void
	no_void_pending_rule: not pending_rules.has (Void)
	start_condition_stack_not_void: start_condition_stack /= Void
	action_factory_not_void: action_factory /= Void

end -- class LX_LEX_PARSER_SKELETON