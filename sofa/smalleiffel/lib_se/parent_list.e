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
class PARENT_LIST
   --
   -- To store the parent list of a class.
   --

inherit GLOBALS;

creation make

feature

   base_class: BASE_CLASS;
         -- Where the parent list is written.

   start_position: POSITION;
         -- Of the keyword "inherit".

   heading_comment: COMMENT;
         -- Global comment of the inherit clause.

   count: INTEGER is
      do
         Result := list.count;
      end;

   up_to_any_in(pl: FIXED_ARRAY[BASE_CLASS]) is
      local
         i: INTEGER;
         p: PARENT;
         bc: BASE_CLASS;
      do
         from
            i := list.upper;
         until
            i < list.lower
         loop
            p := list.item(i);
            bc := p.base_class;
            if not pl.fast_has(bc) then
               pl.add_last(bc);
            end;
            i := i - 1;
         end;
         from
            i := list.upper;
         until
            i < list.lower
         loop
            p := list.item(i);
            bc := p.base_class;
            if bc /= class_any then
               bc.up_to_any_in(pl);
            end;
            i := i - 1;
         end;
      end;

   base_class_name: CLASS_NAME is
      do
         Result := base_class.name;
      end;

   has_redefine(fn: FEATURE_NAME): BOOLEAN is
      require
         fn /= Void
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            Result or else i < list.lower
         loop
            Result := list.item(i).has_redefine(fn);
            i := i - 1;
         end;
      end;

feature {BASE_CLASS}

   id_extra_information(sfw: STD_FILE_WRITE) is
      local
         i: INTEGER;
      do
         sfw.put_integer(count);
         sfw.put_string(" parents: ");
         from
            i := list.lower;
         until
            i > list.upper
         loop
            list.item(i).id_extra_information(sfw);
            sfw.put_character(' ');
            i := i + 1;
         end;
      end;

   up_to_original(bottom: BASE_CLASS; top_fn: FEATURE_NAME): FEATURE_NAME is
      local
         p1, p2: PARENT;
         fn1, fn2, new_fn: FEATURE_NAME;
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i < list.lower or else fn1 /= Void
         loop
            p1 := list.item(i);
            fn1 := p1.up_to_original(bottom,top_fn);
            i := i - 1;
         end;
         from
         until
            i < list.lower
         loop
            p2 := list.item(i);
            fn2 := p2.up_to_original(bottom,top_fn);
            if fn2 /= Void then
               new_fn := p2.do_rename(top_fn);
               if p2.has_select_for(new_fn) then
                  p1 := p2;
                  fn1 := fn2;
               end;
            end;
            i := i - 1;
         end;
         if fn1 /= Void then
            if fn1.to_string /= top_fn.to_string then
               Result := repeated_inheritance(p1,fn1,top_fn);
            else
               Result := fn1;
            end;
         end;
      end;

   original_name(top: BASE_CLASS; bottom_fn: FEATURE_NAME): FEATURE_NAME is
      require
         top /= Void;
         bottom_fn /= Void
      local
         p1: PARENT;
         fn1: FEATURE_NAME;
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i < list.lower or else fn1 /= Void
         loop
            p1 := list.item(i);
            fn1 := p1.original_name(top,bottom_fn);
            i := i - 1;
         end;
         Result := fn1;
         if Result = Void then
            Result := bottom_fn;
            eh.add_position(bottom_fn.start_position);
            eh.append(top.name.to_string);
            eh.append(". PARENT_LIST.original_name, Not Yet Implemented.");
            eh.print_as_warning;
         end;
      end;

   clients_for(fn: FEATURE_NAME): CLIENT_LIST is
      require
         fn /= Void
      local
         i: INTEGER;
         cl: CLIENT_LIST;
      do
         from
            i := list.upper;
         until
            i < list.lower
         loop
            cl := list.item(i).clients_for(fn);
            if Result = Void then
               Result := cl;
            elseif cl /= Void then
               Result := Result.append(cl);
            end;
            if Result = Void then
               i := i - 1;
            elseif Result.gives_permission_to_any then
               i := list.lower - 1;
            else
               eh.cancel;
               i := i - 1;
            end;
         end;
      end;

   going_up(trace: FIXED_ARRAY[PARENT]; top: BASE_CLASS;
            top_fn: FEATURE_NAME;): FEATURE_NAME is
      require
         top /= Void;
         top_fn /= Void
      local
         i: INTEGER;
         p1, p2: PARENT;
         fn1, fn2: FEATURE_NAME;
      do
         from
            i := list.upper;
         until
            fn1 /= Void or else i < list.lower
         loop
            p1 := list.item(i);
            fn1 := p1.going_up(trace,top,top_fn);
            i := i - 1;
         end;
         from
         until
            i < list.lower
         loop
            p2 := list.item(i);
            fn2 := p2.going_up(trace,top,top_fn);
            if fn2 /= Void then
               if p2.has_select_for(fn2) then
                  p1 := p2;
                  fn1 := fn2;
               end;
            end;
            i := i - 1;
         end;
         Result := fn1;
      end;

   is_a_vncg(t1, t2: TYPE): BOOLEAN is
      require
         t1.run_type = t1;
         t2.run_type = t2;
         t2.generic_list /= Void;
         eh.is_empty
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            Result or else i < list.lower
         loop
            Result := list.item(i).is_a_vncg(t1,t2);
            i := i - 1;
         end;
      ensure
         eh.is_empty
      end;

   e_feature(fn: FEATURE_NAME): E_FEATURE is
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            Result /= Void or else i < list.lower
         loop
            Result := list.item(i).e_feature(fn);
            i := i - 1;
         end;
      end;

   collect_invariant(rc: RUN_CLASS) is
      require
         rc /= Void
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i < list.lower
         loop
            list.item(i).base_class.collect_invariant(rc);
            i := i - 1;
         end;
      end;

   inherit_cycle_check is
      local
         i: INTEGER;
         p: PARENT;
         bc: BASE_CLASS;
      do
         from
            i := list.upper;
         until
            i < list.lower
         loop
            p := list.item(i);
            bc := p.type.base_class;
            if bc = Void then
               eh.add_position(p.start_position);
               fatal_error(fz_cnf);
            else
               bc.inherit_cycle_check;
            end;
            i := i - 1;
         end;
      end;

   has_parent(c: BASE_CLASS): BOOLEAN is
      require
         not c.is_any
      local
         i: INTEGER;
         bc: BASE_CLASS;
      do
         from
            i := list.upper;
         until
            Result or else i < list.lower
         loop
            bc := list.item(i).base_class;
            if c = bc then
               Result := true;
            elseif bc.is_subclass_of(c) then
               Result := true;
            else
               i := i - 1;
            end;
         end;
      end;

   first_parent_for(c: BASE_CLASS): PARENT is
         -- Gives the first parent going to `c'.
      local
         i: INTEGER;
         pbc: BASE_CLASS;
      do
         from
            i := list.lower;
         until
            Result /= Void
         loop
            Result := list.item(i);
            pbc := Result.base_class;
            if pbc = c then
            elseif pbc.is_subclass_of(c) then
            else
               Result := Void;
            end;
            i := i + 1;
         end;
      ensure
         Result /= Void
      end;

   next_parent_for(c: BASE_CLASS; previous: PARENT): like previous is
         -- Gives the next one or Void.
      local
         i: INTEGER;
         pbc: BASE_CLASS;
      do
         from
            from
               i := list.lower;
            until
               Result = previous
            loop
               Result := list.item(i);
               i := i + 1;
            end;
            Result := Void;
         until
            Result /= Void or else i > list.upper
         loop
            Result := list.item(i);
            pbc := Result.base_class;
            if pbc = c then
            elseif pbc.is_subclass_of(c) then
            else
               Result := Void;
            end;
            i := i + 1;
         end;
      end;

   header_comment_for(ci: CLASS_INVARIANT) is
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i < list.lower or else ci.header_comment /= Void
         loop
            list.item(i).base_class.header_comment_for(ci);
            i := i - 1;
         end;
      end;

   get_started is
      local
         i1, i2: INTEGER;
         p1, p2: PARENT;
      do
         from
            i1 := list.upper;
         until
            i1 < list.lower
         loop
            list.item(i1).get_started(Current);
            i1 := i1 - 1;
         end;
         if list.count > 1 then
            -- Checking select :
            from
               i2 := list.upper;
            until
               i2 = list.lower
            loop
               from
                  i1 := list.lower;
               invariant
                  i1 < i2 + 1
               variant
                  i2 - i1
               until
                  i1 = i2
               loop
                  p1 := list.item(i1);
                  p2 := list.item(i2);
                  p1.multiple_check(p2);
                  p2.multiple_check(p1);
                  i1 := i1 + 1;
               end;
               i2 := i2 - 1;
            end;
         end;
      end;

   look_up_for(rc: RUN_CLASS; fn: FEATURE_NAME): E_FEATURE is
      local
         i: INTEGER;
         p1, p2: PARENT;
         f1, f2: E_FEATURE;
      do
         from
            i := list.upper;
         until
            f1 /= Void or else i < list.lower
         loop
            p1 := list.item(i);
            f1 := p1.look_up_for(rc,fn);
            i := i - 1;
         end;
         from
         until
            i < list.lower
         loop
            p2 := list.item(i);
            f2 := p2.look_up_for(rc,fn);
            if f2 = Void then
            elseif f1 = f2 then
            elseif f2.is_not_mergeable_with(f1) then
               eh.add_position(start_position);
               eh.add_position(f1.start_position);
               eh.add_position(f2.start_position);
               eh.append(fz_ich);
               eh.print_as_fatal_error;
            elseif f2.is_deferred then
            elseif f1.is_deferred then
               f1 := f2;
               p1 := p2;
            elseif p1.has_redefine(fn) then
               if p2.has_redefine(fn) then
               else
                  eh.add_position(fn.start_position);
                  eh.add_position(p2.start_position);
                  eh.add_position(f2.start_position);
                  eh.append(em1);
                  eh.print_as_fatal_error;
               end;
            elseif p2.has_redefine(fn) then
               eh.add_position(fn.start_position);
               eh.add_position(p1.start_position);
               eh.add_position(f1.start_position);
               eh.append(em1);
               eh.print_as_fatal_error;
            else
               eh.add_position(p2.start_position);
               eh.add_position(p1.start_position);
               eh.add_position(f1.start_position);
               eh.add_position(f2.start_position);
               eh.append(em1);
               eh.print_as_fatal_error;
            end;
            i := i - 1;
         end;
         Result := f1;
      end;

   collect_assertion(fn: FEATURE_NAME) is
      require
         fn /= Void
      local
         i: INTEGER;
         p1, p2: PARENT;
         fn1, fn2: FEATURE_NAME;
      do
         from
            i := list.upper;
         until
            i < list.lower
         loop
            p2 := list.item(i);
            fn2 := p2.name_in_parent(fn);
            if fn2 /= Void and then p2.has_select_for(fn) then
               p1 := p2;
               fn1 := fn2;
            end;
            i := i - 1;
         end;
         if fn1 /= Void then
            p1.base_class.collect_assertion(fn1);
         else
            from
               i := list.upper;
            until
               i < list.lower
            loop
               p1 := list.item(i);
               fn1 := p1.name_in_parent(fn);
               if fn1 /= Void then
                  p1.base_class.collect_assertion(fn1);
               end;
               i := i - 1;
            end;
         end;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.set_indent_level(0);
         if fmt.zen_mode then
            fmt.indent;
         else
            fmt.skip(1);
         end;
         fmt.keyword("inherit");
         fmt.set_indent_level(1);
         fmt.indent;
         if heading_comment /= Void then
            heading_comment.pretty_print;
         end;
         from
            i := list.lower;
         until
            i > list.upper
         loop
            list.item(i).pretty_print;
            i := i + 1;
         end;
      end;

   smallest_ancestor(type, other: TYPE): TYPE is
      require
         type.base_class.parent_list = Current;
         other.base_class.parent_list /= Void;
         type.is_run_type;
         other.is_run_type
      local
         i: INTEGER; p: PARENT; sa: TYPE;
      do
         from
            i := list.upper;
         until
            i < list.lower
         loop
            p := list.item(i);
            sa := p.runnable_type(other);
	    if sa.run_time_mark = other.run_time_mark then
	       Result := sa;
	       i := list.lower - 1;
            elseif Result = Void then
	       Result := sa.smallest_ancestor(other);
            elseif sa.is_a(other) then
	       if Result.is_a(other) then
		  Result := sa.smallest_ancestor(Result);
	       else
		  eh.cancel;
		  Result := sa;
	       end;
	    else 
	       eh.cancel;
            end;
	    i := i - 1;
         end;
      ensure
         Result.is_run_type;
      end;

feature {PRECURSOR_CALL}

   precursor_for(pc: PRECURSOR_CALL; wrf: RUN_FEATURE): EFFECTIVE_ROUTINE is
         -- Look for the feature for `pc' which is written inside `wrf'.
      require
         pc /= Void;
         wrf /= Void
      local
         i: INTEGER;
         parent: PARENT;
         f2: like precursor_for;
      do
         from
            i := list.upper;
         until
            Result /= Void or else i < list.lower
         loop
            parent := list.item(i);
            Result := parent.precursor_for(pc,wrf);
            i := i - 1;
         end;
         if Result = Void then
            eh.add_position(pc.start_position);
            fatal_error("Precursor routine not found.");
         end;
         if run_control.all_check then
            from
            until
               i < list.lower
            loop
               parent := list.item(i);
               f2 := parent.precursor_for(pc,wrf);
               if f2 /= Void and then f2 /= Result then
                  eh.add_position(pc.start_position);
                  eh.add_position(Result.start_position);
                  eh.add_position(f2.start_position);
                  fatal_error("Multiple Precursor found (must use %
                              % { ... } selection.");
               end;
               i := i - 1;
            end;
         end;
      end;

feature {NONE}

   list: FIXED_ARRAY[PARENT];

   make(bc: like base_class; sp: like start_position;
        hc: like heading_comment; l: like list) is
      require
         bc /= Void;
         not sp.is_unknown;
         not l.is_empty
      do
         base_class := bc;
         heading_comment := hc;
         start_position := sp;
         list := l;
      ensure
         base_class = bc;
         start_position = sp;
         heading_comment = hc;
         list = l;
      end;

   repeated_inheritance(p1: PARENT; fn1, top_fn: FEATURE_NAME): FEATURE_NAME is
      require
         p1 /= void;
         fn1 /= Void;
         top_fn /= Void
      local
         i: INTEGER;
         p2: PARENT;
         bc1: BASE_CLASS;
      do
         from
            bc1 := p1.base_class;
            i := list.upper;
         until
            i < list.lower
         loop
            p2 := list.item(i);
            if p1 /= p2 then
               if bc1 = p2.base_class then
                  if p2.do_rename(fn1).to_string = top_fn.to_string then
                     Result := top_fn;
                  elseif p1.do_rename(fn1).to_string = top_fn.to_string then
                     Result := top_fn;
                  end;
               end;
            end;
            i := i - 1;
         end;
         if Result = Void then
            Result := fn1;
         end;
      ensure
         top_fn /= Void
      end;

   em1: STRING is "Inheritance clash.";

invariant

   base_class /= Void;

   not list.is_empty;

end -- PARENT_LIST

