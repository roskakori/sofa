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
class E_WHEN
   --
   -- To store a when clause of an inspect instruction.
   --

inherit GLOBALS;

creation {EIFFEL_PARSER}
   make

creation {E_WHEN,WHEN_LIST}
   from_e_when

feature

   start_position: POSITION;
         -- Of the first character of keyword "when".

feature {E_WHEN}

   list: ARRAY[WHEN_ITEM];

feature

   header_comment: COMMENT;
         -- Of the when clause.

   compound: COMPOUND;
         -- Of the when clause if any.

   when_list: WHEN_LIST;
         -- Corresponding one when checked.

   values: ARRAY[BOOLEAN];
         -- True when the corresponding index is in the when.

feature {NONE}

   points1: FIXED_ARRAY[INTEGER] is
         -- To reach the `compound'.
      once
         !!Result.with_capacity(12);
      end;

   point2: INTEGER;
         -- To go outside the E_INSPECT.

feature {EIFFEL_PARSER}

   make(sp: like start_position; hc: like header_comment) is
      require
         not sp.is_unknown
      do
         start_position := sp;
         header_comment := hc;
      ensure
         start_position = sp;
      end;

feature {WHEN_LIST}

   afd_check is
      do
         if compound /= Void then
            compound.afd_check;
         end;
      end;

feature {NONE}

   from_e_when(other: like Current) is
      local
         i: INTEGER;
         when_item: WHEN_ITEM;
      do
         start_position := other.start_position;
         list := other.list.twin;
         from
            i := list.lower;
         until
            i > list.upper
         loop
            when_item := list.item(i).twin;
            when_item.clear_e_when;
            list.put(when_item,i);
            i := i + 1;
         end;
         header_comment := other.header_comment;
         compound := other.compound;
      end;

feature

   use_current: BOOLEAN is
      do
         if compound /= Void then
            Result := compound.use_current;
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := (compound = Void or else compound.stupid_switch(r));
      end;

   e_inspect: E_INSPECT is
      do
         Result := when_list.e_inspect;
      end;

feature {WHEN_LIST}

   compile_to_jvm(else_position: POSITION; remainder: INTEGER) is
         -- Where `remainder' is the number of E_WHEN after Current.
      local
         point3, point4, bi, bs: INTEGER;
         must_test: BOOLEAN;
         ca: like code_attribute;
      do
         ca := code_attribute;
         if remainder > 0 then
            must_test := true;
         elseif run_control.no_check then
            must_test := true;
         else -- boost :
            must_test := not else_position.is_unknown;
         end;
         points1.clear;
         if must_test then
            from
               bi := values.lower;
            until
               bi > values.upper
            loop
               from
                  bs := bi + 1;
               until
                  bs > values.upper or else not values.item(bs)
               loop
                  bs := bs + 1;
               end;
               bs := bs - 1;
               --
               if bi = bs then
                  ca.opcode_dup;
                  ca.opcode_push_integer(bi);
                  points1.add_last(ca.opcode_if_icmpeq);
               else
                  ca.opcode_dup;
                  ca.opcode_push_integer(bi);
                  point3 := ca.opcode_if_icmplt;
                  ca.opcode_dup;
                  ca.opcode_push_integer(bs);
                  points1.add_last(ca.opcode_if_icmple);
                  ca.resolve_u2_branch(point3);
               end;
               from
                  bi := bs + 1;
               until
                  bi > values.upper or else values.item(bi)
               loop
                  bi := bi + 1;
               end;
            end;
            point4 := ca.opcode_goto;
         end;
         ca.resolve_with(points1);
         if compound /= Void then
            compound.compile_to_jvm;
         end;
         point2 := ca.opcode_goto;
         if must_test then
            ca.resolve_u2_branch(point4);
         end;
      end;

   compile_to_jvm_resolve_branch is
      do
         code_attribute.resolve_u2_branch(point2);
      end;

   compile_to_c is
      local
         bi, bs: INTEGER;
      do
         cpp.put_string("%Nif(");
         from
            bi := values.lower;
         until
            bi > values.upper
         loop
            from
               bs := bi + 1;
            until
               bs > values.upper or else not values.item(bs)
            loop
               bs := bs + 1;
            end;
            bs := bs - 1;
            --
            cpp.put_character('(');
            if bi = bs then
               cpp.put_integer(bi);
               cpp.put_string("==");
               cpp.put_inspect;
            else
               cpp.put_character('(');
               cpp.put_integer(bi);
               cpp.put_string("<=");
               cpp.put_inspect;
               cpp.put_string(")&&(");
               cpp.put_inspect;
               cpp.put_string("<=");
               cpp.put_integer(bs);
               cpp.put_character(')');
            end;
            cpp.put_character(')');
            --
            from
               bi := bs + 1;
            until
               bi > values.upper or else values.item(bi)
            loop
               bi := bi + 1;
            end;
            if bi <= values.upper then
               cpp.put_string("||");
            end;
         end;
         cpp.put_string("){%N");
         if compound /= Void then
            compound.compile_to_c;
         end;
         cpp.put_string(fz_12);
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.keyword(fz_when);
         fmt.level_incr;
         if header_comment /= Void then
            header_comment.pretty_print;
         end;
         if list /= Void then
            from
               i := list.lower;
            until
               i > list.upper
            loop
               list.item(i).pretty_print;
               i := i + 1;
               if i <= list.upper then
                  fmt.put_character(',');
               end;
            end;
         end;
         fmt.level_decr;
         fmt.keyword(fz_then);
         fmt.level_incr;
         if compound /= Void then
            compound.pretty_print;
         end;
         fmt.level_decr;
      end;

   includes_integer(v: INTEGER): BOOLEAN is
      do
         Result := ((values /= Void) and then
                    values.valid_index(v) and then
                    values.item(v));
      end;

feature {WHEN_LIST,E_WHEN}

   to_runnable_integer(wl: like when_list): like Current is
      require
         wl /= Void;
      local
         ct: TYPE;
         ne, i: INTEGER;
         when_item: WHEN_ITEM;
      do
         if when_list = Void then
            ne := nb_errors;
            when_list := wl;
            if list = Void then
               eh.add_position(e_inspect.start_position);
               error(start_position,em2);
            else
               from
                  i := list.lower;
               until
                  i > list.upper or else nb_errors - ne > 0
               loop
                  when_item := list.item(i).to_runnable_integer(Current);
                  if when_item = Void then
                     error(start_position,em1);
                  else
                     list.put(when_item,i);
                  end;
                  i := i + 1;
               end;
            end;
            if compound /= Void then
               ct := small_eiffel.top_rf.current_type;
               compound := compound.to_runnable(ct);
               if compound = Void then
                  error(start_position,em1);
               end;
            end;
            Result := Current;
         else
            !!Result.from_e_when(Current);
            Result := Result.to_runnable_integer(wl);
         end;
      ensure
         Result.when_list = wl
      end;

   to_runnable_character(wl: like when_list): like Current is
      require
         wl /= Void;
      local
         ct: TYPE;
         ne, i: INTEGER;
         when_item: WHEN_ITEM;
      do
         if when_list = Void then
            ne := nb_errors;
            when_list := wl;
            if list = Void then
               eh.add_position(e_inspect.start_position);
               error(start_position,em2);
            else
               from
                  i := list.lower;
               until
                  i > list.upper or else nb_errors - ne > 0
               loop
                  when_item := list.item(i).to_runnable_character(Current);
                  if when_item = Void then
                     error(start_position,em1);
                  else
                     list.put(when_item,i);
                  end;
                  i := i + 1;
               end;
            end;
            if compound /= Void then
               ct := small_eiffel.top_rf.current_type;
               compound := compound.to_runnable(ct);
               if compound = Void then
                  error(start_position,em1);
               end;
            end;
            Result := Current;
         else
            !!Result.from_e_when(Current);
            Result := Result.to_runnable_character(wl);
         end;
      ensure
         Result.when_list = wl
      end;

feature {WHEN_ITEM_1}

   add_when_item_1(wi1: WHEN_ITEM_1) is
      require
         wi1 /= Void
      local
         v: INTEGER;
      do
         v := wi1.expression_value;
         if e_inspect.includes(v) then
            err_occ(v,wi1.start_position);
         elseif values = Void then
            !!values.make(v,v);
            values.put(true,v);
         else
            values.force(true,v);
         end;
      ensure
         e_inspect.includes(wi1.expression_value);
      end;

feature {WHEN_ITEM_2}

   add_when_item_2(wi2: WHEN_ITEM_2) is
      require
         wi2 /= Void
      local
         l, u, i: INTEGER;
      do
         l := wi2.lower_value;
         u := wi2.upper_value;
         if l >= u then
            error(wi2.start_position,"Not a good slice.");
         end;
         if nb_errors = 0 then
            from
               i := l;
            until
               i > u
            loop
               if e_inspect.includes(i) then
                  err_occ(i,wi2.start_position);
                  i := u + 1;
               else
                  i := i + 1;
               end;
            end;
         end;
         if nb_errors = 0 then
            if values = Void then
               !!values.make(l,u);
               values.set_all_with(true);
            else
               values.force(true,l);
               values.force(true,u);
               values.set_slice_with(true,l,u);
            end;
         end;
      end;

feature {EIFFEL_PARSER}

   add_value(v: EXPRESSION) is
      require
         v /= Void;
      local
         element: WHEN_ITEM
      do
         !WHEN_ITEM_1!element.make(v);
         if list = Void then
            !!list.with_capacity(4,1);
	 end;
	 list.add_last(element);
      end;

   add_slice(min, max: EXPRESSION) is
      require
         min /= Void;
         max /= Void;
      local
         element: WHEN_ITEM;
      do
         !WHEN_ITEM_2!element.make(min,max);
         if list = Void then
            !!list.with_capacity(4,1);
         end;
	 list.add_last(element);
      end;

   set_compound(c: like compound) is
      do
         compound := c;
      ensure
         compound = c
      end;

feature {NONE}

   err_occ(v: INTEGER; p: POSITION) is
      do
         eh.add_position(e_inspect.start_position);
         eh.append("Second occurrence for this value (");
         eh.append(v.to_string);
         error(p,") in the same inspect.");
      end;

feature {NONE}

   em1: STRING is "Bad when clause.";
   em2: STRING is "Empty when clause in inspect.";

end -- E_WHEN


