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

creation {EIFFEL_PARSER} make

creation {E_WHEN,WHEN_LIST} from_e_when

feature

   start_position: POSITION;
         -- Of the first character of keyword "when".

   header_comment: COMMENT;
         -- Of the when clause.

   compound: COMPOUND;
         -- Of the when clause if any.

   when_list: WHEN_LIST;
         -- Corresponding one when checked.

feature {NONE}

   values: ARRAY[INTEGER];
	 -- To store pairs of range values.

feature {E_WHEN}

   list: ARRAY[WHEN_ITEM];

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
         point3, point4, bi: INTEGER;
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
               if values.item(bi) = values.item(bi+1) then
                  ca.opcode_dup;
                  ca.opcode_push_integer(values.item(bi));
                  points1.add_last(ca.opcode_if_icmpeq);
               else
                  ca.opcode_dup;
                  ca.opcode_push_integer(values.item(bi));
                  point3 := ca.opcode_if_icmplt;
                  ca.opcode_dup;
                  ca.opcode_push_integer(values.item(bi+1));
                  points1.add_last(ca.opcode_if_icmple);
                  ca.resolve_u2_branch(point3);
               end;
               bi := bi + 2;
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
         bi: INTEGER;
      do
         cpp.put_string("%Nif(");
         from
            bi := values.lower;
         until
            bi > values.upper
         loop
            cpp.put_character('(');
            if values.item(bi) = values.item(bi+1) then
               cpp.put_integer(values.item(bi));
               cpp.put_string("==");
               cpp.put_inspect;
            else
               cpp.put_character('(');
               cpp.put_integer(values.item(bi));
               cpp.put_string("<=");
               cpp.put_inspect;
               cpp.put_string(")&&(");
               cpp.put_inspect;
               cpp.put_string("<=");
               cpp.put_integer(values.item(bi+1));
               cpp.put_character(')');
            end;
            cpp.put_character(')');
            --
            bi := bi + 2;
            if bi < values.upper then
               cpp.put_string("||");
            end;
         end;
         cpp.put_string("){%N");
         if compound /= Void then
            compound.compile_to_c;
         end;
         cpp.put_string(fz_12);
      end;

   compile_to_c_switch is
      local
         bi, v: INTEGER;
      do
         from
            bi := values.lower;
         until
            bi > values.upper
         loop
            from
               v := values.item(bi)
            until
               v > values.item(bi+1)
            loop
               cpp.put_string("case ");
               cpp.put_integer(v);
               cpp.put_string(":%N");
               v := v + 1;
            end;
            bi := bi + 2;
         end;
         if compound /= Void then
            compound.compile_to_c;
         end;
         cpp.put_string("break;%N");
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
      local
         i: INTEGER
      do
         if 
            values /= Void
               and then
            v >= values.item(values.lower)
               and then
            v <= values.item(values.upper)
         then
            from
               i := values.lower
            until
               Result or else i > values.upper
            loop
               Result := values.item(i) <= v and v <= values.item(i+1)
               i := i + 2
            end
         end
      end;

   includes_integer_between(l,u: INTEGER): BOOLEAN is
      require
         invalid_range: l < u
      local
         i: INTEGER
      do
         if 
            values /= Void
               and then
            u >= values.item(values.lower)
               and then
            l <= values.item(values.upper)
         then
            from
               i := values.lower
            until
               Result or else i > values.upper
            loop
               Result := values.item(i) <= u and l <= values.item(i+1)
               i := i + 2
            end
         end
      end;

   largest_range_of_values: INTEGER is
         -- The largest number of consecutive values - returns 0 if none
      local
         i, range: INTEGER
      do
         if values /= Void then
            from
               i := values.lower;
            until
               i > values.upper
            loop
               range := values.item(i+1) - values.item(i) + 1;
               if range > Result then
                  Result := range;
               end
               i := i + 2;
            end;
         end;
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
         i, v: INTEGER;
      do
         v := wi1.expression_value;
         if e_inspect.includes(v) then
            err_occ(v,wi1.start_position);
         elseif values = Void then
            !!values.make(501,502);
            values.put(v,values.lower);
            values.put(v,values.upper);
         else
            i := locate_in_values(v)
            if i = values.lower then  -- v is lower than lowest value
               if v = values.item(i) - 1 then  -- just change lower
                  values.put(v,i)
               else
                  values.resize(values.lower-2, values.upper);
                  values.put(v,values.lower);
                  values.put(v,values.lower+1);
               end
            elseif i > values.upper then  -- v is higher than highest value
               if v = values.item(i-1) + 1 then  -- just change upper
                  values.put(v,i-1)
               else
                  values.resize(values.lower, values.upper+2);
                  values.put(v,values.upper-1);
                  values.put(v,values.upper);
               end
            else
               if v = values.item(i-1) + 1 and v = values.item(i) - 1 then
                  values.put(values.item(i+1),i-1)
                  from until i > values.upper-2 loop
                     values.put(values.item(i+2),i)
                     values.put(values.item(i+3),i+1)
                     i := i + 2
                  end
                  values.resize(values.lower, values.upper-2)
               elseif v = values.item(i-1) + 1 then  -- just change upper
                  values.put(v,i-1)
               elseif v = values.item(i) - 1 then  -- just change lower
                  values.put(v,i)
               else
                  values.resize(values.lower, values.upper+2)
                  from
                     i := values.upper - 1
                  until
                     v > values.item(i-1)
                  loop
                     values.put(values.item(i-2),i)
                     values.put(values.item(i-1),i+1)
                     i := i - 2
                  end
                  values.put(v,i)
                  values.put(v,i+1)
               end
            end
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
         elseif e_inspect.includes_between(l,u) then
            from 
               i := l
            until
               e_inspect.includes(i)  -- try to locate the exact problem
            loop
                if i = l then
                   l := l + 1
                   i := u
                else
                   u := u - 1
                   i := l
                end
            end
            err_occ(i,wi2.start_position);
         elseif values = Void then
            !!values.make(501,502);
            values.put(l,values.lower);
            values.put(u,values.upper);
         else
            i := locate_in_values(l)
            if i = values.lower then  -- l and u are lower than lowest value
               if u = values.item(i) - 1 then  -- just change lower
                  values.put(l,i)
               else
                  values.resize(values.lower-2, values.upper);
                  values.put(l,values.lower);
                  values.put(u,values.lower+1);
               end
            elseif i > values.upper then  -- l and u are higher than highest
               if l = values.item(i-1) + 1 then  -- just change upper
                  values.put(u,i-1)
               else
                  values.resize(values.lower, values.upper+2);
                  values.put(l,values.upper-1);
                  values.put(u,values.upper);
               end
            else
               if l = values.item(i-1) + 1 and u = values.item(i) - 1 then
                  values.put(values.item(i+1),i-1)
                  from until i > values.upper-2 loop
                     values.put(values.item(i+2),i)
                     values.put(values.item(i+3),i+1)
                     i := i + 2
                  end
                  values.resize(values.lower, values.upper-2)
               elseif l = values.item(i-1) + 1 then  -- just change upper
                  values.put(u,i-1)
               elseif u = values.item(i) - 1 then  -- just change lower
                  values.put(l,i)
               else
                  values.resize(values.lower, values.upper+2)
                  from
                     i := values.upper - 1
                  until
                     l > values.item(i-1)
                  loop
                     values.put(values.item(i-2),i)
                     values.put(values.item(i-1),i+1)
                     i := i - 2
                  end
                  values.put(l,i)
                  values.put(u,i+1)
               end
            end
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

   locate_in_values(v: INTEGER): INTEGER is
        -- returns index in values table where v would be inserted
      require
         values /= Void
      do
         from
            Result := values.lower
         until
            Result > values.upper
               or else
            v < values.item(Result)
         loop
            Result := Result + 2
         end
      ensure
         (Result - values.lower) \\ 2 = 0
         Result < values.upper implies v < values.item(Result)
         Result > values.upper implies v > values.item(Result-1)
      end

feature {NONE}

   em1: STRING is "Bad when clause.";
   em2: STRING is "Empty when clause in inspect.";

end -- E_WHEN


