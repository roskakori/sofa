--          This file is part of SmallEiffel The GNU Eiffel Compiler.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr
--                       http://SmallEiffel.loria.fr
-- SmallEiffel is  free  software;  you can  redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software  Foundation;  either  version  2, or (at your option)  any  later
-- version. SmallEiffel is distributed in the hope that it will be useful,but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or  FITNESS FOR A PARTICULAR PURPOSE.   See the GNU General Public License
-- for  more  details.  You  should  have  received a copy of the GNU General
-- Public  License  along  with  SmallEiffel;  see the file COPYING.  If not,
-- write to the  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
-- Boston, MA 02111-1307, USA.
--
class EIFFEL_PARSER
   --
   -- Singleton object in charge of Eiffel parsing.
   -- This singleton is shared via the GLOBALS.`eiffel_parser' once function.
   --

inherit GLOBALS;

feature

   case_insensitive: BOOLEAN;
	 -- When flag "-case_insensitive" is on.

   no_style_warning: BOOLEAN;
	 -- When flag "-no_style_warning" is on.

   is_running: BOOLEAN;
	 -- True when the parser is running (ie. parsing of the
	 -- current class is not finished)..

feature {SMALL_EIFFEL}

   analyse_class(class_name: CLASS_NAME): BASE_CLASS is
      require
	 not is_running;
	 not small_eiffel.is_ready;
	 class_name.to_string /= Void;
	 parser_buffer.is_ready
      local
	 old_nbe, old_nbw: INTEGER;
	 path: STRING;
      do
	 current_id := id_provider.item(class_name.to_string);
	 path := parser_buffer.path;
	 if nb_errors > 0 then
	    eh.append("Correct previous error(s) first.");
	    eh.print_as_fatal_error;
	 end;
	 debug
	    if small_eiffel.is_ready then
	       eh.append("Tried to load class ");
	       eh.append(path);
	       eh.append(" while small_eiffel `is_ready'.");
	       eh.print_as_warning;
	    end;
	 end;
	 echo.put_integer(small_eiffel.base_class_count + 1);
	 echo.put_character('%T');
	 echo.put_string(path);
	 echo.put_character('%N');
	 old_nbe := nb_errors;
	 old_nbw := nb_warnings;
	 is_running := true;
	 inside_function := false;
	 inside_once_function := false;
	 in_ensure := false;
	 last_comments := Void;
	 line := 1;
	 column := 1;
	 current_line := parser_buffer.item(line);
	 if current_line.count = 0 then
	    cc := '%N';
	 else
	    cc := current_line.first;
	 end;
	 !!last_base_class.make(path,class_name.to_string,current_id);
	 skip_comments;
	 a_class_declaration;
	 is_running := false;
	 parser_buffer.unset_is_ready;
	 Result := last_base_class;
	 if nb_errors - old_nbe > 0 then
	    show_nb_errors;
	    echo.w_put_string("Load class %"");
	    echo.w_put_string(path);
	    echo.w_put_string("%" aborted.%N");
	    Result := Void;
	 elseif nb_warnings - old_nbw > 0 then
	    show_nb_warnings;
	    check
	       Result /= Void
	    end;
	 end;
	 if Result /= Void then
	    Result.get_started;
	 end;
      ensure
	 not parser_buffer.is_ready
      end;

feature {COMMAND_FLAGS}

   set_case_insensitive is
      do
	 case_insensitive := true;
      end;

   set_no_style_warning is
      do
	 no_style_warning := true;
      end;

feature {CECIL_POOL}

   connect_to_cecil: STRING is
	 -- Return the cecil file path (first line).
      require
	 not is_running;
	 nb_errors = 0;
	 run_control.cecil_path /= Void
      local
	 path: STRING;
      do
	 path := run_control.cecil_path;
	 echo.put_string("Parsing Cecil File : ");
	 echo.put_string(path);
	 echo.put_character('%N');
	 parser_buffer.load_file(path);
	 if not parser_buffer.is_ready then
	    fatal_error(
	    "Cannot open Cecil file (use -verbose flag for details).");
	 end;
	 path := parser_buffer.path;
	 current_id := id_provider.item(path);
	 is_running := true;
	 formal_generic_list := Void;
	 inside_function := false;
	 inside_once_function := false;
	 in_ensure := false;
	 last_comments := Void;
	 line := 1;
	 column := 1;
	 current_line := parser_buffer.item(line);
	 last_base_class := Void;
	 if current_line.count = 0 then
	    cc := '%N';
	 else
	    cc := current_line.first;
	 end;
	 skip_comments;
	 from
	    !!Result.make(32);
	 until
	    cc = '%N' or else cc = end_of_text
	 loop
	    Result.extend(cc);
	    next_char;
	 end;
	 skip_comments;
	 if cc = end_of_text then
	    fatal_error("Empty Cecil file (use -verbose flag for details).");
	 end;
      end;

   end_of_input: BOOLEAN is
      do
	 Result := cc = end_of_text;
      end;

   parse_c_name: STRING is
      do
	 from
	    !!Result.make(32);
	 until
	    cc.is_separator
	 loop
	    Result.extend(cc);
	    next_char;
	 end;
	 skip_comments;
      end;

   parse_run_type: TYPE is
      do
	 if a_class_type then
	    Result := last_class_type;
	 else
	    fcp(em16);
	 end;
      ensure
	 nb_errors = 0
      end;

   parse_feature_name: FEATURE_NAME is
      do
	 if a_feature_name then
	    Result := last_feature_name;
	 else
	    fcp(em2);
	 end;
      ensure
	 nb_errors = 0
      end;

   disconnect is
      do
	 is_running := false;
	 parser_buffer.unset_is_ready;
      end;

feature {C_PRETTY_PRINTER}

   show_nb_warnings is
      local
	 do_it: BOOLEAN;
      do
	 if echo.verbose then
	    do_it := true;
	 elseif eh.no_warning then
	 else
	    do_it := true;
	 end;
	 if do_it then
	    show_nb(nb_warnings," warning(s).%N");
	 end;
      end;

   show_nb_errors is
      do
	 show_nb(nb_errors," error(s).%N");
      end;

feature {COMPILE_TO_C,COMPILE_TO_JVM}

   set_drop_comments is
      do
	 drop_comments := true;
      end;

feature {TMP_FEATURE}

   ecp(msg: STRING) is
	 -- Error at current position.
      do
	 error(current_position,msg);
      end;

feature {NONE}

   end_of_text: CHARACTER is '%/0/'; -- Flag of the end of the `text'.

   last_comments: COMMENT;
	 -- Void or waiting comment.

   inside_function: BOOLEAN;
	 -- True when a function (once or non-once) is parsed.

   inside_once_function: BOOLEAN;
	 -- True when a once function is parsed.

   formal_generic_list: FORMAL_GENERIC_LIST;
	 -- Void or not empty list of formal generic arguments.

   in_ensure: BOOLEAN;
	 -- True during the parsing of a ensure clause.

   in_rescue: BOOLEAN;
	 -- True during the parsing of a rescue clause.

   arguments: FORMAL_ARG_LIST;
	 -- Void or actual formal arguments list.

   local_vars: LOCAL_VAR_LIST;
	 -- Void or actual local variables list.

   ok: BOOLEAN;
	 -- Dummy variable to call functions.

   tmp_name: TMP_NAME;

   last_ascii_code: INTEGER;
   last_base_class: BASE_CLASS;
   last_base_type: TYPE;
   last_binary: INFIX_NAME;
   last_bit_constant: BIT_CONSTANT;
   last_boolean_constant: BOOLEAN_CONSTANT;
   last_character_or_integer: BASE_TYPE_CONSTANT;
   last_character_constant: CHARACTER_CONSTANT;
   last_class_name: CLASS_NAME;
   last_class_type: TYPE;
   last_expression: EXPRESSION;
   last_feature_declaration: E_FEATURE;
   last_feature_name: FEATURE_NAME;
   last_feature_name_list: FEATURE_NAME_LIST;
   last_keyword: STRING; -- Should be removed.
   last_type_formal_generic: TYPE_FORMAL_GENERIC;
   last_infix: INFIX_NAME;
   last_prefix: PREFIX_NAME;
   last_integer_constant: INTEGER_CONSTANT;
   last_instruction: INSTRUCTION;
   last_index_value: EXPRESSION;
   last_manifest_constant: EXPRESSION;
   last_manifest_string: MANIFEST_STRING;
   last_parent: PARENT;
   last_real_constant: REAL_CONSTANT;
   last_type: TYPE;
   last_tag_mark: TAG_NAME;

   a_argument: BOOLEAN is
      local
	 rank: INTEGER;
      do
	 if arguments /= Void then
	    rank := arguments.rank_of(tmp_name.aliased_string);
	    if rank > 0 then
	       last_expression := tmp_name.to_argument_name2(arguments,rank);
	       Result := true;
	    end;
	 end;
      end;

   a_current: BOOLEAN is
      do
	 if tmp_name.is_current then
	    !WRITTEN_CURRENT!last_expression.make(tmp_name.start_position);
	    Result := true;
	 end;
      end;

   a_formal_arg_list is
	 --++ formal_arg_list -> ["(" {declaration_group ";" ...} ")"]
	 --++ declaration_group -> {identifier "," ...}+ ":" type
      local
	 name: ARGUMENT_NAME1;
	 name_list: ARRAY[ARGUMENT_NAME1];
	 declaration: DECLARATION;
	 list: ARRAY[DECLARATION];
	 state: INTEGER;
	 -- state 0 : waiting for the first name of a group.
	 -- state 1 : waiting "," or ":".
	 -- state 2 : waiting for a name (not the first).
	 -- state 3 : waiting for type mark.
	 -- state 4 : waiting ";" or ")".
	 -- state 5 : end.
	 -- state 6 : error.
      do
	 arguments := Void;
	 if skip1('(') then
	    from
	    until
	       state > 4
	    loop
	       inspect
		  state
	       when 0 then
		  if a_identifier then
		     name := tmp_name.to_argument_name1;
		     state := 1;
		  elseif skip1(')') then
		     state := 5;
		  else
		     state := 6;
		  end;
	       when 1 then
		  if skip1(':') then
		     if name_list /= Void then
			name_list.add_last(name);
			name := Void;
		     end;
		     state := 3;
		  else
		     ok := skip1(',');
		     if name_list = Void then
			!!name_list.with_capacity(2,1);
		     end;
		     name_list.add_last(name);
		     name := Void;
		     state := 2;
		  end;
	       when 2 then
		  if a_identifier then
		     name := tmp_name.to_argument_name1;
		     state := 1;
		  elseif cc = ',' or else cc = ';' then
		     wcp(em13);
		     ok := skip1(',') or else skip1(';');
		  else
		     state := 6;
		  end;
	       when 3 then
		  if a_type then
		     if name_list /= Void then
			!DECLARATION_GROUP!declaration.make(name_list,
			                                    last_type);
			name_list := Void;
		     else
			!DECLARATION_1!declaration.make(name,last_type);
			name := Void;
		     end;
		     if list = Void then
			!!list.with_capacity(2,1);
		     end;
		     list.add_last(declaration);
		     declaration := Void;
		     state := 4;
		  else
		     state := 6;
		  end;
	       else -- state = 4
		  if skip1(')') then
		     state := 5;
		  elseif cc = ',' then
		     wcp("Substitute with %";%".");
		     ok := skip1(',');
		     state := 0;
		  else
		     ok := skip1(';');
		     state := 0;
		  end;
	       end;
	    end;
	    if state = 6 then
	       fcp("Bad formal arguments list.");
	    elseif list = Void then
	       wcp("Empty formal argument list (deleted).");
	    else
	       !!arguments.make(list);
	       tmp_feature.set_arguments(arguments);
	    end;
	 end;
      end;

   a_local_var_list is
	 --++ local_var_list -> [{declaration_group ";" ...}]
	 --++ declaration_group -> {identifier "," ...}+ ":" type
      local
	 name: LOCAL_NAME1;
	 name_list: ARRAY[LOCAL_NAME1];
	 declaration: DECLARATION;
	 list: ARRAY[DECLARATION];
	 rank, state: INTEGER;
	 -- state 0 : waiting for the first name of a group.
	 -- state 1 : waiting "," or ":".
	 -- state 2 : waiting for a name (not the first).
	 -- state 3 : waiting for type mark.
	 -- state 4 : waiting ";".
	 -- state 5 : end.
	 -- state 6 : error.
      do
	 from
	 until
	    state > 4
	 loop
	    inspect
	       state
	    when 0 then
	       if a_identifier then
		  name := tmp_name.to_local_name1;
		  state := 1;
		  if arguments /= Void then
		     rank := arguments.rank_of(name.to_string);
		     if rank > 0 then
			eh.add_position(name.start_position);
			error(arguments.name(rank).start_position,
			      "Same identifier appears twice (local/formal).");
		     end;
		  end;
	       elseif cc = ',' or else cc = ';' then
		  wcp(em13);
		  ok := skip1(',') or else skip1(';');
	       else
		  state := 5;
	       end;
	    when 1 then
	       if skip1(':') then
		  if name_list /= Void then
		     name_list.add_last(name);
		     name := Void;
		  end;
		  state := 3;
	       else
		  if cc = ';' then
		     wcp("Substitute with %",%".");
		     ok := skip1(';');
		  else
		     ok := skip1(',');
		  end;
		  if name_list = Void then
		     !!name_list.with_capacity(2,1);
		  end;
		  name_list.add_last(name);
		  name := Void;
		  state := 2;
	       end;
	    when 2 then
	       if a_identifier then
		  name := tmp_name.to_local_name1;
		  state := 1;
		  if arguments /= Void then
		     rank := arguments.rank_of(name.to_string);
		     if rank > 0 then
			eh.add_position(name.start_position);
			eh.add_position(arguments.name(rank).start_position);
			eh.append("Same identifier appears twice (local/formal).");
			eh.print_as_error;
		     end;
		  end;
	       elseif cc = ',' or else cc = ';' then
		  wcp(em13);
		  ok := skip1(',') or else skip1(';');
	       else
		  state := 6;
	       end;
	    when 3 then
	       if a_type then
		  if name_list /= Void then
		     !DECLARATION_GROUP!declaration.make(name_list,last_type);
		     name_list := Void;
		  else
		     !DECLARATION_1!declaration.make(name,last_type);
		     name := Void;
		  end;
		  if list = Void then
		     !!list.with_capacity(2,1);
		  end;
		  list.add_last(declaration);
		  state := 4;
	       else
		  state := 6;
	       end;
	    else -- state = 4
	       if cc = ',' then
		  wcp("Substitute with %";%".");
		  ok := skip1(',');
		  state := 0;
	       else
		  ok := skip1(';');
		  state := 0;
	       end;
	    end;
	 end;
	 if state = 6 then
	    fcp("Bad local variable list.");
	 elseif list /= Void then
	    !!local_vars.make(list);
	    tmp_feature.set_local_vars(local_vars);
	 end;
      end;

   a_local_variable: BOOLEAN is
      local
	 rank: INTEGER;
      do
	 if local_vars /= Void then
	    rank := local_vars.rank_of(tmp_name.aliased_string);
	    if rank > 0 then
	       last_expression := tmp_name.to_local_name2(local_vars,rank);
	       Result := true;
	    end;
	 end;
      end;

   a_result: BOOLEAN is
      do
	 if tmp_name.is_result then
	    last_expression := last_result;
	    Result := true;
	 end;
      end;

   a_void: BOOLEAN is
      do
	 if tmp_name.is_void then
	    last_expression := tmp_name.to_e_void;
	    Result := true;
	 end;
      end;

   get_comments: COMMENT is
      do
	 Result := last_comments;
	 last_comments := Void;
      end;

   start_line, start_column: INTEGER;
	 -- To store beginning position of : `a_keyword', `a_integer',
	 -- `a_real', `skip1', `skip2' and `skip1unless2'.

   a_keyword(keyword: STRING): BOOLEAN is
	 -- Look for `keyword' beginning strictly at current position.
	 -- A keyword is never followed by a character of
	 -- this set : 'A'..'Z','a'..'z','0'..'9','_'.
	 -- When Result is true, `last_keyword' is updated.
      require
	 keyword.count >= 1
      local
	 c, i: INTEGER;
	 back_cc: CHARACTER;
      do
	 from
	    back_cc := cc;
	    start_line := line;
	    start_column := column;
	    c := keyword.count;
	    i := 1;
	 until
	    c <= 0
	 loop
	    if cc.same_as(keyword.item(i)) then
	       i := i + 1;
	       c := c - 1;
	       next_char;
	    else
	       c := -1;
	    end;
	 end;
	 if c = 0 then
	    inspect
	       cc
	    when ' ','%N','%T','-' then
	       Result := true;
	       last_keyword := keyword;
	       skip_comments;
	    when 'a'..'z','A'..'Z','0'..'9','_' then
	       column := start_column;
	       cc := back_cc;
	    else
	       Result := true;
	       last_keyword := keyword;
	    end;
	 else
	    column := start_column;
	    cc := back_cc;
	 end;
      end;

   a_ascii_code is
	 -- To read a character given as an ascii code in a manifest
	 -- constant CHARACTER or STRING;
	 -- Require/Ensure : cc = '/'.
      local
	 counter: INTEGER;
      do
	 from
	    check
	       cc = '/'
	    end;
	    next_char;
	    counter := 0;
	    last_ascii_code := 0;
	 until
	    counter > 3 or else cc = '/'
	 loop
	    inspect
	       cc
	    when '0' .. '9' then
	       last_ascii_code := last_ascii_code * 10 + cc.value;
	    else
	       fcp("Unexpected character in ascii code.");
	    end;
	    counter := counter + 1;
	    next_char;
	 end;
	 if counter = 0 then
	    fcp("Bad (empty ?) ascii code.");
	 elseif counter > 3 then
	    fcp("Three digit is enought for an ascii code.");
	 else
	    check
	       cc = '/'
	    end;
	 end;
      end;

   go_back_at(l, c: INTEGER) is
	 -- Go back to some existing `l',`c'.
      require
	 l >= 1;
	 c >= 1
      do
	 line := l;
	 column := c;
	 current_line := parser_buffer.item(l);
	 cc := current_line.item(c);
      end;

   next_char is
      do
	 if column < current_line.count then
	    column := column + 1;
	    cc := current_line.item(column);
	 elseif column = current_line.count then
	    column := column + 1;
	    cc := '%N';
	 elseif line = parser_buffer.count then
	    cc := end_of_text;
	 else
	    line := line + 1;
	    column := 1;
	    current_line := parser_buffer.item(line);
	    if current_line.count = 0 then
	       cc := '%N';
	    else
	       cc := current_line.first;
	    end;
	 end;
      end;

   skip1(char: CHARACTER): BOOLEAN is
      do
	 if char = cc then
	    start_line := line;
	    start_column := column;
	    Result := true;
	    next_char;
	    skip_comments;
	 end;
      end;

   skip2(c1, c2: CHARACTER): BOOLEAN is
      do
	 if c1 = cc then
	    start_line := line;
	    start_column := column;
	    next_char;
	    if c2 = cc then
	       Result := true;
	       next_char;
	       skip_comments;
	    else
	       cc := c1;
	       column := start_column;
	    end;
	 end;
      end;

   skip1unless2(c1, c2: CHARACTER): BOOLEAN is
      do
	 start_line := line;
	 start_column := column;
	 if cc = c1 then
	    next_char;
	    if cc = c2 then
	       cc := c1;
	       column := start_column;
	    else
	       Result := true;
	       skip_comments;
	    end;
	 end;
      end;

   skip_comments is
	 -- Skip separators and comments if any.
	 -- Unless `drop_comments', comments are stored in `last_comments'.
      local
	 sp: POSITION;
	 stop: BOOLEAN;
      do
	 from
	 until
	    stop
	 loop
	    inspect
	       cc
	    when ' ','%T','%N' then
	       next_char;
	    when '-' then
	       next_char;
	       if cc = '-' then
		  if drop_comments then
		     if line = parser_buffer.count then
			cc := end_of_text;
			stop := true;
		     else
			line := line + 1;
			column := 1;
			current_line := parser_buffer.item(line);
			if current_line.count = 0 then
			   cc := '%N';
			else
			   cc := current_line.first;
			end;
		     end;
		  else
		     from
			sp := pos(line,column - 1);
			next_char;
			lcs.clear;
		     until
			cc = '%N'
		     loop
			lcs.extend(cc);
			next_char;
		     end;
		     if last_comments = Void then
			!!last_comments.make(sp,lcs.twin);
		     else
			last_comments.add_last(lcs.twin);
		     end;
		  end;
	       else
		  cc := '-';
		  column := column - 1;
		  stop := true;
	       end;
	    else
	       stop := true;
	    end;
	 end;
      end;

   a_bit_constant: BOOLEAN is
      local
	 l, c, state: INTEGER;
	 -- state 0 : first bit read.
	 -- state 1 : happy end.
	 -- state 2 : error end.
      do
	 if cc = '0' or else cc = '1' then
	    from
	       l := line;
	       c := column;
	       tmp_string.clear;
	       tmp_string.extend(cc);
	    until
	       state > 0
	    loop
	       next_char;
	       inspect
		  cc
	       when '0','1' then
		  tmp_string.extend(cc);
	       when 'b','B' then
		  !!last_bit_constant.make(pos(l,c),tmp_string.twin);
		  next_char;
		  skip_comments;
		  state := 1;
		  Result := true;
	       else
		  go_back_at(l,c);
		  state := 2;
	       end;
	    end;
	 end;
      end;

   a_character_constant: BOOLEAN is
      local
	 sp: POSITION;
	 state, printing_mode: INTEGER;
	 value: CHARACTER;
	 -- state 0 : first '%'' read.
	 -- state 1 : first '%%' read.
	 -- state 2 : wait for second '%''.
	 -- state 3 : happy end.
      do
	 if cc = '%'' then
	    from
	       sp := pos(line,column);
	       Result := true;
	    until
	       state > 2
	    loop
	       next_char;
	       inspect
		  state
	       when 0 then
		  inspect
		     cc
		  when '%%' then
		     state := 1;
		  when '%'' then
		     fcp(em10);
		     state := 2;
		  else
		     value := cc;
		     printing_mode := 0;
		     state := 2;
		  end;
	       when 1 then
		  printing_mode := 1;
		  state := 2;
		  inspect
		     cc
		  when 'A' then
		     value := '%A';
		  when 'B' then
		     value := '%B';
		  when 'C' then
		     value := '%C';
		  when 'D' then
		     value := '%D';
		  when 'F' then
		     value := '%F';
		  when 'H' then
		     value := '%H';
		  when 'L' then
		     value := '%L';
		  when 'N' then
		     value := '%N';
		  when 'Q' then
		     value := '%Q';
		  when 'R' then
		     value := '%R';
		  when 'S' then
		     value := '%S';
		  when 'T' then
		     value := '%T';
		  when 'U' then
		     value := '%U';
		  when 'V' then
		     value := '%V';
		  when '%%' then
		     value := '%%';
		  when '%'' then
		     value := '%'';
		  when '%"' then
		     value := '%"';
		  when '(' then
		     value := '%(';
		  when ')' then
		     value := '%)';
		  when '<' then
		     value := '%<';
		  when '>' then
		     value := '%>';
		  when '/' then
		     a_ascii_code;
		     value := last_ascii_code.to_character;
		     printing_mode := 2;
		  else
		     fcp("Unknown special character.");
		  end;
	       else -- state = 2
		  state := 3;
		  inspect
		     cc
		  when '%'' then
		  else
		     fcp(em10);
		  end;
		  next_char;
		  skip_comments;
	       end;
	    end;
	    !!last_character_constant.make(sp,value,printing_mode);
	 end;
      end;

   a_constant: BOOLEAN is
	 -- Only true for constant allowed in "when of inspect".
      local
	 implicit_current: IMPLICIT_CURRENT;
	 sfn: SIMPLE_FEATURE_NAME;
      do
	 if a_identifier then
	    Result := true;
	    sfn := tmp_name.to_simple_feature_name;
	    !!implicit_current.make(sfn.start_position);
	    !CALL_0_C!last_expression.make(implicit_current,sfn);
	 elseif a_character_constant then
	    Result := true;
	    last_expression := last_character_constant;
	 elseif a_integer_constant then
	    Result := true;
	    last_expression := last_integer_constant;
	 end;
      end;

   a_base_class_name: BOOLEAN is
      local
	 state, c: INTEGER;
	 do_warning: BOOLEAN;
	 -- state 0 : first letter read.
	 -- state 1 : end.
      do
	 if cc.is_letter then
	    from
	       if cc >= 'a' then
		  do_warning := true;
		  cc := cc.to_upper;
	       end;
	       c := column;
	       tmp_name.reset(pos(line,c));
	       tmp_name.extend(cc);
	    until
	       state > 0
	    loop
	       next_char;
	       inspect
		  cc
	       when 'A'..'Z','0'..'9','_' then
		  tmp_name.extend(cc);
	       when 'a'..'z' then
		  do_warning := true;
		  tmp_name.extend(cc.to_upper);
	       else
		  state := 1;
	       end;
	    end;
	    if tmp_name.isa_keyword then
	       cc := tmp_name.buffer.first;
	       column := c;
	    else
	       Result := true;
	       skip_comments;
	       if do_warning then
		  warning(tmp_name.start_position,em14);
	       end;
	       last_class_name := tmp_name.to_class_name;
	    end;
	 end;
      end;

   a_base_class_name1 is
	 -- Read the current base class name.
      local
	 cn: CLASS_NAME;
	 bc: BASE_CLASS;
      do
	 bc := last_base_class;
	 cn := bc.name;
	 cn.set_accurate_position(pos(line,column));
	 if a_base_class_name then
	    if last_class_name.to_string /= cn.to_string then
	       eh.add_position(last_class_name.start_position);
	       eh.append(fz_01);
	       eh.append(bc.path);
	       eh.append("%" does not contains class %"");
	       eh.append(cn.to_string);
	       fatal_error(fz_03);
	    end;
	 else
	    fcp(em15);
	 end;
	 if forbidden_class.fast_has(cn.to_string) then
	    eh.add_position(cn.start_position);
	    fatal_error("Cannot write such a class.");
	 end;
      end;
   
   a_type_formal_generic: BOOLEAN is
      local
	 fga: FORMAL_GENERIC_ARG;
	 cn: CLASS_NAME;
	 rank: INTEGER;
      do
	 if formal_generic_list /= Void then
	    from
	       rank := 1;
	    until
	       Result or else rank > formal_generic_list.count
	    loop
	       fga := formal_generic_list.item(rank);
	       if a_keyword(fga.name.to_string) then
		  !!cn.make(fga.name.to_string,pos(start_line,start_column));
		  !!last_type_formal_generic.make(cn,rank);
		  Result := true;
	       end;
	       rank := rank + 1;
	    end;
	 end;
      end;

   a_free_operator: BOOLEAN is
	 --++ free_operator -> "@..." |
	 --++                  "#..." |
	 --++                  "|..." |
	 --++                  "&..."
	 --++
      do
	 if (cc = '@') or else
	    (cc = '#') or else
	    (cc = '|') or else
	    (cc = '&') then
	    Result := true;
	    from
	       tmp_name.reset(pos(line,column));
	       tmp_name.extend(cc);
	       next_char;
	    until
	       (cc = '%N') or else
	       (cc = ' ') or else
	       (cc = '%T') or else
	       (cc = '%"')
	    loop
	       tmp_name.extend(cc);
	       next_char;
	    end;
	    skip_comments;
	 end;
      end;

   a_identifier: BOOLEAN is
      do
	 if case_insensitive then
	    Result := a_identifier1;
	 else
	    Result := a_identifier2;
	 end;
      end;

   a_integer: BOOLEAN is
      local
	 sp: POSITION;
	 state, value: INTEGER;
	 -- state 0 : 1st digit read (no '_' encountered).
	 -- state 1 : 2nd digit read (no '_' encountered).
	 -- state 2 : 3rd digit read (no '_' encountered).
	 -- state 3 : more than 3 digit read (no '_' encountered).
	 -- state 4 : after '_'.
	 -- state 5 : after '_' and 1 digit read.
	 -- state 6 : after '_' and 2 digit read.
	 -- state 7 : after '_' and 3 digit read.
	 -- state 8 : satisfaction state.
      do
	 if cc.is_digit then
	    from
	       Result := true;
	       sp := pos(line,column);
	       value := cc.value;
	    until
	       state > 7
	    loop
	       next_char;
	       inspect
		  state
	       when 0 then
		  inspect
		     cc
		  when '0'..'9' then
		     value := value * 10 + cc.value;
		     state := 1;
		  when '_' then
		     state := 4;
		  else
		     state := 8;
		  end;
	       when 1 then
		  inspect
		     cc
		  when '0'..'9' then
		     value := value * 10 + cc.value;
		     state := 2;
		  when '_' then
		     state := 4;
		  else
		     state := 8;
		  end;
	       when 2 then
		  inspect
		     cc
		  when '0'..'9' then
		     value := value * 10 + cc.value;
		     state := 3;
		  when '_' then
		     state := 4;
		  else
		     state := 8;
		  end;
	       when 3 then
		  inspect
		     cc
		  when '0'..'9' then
		     value := value * 10 + cc.value;
		  when '_' then
		     fcp(em9);
		  else
		     state := 8;
		  end;
	       when 4 then
		  inspect
		     cc
		  when '0'..'9' then
		     value := value * 10 + cc.value;
		     state := 5;
		  else
		     fcp(em9);
		  end;
	       when 5 then
		  inspect
		     cc
		  when '0'..'9' then
		     value := value * 10 + cc.value;
		     state := 6;
		  else
		     fcp(em9);
		  end;
	       when 6 then
		  inspect
		     cc
		  when '0'..'9' then
		     value := value * 10 + cc.value;
		     state := 7;
		  else
		     fcp(em9);
		  end;
	       when 7 then
		  inspect
		     cc
		  when '0'..'9' then
		     fcp(em9);
		  when '_' then
		     state := 4;
		  else
		     state := 8;
		  end;
	       end;
	    end;
	    if cc.is_letter then
	       fcp(em17);
	    end;
	    skip_comments;
	    !!last_integer_constant.make(value,sp);
	 end;
      end;

   a_manifest_string: BOOLEAN is
      local
	 state: INTEGER;
	 -- state 0 : inside string.
	 -- state 1 : just read a '%%'.
	 -- state 2 : extended form starting (waiting for '%N').
	 -- state 3 : extended form ending (waiting for '%%').
	 -- state 4 : happy end.
      do
	 if cc = '%"' then
	    from
	       Result := true;
	       !!last_manifest_string.make(pos(line,column));
	    until
	       state > 3
	    loop
	       next_char;
	       inspect
		  state
	       when 0 then
		  inspect
		     cc
		  when '%N' then
		     fcp(em8);
		  when '%"' then
		     state := 4;
		  when '%%' then
		     state := 1;
		  else
		     last_manifest_string.add(cc);
		  end;
	       when 1 then
		  state := 0;
		  inspect
		     cc
		  when '%N' then
		     state := 3;
		  when 'A' then
		     last_manifest_string.add_percent('%A');
		  when 'B' then
		     last_manifest_string.add_percent('%B');
		  when 'C' then
		     last_manifest_string.add_percent('%C');
		  when 'D' then
		     last_manifest_string.add_percent('%D');
		  when 'F' then
		     last_manifest_string.add_percent('%F');
		  when 'H' then
		     last_manifest_string.add_percent('%H');
		  when 'L' then
		     last_manifest_string.add_percent('%L');
		  when 'N' then
		     last_manifest_string.add_percent('%N');
		  when 'Q' then
		     last_manifest_string.add_percent('%Q');
		  when 'R' then
		     last_manifest_string.add_percent('%R');
		  when 'S' then
		     last_manifest_string.add_percent('%S');
		  when 'T' then
		     last_manifest_string.add_percent('%T');
		  when 'U' then
		     last_manifest_string.add_percent('%U');
		  when 'V' then
		     last_manifest_string.add_percent('%V');
		  when '%%' then
		     last_manifest_string.add_percent('%%');
		  when '%'' then
		     last_manifest_string.add_percent('%'');
		  when '%"' then
		     last_manifest_string.add_percent('%"');
		  when '(' then
		     last_manifest_string.add_percent('%(');
		  when ')' then
		     last_manifest_string.add_percent('%)');
		  when '<' then
		     last_manifest_string.add_percent('%<');
		  when '>' then
		     last_manifest_string.add_percent('%>');
		  when '/' then
		     a_ascii_code;
		     last_manifest_string.add_ascii(last_ascii_code.to_character);
		  when ' ','%T' then
		     state := 2;
		  else
		     fcp("Unknown special character.");
		     state := 0;
		  end;
	       when 2 then
		  inspect
		     cc
		  when '%N' then
		     state := 3;
		  when ' ','%T' then
		  else
		     fcp("In extended form of manifest string.%
			 %Bad character after '%%'.");
		  end;
	       else -- state = 3
		  inspect
		     cc
		  when ' ','%T' then
		  when '%%' then
		     last_manifest_string.break_line;
		     state := 0;
		  when '%N' then
		     fcp(em8);
		     state := 0;
		  else
		     fcp("In extended form of manifest string.%
			 % Bad character before '%%'.");
		     state := 0;
		  end;
	       end;
	    end;
	    next_char;
	    skip_comments;
	 end;
      end;

   a_real: BOOLEAN is
      local
	 state, l, c: INTEGER;
	 -- state 0  : reading integral part.
	 -- state 1  : reading integral part after '_'.
	 -- state 2  : reading integral part after '_' and 1 digit.
	 -- state 3  : reading integral part after '_' and 2 digits.
	 -- state 4  : '.' read and not empty integral_part.
	 -- state 5  : '.' read and empty integral_part.
	 -- state 6  : reading frac_part.
	 -- state 7  : reading frac_part after '_'.
	 -- state 8  : reading frac_part after '_' and 1 digit.
	 -- state 9  : reading frac_part after '_' and 2 digits.
	 -- state 10 : 'E' or 'e' read.
	 -- state 11 : reading exponent.
	 -- state 12 : happy end.
	 -- state 13 : error end.
      do
	 if cc.is_digit or else cc = '.' then
	    from
	       l := line;
	       c := column;
	       tmp_string.clear;
	       if cc = '.' then
		  tmp_string.append(fz_59);
		  state := 5;
	       else
		  tmp_string.extend(cc);
	       end;
	    until
	       state > 11
	    loop
	       next_char;
	       inspect
		  state
	       when 0 then
		  inspect
		     cc
		  when '0' .. '9' then
		     tmp_string.extend(cc);
		  when '.' then
		     tmp_string.extend('.');
		     state := 4;
		  else
		     state := 13;
		  end;
	       when 1 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 2;
		  else
		     fcp(em9);
		  end;
	       when 2 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 3;
		  else
		     fcp(em9);
		  end;
	       when 3 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 0;
		  else
		     fcp(em9);
		  end;
	       when 4 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 6;
		  when 'E','e' then
		     tmp_string.extend('E');
		     state := 10;
		  else
		     state := 12;
		  end;
	       when 5 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 6;
		  else
		     state := 13;
		  end;
	       when 6 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		  when 'E','e' then
		     tmp_string.extend('E');
		     state := 10;
		  when '_' then
		     state := 7;
		  else
		     state := 12;
		  end;
	       when 7 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 8;
		  else
		     fcp(em1);
		  end;
	       when 8 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 9;
		  else
		     fcp(em1);
		  end;
	       when 9 then
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 6;
		  else
		     fcp(em1);
		  end;
	       when 10 then
		  inspect
		     cc
		  when '+' then
		     state := 11;
		  when '-' then
		     tmp_string.extend('-');
		     state := 11;
		  when '0'..'9' then
		     tmp_string.extend(cc);
		     state := 11
		  else
		     fcp("Exponent of a real value expected.");
		     state := 13;
		  end;
	       else -- state = 11
		  inspect
		     cc
		  when '0'..'9' then
		     tmp_string.extend(cc);
		  else
		     state := 12;
		  end;
	       end;
	    end;
	    if state = 12 then
	       !!last_real_constant.make(pos(l,c),tmp_string.twin);
	       Result := true;
	       skip_comments;
	    else
	       go_back_at(l,c);
	    end;
	 end;
      end;

   a_retry: BOOLEAN is
      do
	 if a_keyword(fz_retry) then
	    if not in_rescue then
	       error(pos(start_line,start_column),
		     "%"retry%" cannot be outside of a rescue clause.");
	    end;
	    !E_RETRY!last_instruction.make(pos(start_line,start_column));
	    Result := true;
	 end;
      end;

   a_actual: BOOLEAN is
	 --++ actual -> expression |
	 --++           "$" identifier
	 --++
      do
	 if skip1('%D') then
	    if a_identifier then
	       if a_result or else a_void or else a_current then
		  eh.add_position(last_expression.start_position);
		  fatal_error(fz_vuar4);
	       else
		  !ADDRESS_OF!last_expression.make(tmp_name.to_simple_feature_name);
		  Result:= true;
	       end;
	    else
	       fcp(fz_vuar4);
	    end;
	 elseif a_expression then
	    Result := true;
	 end;
      end;

   a_actuals: EFFECTIVE_ARG_LIST is
	 --++ actuals -> "(" {actual "," ...} ")"
	 --++
      local
	 first_one: EXPRESSION;
	 remainder: FIXED_ARRAY[EXPRESSION];
      do
	 if skip1('(') then
	    from
	    until
	       not a_actual
	    loop
	       if first_one = Void then
		  first_one := last_expression;
	       else
		  if remainder = Void then
		     !!remainder.with_capacity(4);
		  end;
		  remainder.add_last(last_expression);
	       end;
	       if not skip1(',') and then cc /= ')' then
	    wcp(em5);
	       end;
	    end;
	    if first_one = Void then
	       wcp("Empty argument list (deleted).");
	    else
	       !!Result.make_n(first_one,remainder);
	    end;
	    if not skip1(')') then
	       fcp("')' expected to end arguments list.");
	    end;
	 end;
      end;

   a_after_a_dot(do_instruction: BOOLEAN; target: EXPRESSION) is
	 --++ after_a_dot -> identifier [actuals] ["." after_a_dot]
	 --++
      require
	 target /= Void
      local
	 sfn: SIMPLE_FEATURE_NAME;
	 eal: EFFECTIVE_ARG_LIST;
      do
	 if a_identifier then
	    if a_result or else a_void or else a_current then
	       error(last_expression.start_position,
		     "This name must not appear after a dot.");
	    end;
	    sfn := tmp_name.to_simple_feature_name;
	    eal := a_actuals;
	    a_r10(do_instruction,target,sfn,eal);
	 else
	    fcp("Identifier expected after a dot.");
	 end;
      end;

   a_assignment_or_call: BOOLEAN is
	 --++ assignment_or_call -> "(" expression ")" r10 |
	 --++                       precursor_call |
	 --++                       "Current" r10 |
	 --++                       "Result" r10 |
	 --++                       local_variable r10 |
	 --++                       formal_argument r10 |
	 --++                       writable ":=" expression |
	 --++                       writable "?=" expression |
	 --++                       identifier procedure_call
	 --++
      do
	 if skip1('(') and then a_expression then
	    Result := true;
	    if skip1(')') then
	       a_r10(true,last_expression,Void,Void);
	    else
	       fcp("')' expected.");
	    end;
	 elseif a_precursor(true) then
	    Result := true;
	 elseif a_identifier then
	    Result := true;
	    if skip2(':','=') then
	       a_assignment_aux(true);
	    elseif skip2('?','=') then
	       a_assignment_aux(false);
	    elseif a_current or else a_result or else a_local_variable
	       or else a_argument then
	       a_r10(true,last_expression,Void,Void);
	    else
	       a_procedure_call;
	    end;
	 end;
      end;

   a_assignment_aux(regular: BOOLEAN) is
      local
	 writable, rhs: EXPRESSION;
      do
	 if a_current then
	    eh.add_position(last_expression.start_position);
	    fatal_error("Must not affect `Current'.");
	 elseif a_void then
	    eh.add_position(tmp_name.start_position);
	    fatal_error("Must not affect `Void'.");
	 elseif a_argument then
	    eh.add_position(last_expression.start_position);
	    fatal_error("Must not affect a formal argument.");
	 else
	    if tmp_name.is_result then
	       writable := last_result;
	    elseif a_local_variable then
	       writable := last_expression;
	    else
	       writable := tmp_name.to_simple_feature_name;
	    end;
	    if a_expression then
	       rhs := last_expression;
	       if regular then
		  !ASSIGNMENT!last_instruction.make(writable,rhs);
	       else
		  !REVERSE_ASSIGNMENT!last_instruction.make(writable,rhs);
	       end;
	    else
	       fcp("Right hand side expression expected for assignment.");
	    end;
	 end;
      end;

   a_assertion: ARRAY[ASSERTION] is
	 --++ assertion -> {assertion_clause ";" ...}
	 --++ assertion_clause -> [identifier ":"] [expression] [comment]
	 --++
      local
	 tag: like last_tag_mark;
	 expression: like last_expression;
	 assertion: ASSERTION;
	 state: INTEGER;
	 -- state 0 : nothing read.
	 -- state 1 : read a `tag'.
	 -- state 2 : read an `expression'.
	 -- state 3 : read a `tag' and an `expression'.
	 -- state 4 : end;
      do
	 from
	 until
	    state > 3
	 loop
	    inspect
	       state
	    when 0 then
	       if cc = ';' then
		  wcp(fz_desc);
		  ok := skip1(';');
		  if last_comments /= Void then
		     !!assertion.make(Void,Void,get_comments);
		     if Result = Void then
			!!Result.with_capacity(2,1);
		     end;
		     Result.add_last(assertion);
		  end;
	       elseif a_tag_mark then
		  tag := last_tag_mark;
		  state := 1;
	       elseif a_expression then
		  expression := last_expression;
		  state := 2;
	       else
		  state := 4;
	       end;
	    when 1 then
	       if skip1(';') then
		  !!assertion.make(tag,Void,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  state := 0;
	       elseif a_tag_mark then
		  !!assertion.make(tag,Void,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  tag := last_tag_mark;
	       elseif a_expression then
		  expression := last_expression;
		  state := 3;
	       else
		  !!assertion.make(tag,Void,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  state := 4;
	       end;
	    when 2 then
	       if skip1(';') then
		  !!assertion.make(Void,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  state := 0;
	       elseif a_tag_mark then
		  !!assertion.make(Void,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  tag := last_tag_mark;
		  state := 1;
	       elseif a_expression then
		  !!assertion.make(Void,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  expression := last_expression;
		  state := 2;
	       else
		  !!assertion.make(Void,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  state := 4;
	       end;
	    else -- state = 3
	       if skip1(';') then
		  !!assertion.make(tag,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  state := 0;
	       elseif a_tag_mark then
		  !!assertion.make(tag,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  tag := last_tag_mark;
		  state := 1;
	       elseif a_expression then
		  !!assertion.make(tag,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  expression := last_expression;
		  state := 2;
	       else
		  !!assertion.make(tag,expression,get_comments);
		  if Result = Void then
		     !!Result.with_capacity(2,1);
		  end;
		  Result.add_last(assertion);
		  state := 4;
	       end;
	    end;
	 end;
      end;

   a_base_type: BOOLEAN is
	 --++ base_type -> "ANY" | ARRAY "[" type "]" | "BOOLEAN" |
	 --++         "CHARACTER" | "DOUBLE" | "INTEGER" | "NONE" |
	 --++         "POINTER" | "REAL" | "STRING"
	 --++
      local
	 sp: POSITION;
      do
	 Result := true;
	 if a_keyword(as_any) then
	    !TYPE_ANY!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_array) then
	    sp := pos(start_line,start_column);
	    if skip1('[') and then a_type and then skip1(']') then
	       check
		  last_type /= Void
	       end;
	       !TYPE_ARRAY!last_base_type.make(sp,last_type);
	    else
	       fcp("Bad use of predefined type ARRAY.");
	    end;
	 elseif a_keyword(as_native_array) then
	    sp := pos(start_line,start_column);
	    if skip1('[') and then a_type and then skip1(']') then
	       check
		  last_type /= Void
	       end;
	       !TYPE_NATIVE_ARRAY!last_base_type.make(sp,last_type);
	    else
	       fcp("Bad use of predefined type NATIVE_ARRAY.");
	    end;
	 elseif a_keyword(as_boolean) then
	    !TYPE_BOOLEAN!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_character) then
	    !TYPE_CHARACTER!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_double) then
	    !TYPE_DOUBLE!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_integer) then
	    !TYPE_INTEGER!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_none) then
	    !TYPE_NONE!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_pointer) then
	    !TYPE_POINTER!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_real) then
	    !TYPE_REAL!last_base_type.make(pos(start_line,start_column));
	 elseif a_keyword(as_string) then
	    !TYPE_STRING!last_base_type.make(pos(start_line,start_column));
	 else
	    Result := false;
	 end;
      end;

   a_binary(sp: POSITION): BOOLEAN is
	 --++ binary -> "<=" | ">=" | "//" | "\\" |
	 --++           "+" | "-" | "*" | "/" | "<" | ">" | "^" |
	 --++           xor" | "implies" | "and then" | "and" | "or else" | "or"
	 --++
      do
	 Result := true;
	 if skip2('<','=') then
	    !!last_binary.make(as_le,sp);
	 elseif skip2('>','=') then
	    !!last_binary.make(as_ge,sp);
	 elseif skip2('/','/') then
	    !!last_binary.make(as_slash_slash,sp);
	 elseif skip2('\','\') then
	    !!last_binary.make(as_backslash_backslash,sp);
	 elseif skip1('+') then
	    !!last_binary.make(as_plus,sp);
	 elseif skip1('-') then
	    !!last_binary.make(as_minus,sp);
	 elseif skip1('*') then
	    !!last_binary.make(as_muls,sp);
	 elseif skip1('/') then
	    !!last_binary.make(as_slash,sp);
	 elseif skip1('>') then
	    !!last_binary.make(as_gt,sp);
	 elseif skip1('<') then
	    !!last_binary.make(as_lt,sp);
	 elseif skip1('^') then
	    !!last_binary.make(as_pow,sp);
	 elseif a_keyword(as_xor) then
	    !!last_binary.make(as_xor,sp);
	 elseif a_keyword(as_implies) then
	    !!last_binary.make(as_implies,sp)
	 elseif a_keyword(as_and) then
	    if a_keyword(fz_then) then
	       !!last_binary.make(as_and_then,sp);
	    else
	       !!last_binary.make(as_and,sp);
	    end;
	 elseif a_keyword(as_or) then
	    if a_keyword(fz_else) then
	       !!last_binary.make(as_or_else,sp);
	    else
	       !!last_binary.make(as_or,sp);
	    end;
	 else
	    last_binary := Void;
	    Result := false;
	 end;
      end;

   a_boolean_constant: BOOLEAN is
	 --++ boolean_constant -> "true" | "false"
	 --++
      do
	 if a_keyword(fz_true) then
	    !E_TRUE!last_boolean_constant.make(pos(start_line,start_column));
	    Result := true;
	 elseif a_keyword(fz_false) then
	    !E_FALSE!last_boolean_constant.make(pos(start_line,start_column));
	    Result := true;
	 end;
      end;

   a_character_or_integer: BOOLEAN is
	 --++ character_or_integer -> character_constant |
	 --++                         integer_constant
	 --++
      do
	 if a_character_constant then
	    last_character_or_integer := last_character_constant;
	    Result := true;
	 elseif a_integer_constant then
	    last_character_or_integer := last_integer_constant;
	    Result := true;
	 end;
      end;

   a_check: BOOLEAN is
	 --++ check -> "check" assertion "end"
	 --++
      local
	 sp: POSITION;
	 hc: COMMENT;
	 al: ARRAY[ASSERTION];
      do
	 if a_keyword(fz_check) then
	    sp := pos(start_line,start_column);
	    hc := get_comments;
	    al := a_assertion;
	    if not a_keyword(fz_end) then
	       eh.add_position(sp);
	       fcp("Keyword %"end%" expected at the end of check clause.");
	    end;
	    if hc /= Void or else al /= Void then
	       !E_CHECK!last_instruction.make(sp,hc,al);
	       Result := true;
	    elseif skip1(';') then
	    end;
	 end;
      end;

   a_class_declaration is
	 --++ class_declaration -> [indexing]
	 --++                      ["expanded" | "deferred"]
	 --++                      "class" base_class_name
	 --++                      ["[" formal_generic_list "]"]
	 --++                      [comment]
	 --++                      ["obsolete" manifest_string]
	 --++                      ["inherit" parent_list]
	 --++                      {"creation" creation_clause ...}
	 --++                      {"create" creation_clause ...}
	 --++                      {"feature" feature_clause ...}
	 --++                      ["invariant" assertion]
	 --++                      "end"
	 --++
      local
	 sp: POSITION;
	 hc: COMMENT;
	 al: ARRAY[ASSERTION];
	 drop_comments_save: BOOLEAN;
      do
	 a_indexing;
	 if a_keyword(fz_deferred) then
	    last_base_class.set_is_deferred;
	 end;
	 if a_keyword(fz_expanded) then
	    last_base_class.set_is_expanded;
	    if a_keyword(fz_deferred) then
	       last_base_class.set_is_deferred;
	    end;
	 end;
	 last_base_class.set_heading_comment1(get_comments);
	 if not a_keyword(fz_class) then
	    fcp("Keyword %"class%" expected.");
	 end;
	 a_base_class_name1;
	 a_formal_generic_list;
	 if a_keyword(fz_obsolete) then
	    if a_manifest_string then
	       last_base_class.set_obsolete_type_string(last_manifest_string);
	    else
	       fcp("Manifest string expected for %"obsolete%" clause.");
	    end;
	 end;
	 last_base_class.set_heading_comment2(get_comments);
	 if a_keyword(fz_inherit) then
	    a_parent_list(pos(start_line,start_column),get_comments);
	 end;
	 from
	 until
	    not (a_keyword(fz_creation) or else a_keyword(fz_create))
	 loop
	    a_creation_clause(pos(start_line,start_column));
	 end;
	 from
	 until
	    not a_keyword(fz_feature)
	 loop
	    a_feature_clause;
	 end;
	 drop_comments_save := drop_comments;
	 drop_comments := false;
	 if a_keyword(fz_invariant) then
	    sp := pos(start_line,start_column);
	    hc := get_comments;
	    al := a_assertion;
	    last_base_class.set_invariant(sp,hc,al);
	 end;
	 if a_keyword(fz_end) or else last_keyword = fz_end then
	    if cc = ';' then
	       wcp(fz_desc);
	       ok := skip1(';');
	    end;
	    last_base_class.set_end_comment(get_comments);
	    if cc /= end_of_text then
	       fcp("End of text expected.");
	    end;
	 else
	    fcp("Keyword %"end%" expected at the end of a class.");
	 end;
	 drop_comments := drop_comments_save;
      end;

   a_class_type: BOOLEAN is
	 --++ class_type -> base_type |
	 --++               base_class_name ["[" {type "," ...} "]"]
	 --++
      local
	 state: INTEGER;
	 base_class_name: CLASS_NAME;
	 generic_list: ARRAY[TYPE];
	 -- state 0 : `base_class_name' read.
	 -- state 1 : waiting next generic argument.
	 -- state 2 : waiting ',' or ']'.
	 -- state 3 : end.
      do
	 if a_base_type then
	    last_class_type := last_base_type;
	    Result := true;
	 elseif a_base_class_name then
	    from
	       Result := true;
	       base_class_name := last_class_name;
	    until
	       state > 2
	    loop
	       inspect
		  state
	       when 0 then
		  if skip1('[') then
		     state := 1;
		  else
		     !TYPE_CLASS!last_class_type.make(base_class_name);
		     state := 3;
		  end;
	       when 1 then
		  if a_type then
		     if generic_list = Void then
			!!generic_list.with_capacity(2,1);
		     end;
		     generic_list.add_last(last_type);
		     state := 2;
		  elseif cc = ',' then
		     wcp(em12);
		     ok := skip1(',');
		  elseif cc = ']' then
		     state := 2;
		  else
		     fcp(em16);
		     state := 2;
		  end;
	       else -- state = 2
		  if skip1(',') then
		     state := 1;
		  elseif cc = ']' then
		     if generic_list = Void then
			wcp("Empty generic list (deleted).");
			!TYPE_CLASS!last_class_type.make(base_class_name);
		     else
			!TYPE_GENERIC!last_class_type.make(base_class_name,generic_list);
		     end;
		     ok := skip1(']');
		     state := 3;
		  elseif a_type then
		     if generic_list = Void then
			!!generic_list.with_capacity(2,1);
		     end;
		     generic_list.add_last(last_type);
		     warning(last_type.start_position,em5);
		  else
		     fcp("Bad generic list.");
		     state := 3;
		  end;
	       end;
	    end;
	 end;
      end;

   a_clients: CLIENT_LIST is
	 --++ clients -> "{" { base_class_name "," ... } "}"
	 --++
      local
	 sp: POSITION;
	 list: CLASS_NAME_LIST;
	 state: INTEGER;
	 -- state 0 : waiting a base_class_name or "}" if empty list.
	 -- state 1 : waiting a base_class_name after a ",".
	 -- state 2 : waiting "," or "}" to end list.
	 -- state 3 : error.
	 -- state 4 : end.
      do
	 if skip1('{') then
	    from
	       sp := pos(start_line,start_column);
	    until
	       state > 3
	    loop
	       inspect
		  state
	       when 0 then
		  if a_base_class_name then
		     !!list.make_1(last_class_name);
		     state := 2;
		  elseif skip1('}') then
		     state := 4;
		  elseif cc = ',' then
		     wcp(em7);
		     ok := skip1(',');
		  else
		     state := 3;
		  end;
	       when 1 then
		  if a_base_class_name then
		     list.add_last(last_class_name);
		     state := 2;
		  elseif cc = ',' then
		     wcp(em7);
		     ok := skip1(',');
		  elseif cc = '}' then
		     wcp("Unexpected bracket.");
		     ok := skip1('}');
		     state := 4;
		  else
		     state := 3;
		  end;
	       when 2 then
		  if skip1(',') then
		     state := 1;
		  elseif skip1('}') then
		     state := 4;
		  elseif a_base_class_name then
		     warning(last_class_name.start_position,em5);
		     list.add_last(last_class_name);
		  else
		     state := 3;
		  end;
	       else -- state = 3
		  fcp(em11);
		  state := 4;
	       end;
	    end;
	    !!Result.make(sp,list);
	 else
	    !!Result.omitted;
	 end;
      ensure
	 Result /= Void
      end;

   a_compound1: COMPOUND is
	 --++ compound -> {instruction ";" ...}
	 --++
      local
	 hc: COMMENT;
	 instruction, first_one: INSTRUCTION;
	 remainder: FIXED_ARRAY[INSTRUCTION];
      do
	 from
	    hc := get_comments;
	    from
	    until
	       cc /= ';'
	    loop
	       wcp(fz_desc);
	       ok := skip1(';');
	    end;
	 until
	    not a_instruction or else nb_errors > 0
	 loop
	    instruction := last_instruction;
	    check
	       instruction /= Void;
	    end;
	    if cc = '(' then
	       wcp(em6);
	    end;
	    from
	       ok := skip1(';');
	    until
	       cc /= ';'
	    loop
	       wcp(fz_desc);
	       ok := skip1(';');
	    end;
	    if nb_errors = 0 then
	       instruction := instruction.add_comment(get_comments);
	       if first_one = Void then
		  first_one := instruction;
	       else
		  if remainder = Void then
		     !!remainder.with_capacity(4);
		  end;
		  remainder.add_last(instruction);
	       end;
	    end;
	 end;
	 if hc /= Void or else first_one /= Void then
	    !!Result.make(hc,first_one,remainder);
	 end;
      end;

   a_compound2(compound_of, terminator: STRING): COMPOUND is
	 -- Like a_compound1 but stop when `terminator' is encountered.
      local
	 hc: COMMENT;
	 instruction, first_one: INSTRUCTION;
	 remainder: FIXED_ARRAY[INSTRUCTION];
      do
	 from
	    hc := get_comments;
	    from
	    until
	       cc /= ';'
	    loop
	       wcp(fz_desc);
	       ok := skip1(';');
	    end;
	 until
	    not a_instruction or else nb_errors > 0
	 loop
	    instruction := last_instruction;
	    check
	       instruction /= Void;
	    end;
	    if cc = '(' then
	       wcp(em6);
	    end;
	    from
	       ok := skip1(';');
	    until
	       cc /= ';'
	    loop
	       wcp(fz_desc);
	       ok := skip1(';');
	    end;
	    if nb_errors = 0 then
	       instruction := instruction.add_comment(get_comments);
	       if first_one = Void then
		  first_one := instruction;
	       else
		  if remainder = Void then
		     !!remainder.with_capacity(4);
		  end;
		  remainder.add_last(instruction);
	       end;
	    end;
	 end;
	 if not a_keyword(terminator) then
	    eh.append("In compound (");
	    eh.append(compound_of);
	    eh.append("). Instruction or keyword %"");
	    eh.append(terminator);
	    fcp("%" expected.");
	 end;
	 if hc /= Void or else first_one /= Void then
	    !!Result.make(hc,first_one,remainder);
	 end;
      end;

   a_conditional: BOOLEAN is
	 --++ conditional -> "if" then_part_list ["else" compound] "end"
	 --++
      local
	 ifthenelse: IFTHENELSE;
      do
	 if a_keyword(fz_if) then
	    Result := true;
	    !!ifthenelse.make(pos(start_line,start_column));
	    a_then_part_list(ifthenelse);
	    if a_keyword(fz_else) then
	       ifthenelse.set_else_compound(a_compound2("else part",fz_end));
	    else
	       if not a_keyword(fz_end) then
		  wcp("Keyword %"end%" added.");
	       end;
	    end;
	    last_instruction := ifthenelse;
	 end;
      end;

   a_creation: BOOLEAN is
	 --++ creation -> "!"[type]"!" writable ["." procedure_name [actuals]]
	 --++
      local
	 sp: POSITION;
	 type: TYPE;
	 writable: EXPRESSION;
	 procedure_name: SIMPLE_FEATURE_NAME;
	 call: PROC_CALL;
      do
	 if skip1('!') then
	    Result := true;
	    sp := pos(start_line,start_column);
	    if a_type then
	       type := last_type;
	       if type.is_anchored then
		  warning(type.start_position,em20);
	       end;
	       if not skip1('!') then
		  fcp("Bad creation instruction ('!' expected).");
	       end;
	    elseif skip1('!') then
	    else
	       fcp("Bad creation instruction (type or '!' expected).");
	    end;
	    writable := mandatory_writable;
	    if skip1('.') then
	       if a_identifier then
		  procedure_name := tmp_name.to_simple_feature_name;
		  if cc = '(' then
		     call := to_proc_call(writable,procedure_name,a_actuals);
		  else
		     !PROC_CALL_0!call.make(writable,procedure_name);
		  end;
	       else
		  fcp(em23);
	       end;
	    end;
	    if type = Void and then call = Void then
	       !CREATION_CALL_1!last_instruction.make(sp,writable);
	    elseif type /= Void and then call = Void then
	       !CREATION_CALL_2!last_instruction.make(sp,type,writable);
	    elseif type = Void and then call /= Void then
	       !CREATION_CALL_3!last_instruction.make(sp,writable,call);
	    else
	       !CREATION_CALL_4!last_instruction.make(sp,type,writable,call);
	    end;
	 end;
      end;

   a_create_instruction: BOOLEAN is
	 --++ create -> ["{" type "}"] writable ["." procedure_name [actuals]]
	 --++
	 -- Note: this is only syntactic sugar to accept this new 
	 -- notation (which is by now pretty_printed in the good old 
	 -- notation ;-).
      local
	 sp: POSITION;
	 type: TYPE;
	 writable: EXPRESSION;
	 procedure_name: SIMPLE_FEATURE_NAME;
	 call: PROC_CALL;
      do
	 if a_keyword(fz_create) then
	    Result := true;
	    sp := pos(start_line,start_column);
-- ***
--	    eh.add_position(sp);
--	    eh.append("New create instruction used (temporary warning %
--                      %because this new syntax may be ambigous).");
--	    eh.print_as_warning;
-- ***
	    if skip1('{') then
	       if a_type then
		  type := last_type;
		  if type.is_anchored then
		     warning(type.start_position,em20);
		  end;
		  if not skip1('}') then
		     fcp("Bad create instruction ('}' expected).");
		  end;
	       else
		  fcp("Bad create instruction (type expected).");
	       end;
	    end;
	    writable := mandatory_writable;
	    if skip1('.') then
	       if a_identifier then
		  procedure_name := tmp_name.to_simple_feature_name;
		  if cc = '(' then
		     call := to_proc_call(writable,procedure_name,a_actuals);
		  else
		     !PROC_CALL_0!call.make(writable,procedure_name);
		  end;
	       end;
	    end;
	    if type = Void and then call = Void then
	       !CREATION_CALL_1!last_instruction.make(sp,writable);
	    elseif type /= Void and then call = Void then
	       !CREATION_CALL_2!last_instruction.make(sp,type,writable);
	    elseif type = Void and then call /= Void then
	       !CREATION_CALL_3!last_instruction.make(sp,writable,call);
	    else
	       !CREATION_CALL_4!last_instruction.make(sp,type,writable,call);
	    end;
	 end;
      end;
   
   a_creation_clause(sp: POSITION) is
	 --++ creation_clause -> [clients] [comment] feature_list
	 --++
      local
	 clients: CLIENT_LIST;
	 comments: COMMENT;
	 creation_clause: CREATION_CLAUSE;
      do
	 clients := a_clients;
	 comments := get_comments;
	 if a_feature_name_list then
	 end;
	 !!creation_clause.make(sp,clients,comments,last_feature_name_list);
	 last_base_class.add_creation_clause(creation_clause);
      end;

   a_debug: BOOLEAN is
	 --++ debug -> "debug" "(" {manifest_string "," ...} ")"
	 --++                  compound "end"
	 --++
      local
	 sp: POSITION;
	 list: ARRAY[MANIFEST_STRING];
	 e_debug: E_DEBUG;
      do
	 if a_keyword(fz_debug) then
	    sp := pos(start_line,start_column);
	    if skip1('(') then
	       from
	       until
		  not a_manifest_string
	       loop
		  if list = Void then
		     !!list.with_capacity(2,1);
		  end;
		  list.add_last(last_manifest_string);
		  ok := skip1(',');
	       end;
	       if list = Void then
		  wcp("Empty debug key list (deleted).");
	       end;
	       if not skip1(')') then
		  fcp("%")%" expected to end debug string list.");
	       end;
	    end;
	    Result := true;
	    !!e_debug.make(sp,list,a_compound2("debug",fz_end));
	    last_instruction := e_debug;
	    end;
	 end;

   a_expression: BOOLEAN is
	 --++ expression -> "<<" {Expression "," ...} ">>" |
	 --++               Void |
	 --++               e0
	 --++
      local
	 sp: POSITION;
	 list: ARRAY[EXPRESSION];
      do
	 if skip2('<','<') then
	    from
	       Result := true;
	       sp := pos(start_line,start_column);
	    until
	       not a_expression
	    loop
	       if list = Void then
		  !!list.with_capacity(4,1);
	       end;
	       list.add_last(last_expression);
	       ok := skip1(',');
	    end;
	    if not skip2('>','>') then
	       fcp("End of manifest array expected.");
	    end;
	    !MANIFEST_ARRAY!last_expression.make(sp,list);
	 else
	    Result := a_e0;
	 end;
      end;

   a_e0: BOOLEAN is
	 --++ e0 -> e1 r1
	 --++
      do
	 Result := a_e1;
	 if Result then
	    a_r1(last_expression);
	 end;
      end;

   a_e1: BOOLEAN is
	 --++ e1 -> e2 r2
	 --++
      do
	 Result := a_e2;
	 if Result then
	    a_r2(last_expression);
	 end;
      end;

   a_e2: BOOLEAN is
	 --++ e2 -> e3 r3
	 --++
      do
	 Result := a_e3;
	 if Result then
	    a_r3(last_expression);
	 end;
      end;

   a_e3: BOOLEAN is
	 --++ e3 -> e4 r4
	 --++
      do
	 Result := a_e4;
	 if Result then
	    a_r4(last_expression);
	 end;
      end;

   a_e4: BOOLEAN is
	 --++ e4 -> e5 r5
	 --++
      do
	 Result := a_e5;
	 if Result then
	    a_r5(last_expression);
	 end;
      end;

   a_e5: BOOLEAN is
	 --++ e5 -> e6 r6
	 --++
      do
	 Result := a_e6;
	 if Result then
	    a_r6(last_expression);
	 end;
      end;

   a_e6: BOOLEAN is
	 --++ e6 -> e7 r7
	 --++
      do
	 Result := a_e7;
	 if Result then
	    a_r7(last_expression);
	 end;
      end;

   a_e7: BOOLEAN is
	 --++ e7 -> e8 r8
	 --++
      do
	 Result := a_e8;
	 if Result then
	    a_r8(last_expression);
	 end;
      end;

   a_e8: BOOLEAN is
	 --++ e8 -> "not" e8 |
	 --++       "+" e8 |
	 --++       "-" e8 |
	 --++       free_operator e8 !
	 --++       e9
	 --++
      local
	 op: PREFIX_NAME;
	 prefix_freeop: CALL_PREFIX_FREEOP;
	 sp: POSITION;
      do
	 if a_keyword(as_not) then
	    sp := pos(start_line,start_column);
	    if a_e8 then
	       !CALL_PREFIX_NOT!last_expression.make(sp,last_expression);
	       Result := true;
	    else
	       err_exp(sp,as_not);
	    end;
	 elseif skip1('+') then
	    sp := pos(start_line,start_column);
	    if a_e8 then
	       !CALL_PREFIX_PLUS!last_expression.make(sp,last_expression);
	       Result := true;
	    else
	       err_exp(sp,"+ (prefix)");
	    end;
	 elseif skip1('-') then
	    sp := pos(start_line,start_column);
	    if a_e8 then
	       !CALL_PREFIX_MINUS!last_expression.make(sp,last_expression);
	       Result := true;
	    else
	       err_exp(sp,"- (prefix)");
	    end;
	 elseif a_free_operator then
	    op := tmp_name.to_prefix_name;
	    if a_e8 then
	       !!prefix_freeop.make(last_expression,op);
	       last_expression := prefix_freeop;
	       Result := true;
	    else
	       eh.append("Bad use of prefix operator. ");
	       err_exp(op.start_position,op.to_string);
	    end;
	 else
	    Result := a_e9;
	 end;
      end;

   a_e9: BOOLEAN is
	 --++ e9 -> e10 |
	 --++       "old" e10
	 --++
      do
	 if a_keyword(fz_old) then
	    if not in_ensure then
	       error(pos(start_line,start_column),
		     "Expression %"old%" can be used in ensure clause %
				       %only (VAOL.1).");
	    end;
	    if a_e10 then
	       !E_OLD!last_expression.make(last_expression);
	       Result := true;
	    else
	       fcp("Expression expected after %"old%".");
	    end;
	 else
	    Result := a_e10;
	 end;
      end;

   a_e10: BOOLEAN is
	 --++ e10 -> strip |
	 --++       "(" expression ")" r10 |
	 --++       manifest_constant |
	 --++       precursor_call |
	 --++       "Result" r10 |
	 --++       "Current" r10 |
	 --++       "Void" r10 |
	 --++       local_variable r10 |
	 --++       argument r10 |
	 --++       function_call r10 |
	 --++
      do
	 if a_strip then
	    Result := true;
	 elseif skip1('(') then
	    Result := true;
	    if a_expression then
	       if skip1(')') then
		  a_r10(false,last_expression,Void,Void);
	       else
		  fcp("')' expected in expression.")
	       end;
	    else
	       fcp("Expression expected.")
	    end;
	 elseif a_manifest_constant then
	    last_expression := last_manifest_constant;
	    Result := true;
	    if skip1('.') then
	       wcp("Added brackets for manifest constant before dot.");
	       a_after_a_dot(false,last_expression);
	    end;
	 elseif a_precursor(false) then
	    Result := true;
	 elseif a_identifier then
	    Result := true;
	    if a_result or else a_current or else a_void or else
	       a_local_variable or else a_argument then
	       a_r10(false,last_expression,Void,Void);
	    else
	       a_function_call;
	    end;
	 end;
      end;

   a_external: ROUTINE is
	 --++ external -> "<external-specification>" external_name
	 --++
      local
	 tag: STRING;
	 l: NATIVE;
      do
	 if not skip1('%"') then
	    fcp(em18);
	 end;
	 from
	    !!tag.make(24);
	 until
	    cc = '%"'
	 loop
	    if cc = '%%' then
	       next_char;
	    end;
	    tag.extend(cc);
	    next_char;
	 end;
	 if ("SmallEiffel").is_equal(tag) then
	    !NATIVE_SMALL_EIFFEL!l.make(tag);
	 elseif ("compiler built-in").is_equal(tag) then
	    !NATIVE_SMALL_EIFFEL!l.make(tag);
	 elseif ("C_WithCurrent").is_equal(tag) then
	    !NATIVE_WITH_CURRENT!l.make(tag);
	 elseif ("C_InlineWithCurrent").is_equal(tag) then
	    !NATIVE_INLINE_WITH_CURRENT!l.make(tag);
	 elseif ("C_WithoutCurrent").is_equal(tag) then
	    !NATIVE_WITHOUT_CURRENT!l.make(tag);
	 elseif ("C_InlineWithoutCurrent").is_equal(tag) then
	    !NATIVE_INLINE_WITHOUT_CURRENT!l.make(tag);
	 elseif ("CSE").is_equal(tag) then
	    !NATIVE_SMALL_EIFFEL!l.make(tag);
	    wcpefnc("CSE",fz_se);
	 elseif ("CWC").is_equal(tag) then
	    -- To be compatible with Visual Eiffel.
	    !NATIVE_WITH_CURRENT!l.make(tag);
	 elseif ("ICWC").is_equal(tag) then
	    !NATIVE_INLINE_WITH_CURRENT!l.make(tag);
	    wcpefnc("ICWC","C_InlineWithCurrent");
	 elseif ("IC").is_equal(tag) then
	    !NATIVE_INLINE_WITHOUT_CURRENT!l.make(tag);
	    wcpefnc("IC","C_InlineWithoutCurrent");
	 elseif ("JVM_invokestatic").is_equal(tag) then
	    !NATIVE_JVM_INVOKESTATIC!l.make(tag);
	 elseif ("JVM_invokevirtual").is_equal(tag) then
	    !NATIVE_JVM_INVOKEVIRTUAL!l.make(tag);
	 elseif tag.has_prefix("C++") then
	    !NATIVE_C_PLUS_PLUS!l.make(tag);
	 elseif tag.has_prefix("C") then
	    !NATIVE_WITHOUT_CURRENT!l.make(tag);
	 else
	    fcp("Unkown external specification.");
	 end;
	 if not skip1('%"') then
	    fcp(em18);
	 end;
	 Result := tmp_feature.to_external_routine(l,a_alias);
      end;

   a_alias: STRING is
	 --++ external_name -> ["alias" manifest_string]
	 --++
      do
	 if a_keyword(fz_alias) then
	    if not skip1('%"') then
	       fcp(em19);
	    end;
	    from
	       !!Result.make(24);
	    until
	       cc = '%"'
	    loop
	       Result.extend(cc);
	       next_char;
	    end;
	    if not skip1('%"') then
	       fcp(em19);
	    end;
	 end;
      end;

   a_feature_name_list: BOOLEAN is
	 --++ feature_name_list -> {feature_name "," ...}
	 --++
	 --
	 -- Gives true when list is not empty.
      local
	 state: INTEGER;
	 -- state 0 : nothing read.
	 -- state 1 : feature name read.
	 -- state 2 : separator read.
	 -- state 3 : end.
      do
	 from
	    last_feature_name_list := Void;
	 until
	    state >= 3
	 loop
	    inspect
	       state
	    when 0 then
	       if a_feature_name then
		  !!last_feature_name_list.make_1(last_feature_name);
		  Result := true;
		  state := 1;
	       elseif cc = ',' then
		  wcp(em7);
		  ok := skip1(',');
	       else
		  state := 3
	       end;
	    when 1 then
	       if cc = ',' then
		  ok := skip1(',');
		  state := 2;
	       elseif a_feature_name then
		  warning(last_feature_name.start_position,em5);
		  last_feature_name_list.add_last(last_feature_name);
	       else
		  state := 3;
	       end;
	    when 2 then
	       if a_feature_name then
		  last_feature_name_list.add_last(last_feature_name);
		  state := 1;
	       elseif cc = ',' then
		  wcp(em12);
		  ok := skip1(',');
	       else
		  ecp(em2);
		  state := 3;
	       end;
	    end;
	 end;
      end;

   a_feature_name: BOOLEAN is
	 --++ feature_name -> prefix |
	 --++                 infix |
	 --++                 simple_feature_name
	 --++
      do
	 if a_prefix then
	    last_feature_name := last_prefix;
	    Result := true;
	 elseif a_infix then
	    last_feature_name := last_infix;
	    Result := true;
	 elseif a_identifier then
	    last_feature_name := tmp_name.to_simple_feature_name;
	    Result := true;
	 end;
      end;

   a_feature_clause is
	 --++ feature_clause -> [clients] [comment] feature_declaration_list
	 --++
      local
	 feature_clause: FEATURE_CLAUSE;
	 clients: CLIENT_LIST;
	 comment: COMMENT;
      do
	 from
	    clients := a_clients;
	    comment := get_comments;
	    faof.clear;
	 until
	    not a_feature_declaration
	 loop
	    ok := skip1(';');
	    if last_feature_declaration /= Void then
	       faof.add_last(last_feature_declaration);
	       last_feature_declaration.set_header_comment(get_comments);
	    end;
	 end;
	 if not faof.is_empty then
	    !!feature_clause.make(clients,comment,faof.twin);
	    last_base_class.add_feature_clause(feature_clause);
	 elseif comment /= Void then
	    !!feature_clause.make(clients,comment,Void);
	    last_base_class.add_feature_clause(feature_clause);
	 end;
	 last_keyword := Void;
      end;

   a_feature_declaration: BOOLEAN is
	 --++ feature_declaration -> {["frozen"] feature_name "," ...}+
	 --++                        formal_arg_list
	 --++                        [":" type]
	 --++                        ["is" "unique" |
	 --++                         "is" manifest_constant |
	 --++                         "is" routine]
	 --++
      do
	 from
	    tmp_feature.initialize;
	    if a_keyword(fz_frozen) then
	       if a_feature_name then
		  Result := true;
		  to_frozen_feature_name;
		  tmp_feature.add_synonym(last_feature_name);
	       else
		  fcp(em2);
	       end;
	    elseif a_feature_name then
	       Result := true;
	       tmp_feature.add_synonym(last_feature_name);
	    end;
	 until
	    not skip1(',')
	 loop
	    if a_keyword(fz_frozen) then
	       if a_feature_name then
		  to_frozen_feature_name;
		  tmp_feature.add_synonym(last_feature_name);
	       else
		  fcp("Frozen feature name synonym expected.");
	       end;
	    elseif a_feature_name then
	       tmp_feature.add_synonym(last_feature_name);
	    else
	       ecp("Synonym feature name expected.");
	    end;
	 end;
	 if Result then
	    a_formal_arg_list;
	    if skip1(':') then
	       if a_type then
		  inside_function := true;
		  tmp_feature.set_type(last_type);
	       else
		  fcp(em16);
	       end;
	    else
	       inside_function := false;
	    end;
	    if a_keyword(fz_is) then
	       if a_keyword(fz_unique) then
		  last_feature_declaration := tmp_feature.to_cst_att_unique;
	       elseif a_boolean_constant then
		  last_feature_declaration :=
		     tmp_feature.to_cst_att_boolean(last_boolean_constant);
	       elseif a_character_constant then
		  last_feature_declaration :=
		     tmp_feature.to_cst_att_character(last_character_constant);
	       elseif a_manifest_string then
		  last_feature_declaration :=
		     tmp_feature.to_cst_att_string(last_manifest_string);
	       elseif a_bit_constant then
		  last_feature_declaration :=
		     tmp_feature.to_cst_att_bit(last_bit_constant);
	       elseif a_real_constant then
		  last_feature_declaration :=
		     tmp_feature.to_cst_att_real(last_real_constant);
	       elseif a_integer_constant then
		  last_feature_declaration :=
		     tmp_feature.to_cst_att_integer(last_integer_constant);
	       else
		  last_feature_declaration := a_routine;
	       end;
	    else
	       last_feature_declaration := tmp_feature.to_writable_attribute;
	    end;
	    inside_function := false;
	    inside_once_function := false;
	    arguments := Void;
	 end;
      end;

   a_formal_generic_list is
	 --++ formal_generic_list -> ["[" {formal_generic "," ...} "]"]
	 --++ formal_generic -> base_class_name ["->" class_type]
	 --++
      local
	 l, c: INTEGER;
	 name: CLASS_NAME;
	 constraint: TYPE;
	 fga: FORMAL_GENERIC_ARG;
	 list: ARRAY[FORMAL_GENERIC_ARG];
	 state: INTEGER;
	 -- state 0 : waiting for "[".
	 -- state 1 : waiting for a base class `name'.
	 -- state 2 : waiting for "->" or "," or "]".
	 -- state 3 : waiting for "," or "]".
	 -- state 4 : waiting for a `constraint' type.
	 -- state 5 : end.
	 -- state 6 : error.
      do
	 from
	    formal_generic_list := Void;
	 until
	    state > 4
	 loop
	    inspect
	       state
	    when 0 then
	       if skip1('%(') then
		  l := start_line;
		  c := start_column;
		  state := 1;
	       else
		  state := 5;
	       end;
	    when 1 then
	       if a_base_class_name then
		  name := last_class_name;
		  state := 2;
	       else
		  state := 6;
	       end;
	    when 2 then
	       if skip2('-','>') then
		  state := 4;
	       elseif cc = ',' or else cc = ']' then
		  !!fga.make(name,constraint);
		  name := Void;
		  constraint := Void;
		  if list = Void then
		     !!list.with_capacity(2,1);
		  end;
		  list.add_last(fga);
		  fga := Void;
		  if skip1(',') then
		     state := 1;
		  else
		     ok := skip1('%)');
		     state := 5;
		  end;
	       else
		  state := 6;
	       end;
	    when 3 then
	       if cc = ',' or else cc = ']' then
		  !!fga.make(name,constraint);
		  name := Void;
		  constraint := Void;
		  if list = Void then
		     !!list.with_capacity(2,1);
		  end;
		  list.add_last(fga);
		  fga := Void;
		  if skip1(',') then
		     state := 1;
		  else
		     ok := skip1('%)');
		     state := 5;
		  end;
	       else
		  state := 6;
	       end;
	    else -- state = 4
	       if a_class_type then
		  constraint := last_class_type;
		  state := 3;
	       else
		  fcp("Constraint Class name expected.");
		  state := 6;
	       end;
	    end;
	 end;
	 if state = 6 then
	    check
	       nb_errors > 0;
	    end;
	 elseif l > 0 and then list = Void then
	    warning(pos(l,c),"Empty formal generic list (deleted).");
	 elseif l > 0 then
	    check
	       not list.is_empty;
	    end;
	    !!formal_generic_list.make(pos(l,c),list);
	    last_base_class.set_formal_generic_list(formal_generic_list);
	 end;
      end;

   a_function_call is
	 --++ function_call -> [actuals] r10 |
	 --++                   ^
	 --++
      local
	 sfn: SIMPLE_FEATURE_NAME;
	 implicit_current: IMPLICIT_CURRENT;
      do
	 sfn := tmp_name.to_simple_feature_name;
	 !!implicit_current.make(sfn.start_position);
	 a_r10(false,implicit_current,sfn,a_actuals);
      end;

   a_index_clause: BOOLEAN is
	 --++ index_clause -> [identifier ":"] {index_value "," ...}+
	 --++
      local
	 index_clause: INDEX_CLAUSE;
      do
	 if a_identifier then
	    Result := true;
	    if skip1(':') then
	       !!index_clause.with_tag(tmp_name.aliased_string);
	       if a_index_value then
		  index_clause.add_last(last_index_value);
	       else
		  fcp(em3);
	       end;
	    else
	       !!index_clause.without_tag(tmp_name.to_simple_feature_name);
	    end;
	 elseif a_manifest_constant then
	    Result := true;
	    !!index_clause.without_tag(last_manifest_constant);
	 end;
	 if Result then
	    from
	    until
	       not skip1(',')
	    loop
	       if a_index_value then
		  index_clause.add_last(last_index_value);
	       else
		  fcp(em3);
	       end;
	    end;
	    last_base_class.add_index_clause(index_clause);
	 end;
      end;

   a_index_value: BOOLEAN is
	 --++ index_value -> identifier | manifest_constant
	 --++
      do
	 if a_identifier then
	    last_index_value := tmp_name.to_simple_feature_name;
	    Result := true;
	 elseif a_manifest_constant then
	    last_index_value := last_manifest_constant;
	    Result := true;
	 end;
      end;

   a_indexing is
	 --++ indexing -> "indexing" {index_clause ";" ...}
	 --++
      do
	 if a_keyword(fz_indexing) then
	    from
	    until
	       not a_index_clause
	    loop
	       ok := skip1(';');
	    end;
	 end;
      end;

   a_infix: BOOLEAN is
	 --++ infix -> "infix" "%"" binary "%""
	 --++          "infix" "%"" free_operator "%""
	 --++
      local
	 sp: POSITION;
      do
	 if a_keyword(fz_infix) then
	    Result := true;
	    sp := pos(start_line,start_column);
	    if cc = '%"' then
	       next_char;
	    else
	       wcp("Character '%%%"' inserted after %"infix%".");
	    end;
	    if a_binary(sp) then
	       last_infix := last_binary;
	    elseif a_free_operator then
	       last_infix := tmp_name.to_infix_name(sp);
	    else
	       fcp("Infix operator name expected.");
	    end;
	    if not skip1('%"') then
	       wcp("Character '%%%"' inserted.");
	    end;
	 end;
      end;

   a_inspect: BOOLEAN is
	 --++ inspect -> "inspect" expression
	 --++            {when_part ...}
	 --++            ["else" compound]
	 --++            "end"
	 --++
      local
	 sp, spec: POSITION;
	 i: E_INSPECT;
	 ec: COMPOUND;
      do
	 if a_keyword(fz_inspect) then
	    Result := true;
	    sp := pos(start_line,start_column);
	    if a_expression then
	       last_expression := last_expression.add_comment(get_comments);
	    else
	       fcp("Expression expected (%"inspect ... %").");
	    end;
	    from
	       !!i.make(sp,last_expression);
	    until
	       not a_when_part(i)
	    loop
	    end;
	    if a_keyword(fz_else) then
	       spec := pos(start_line,start_column);
	       ec := a_compound2("else of inspect",fz_end);
	       i.set_else_compound(spec,ec);
	    elseif not a_keyword(fz_end) then
	       wcp("Added %"end%" for inspect instruction.");
	    end;
	    last_instruction := i;
	 end;
      end;

   a_instruction: BOOLEAN is
	 --++ instruction -> check | debug | conditionnal | retry |
	 --++                inspect | loop | creation | assignment_or_call
	 --++
      do
	 Result := true;
	 if a_check then
	 elseif a_debug then
	 elseif a_conditional then
	 elseif a_retry then
	 elseif a_inspect then
	 elseif a_loop then
	 elseif a_create_instruction then
	 elseif a_assignment_or_call then
	 elseif a_creation then
	 else
	    Result := false;
	 end;
      end;

   a_integer_constant: BOOLEAN is
	 --++ integer_constant -> ["+" | "-"] integer
	 --++
      do
	 if skip1('+') then
	    if a_integer then
	       Result := true;
	    else
	       fcp(fz_iinaiv);
	    end;
	 elseif skip1('-') then
	    if a_integer then
	       last_integer_constant.unary_minus;
	       Result := true;
	    else
	       fcp(fz_iinaiv);
	    end;
	 else
	    Result := a_integer;
	 end;
      end;

   a_loop: BOOLEAN is
	 --++ loop -> "from" compound
	 --++         ["invariant"] assertion
	 --++         ["variant" [identifier ":"] expression]
	 --++         "until" expression
	 --++         "loop" compound
	 --++         "end"
	 --++
      local
	 l1, c1, l2, c2: INTEGER;
	 e_loop: E_LOOP;
	 i: COMPOUND;
	 ic: LOOP_INVARIANT;
	 vc: LOOP_VARIANT;
	 ue: EXPRESSION;
	 lb: COMPOUND;
	 hc: COMMENT;
	 al: ARRAY[ASSERTION];
      do
	 if a_keyword(fz_from) then
	    Result := true;
	    l1 := start_line;
	    c1 := start_column;
	    i := a_compound1;
	    if a_keyword(fz_invariant) then
	       l2 := start_line;
	       c2 := start_column;
	       hc := get_comments;
	       al := a_assertion;
	       if hc /= Void or else al /= Void then
		  !!ic.make(pos(l2,c2),hc,al);
	       end;
	    end;
	    if a_keyword(fz_variant) then
	       if a_tag_mark and then a_expression then
		  !LOOP_VARIANT_2!vc.make(last_tag_mark,last_expression,
					  get_comments);
	       elseif a_expression then
		  !LOOP_VARIANT_1!vc.make(last_expression,get_comments);
	       else
		  wcp("Variant (INTEGER) Expression Expected.");
	       end;
	    end;
	    if a_keyword(fz_until) then
	       if a_expression then
		  ue := last_expression.add_comment(get_comments);
	       else
		  fcp("Boolean expression expected (until).");
		  ue := last_expression;
	       end;
	    else
	       fcp("Keyword %"until%" expected (in a loop).");
	       ue := last_expression;
	    end;
	    if cc = ';' then
	       wcp(fz_desc);
	       ok := skip1(';');
	    end;
	    if not a_keyword(fz_loop) then
	       wcp("Keyword %"loop%" expected (in a loop).");
	    end;
	    lb := a_compound2("loop body",fz_end);
	    !!e_loop.make(pos(l1,c1),i,ic,vc,ue,lb);
	    last_instruction := e_loop;
	 end;
      end;

   a_manifest_constant: BOOLEAN is
	 --++ manifest_constant -> boolean_constant | character_constant |
	 --++                      real_constant | integer_constant |
	 --++                      manifest_string | bit_constant
	 --++
      do
	 if a_boolean_constant then
	    last_manifest_constant := last_boolean_constant;
	    Result := true;
	 elseif a_character_constant then
	    last_manifest_constant := last_character_constant;
	    Result := true;
	 elseif a_manifest_string then
	    last_manifest_constant := last_manifest_string;
	    Result := true;
	 elseif a_bit_constant then
	    last_manifest_constant := last_bit_constant;
	    Result := true;
	 elseif a_real_constant then
	    last_manifest_constant := last_real_constant;
	    Result := true;
	 elseif a_integer_constant then
	    last_manifest_constant := last_integer_constant;
	    Result := true;
	 end;
      end;

   a_new_export_list is
	 --++ new_export_list -> ["export" {new_export_item ";" ...}]
	 --++ new_export_item -> clients "all" |
	 --++                    clients feature_list
	 --++
      local
	 export_list: EXPORT_LIST;
	 sp: POSITION;
	 clients: CLIENT_LIST;
	 items: ARRAY[EXPORT_ITEM];
	 new_export_item: EXPORT_ITEM;
	 state: INTEGER;
	 -- state 0 : waiting for a `clients'.
	 -- state 1 : `clients' read.
	 -- state 2 : waiting ";" before next one.
	 -- state 3 : error.
	 -- state 4 : end.
	 --
      do
	 if a_keyword(fz_export) then
	    from
	       sp := pos(start_line,start_column);
	    until
	       state > 3
	    loop
	       inspect
		  state
	       when 0 then
		  if cc = '{' then
		     clients := a_clients;
		     state := 1;
		  elseif cc = ';' then
		     wcp(fz_desc);
		     ok := skip1(';');
		  else
		     if items /= Void then
			!!export_list.make(sp,items);
			last_parent.set_export(export_list);
		     end;
		     state := 4;
		  end;
	       when 1 then
		  if a_keyword(fz_all) then
		     !!new_export_item.make_all(clients);
		     if items = Void then
			!!items.with_capacity(2,1);
		     end;
		     items.add_last(new_export_item);
		     state := 2;
		  else
		     if a_feature_name_list then
			!!new_export_item.make(clients,last_feature_name_list);
			if items = Void then
			   !!items.with_capacity(2,1);
			end;
			items.add_last(new_export_item);
			state := 2;
		     else
			state := 3;
		     end;
		  end;
	       when 2 then
		  if skip1(';') then
		     state := 0;
		  elseif cc = '{' then
		     wcp(em6);
		     state := 0;
		  else
		     if items /= Void then
			!!export_list.make(sp,items);
			last_parent.set_export(export_list);
		     end;
		     state := 4;
		  end;
	       else -- state = 3
		  fcp(em11);
		  state := 4;
	       end;
	    end;
	 end;
      end;

   a_parent_list(sp: POSITION; hc: COMMENT) is
	 --++ parent_list -> {parent ";" ...}
	 --++
      local
	 list: ARRAY[PARENT];
      do
	 from
	 until
	    not a_parent
	 loop
	    if list = Void then
	       !!list.with_capacity(4,1);
	    end;
	    list.add_last(last_parent);
	    ok := skip1(';');
	    last_parent.set_comment(get_comments);
	 end;
	 if hc /= Void or else list /= Void then
	    if list = Void then
	       if last_base_class.heading_comment2 = Void then
		  last_base_class.set_heading_comment2(hc);
	       else
		  last_base_class.heading_comment2.append(hc);
	       end;
	    else
	       last_base_class.set_parent_list(sp,hc,list);
	    end;
	 end;
      end;

   a_parent: BOOLEAN is
	 --++ parent -> class_type
	 --++           ["rename" rename_list]
	 --++           new_export_list
	 --++           ["undefine" feature_name_list]
	 --++           ["redefine" feature_name_list]
	 --++           ["select" feature_name_list]
	 --++           ["end"]
	 --++
      do
	 if a_class_type then
	    Result := true;
	    !!last_parent.make(last_class_type);
	    if a_keyword(fz_rename) then
	       a_rename_list;
	       if cc = ';' then
		  wcp("Unexpected %";%" to end rename list.");
		  ok := skip1(';');
	       end;
	    end;
	    a_new_export_list;
	    if a_keyword(fz_undefine) then
	       if a_feature_name_list then
		  last_parent.set_undefine(last_feature_name_list)
	       end;
	    end;
	    if a_keyword(fz_redefine) then
	       if a_feature_name_list then
		  last_parent.set_redefine(last_feature_name_list)
	       end;
	    end;
	    if a_keyword(fz_select) then
	       if a_feature_name_list then
		  last_parent.set_select(last_feature_name_list);
	       end;
	    end;
	    if a_keyword(fz_rename) or else
	       a_keyword(fz_export) or else
	       a_keyword(fz_undefine) or else
	       a_keyword(fz_redefine) or else
	       a_keyword(fz_select) then
	       eh.add_position(pos(start_line,start_column));
	       fatal_error("Inheritance option not at a good place. %
			   %The good order is: %"rename... export... %
						%undefine... redefine... select...%".");
						end;
						ok := a_keyword(fz_end);
					     end;
					  end;

					  a_prefix: BOOLEAN is
	 --++ prefix -> "prefix" "%"" unary "%""
	 --++           "prefix" "%"" free_operator "%""
	 --++
      do
	 if a_keyword(fz_prefix) then
	    Result := true;
	    if cc = '%"' then
	       next_char;
	    else
	       wcp("Character '%%%"' inserted after %"prefix%".");
	    end;
	    if a_unary then
	    elseif a_free_operator then
	       last_prefix := tmp_name.to_prefix_name;
	    else
	       fcp("Prefix operator name expected.");
	    end;
	    if not skip1('%"') then
	       wcp("Character '%%%"' inserted.");
	    end;
	 end;
      end;

   a_precursor(do_instruction: BOOLEAN): BOOLEAN is
	 --++ precursor -> ["{" class_name "}"] "Precursor" [actuals] |
	 --++              ^
	 --++
      local
	 l, c: INTEGER;
	 parent: CLASS_NAME;
	 args: EFFECTIVE_ARG_LIST;
      do
	 if skip1('{') then
	    Result := true;
	    l := start_line;
	    c := start_column;
	    if skip1('{') then
	       warning(pos(start_line,start_column),
		       "One single opening '{' is correct too here.");
	    end;
	    if a_base_class_name then
	       parent := last_class_name;
	    end;
	    if not skip1('}')  then
	       fcp("Closing '}' expected to end Precursor's parent qualification.");
	    end;
	    if skip1('}') then
	       warning(pos(start_line,start_column),
		       "One single closing '}' is correct too here.");
	    end;
	 end;
	 if a_keyword(as_precursor) then
	    Result := true;
	    if l = 0 then
	       l := start_line;
	       c := start_column;
	    end;
	    args := a_actuals;
	 elseif l > 0 then
	    fcp("Precursor keyword expected here.");
	 end;
	 if Result then
	    if skip1('.') then
	       !E_PRECURSOR_FUNCTION!last_expression.make(pos(l,c),parent,args);
	       a_after_a_dot(do_instruction,last_expression);
	    elseif do_instruction then
	       !E_PRECURSOR_PROCEDURE!last_instruction.make(pos(l,c),parent,args);
	    else
	       !E_PRECURSOR_FUNCTION!last_expression.make(pos(l,c),parent,args);
	    end;
	 end;
      end;

   a_procedure_call is
	 --++ procedure_call -> [actuals] r10 |
	 --++                   ^
	 --++
      local
	 sfn: SIMPLE_FEATURE_NAME;
	 implicit_current: IMPLICIT_CURRENT;
      do
	 sfn := tmp_name.to_simple_feature_name;
	 !!implicit_current.make(sfn.start_position);
	 a_r10(true,implicit_current,sfn,a_actuals);
      end;

   a_real_constant: BOOLEAN is
	 --++ real_constant -> ["+" | "-"] real
	 --++
      local
	 l, c: INTEGER;
      do
	 l := line;
	 c := column;
	 if skip1('+') then
	    if a_real then
	       Result := true;
	    else
	       go_back_at(l,c);
	    end;
	 elseif skip1('-') then
	    if a_real then
	       last_real_constant.unary_minus;
	       Result := true;
	    else
	       go_back_at(l,c);
	    end;
	 elseif a_real then
	    Result := true;
	 end;
      end;

   a_rename_list is
	 --++ rename_list -> {rename_pair "," ...}
	 --++
      do
	 from
	 until
	    not a_rename_pair
	 loop
	    ok := skip1(',');
	 end;
      end;

   a_rename_pair: BOOLEAN is
	 --++ rename_pair -> identifier "as" identifier
	 --++
      local
	 name1: FEATURE_NAME;
	 rename_pair: RENAME_PAIR;
	 l, c: INTEGER;
      do
	 l := line;
	 c := column;
	 if a_feature_name then
	    name1 := last_feature_name;
	    if a_keyword(fz_as) then
	       if a_feature_name then
		  Result := true;
		  !!rename_pair.make(name1,last_feature_name);
		  last_parent.add_rename(rename_pair);
	       else
		  fcp("Second identifier of a %"rename%" pair expected.");
	       end;
	    else
	       go_back_at(l,c);
	    end;
	 end;
      end;

   a_routine: ROUTINE is
	 --++ routine -> ["obsolete" manifest_string]
	 --++            ["require" ["else"] assertion]
	 --++            ["local" entity_declaration_list]
	 --++            routine_body
	 --++            ["ensure" ["then"] assertion]
	 --++            ["rescue" compound]
	 --++            "end"
	 --++
      local
	 sp: POSITION;
	 hc: COMMENT;
	 al: ARRAY[ASSERTION];
	 ea: E_ENSURE;

      do
	 if a_keyword(fz_obsolete) then
	    if a_manifest_string then
	       tmp_feature.set_obsolete_mark(last_manifest_string);
	    else
	       fcp("Obsolete manifest string expected.");
	    end;
	 end;
	 tmp_feature.set_header_comment(get_comments);
	 if a_keyword(fz_require) then
	    sp := pos(start_line,start_column);
	    if a_keyword(fz_else) then
	       hc := get_comments;
	       tmp_feature.set_require_else(sp,hc,a_assertion);
	    else
	       hc := get_comments;
	       tmp_feature.set_require(sp,hc,a_assertion);
	    end;
	 end;
	 if a_keyword(fz_local) then
	    a_local_var_list;
	 end;
	 Result := a_routine_body;
	 if a_keyword(fz_ensure) then
	    sp := pos(start_line,start_column);
	    in_ensure := true;
	    if a_keyword(fz_then) then
	       hc := get_comments;
	       al := a_assertion;
	       if hc /= Void or else al /= Void then
		  !!ea.make(sp,hc,al);
		  ea.set_ensure_then;
	       end;
	       Result.set_ensure_assertion(ea);
	    else
	       hc := get_comments;
	       al := a_assertion;
	       if hc /= Void or else al /= Void then
		  !!ea.make(sp,hc,al);
	       end;
	       Result.set_ensure_assertion(ea);
	    end;
	    in_ensure := false;
	 end;
	 if a_keyword(fz_rescue) then
	    in_rescue := true;
	    Result.set_rescue_compound(a_compound2(fz_rescue,fz_end));
	    in_rescue := false;
	 elseif not a_keyword(fz_end) then
	    wcp("A routine must be ended with %"end%".");
	 end;
	 local_vars := Void;
      end;

   a_routine_body: ROUTINE is
	 --++ routine_body -> "deferred" |
	 --++                 "external" external |
	 --++                 "do" compound |
	 --++                 "once" compound
	 --++
      do
	 if a_keyword(fz_deferred) then
	    last_base_class.set_is_deferred;
	    Result := tmp_feature.to_deferred_routine;
	 elseif a_keyword(fz_external) then
	    Result := a_external;
	 elseif a_keyword(fz_do) then
	    tmp_feature.set_routine_body(a_compound1);
	    Result := tmp_feature.to_procedure_or_function;
	 elseif a_keyword(fz_once) then
	    inside_once_function := true;
	    tmp_feature.set_routine_body(a_compound1);
	    Result := tmp_feature.to_once_routine;
	 else
	    fcp("Routine body expected.");
	 end;
      end;

   a_r1(left_part: like last_expression) is
	 --++ r1 -> "implies" e1 r1 |
	 --++       ^
	 --++
      local
	 infix_implies: CALL_INFIX_IMPLIES;
	 sp: POSITION;
      do
	 if a_keyword(as_implies) then
	    sp := pos(start_line,start_column);
	    if a_e1 then
	       !!infix_implies.make(left_part,sp,last_expression);
	       a_r1(infix_implies);
	    else
	       error(sp,"Expression expected after 'implies'.");
	    end;
	 else
	    last_expression := left_part;
	 end;
      end;

   a_r2(left_part: like last_expression) is
	 --++ r2 -> "or else" e2 r2 |
	 --++       "or" e2 r2 |
	 --++       "xor" e2 r2 |
	 --++       ^
	 --++
      local
	 infix_or_else: CALL_INFIX_OR_ELSE;
	 infix_or: CALL_INFIX_OR;
	 infix_xor: CALL_INFIX_XOR;
	 sp: POSITION;
      do
	 if a_keyword(as_or) then
	    sp := pos(start_line,start_column);
	    if a_keyword(fz_else) then
	       if a_e2 then
		  !!infix_or_else.make(left_part,sp,last_expression);
		  a_r2(infix_or_else);
	       else
		  err_exp(sp,as_or_else);
	       end;
	    else
	       if a_e2 then
		  !!infix_or.make(left_part,sp,last_expression);
		  a_r2(infix_or);
	       else
		  err_exp(sp,as_or);
	       end;
	    end;
	 elseif a_keyword(as_xor) then
	    sp := pos(start_line,start_column);
	    if a_e2 then
	       !!infix_xor.make(left_part,sp,last_expression);
	       a_r2(infix_xor);
	    else
	       err_exp(sp,as_xor);
	    end;
	 else
	    last_expression := left_part;
	 end;
      end;

   a_r3(left_part: like last_expression) is
	 --++ r3 -> "and then" e3 r3 |
	 --++       "and" e3 r3 |
	 --++       ^
	 --++
      local
	 infix_and_then: CALL_INFIX_AND_THEN;
	 infix_and: CALL_INFIX_AND;
	 sp: POSITION;
      do
	 if a_keyword(as_and) then
	    sp := pos(start_line,start_column);
	    if a_keyword(fz_then) then
	       if a_e3 then
		  !!infix_and_then.make(left_part,sp,last_expression);
		  a_r3(infix_and_then);
	       else
		  err_exp(sp,as_and_then);
	       end;
	    else
	       if a_e3 then
		  !!infix_and.make(left_part,sp,last_expression);
		  a_r3(infix_and);
	       else
		  err_exp(sp,as_and);
	       end;
	    end;
	 else
	    last_expression := left_part;
	 end;
      end;

   a_r4(left_part: like last_expression) is
	 --++ r4 -> "=" e4 r4 |
	 --++       "/=" e4 r4 |
	 --++       "<=" e4 r4 |
	 --++       "<" e4 r4 |
	 --++       ">=" e4 r4 |
	 --++       ">" e4 r4 |
	 --++       ^
	 --++
      local
	 call_infix: CALL_INFIX;
	 sp: POSITION;
      do
	 if skip1('=') then
	    sp := pos(start_line,start_column);
	    if a_e4 then
	       !CALL_INFIX_EQ!call_infix.make(left_part,sp,last_expression);
	       a_r4(call_infix);
	    else
	       err_exp(sp,as_eq);
	    end;
	 elseif skip2('/','=') then
	    sp := pos(start_line,start_column);
	    if a_e4 then
	       !CALL_INFIX_NEQ!call_infix.make(left_part,sp,last_expression);
	       a_r4(call_infix);
	    else
	       err_exp(sp,as_neq);
	    end;
	 elseif skip2('<','=') then
	    sp := pos(start_line,start_column);
	    if a_e4 then
	       !CALL_INFIX_LE!call_infix.make(left_part,sp,last_expression);
	       a_r4(call_infix);
	    else
	       err_exp(sp,as_le);
	    end;
	 elseif skip2('>','=') then
	    sp := pos(start_line,start_column);
	    if a_e4 then
	       !CALL_INFIX_GE!call_infix.make(left_part,sp,last_expression);
	       a_r4(call_infix);
	    else
	       err_exp(sp,as_ge);
	    end;
	 elseif skip1('<') then
	    sp := pos(start_line,start_column);
	    if a_e4 then
	       !CALL_INFIX_LT!call_infix.make(left_part,sp,last_expression);
	       a_r4(call_infix);
	    else
	       err_exp(sp,as_lt);
	    end;
	 elseif skip1unless2('>','>') then
	    sp := pos(start_line,start_column);
	    if a_e4 then
	       !CALL_INFIX_GT!call_infix.make(left_part,sp,last_expression);
	       a_r4(call_infix);
	    else
	       err_exp(sp,as_gt);
	    end;
	 else
	    last_expression := left_part;
	 end;
      end;

   a_r5(left_part: like last_expression) is
	 --++ r5 -> "+" e5 r5 |
	 --++       "-" e5 r5 |
	 --++       ^
	 --++
      local
	 infix_plus: CALL_INFIX_PLUS;
	 infix_minus: CALL_INFIX_MINUS;
	 sp: POSITION;
      do
	 if skip1('+') then
	    sp := pos(start_line,start_column);
	    if a_e5 then
	       !!infix_plus.make(left_part,sp,last_expression);
	       a_r5(infix_plus);
	    else
	       err_exp(sp,as_plus);
	    end;
	 elseif skip1('-') then
	    sp := pos(start_line,start_column);
	    if a_e5 then
	       !!infix_minus.make(left_part,sp,last_expression);
	       a_r5(infix_minus);
	    else
	       err_exp(sp,as_minus);
	    end;
	 else
	    last_expression := left_part;
	 end;
      end;

   a_r6(left_part: like last_expression) is
	 --++ r6 -> "*" e6 r6 |
	 --++       "//" e6 r6 |
	 --++       "\\" e6 r6 |
	 --++       "/" e6 r6 |
	 --++       ^
	 --++
      local
	 infix_times: CALL_INFIX_TIMES;
	 infix_int_div: CALL_INFIX_INT_DIV;
	 infix_int_rem: CALL_INFIX_INT_REM;
	 infix_div: CALL_INFIX_DIV;
	 sp: POSITION;
      do
	 if skip1('*') then
	    sp := pos(start_line,start_column);
	    if a_e6 then
	       !!infix_times.make(left_part,sp,last_expression);
	       a_r6(infix_times);
	    else
	       err_exp(sp,as_muls);
	    end;
	 elseif skip2('/','/') then
	    sp := pos(start_line,start_column);
	    if a_e6 then
	       !!infix_int_div.make(left_part,sp,last_expression);
	       a_r6(infix_int_div);
	    else
	       err_exp(sp,as_slash_slash);
	    end;
	 elseif skip2('\','\') then
	    sp := pos(start_line,start_column);
	    if a_e6 then
	       !!infix_int_rem.make(left_part,sp,last_expression);
	       a_r6(infix_int_rem);
	    else
	       err_exp(sp,as_backslash_backslash);
	    end;
	 elseif skip1unless2('/','=') then
	    sp := pos(start_line,start_column);
	    if a_e6 then
	       !!infix_div.make(left_part,sp,last_expression);
	       a_r6(infix_div);
	    else
	       err_exp(sp,as_slash);
	    end;
	 else
	    last_expression := left_part;
	 end;
      end;

   a_r7(left_part: like last_expression) is
	 --++ r7 -> "^" e7 r7 |
	 --++       ^
	 --++
      local
         sp: POSITION;
      do
         if skip1('^') then
            sp := pos(start_line,start_column);
            if a_e7 then
               a_r7(last_expression);
               !CALL_INFIX_POWER!last_expression.make(left_part,sp,last_expression);
            else
               err_exp(sp,as_pow);
            end;
         else
            last_expression := left_part;
         end;
      end;

   a_r8(left_part: like last_expression) is
	 --++ r8 -> free_operator e8 r8 |
	 --++       ^
	 --++
      local
	 infix_name: INFIX_NAME;
	 infix_freeop: CALL_INFIX_FREEOP;
      do
	 if a_free_operator then
	    infix_name := tmp_name.to_infix_name_use;
	    if a_e8 then
	       !!infix_freeop.make(left_part,infix_name,last_expression);
	       a_r8(infix_freeop);
	    else
	       err_exp(infix_name.start_position,infix_name.to_string);
	    end;
	 else
	    last_expression := left_part;
	 end;
      end;

   a_r10(do_instruction: BOOLEAN; t: EXPRESSION; fn: FEATURE_NAME;
	 eal: EFFECTIVE_ARG_LIST) is
	 --++ r10 -> "." after_a_dot |
	 --++        ^
	 --++
      do
	 if skip1('.') then
	    if t /= Void and then t.is_void then
	       eh.add_position(t.start_position);
	       fatal_error("Void is not a valid target.");
	    end;
	    a_after_a_dot(do_instruction,to_call(t,fn,eal));
	 else
	    if do_instruction then
	       last_instruction := to_proc_call(t,fn,eal);
	       last_expression := Void;
	    else
	       last_expression := to_call(t,fn,eal);
	       last_instruction := Void;
	    end;
	 end;
      end;

   a_strip: BOOLEAN is
	 --++ a_strip -> "strip" "(" {identifier "," ...} ")"
      local
	 sp: POSITION;
      do
	 if a_keyword(fz_strip) then
	    sp := pos(start_line,start_column);
	    if skip1('(') then
	       ok := a_feature_name_list;
	       !E_STRIP!last_expression.make(sp,last_feature_name_list);
	       if not skip1(')') then
		  fcp("')' expected to end a strip expression.");
	       end;
	       Result := true;
	    else
	       fcp("'(' expected to begin a strip list.");
	    end;
	 end;
      end;

   a_tag_mark: BOOLEAN is
	 --++ tag_mark -> identifier ":"
	 --++
      local
	 l, c: INTEGER;
      do
	 l := line;
	 c := column;
	 if a_identifier then
	    if skip1(':') then
	       Result := true;
	       last_tag_mark := tmp_name.to_tag_name;
	    else
	       go_back_at(l,c);
	    end;
	 end;
      end;

   a_then_part_list(ifthenelse: IFTHENELSE) is
	 --++ then_part_list -> {then_part "elseif"}+
	 --++
      do
	 from
	    if not a_then_part(ifthenelse) then
	       fcp("In %"if ... then ...%".");
	    end;
	 until
	    not a_keyword(fz_elseif)
	 loop
	    if not a_then_part(ifthenelse) then
	       fcp("In %"elseif ... then ...%".");
	    end;
	 end;
      end;

   a_then_part(ifthenelse: IFTHENELSE): BOOLEAN is
	 --++ then_part -> expression "then"
	 --++
      local
	 expression: EXPRESSION;
      do
	 if a_expression then
	    Result := true;
	    expression := last_expression.add_comment(get_comments);
	    if not a_keyword(fz_then) then
	       wcp("Added %"then%".");
	    end;
	    ifthenelse.add_if_then(expression,a_compound1);
	 end;
      end;

   a_type: BOOLEAN is
	 --++ type -> "like" <anchor> | "expanded" class_type | BIT <constant>
	 --++         type_formal_generic | class_type
	 --++
      local
	 sp: POSITION;
	 argument_name2: ARGUMENT_NAME2;
      do
	 Result := true;
	 if a_keyword(fz_like) then
	    sp := pos(start_line,start_column);
	    if a_infix then
	       !TYPE_LIKE_FEATURE!last_type.make(sp,last_infix);
	    elseif a_prefix then
	       !TYPE_LIKE_FEATURE!last_type.make(sp,last_prefix);
	    elseif a_identifier then
	       if a_current then
		  !TYPE_LIKE_CURRENT!last_type.make(sp);
	       elseif a_argument then
		  argument_name2 ?= last_expression;
		  !TYPE_LIKE_ARGUMENT!last_type.make(sp,argument_name2);
	       else
		  !TYPE_LIKE_FEATURE!last_type.make(sp,
						    tmp_name.to_simple_feature_name);
	       end;
	    else
	       fcp("Anchor expected. An anchor could be `Current', %
		   %a feature name or an argument name.");
	    end;
	 elseif a_keyword(fz_expanded) then
	    sp := pos(start_line,start_column);
	    if a_class_type then
	       !TYPE_EXPANDED!last_type.make(sp,last_class_type);
	    else
	       fcp("Must find a class type after %"expanded%".");
	    end;
	 elseif a_keyword(as_bit) then
	    sp := pos(start_line,start_column);
	    if a_integer then
	       !TYPE_BIT_1!last_type.make(sp,last_integer_constant);
	    elseif a_identifier then
	       !TYPE_BIT_2!last_type.make(sp,tmp_name.to_simple_feature_name);
	    else
	       fcp("Expected constant for BIT_N type declaration.");
	    end;
	 elseif a_type_formal_generic then
	    last_type := last_type_formal_generic;
	 elseif a_class_type then
	    last_type := last_class_type;
	 else
	    Result := false;
	 end;
      end;

   a_unary: BOOLEAN is
	 --++ unary -> "not" | "+" | "-"
	 --++
      do
	 if a_keyword(as_not) then
	    !!last_prefix.make(as_not,pos(start_line,start_column));
	    Result := true;
	 elseif skip1('+') then
	    !!last_prefix.make(as_plus,pos(start_line,start_column));
	    Result := true;
	 elseif skip1('-') then
	    !!last_prefix.make(as_minus,pos(start_line,start_column));
	    Result := true;
	 end;
      end;

   a_when_part(i: E_INSPECT): BOOLEAN is
	 --++ when_part -> "when" {when_part_item "," ...} then compound
	 --++
	 --++ when_part_item -> constant ".." constant |
	 --++                   constant
	 --++
	 --++ constant -> character_constant | integer_constant | identifier
	 --++
      local
	 state: INTEGER;
	 -- state 0 : sepator read, waiting a constant or "then".
	 -- state 1 : first constant read.
	 -- state 2 : ".." read.
	 -- state 3 : slice read.
	 -- state 4 : end.
	 e_when: E_WHEN;
	 constant: EXPRESSION;
      do
	 if a_keyword(fz_when) then
	    from
	       Result := true;
	       !!e_when.make(pos(start_line,start_column),get_comments);
	    until
	       state > 3
	    loop
	       inspect
		  state
	       when 0 then
		  if a_constant then
		     constant := last_expression;
		     state := 1;
		  elseif a_keyword(fz_then) then
		     if constant /= Void then
			e_when.add_value(constant);
		     end;
		     e_when.set_compound(a_compound1);
		     i.add_when(e_when);
		     state := 4;
		  elseif cc = ',' then
		     wcp(em7);
		     ok := skip1(',');
		  else
		     fcp(em4);
		     state := 4;
		  end;
	       when 1 then
		  if a_keyword(fz_then) then
		     if constant /= Void then
			e_when.add_value(constant);
		     end;
		     e_when.set_compound(a_compound1);
		     i.add_when(e_when);
		     state := 4;
		  elseif skip2('.','.') then
		     state := 2;
		  elseif skip1(',') then
		     e_when.add_value(constant);
		     constant := Void;
		     state := 0;
		  else
		     fcp(em4);
		     state := 4;
		  end;
	       when 2 then
		  if a_constant then
		     e_when.add_slice(constant,last_expression);
		     constant := Void;
		     state := 3;
		  else
		     fcp(em4);
		     state := 4;
		  end;
	       else -- state = 3
		  if skip1(',') then
		     state := 0;
		  elseif a_keyword(fz_then) then
		     e_when.set_compound(a_compound1);
		     i.add_when(e_when);
		     state := 4;
		  elseif a_constant then
		     constant := last_expression;
		     warning(tmp_name.start_position,em5);
		     state := 1;
		  else
		     fcp(em4);
		     state := 4;
		  end;
	       end;
	    end;
	 end;
      end;

   mandatory_writable: EXPRESSION is
	 -- Skip and return the writable which is mandatory here.
      do
	 if a_identifier then
	    if a_current then
	       eh.add_position(last_expression.start_position);
	       eh.append("Current is not a writable variable.");
	       eh.print_as_fatal_error;
	    elseif a_argument then
	       eh.add_position(last_expression.start_position);
	       eh.append(em21);
	       eh.print_as_fatal_error;
	    elseif a_result or else a_local_variable then
	       Result := last_expression;
	    else
	       Result := tmp_name.to_simple_feature_name;
	    end;
	 else
	    fcp(em22);
	 end;
      ensure
	 Result /= Void
      end;
   
   to_call(t: EXPRESSION; fn: FEATURE_NAME;
	   eal: EFFECTIVE_ARG_LIST): EXPRESSION is
      require
	 t /= Void;
      do
	 if fn = Void then
	    check
	       eal = Void;
	    end;
	    Result := t;
	 elseif eal = Void then
	    !CALL_0_C!Result.make(t,fn);
	 elseif eal.count = 1 then
	    !CALL_1_C!Result.make(t,fn,eal);
	 else
	    !CALL_N!Result.make(t,fn,eal);
	 end;
      end;

   to_proc_call(t: EXPRESSION; fn: FEATURE_NAME;
		eal: EFFECTIVE_ARG_LIST): PROC_CALL is
      do
	 if fn = Void then
	    fcp("An expression has a result value. %
		%This is not an instruction.");
	 elseif eal = Void then
	    !PROC_CALL_0!Result.make(t,fn);
	 elseif eal.count = 1 then
	    !PROC_CALL_1!Result.make(t,fn,eal);
	 else
	    !PROC_CALL_N!Result.make(t,fn,eal);
	 end;
      end;

   wcpefnc(old_name, new_name: STRING) is
      do
	 eh.append("For readability, the keyword %"");
	 eh.append(old_name);
	 eh.append("%" is now %"");
	 eh.append(new_name);
	 wcp("%". You should update your Eiffel code now.");
      end;

   forbidden_class: ARRAY[STRING] is
      once
	 Result := <<as_none>>;
      end;

   lcs: STRING is
	 -- Last Comment String.
      once
	 !!Result.make(80);
      end;

   tmp_string: STRING is
      once
	 !!Result.make(80);
      end;

   a_identifier1: BOOLEAN is
	 -- Case Insensitive (option -case_insensitive).
      require
	 case_insensitive
      local
	 state, c: INTEGER;
	 -- state 0 : first letter read.
	 -- state 1 : end.
      do
	 if cc.is_letter then
	    from
	       c := column;
	       tmp_name.reset(pos(line,c));
	       tmp_name.extend(cc.to_lower);
	    until
	       state > 0
	    loop
	       next_char;
	       inspect
		  cc
	       when 'a'..'z','0'..'9','_' then
		  tmp_name.extend(cc);
	       when 'A'..'Z' then
		  tmp_name.extend(cc.to_lower);
	       else
		  state := 1;
	       end;
	    end;
	    if tmp_name.isa_keyword then
	       cc := tmp_name.buffer.first;
	       column := c;
	    else
	       Result := true;
	       skip_comments;
	    end;
	 end;
      end;

   a_identifier2: BOOLEAN is
	 -- Case Sensitivity for identifiers (default).
      require
	 not case_insensitive
      local
	 state, c: INTEGER;
	 do_warning: BOOLEAN;
	 -- state 0 : first letter read.
	 -- state 1 : end.
      do
	 if cc.is_letter then
	    from
	       c := column;
	       tmp_name.reset(pos(line,c));
	       tmp_name.extend(cc);
	    until
	       state > 0
	    loop
	       next_char;
	       inspect
		  cc
	       when 'a'..'z','0'..'9','_' then
		  tmp_name.extend(cc);
	       when 'A'..'Z' then
		  do_warning := true;
		  tmp_name.extend(cc);
	       else
		  state := 1;
	       end;
	    end;
	    if tmp_name.isa_keyword then
	       cc := tmp_name.buffer.first;
	       column := c;
	    else
	       Result := true;
	       skip_comments;
	       if no_style_warning then
	       elseif do_warning then
		  warning(tmp_name.start_position,
			  "Identifier should use only lowercase letters.");
	       end;
	    end;
	 end;
      end;

   line, column: INTEGER;
	 -- Current `line' number and current `column' number.

   current_line: STRING;
	 -- Current line string of `text'.

   cc: CHARACTER;
	 -- Current character in the `current_line'.

   show_nb(nb: INTEGER; tail: STRING) is
      do
	 if nb > 0 then
	    echo.w_put_string(fz_error_stars);
	    echo.w_put_integer(nb);
	    echo.w_put_string(tail);
	 end;
      end;

   tmp_feature: TMP_FEATURE;

   drop_comments: BOOLEAN;
	 -- When objects COMMENT are not necessary.

   current_id: INTEGER;
	 -- This is the `id' of the `last_base_class' or the `id' of 
	 -- the cecil file path.

   pos(l, c: INTEGER): POSITION is
      require
	 l >= 1;
	 c >= 1
      do
	 Result.set(l,c,current_id,last_base_class);
      end;

   to_frozen_feature_name is
      do
	 !FROZEN_FEATURE_NAME!last_feature_name.make(last_feature_name);
      end;

   last_result: ABSTRACT_RESULT is
      local
	 sp: POSITION;
      do
	 sp := tmp_name.start_position;
	 if inside_function then
	    if inside_once_function then
	       !ONCE_RESULT!Result.make(sp);
	    else
	       !ORDINARY_RESULT!Result.make(sp);
	    end;
	 else
	    eh.add_position(sp);
	    fatal_error("`Result' must only be used inside a function.");
	 end;
      ensure
	 Result /= Void
      end;

   faof: FIXED_ARRAY[E_FEATURE] is
      once
	 !!Result.with_capacity(256);
      end;

   err_exp(sp: POSITION; operator: STRING) is
	 -- When an error occurs in the right hand side of `operator'.
      local
	 msg: STRING;
      do
	 !!msg.make(0);
	 msg.append("Right hand side expression of %"");
	 msg.append(operator);
	 msg.append("%" expected.");
	 eh.add_position(sp);
	 fatal_error(msg);
      end;

   fcp(msg: STRING) is
	 -- Fatal error at current position.
      do
	 eh.add_position(current_position);
	 fatal_error(msg);
      end;

   wcp(msg: STRING) is
	 -- Warning at current position.
      do
	 warning(current_position,msg);
      end;

   current_position: POSITION is
      do
	 Result := pos(line,column);
      end;

   em1 : STRING is "Underscore in fractionnal part must group 3 digits.";
   em2 : STRING is "Feature name expected.";
   em3 : STRING is "Index value expected (%"indexing ...%").";
   em4 : STRING is "Error in inspect.";
   em5 : STRING is "Added %",%".";
   em6 : STRING is "Added %";%".";
   em7 : STRING is "Unexpected comma (deleted)."
   em8 : STRING is "Unexpected new line in manifest string.";
   em9 : STRING is "Underscore in number must group 3 digits.";
   em10: STRING is "Bad character constant.";
   em11: STRING is "Bad clients list.";
   em12: STRING is "Deleted extra coma.";
   em13: STRING is "Deleted extra separator.";
   em14: STRING is "Class name should use only uppercase letters.";
   em15: STRING is "Name of the current class expected.";
   em16: STRING is "Type mark expected.";
   em17: STRING is "Unexpected character.";
   em18: STRING is "Bad external clause ('%"' expected).";
   em19: STRING is "Bad alias clause ('%"' expected).";
   em20: STRING is "Explicit creation/create type mark must not be anchored.";
   em21: STRING is "A formal argument is not a writable variable.";
   em22: STRING is "Bad creation/create (writable expected).";
   em23: STRING is "Bad creation/create (procedure name expected).";

   singleton_memory: EIFFEL_PARSER is
      once
	 Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- EIFFEL_PARSER

