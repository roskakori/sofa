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
deferred class ASSERTION_LIST
   --
   -- To store a list of assertions (see ASSERTION).
   --
   -- See also : CLASS_INVARIANT, E_REQUIRE, E_ENSURE,
   --            LOOP_INVARIANT and CHECK_INVARIANT.
   --

inherit GLOBALS;

feature

   name: STRING is
         -- "require", "ensure" or "invariant".
      deferred
      end;

   start_position: POSITION;
         -- If any, the position of the first letter of `name'.

   header_comment: COMMENT;

feature {ASSERTION_LIST,E_CHECK,E_FEATURE}

   list: ARRAY[ASSERTION];

feature

   current_type: TYPE;
         -- Not Void when checked in.

feature {NONE}

   run_feature: RUN_FEATURE;
         -- Corresponding one (if any) when runnable.
         -- Note: class invariant are not inside a RUN_FEATURE.

feature

   set_current_type(ct: like current_type) is
      do
         current_type := ct;
      end;

   afd_check is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0
            loop
               list.item(i).afd_check;
               i := i - 1;
            end;
         end;
      end;

feature {NONE}

   is_always_true: BOOLEAN is
      local
         i: INTEGER;
         assertion: ASSERTION;
      do
         from
            i := list.upper;
            Result := true;
         until
            not Result or else i = 0
         loop
            assertion := list.item(i);
            Result := assertion.is_always_true;
            i := i - 1;
         end;
      end;

feature

   compile_to_c is
      require
         run_control.require_check
      local
         i: INTEGER;
         need_se_tmp: BOOLEAN;
         assertion: ASSERTION;
      do
         if is_always_true then
            cpp.increment_static_expression_count(list.count);
         else
            if run_feature = Void then
               cpp.put_string("if(ds.fd->assertion_flag){%N%
                              %ds.fd->assertion_flag=0;%N");
            else
               cpp.put_string("if(");
               run_feature.c_assertion_flag;
               cpp.put_string("){%N");
               run_feature.c_assertion_flag;
               cpp.put_string("=0;%N");
            end;
            from
               i := 1;
            until
               i > list.upper
            loop
               assertion := list.item(i);
               if assertion.is_always_true then
               else
                  assertion.collect_c_tmp;
                  need_se_tmp := cpp.se_tmp_open_declaration;
                  cpp.set_check_assertion_mode(check_assertion_mode);
                  assertion.compile_to_c;
                  if need_se_tmp then
                     cpp.se_tmp_close_declaration;
                  end;
               end;
               i := i + 1;
            end;
            if run_feature = Void then
               cpp.put_string("ds.fd->assertion_flag=1;%N}%N");
            else
               run_feature.c_assertion_flag;
               cpp.put_string("=1;%N}%N");
            end;
         end;
      end;

   frozen compile_to_jvm(last_chance: BOOLEAN) is
         -- If `last_chance' is true, an error message is printed at
         -- run-time.
         -- The final result is always left a top of stack.
      local
         point_true, i: INTEGER;
         ca: like code_attribute;
      do
         ca := code_attribute;
         ca.check_opening;
         from
            failure.clear;
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).compile_to_jvm(last_chance);
            failure.add_last(ca.opcode_ifeq);
            i := i + 1;
         end;
         ca.opcode_iconst_1;
         point_true := ca.opcode_goto;
         ca.resolve_with(failure);
         ca.opcode_iconst_0;
         ca.resolve_u2_branch(point_true);
         ca.check_closing;
      end;

   is_pre_computable: BOOLEAN is
      local
         i: INTEGER;
      do
         if list = Void then
            Result := true;
         else
            from
               i := list.upper;
               Result := true;
            until
               not Result or else i = 0
            loop
               Result := list.item(i).is_pre_computable;
               i := i - 1;
            end;
         end;
      end;

   use_current: BOOLEAN is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               Result or else i = 0
            loop
               Result := list.item(i).use_current;
               i := i - 1;
            end;
         end;
      end;

feature {NONE}

   make(sp: like start_position; hc: like header_comment; l: like list) is
      require
         l /= Void implies not l.is_empty;
         hc /= Void or else l /= Void;
      do
         start_position := sp;
         header_comment := hc;
         list := l;
      ensure
         start_position = sp;
         header_comment = hc;
         list = l;
      end;

feature {NONE}

   make_runnable(sp: like start_position; l: like list;
                 ct: like current_type; rf: like run_feature) is
      require
         not l.is_empty;
         ct /= Void
      do
         start_position := sp;
         list := l;
         current_type := ct;
         run_feature := rf;
      ensure
         start_position = sp;
         list = l;
         current_type = ct;
         run_feature = rf
      end;

feature

   is_empty: BOOLEAN is
      do
         Result := list = Void;
      end;

   run_class: RUN_CLASS is
      do
         Result := current_type.run_class;
      end;

   frozen to_runnable(ct: TYPE): like Current is
      require
         ct.run_type = ct;
      do
         if current_type = Void then
            current_type := ct;
            run_feature := small_eiffel.top_rf;
            if list /= Void then
               list := assertion_collector.runnable(list,ct,run_feature,'_');
            end;
            if nb_errors = 0 then
               Result := Current;
            end;
         else
            Result := twin;
            Result.set_current_type(Void);
            Result := Result.to_runnable(ct);
         end;
      ensure
         nb_errors = 0 implies Result /= Void
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.indent;
         fmt.keyword(name);
         fmt.level_incr;
         if header_comment /= Void then
            header_comment.pretty_print;
         else
            fmt.indent;
         end;
         if list /= Void then
            from
               i := 1;
            until
               i > list.upper
            loop
               if fmt.zen_mode and i = list.upper then
                  fmt.set_semi_colon_flag(false);
               else
                  fmt.set_semi_colon_flag(true);
               end;
               fmt.indent;
               list.item(i).pretty_print;
               i := i + 1;
            end;
         end;
         fmt.level_decr;
         fmt.indent;
      ensure
         fmt.indent_level = old fmt.indent_level;
      end;

   set_header_comment(hc: like header_comment) is
      do
         header_comment := hc;
      end;

feature {E_FEATURE,RUN_CLASS,ASSERTION_COLLECTOR}

   add_into(collector: ARRAY[ASSERTION]) is
      local
         i: INTEGER;
         a: ASSERTION;
      do
         if list /= Void then
            from
               i := 1;
            until
               i > list.upper
            loop
               a := list.item(i);
               if not collector.fast_has(a) then
                  collector.add_last(a);
               end;
               i := i + 1;
            end;
         end;
      end;

feature {NONE}

   failure: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(12);
      end;

   check_assertion_mode: STRING is
      deferred
      end;

feature {ONCE_ROUTINE_POOL, RUN_REQUIRE}

   clear_run_feature is
      do
         run_feature := Void;
      end;

invariant

   list /= Void implies (list.lower = 1 and not list.is_empty);

end -- ASSERTION_LIST
