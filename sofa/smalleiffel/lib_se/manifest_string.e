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
class MANIFEST_STRING
   --
   -- When using Manifest Constant STRING.
   --

inherit EXPRESSION;

creation {EIFFEL_PARSER} make

feature

   start_position: POSITION;
         -- Of the first character '%"'.

   to_string: STRING;
         -- Eiffel contents of the string.

feature {NONE}

   break: ARRAY[INTEGER];
         -- If not Void, places in `to_string' where extended notation (with
         -- line(s) break) is used. The corresponding character in to string
         -- is put on next line.

   ascii: ARRAY[INTEGER];
         -- If not Void, places in `to_string' where character are to be
         -- printed using asci code notation.

   percent: ARRAY[INTEGER];
         -- If not Void, places in `to_string' where character are to be
         -- printed using percent.

feature {MANIFEST_STRING,MANIFEST_STRING_POOL}

   mangling: STRING;
         -- When runnable. Name to be used for the corresponding C
         -- global variable or for the JVM corresponding field.

feature

   is_manifest_string: BOOLEAN is true;

   is_manifest_array: BOOLEAN is false;

   is_writable: BOOLEAN is false;

   is_current: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_void: BOOLEAN is false;

   is_result: BOOLEAN is false;

   use_current: BOOLEAN is false;

   is_pre_computable: BOOLEAN is true;

   c_simple: BOOLEAN is true;

   can_be_dropped: BOOLEAN is true;

   static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_string);
      end;

   result_type: TYPE_STRING is
      do
         Result := type_string;
      end;

   assertion_check(tag: CHARACTER) is
      do
      end;

   static_value: INTEGER is
      do
      end;

   isa_dca_inline_argument: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   mapping_c_target(target_type: TYPE) is
      do
         cpp.put_string(mangling);
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         cpp.put_character('(');
         cpp.put_string(fz_cast_t0_star);
         cpp.put_string(mangling);
         cpp.put_character(')');
      end;

   c_declare_for_old is
      do
      end;

   compile_to_c_old is
      do
      end;

   compile_to_jvm_old is
      do
      end;

   afd_check is
      do
      end;

   count: INTEGER is
      do
         Result := to_string.count;
      end;

   compile_target_to_jvm, compile_to_jvm is
      local
         idx: INTEGER;
      do
         idx := fieldref_idx;
         code_attribute.opcode_getstatic(idx,1);
      end;

   compile_to_jvm_assignment(a: ASSIGNMENT) is
      do
      end;

   jvm_branch_if_false: INTEGER is
      do
      end;

   jvm_branch_if_true: INTEGER is
      do
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := 1;
         compile_to_jvm;
      end;

   to_runnable(ct: TYPE): MANIFEST_STRING is
      do
         if mangling = Void then
            mangling := manifest_string_pool.register(Current);
         end;
         Result := Current;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;

   precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   bracketed_pretty_print, pretty_print is
      local
         i, column: INTEGER;
      do
         from
            column := fmt.column;
            fmt.put_character('%"');
            i := 1;
         until
            i > to_string.count
         loop
            if is_on_next_line(i) then
               fmt.put_string("%%%N");
               from
               until
                  column = fmt.column
               loop
                  fmt.put_character(' ');
               end;
               fmt.put_character('%%');
            end;
            pretty_print_character(i);
            i := i + 1;
         end;
         fmt.put_character('%"');
      end;

   print_as_target is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
         fmt.put_character('.');
      end;

   short is
      local
         i: INTEGER;
      do
         short_print.hook_or("open_ms","%"");
         from
            i := 1;
         until
            i > to_string.count
         loop
            short_character(i);
            i := i + 1;
         end;
         short_print.hook_or("close_ms","%"");
      end;

   short_target is
      do
         bracketed_short;
         short_print.a_dot;
      end;

feature {EIFFEL_PARSER}

   add(ch: CHARACTER) is
         -- Append `ch' to manifest string setting ordinary printing mode.
      do
         to_string.extend(ch);
      end;

   add_ascii(ch: CHARACTER) is
         -- Append `ch' to manifest string setting `ascii' printing mode.
      do
         to_string.extend(ch);
         if ascii = Void then
            !!ascii.with_capacity(4,1);
         end;
	 ascii.add_last(to_string.count);
      end;

   add_percent(ch: CHARACTER) is
         -- Append `ch' to manifest string setting `percent'  printing mode.
      do
         to_string.extend(ch);
         if percent = Void then
            !!percent.with_capacity(4,1);
         end;
	 percent.add_last(to_string.count);
      end;

   break_line is
         -- Next character will be a `break'.
      do
         if break = Void then
            !!break.with_capacity(4,1);
         end;
	 break.add_last(to_string.count + 1);
      end;

feature {CREATION_CALL,EXPRESSION_WITH_COMMENT}

   jvm_assign is
      do
      end;

feature {MANIFEST_STRING_POOL}

   fieldref_idx: INTEGER is
      do
         Result := constant_pool.idx_fieldref_for_manifest_string(mangling);
      end;

feature {NONE}

   make(sp: like start_position) is
      require
         not sp.is_unknown
      do
         start_position := sp;
         !!to_string.make(0);
      ensure
         start_position = sp
      end;

   tmp_string: STRING is
      once
         !!Result.make(8);
      end;

   pretty_print_character(i: INTEGER) is
      require
         1 <= i;
         i <= count;
      local
         val: INTEGER;
      do
         if percent /= Void and then percent.fast_has(i) then
            tmp_string.clear;
            character_coding(to_string.item(i),tmp_string);
            fmt.put_string(tmp_string);
         elseif ascii /= Void and then ascii.fast_has(i) then
            val := to_string.item(i).code;
            fmt.put_string("%%/");
            fmt.put_integer(val);
            fmt.put_string(as_slash);
         else
            fmt.put_character(to_string.item(i));
         end;
      end;

   short_character(i: INTEGER) is
      require
         1 <= i;
         i <= count;
      local
         val: INTEGER;
         c: CHARACTER;
      do
         tmp_string.clear;
         if percent /= Void and then percent.fast_has(i) then
            character_coding(to_string.item(i),tmp_string);
         elseif ascii /= Void and then ascii.fast_has(i) then
            val := to_string.item(i).code;
            tmp_string.append("%%/");
            val.append_in(tmp_string);
            tmp_string.append(as_slash);
         end;
         if tmp_string.count = 0 then
            short_print.a_character(to_string.item(i));
         else
            from
               val := 1;
            until
               val > tmp_string.count
            loop
               c := tmp_string.item(val);
               if c = '%%' then
                  short_print.hook_or("Prcnt_ms","%%");
               elseif c = '/' then
                  short_print.hook_or("Slash_ms",as_slash);
               else
                  short_print.a_character(c);
               end;
               val := val + 1;
            end;
         end;
      end;

   is_on_next_line(i: INTEGER): BOOLEAN is
      require
         1 <= i;
         i <= count;
      do
         if break /= Void then
            Result := break.fast_has(i);
         end;
      end;

invariant

   not start_position.is_unknown;

   to_string /= Void;

end -- MANIFEST_STRING

