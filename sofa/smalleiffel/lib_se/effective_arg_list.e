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
class EFFECTIVE_ARG_LIST
   --
   -- For an effective arguments list (for a routine call).
   --

inherit GLOBALS;

creation make_1, make_n

creation {EFFECTIVE_ARG_LIST} from_model

feature {EFFECTIVE_ARG_LIST}

   first_one: EXPRESSION;

   remainder: FIXED_ARRAY[EXPRESSION];
         -- Corresponding list of actual arguments.

feature

   current_type: TYPE;
         -- Not Void when checked in.

   count: INTEGER is
      do
         if remainder = Void then
            Result := 1;
         else
            Result := remainder.upper + 2;
         end;
      end;

   expression(i: INTEGER): EXPRESSION is
      require
         i.in_range(1,count)
      do
         if i = 1 then
            Result := first_one;
         else
            Result := remainder.item(i - 2);
         end;
      ensure
         Result /= Void
      end;

   first: EXPRESSION is
      require
         count >= 1
      do
         Result := first_one;
      ensure
         Result /= Void
      end;

   run_class: RUN_CLASS is
      do
         Result := current_type.run_class;
      end;

   start_position: POSITION is
      do
         Result := first.start_position;
      end;

   match_with(rf: RUN_FEATURE; ct: TYPE) is
         -- Check the good match for actual/formal arguments when
         -- context of the call is `ct'.
      require
         rf /= Void;
         ct.run_type = ct
      local
         fal: FORMAL_ARG_LIST;
         i: INTEGER;
         e: EXPRESSION;
         at, ft: TYPE;
      do
         fal := rf.arguments;
         if fal = Void then
            eh.add_position(rf.start_position);
            error(start_position,em2);
         end;
         if nb_errors = 0 and then fal.count /= count then
            eh.add_position(fal.start_position);
            error(start_position,em2);
         end;
         from
            i := count;
         until
            i = 0 or else nb_errors > 0
         loop
            e := expression(i);
            at := e.result_type;
            ft := fal.type(i);
            if e.is_void then
               if ft.is_expanded then
                  eh.add_position(e.start_position);
                  error(ft.start_position,
                        "Cannot pass Void for expanded argument.");
               end;
            elseif ft.is_like_current then
               if at.run_type.is_a(ft.run_type) then
                  if at.run_type.is_expanded then
                  elseif at.run_type.is_a(ft.run_type) then
                  else
                     eh.add_position(e.start_position);
                     error(ft.start_position,em1);
                  end;
               else
                  eh.add_position(e.start_position);
                  error(ft.start_position,em1);
               end;
            elseif ft.is_like_feature then
               if at.run_type.is_a(ft.run_type) then
               else
                  eh.add_position(e.start_position);
                  error(ft.start_position," It is not Like <feature>.");
               end;
            elseif is_like_argument(e,at,ft) then
            elseif at.is_a(ft) then
            else
               error(e.start_position,
                     " Actual-argument/Formal-argument mismatch.");
            end;
            e := conversion_handler.implicit_cast(e,ft);
            put(e,i);
            i := i - 1;
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      require
         ct.run_type = ct
      local
         i: INTEGER;
         e1, e2: EXPRESSION;
      do
         if current_type = Void then
            current_type := ct;
            from
               i := count;
            until
               i = 0
            loop
               e1 := expression(i);
               e2 := e1.to_runnable(current_type);
               if e2 = Void then
                  error(e1.start_position,"Bad expression.");
               elseif e1 /= e2 then
                  put(e2,i);
               end;
               i := i - 1;
            end;
            if nb_errors = 0 then
               Result := Current;
            end;
         elseif ct.run_class = run_class then -- *** C'est POSSIBLE ???? ****
            Result := Current;
         else
            !!Result.from_model(Current);
            Result := Result.to_runnable(ct);
         end;
      end;

   afd_check is
      require
         current_type /= Void
      local
         i: INTEGER;
      do
         from
            i := count;
         until
            i = 0
         loop
            expression(i).afd_check;
            i := i - 1;
         end;
      end;

   compile_to_c(fal: FORMAL_ARG_LIST) is
         -- Produce C code for all expressions of the list.
      require
         cpp.on_c;
         count = fal.count
      local
         i, up: INTEGER;
      do
         from
            i := 1;
            up := count;
         until
            i > up
         loop
            compile_to_c_ith(fal,i);
            i := i + 1;
            if i <= up then
               cpp.put_character(',');
            end;
         end;
      ensure
         cpp.on_c
      end;

   compile_to_c_ith(fal: FORMAL_ARG_LIST; index: INTEGER) is
         -- Produce C code for expression `index'.
      require
         cpp.on_c;
         count = fal.count;
         1 <= index;
         index <= count
      local
         e: EXPRESSION;
         ft: TYPE;
      do
         e := expression(index);
         ft := fal.type(index).run_type;
         e.mapping_c_arg(ft);
      ensure
         cpp.on_c
      end;

   collect_c_tmp is
      local
         i, c: INTEGER;
      do
         from
            i := 1;
            c := count;
         until
            i > c
         loop
            expression(i).collect_c_tmp;
            i := i + 1;
         end;
      end;

   c_declare_for_old is
      local
         i, c: INTEGER;
      do
         from
            i := 1;
            c := count;
         until
            i > c
         loop
            expression(i).c_declare_for_old;
            i := i + 1;
         end;
      end;

   compile_to_c_old is
      local
         i, c: INTEGER;
      do
         from
            i := 1;
            c := count;
         until
            i > c
         loop
            expression(i).compile_to_c_old;
            i := i + 1;
         end;
      end;

   compile_to_jvm_old is
      local
         i, c: INTEGER;
      do
         from
            i := 1;
            c := count;
         until
            i > c
         loop
            expression(i).compile_to_jvm_old;
            i := i + 1;
         end;
      end;

   compile_to_jvm(fal: FORMAL_ARG_LIST): INTEGER is
      require
         count = fal.count
      local
         i, up: INTEGER;
      do
         from
            i := 1;
            up := count;
         until
            i > up
         loop
            Result := Result + compile_to_jvm_ith(fal,i);
            i := i + 1;
         end;
      end;

   compile_to_jvm_ith(fal: FORMAL_ARG_LIST; index: INTEGER): INTEGER is
      require
         count = fal.count;
         1 <= index;
         index <= count
      local
         e: EXPRESSION;
         ft: TYPE;
      do
         e := expression(index);
         ft := fal.type(index).run_type;
         Result :=  e.compile_to_jvm_into(ft);
      end;

   use_current: BOOLEAN is
      local
         i: INTEGER;
      do
         from
            i := count;
         until
            Result or else i = 0
         loop
            Result := expression(i).use_current;
            i := i - 1;
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      local
         i: INTEGER;
      do
         from
            Result := true;
            i := count;
         until
            not Result or else i = 0
         loop
            Result := expression(i).stupid_switch(r);
            i := i - 1;
         end;
      end;

   is_pre_computable: BOOLEAN is
      local
         i: INTEGER;
      do
         from
            i := count;
            Result := true;
         until
            not Result or else i = 0
         loop
            Result := expression(i).is_pre_computable;
            i := i - 1;
         end;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.put_character('(');
         from
            i := 1;
         until
            i > count
         loop
            expression(i).pretty_print;
            i := i + 1;
            if i <= count then
               fmt.put_character(',');
            end;
         end;
         fmt.put_character(')');
      end;

   short is
      local
         i: INTEGER;
      do
         short_print.hook_or("op_eal","(");
         from
            i := 1;
         until
            i > count
         loop
            expression(i).short;
            i := i + 1;
            if i <= count then
               short_print.hook_or("eal_sep",",");
            end;
         end;
         short_print.hook_or("cl_eal",")");
      end;

   is_static: BOOLEAN is
         -- Is true when only `is_static' expression are used.
      local
         i: INTEGER;
      do
         from
            Result := true;
            i := count;
         until
            not Result or else i = 0
         loop
            Result := expression(i).is_static;
            i := i - 1;
         end;
      end;

   can_be_dropped: BOOLEAN is
         -- Is true when only `can_be_dropped' expression are used.
      local
         i: INTEGER;
      do
         from
            Result := true;
            i := count;
         until
            not Result or else i = 0
         loop
            Result := expression(i).can_be_dropped;
            i := i - 1;
         end;
      end;

feature {RUN_FEATURE_3,RUN_FEATURE_4}

   isa_dca_inline(relay_rf, rf: RUN_FEATURE): BOOLEAN is
         -- Assume `rf' is inside `relay_rf'.
      require
         relay_rf /= Void;
         rf /= Void
      local
         relay_args, args: FORMAL_ARG_LIST;
         e: EXPRESSION;
         i, r: INTEGER;
      do
         relay_args := relay_rf.arguments;
         args := rf.arguments;
         from
            Result := true;
            i := count;
            isa_dca_inline_memory.force(false,i);
            isa_dca_inline_memory.clear_all;
         until
            not Result or else i = 0
         loop
            e := expression(i);
            r := e.isa_dca_inline_argument;
            inspect
               r
            when 0 then
               Result := false;
            when -1 then
               if args.type(i).is_expanded then
                  Result := e.result_type.is_expanded;
               else
                  Result := e.result_type.is_reference;
               end;
            else
               check
                  r > 0
               end;
               isa_dca_inline_memory.put(true,r);
               if relay_args.type(r).is_reference then
                  if args.type(i).is_reference then
                     Result := e.result_type.is_reference;
                  else
                     Result := false;
                  end;
               elseif args.type(i).is_expanded then
                  Result := e.result_type.is_expanded;
               else
                  Result := false;
               end;
            end;
            i := i - 1;
         end;
         if Result then
            -- No arguments are lost :
            from
               if relay_rf.arguments /= Void then
                  i := relay_rf.arguments.count;
               else
                  i := 0;
               end;
            until
               not Result or else i = 0
            loop
               Result := isa_dca_inline_memory.item(i);
               i := i - 1;
            end;
         end;
      end;

feature {C_PRETTY_PRINTER}

   dca_inline(fal: FORMAL_ARG_LIST) is
      require
         fal /= Void
      local
         i, up: INTEGER;
      do
         from
            up := count;
            i := 1;
         until
            i > up
         loop
            dca_inline_ith(fal,i);
            i := i + 1;
            if i <= up then
               cpp.put_character(',');
            end;
         end;
      end;

   dca_inline_ith(fal: FORMAL_ARG_LIST; index: INTEGER) is
      require
         fal /= Void;
         index <= count
      local
         e: EXPRESSION;
         ft: TYPE;
      do
         e := expression(index);
         ft := fal.type(index).run_type;
         e.dca_inline_argument(ft);
      end;

feature {EFFECTIVE_ARG_LIST}

   put(e: EXPRESSION; i: INTEGER) is
      require
         i.in_range(1,count)
      do
         if i = 1 then
            first_one := e;
         else
            remainder.put(e,i - 2);
         end;
      end;

feature {CALL_N}

   assertion_check(tag: CHARACTER) is
      local
         i: INTEGER;
      do
         from
            i := count;
         until
            i = 0
         loop
            expression(i).assertion_check(tag);
            i := i - 1;
         end;
      end;

feature {NONE}

   make_1(e: EXPRESSION) is
      require
         e /= Void
      do
         first_one := e;
      ensure
         count = 1;
         first = e
      end;

   make_n(fo: like first_one; r: like remainder) is
      require
         fo /= Void
      do
         first_one := fo;
         remainder := r;
      ensure
         first_one = fo;
         remainder = r
      end;

   from_model(model: like Current) is
      require
         model /= Void
      do
         first_one := model.first_one;
         remainder := model.remainder;
         if remainder /= Void then
            remainder := remainder.twin;
         end;
      ensure
         count = model.count
      end;

   isa_dca_inline_memory: ARRAY[BOOLEAN] is
      once
         !!Result.make(1,2);
      end;

   is_like_argument(e: EXPRESSION; at, ft: TYPE): BOOLEAN is
      local
         tla: TYPE_LIKE_ARGUMENT;
         ot: TYPE;
      do
         tla ?= ft;
         if tla /= Void then
            Result := true;
            ot := expression(tla.rank).result_type;
            if not at.run_type.is_a(ot.run_type) then
               eh.add_position(e.start_position);
               error(ft.start_position," It is not Like <argument>.");
            end;
         end;
      end;

   em1: STRING is " It is not Like Current.";
   em2: STRING is "Bad number of arguments.";

invariant

   first_one /= Void;

   remainder /= Void implies count = remainder.count + 1;

end -- EFFECTIVE_ARG_LIST

