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
class PARENT
   --
   -- To store the inheritance options for one parent of a class.
   --

inherit GLOBALS;

creation make

feature

   type: TYPE;
         -- Declaration type mark of the parent.

   base_class: BASE_CLASS;
	 -- An alias for `type.base_class'.

   base_class_name: STRING;
	 -- An alias for `base_class.name.to_string'.

feature {PARENT}

   parent_list: PARENT_LIST;
         -- The corresponding one;

feature {PARENT} -- Optionnal list in syntaxical order:

   rename_list: RENAME_LIST;

   export_list: EXPORT_LIST;

   undefine_list: FEATURE_NAME_LIST

   redefine_list: FEATURE_NAME_LIST;

   select_list: FEATURE_NAME_LIST;

feature {PARENT_LIST}

   start_position: POSITION is
      do
         Result := type.start_position;
      end;

   id_extra_information(sfw: STD_FILE_WRITE) is
      do
         sfw.put_integer(base_class.id);
      end;

   name_in_parent(fn: FEATURE_NAME): FEATURE_NAME is
         -- Gives Void or the name of `fn' before renaming.
      require
         fn /= Void
      do
         if rename_list = Void then
            Result := fn;
         else
            Result := rename_list.name_in_parent(fn);
         end;
      end;

   do_rename(fn: FEATURE_NAME): like fn is
         -- If some rename exists for `fn', return the new name.
         -- Otherwise, give back `fn'.
      require
         fn /= Void
      do
         if rename_list = Void then
            Result := fn;
         else
            Result := rename_list.name_in_child(fn);
            if Result = Void then
               Result := fn;
            end;
         end;
      ensure
         Result /= Void
      end;

   has_redefine(fn: FEATURE_NAME): BOOLEAN is
      require
         fn /= Void
      do
         if redefine_list /= Void then
            Result := redefine_list.has(fn);
         end;
      end;

   look_up_for(rc: RUN_CLASS; fn: FEATURE_NAME): E_FEATURE is
      require
         rc /= Void;
         fn /= Void
      local
         pfn: like fn;
      do
         if rename_list = Void then
            Result := base_class.look_up_for(rc,fn);
            Result := apply_undefine(Result,fn);
         else
            pfn := rename_list.name_in_parent(fn);
            if pfn /= Void then
               Result := base_class.look_up_for(rc,pfn);
               Result := apply_undefine(Result,fn);
            end;
         end;
      end;

   precursor_for(pc: PRECURSOR_CALL; wrf: RUN_FEATURE): EFFECTIVE_ROUTINE is
         -- Look for the feature for `pc' which is written inside `wrf'.
      local
         original_fn: FEATURE_NAME;
         cn: CLASS_NAME;
         f: E_FEATURE;
	 er: EXTERNAL_ROUTINE;
      do
         original_fn := wrf.base_feature.first_name;
         if has_redefine(original_fn) then
            cn := pc.parent;
            if cn = Void or else cn.to_string = base_class_name then
               f := look_up_for(wrf.run_class,original_fn);
               Result ?= f;
               if f /= Void and then Result = Void then
                  eh.add_position(pc.start_position);
                  eh.add_position(f.start_position);
		  er ?= f;
		  if er /= Void then
		     fatal_error("Precursor construct not implemented for %
				 %external features (sorry).");
		  end;
                  fatal_error("The Precursor is not an effective routine.");
               end;
            end;
         end;
      end;

   multiple_check(other: like Current) is
         -- Note : is called twice in order to swap each couple of parents.
      require
         other /= Current
      local
         bc1, bc2: BASE_CLASS;
         i: INTEGER;
         fn1, fn2: FEATURE_NAME;
      do
         check
            parent_list = other.parent_list
         end;
         bc1 := base_class;
         bc2 := other.base_class;
         if bc1 = bc2 or else
            bc1.is_subclass_of(bc2) or else
            bc2.is_subclass_of(bc1)
          then
            if redefine_list /= Void then
               from
                  i := redefine_list.count
               until
                  i = 0
               loop
                  fn1 := redefine_list.item(i);
                  if other.rename_list = Void then
                  else
                     fn2 := other.rename_list.name_in_child(fn1);
                     if fn2 /= fn1 then
                        if select_list /= Void then
                           if select_list.has(fn1) then
                              if other.select_list /= Void then
                                 if other.select_list.has(fn2) then
                                    select_conflict(fn1,fn2);
                                 end;
                              end;
                           elseif other.select_list = Void then
                              missing_select(fn1,fn2);
                           elseif not other.select_list.has(fn2) then
                              missing_select(fn1,fn2);
                           end;
                        elseif other.select_list = Void then
                           missing_select(fn1,fn2);
                        elseif not other.select_list.has(fn2) then
                           missing_select(fn1,fn2);
                        end;
                     end;
                  end;
                  i := i - 1;
               end;
            end;
         else
            -- Nothing because of swapped duplicate call.
         end;
      end;

   runnable_type(ct: TYPE): TYPE is
      require
         ct.is_run_type
      do
         if type.is_generic then
            Result := type.to_runnable(ct);
         else
            Result := type;
         end;
      ensure
         Result.is_run_type
      end;

   is_a_vncg(t1, t2: TYPE): BOOLEAN is
      require
         t1.run_type = t1;
         t2.run_type = t2;
         t2.generic_list /= Void;
         eh.is_empty
      local
         rank, i: INTEGER;
         gl, gl1, gl2: ARRAY[TYPE];
         tfg: TYPE_FORMAL_GENERIC;
         rt: TYPE;
         t2_bc: BASE_CLASS;
         t2_bcn: STRING;
      do
	 t2_bc := t2.base_class;
         t2_bcn := t2_bc.name.to_string;
         if base_class_name = t2_bcn then -- Here is a good parent :
            gl := type.generic_list;
            gl2 := t2.generic_list;
            if gl = Void or else gl.count /= gl2.count then
               eh.add_position(start_position);
               eh.add_position(t2.start_position);
               fatal_error("Bad number of generic arguments.");
            end;
            if t1.is_generic then
               gl1 := t1.generic_list;
               from
                  Result := true;
                  i := gl2.count;
               until
                  not Result or else i = 0
               loop
                  if gl.item(i).is_formal_generic then
                     tfg ?= gl.item(i);
                     rank := tfg.rank;
                     Result :=  gl1.item(rank).is_a(gl2.item(i));
                  else
                     rt := gl.item(i).to_runnable(t1).run_type;
                     Result := rt.is_a(gl2.item(i));
                  end;
                  i := i - 1;
               end;
            elseif type.is_run_type then
               Result := type.is_a(t2);
            else
	       -- Don't know exactely what to do here :(
	       eh.add_position(start_position);
	       eh.append(
                  "SmallEiffel is not yet able to handle this parent type %
		  %mark (probably because of constrained genericity). You %
		  %should try to inherit something else, more accurate for %
		  %the compiler. Sorry.");
	       eh.print_as_fatal_error;
            end;
            if not Result then
               eh.cancel;
            end;
         elseif base_class.is_subclass_of(t2_bc) then
            if t1.is_generic then
               rt := type.to_runnable(t1).run_type;
               Result := base_class.is_a_vncg(rt,t2);
            else
               Result := base_class.is_a_vncg(type,t2);
            end;
            if not Result then
               eh.cancel;
            end;
         end;
      ensure
         eh.is_empty
      end;

   e_feature(fn: FEATURE_NAME): E_FEATURE is
      local
         fn2: FEATURE_NAME;
      do
         if rename_list = Void then
            Result := base_class.e_feature(fn);
         else
            fn2 := rename_list.name_in_parent(fn);
            if fn2 /= Void then
               Result := base_class.e_feature(fn2);
            end;
         end;
      end;

   clients_for(fn: FEATURE_NAME): CLIENT_LIST is
      require
         fn /= Void
      local
         fn2: like fn;
      do
         if rename_list = Void then
            Result := consider_export(fn);
         else
            fn2 := rename_list.name_in_parent(fn);
            if fn2 /= Void then
               Result := consider_export(fn2);
            end;
         end;
      end;

   pretty_print is
      local
         end_needed: BOOLEAN;
      do
         fmt.set_indent_level(1);
         fmt.indent;
         type.pretty_print;
         if rename_list = Void and then
            export_list = Void and then
            undefine_list = Void and then
            redefine_list = Void and then
            select_list = Void then
            fmt.put_character(';');
         end;
         if comment /= Void then
            fmt.put_character(' ');
            comment.pretty_print;
         end;
         if rename_list /= Void then
            end_needed := true;
            rename_list.pretty_print;
         end;
         if export_list /= Void then
            end_needed := true;
            export_list.pretty_print;
         end;
         if undefine_list /= Void then
            end_needed := true;
            fmt.set_indent_level(2);
            fmt.indent;
            fmt.keyword("undefine");
            undefine_list.pretty_print;
         end;
         if redefine_list /= Void then
            end_needed := true;
            fmt.set_indent_level(2);
            fmt.indent;
            fmt.keyword("redefine");
            redefine_list.pretty_print;
         end;
         if select_list /= Void then
            end_needed := true;
            fmt.set_indent_level(2);
            fmt.indent;
            fmt.keyword("select");
            select_list.pretty_print;
         end;
         if end_needed then
            fmt.set_indent_level(2);
            fmt.indent;
            fmt.keyword("end;");
         end;
         fmt.set_indent_level(1);
         fmt.indent;
      end;

   get_started(pl: like parent_list) is
      require
         pl /= Void;
      local
         i: INTEGER;
         wbc: BASE_CLASS;
         fn, old_fn, new_fn: FEATURE_NAME;
         all_check: BOOLEAN;
      do
         all_check := run_control.all_check;
         parent_list := pl;
         base_class := type.base_class;
	 base_class_name := base_class.name.to_string;
         wbc := parent_list.base_class;
         if all_check then
            if base_class.formal_generic_list /= Void then
               if type.generic_list = Void then
                  -- Nothing, because previous call triggers an error message.
               end;
            elseif type.is_generic then
               eh.add_position(base_class.name.start_position);
               eh.add_position(start_position);
               fatal_error("This class is not generic (VTUG.1).");
            end;
         end;
         if all_check and then rename_list /= Void then
            rename_list.get_started(base_class);
         end;
         if all_check and then undefine_list /= Void then
            from
               i := undefine_list.count;
            until
               i = 0
            loop
               fn := undefine_list.item(i);
               old_fn := get_old_name(fn);
               if old_fn = Void and then not base_class.has(fn) then
                  eh.add_position(fn.start_position);
                  fatal_error("Cannot undefine non-existent feature (VDUS.1).");
               end;
               i := i - 1;
            end;
         end;
         if redefine_list /= Void then
            from
               i := redefine_list.count;
            until
               i = 0
            loop
               fn := redefine_list.item(i);
               if not wbc.proper_has(fn) then
                  eh.add_position(fn.start_position);
                  fatal_error("Redefinition not found.");
               end;
               if all_check then
                  old_fn := get_old_name(fn);
                  if old_fn = Void and then not base_class.has(fn) then
                     eh.add_position(fn.start_position);
                     fatal_error(Vdrs1);
                  end;
                  new_fn := get_new_name(fn);
                  if new_fn /= Void then
                     eh.add_position(new_fn.start_position);
                     eh.add_position(fn.start_position);
                     fatal_error(Vdrs1);
                  end;
               end;
               i := i - 1;
            end;
         end;
         if all_check and then select_list /= Void then
            from
               i := select_list.count;
            until
               i = 0
            loop
               fn := select_list.item(i);
               old_fn := get_old_name(fn);
               if old_fn = Void and then not base_class.has(fn) then
                  eh.add_position(fn.start_position);
                  fatal_error(Vmss);
               end;
               new_fn := get_new_name(fn);
               if new_fn /= Void then
                  if get_old_name(new_fn) = Void then
                     eh.add_position(new_fn.start_position);
                     eh.add_position(fn.start_position);
                     fatal_error(Vmss);
                  end;
               end;
               i := i - 1;
            end;
         end;
      ensure
         parent_list = pl
      end;

   up_to_original(bottom: BASE_CLASS; top_fn: FEATURE_NAME): FEATURE_NAME is
      local
         old_name: FEATURE_NAME;
         bc: BASE_CLASS;
      do
         bc := base_class;
         if rename_list = Void then
            Result := bc.up_to_original(bottom,top_fn);
         else
            old_name := rename_list.name_in_parent(top_fn);
            if old_name /= Void then
               Result := bc.up_to_original(bottom,old_name);
            end;
         end;
      end;

   original_name(top: BASE_CLASS; bottom_fn: FEATURE_NAME): FEATURE_NAME is
      require
         top /= Void;
         bottom_fn /= Void
      local
         old_name: FEATURE_NAME;
         bc: BASE_CLASS;
      do
         bc := base_class;
         if bc = top or else bc.is_subclass_of(top) then
            if rename_list = Void then
               Result := bc.original_name(top,bottom_fn);
            else
               old_name := rename_list.name_in_parent(bottom_fn);
               if old_name /= Void then
                  Result := bc.original_name(top,old_name);
               end;
            end;
         end;
      end;

   going_up(trace: FIXED_ARRAY[PARENT]; top: BASE_CLASS;
            top_fn: FEATURE_NAME;): FEATURE_NAME is
      local
         bc: like base_class;
      do
         bc := base_class;
         if bc = top then
            Result := going_down(trace,top_fn);
         elseif base_class_name = as_general then
            Result := going_down(trace,top_fn);
         elseif bc.is_subclass_of(top) then
            trace.add_last(Current);
            Result := bc.going_up(trace,top,top_fn);
         end;
      end;

   has_select_for(fn: FEATURE_NAME): BOOLEAN is
      require
         fn /= Void
      do
         if select_list /= Void then
            Result := select_list.has(fn);
         end;
      end;

feature {EIFFEL_PARSER}

   set_comment(c: like comment) is
      do
         comment := c;
      end;

   add_rename(rp: RENAME_PAIR) is
      require
         rp /= Void
      do
         if rename_list = Void then
            !!rename_list.make(rp);
         else
            rename_list.add_last(rp);
         end;
      end;

   set_export(el: EXPORT_LIST) is
      require
         el /= Void
      do
         export_list := el;
      ensure
         export_list = el
      end;

   set_undefine(ul: FEATURE_NAME_LIST) is
      do
         undefine_list := ul;
      ensure
         undefine_list = ul
      end;

   set_redefine(rl: FEATURE_NAME_LIST) is
      do
         redefine_list := rl;
      ensure
         redefine_list = rl
      end;

   set_select(sl: like select_list) is
      do
         select_list := sl;
      ensure
         select_list = sl
      end;

feature {PARENT}

   going_down(trace: FIXED_ARRAY[PARENT]; fn: FEATURE_NAME;): FEATURE_NAME is
      require
         trace /= Void;
         fn /= Void
      local
         previous: like Current;
      do
         if rename_list = Void then
            Result := fn;
         else
            Result := rename_list.name_in_child(fn);
         end;
         if not trace.is_empty then
            previous := trace.last;
            trace.remove_last;
            Result := previous.going_down(trace,Result);
         end;
      ensure
         Result /= Void
      end;

feature {NONE}

   comment: COMMENT;
         -- Associated heading comment.
   
   make(t: like type) is
      require
         not t.is_anchored;
         not t.start_position.is_unknown
      do
         type := t;
         if forbidden_parent_list.fast_has(type.written_mark) then
            eh.add_position(start_position);
            eh.append("You cannot inherit %"");
            eh.append(type.written_mark);
            fatal_error("%" (not yet implemented).");
         end;
      ensure
         type = t
      end;

   forbidden_parent_list: ARRAY[STRING] is
      once
         Result := <<as_none,as_boolean,as_integer,as_character,
                     as_real,as_double,as_bit,as_pointer,
                     as_native_array>>;
      end;

   get_old_name(fn: FEATURE_NAME): like fn is
      do
         if rename_list /= Void then
            Result := rename_list.name_in_parent(fn);
            if Result = fn then
               Result := Void;
            end;
         end;
      end;

   get_new_name(fn: FEATURE_NAME): like fn is
      do
         if rename_list /= Void then
            Result := rename_list.name_in_child(fn);
            if Result = fn then
               Result := Void;
            end;
         end;
      end;

   apply_undefine(f: E_FEATURE; fn: FEATURE_NAME): E_FEATURE is
      local
         ufn: FEATURE_NAME;
         fnkey: STRING;
         index: INTEGER;
      do
         ufn := has_undefine(fn);
         if ufn /= Void then
            if undefine_memory1 = Void then
               !!undefine_memory1.with_capacity(undefine_list.count);
               !!undefine_memory2.with_capacity(undefine_list.count);
            end;
            fnkey := ufn.to_key;
            index := undefine_memory1.fast_index_of(fnkey);
            if index > undefine_memory1.upper then
               undefine_memory1.add_last(fnkey);
               Result := f.try_to_undefine(ufn,parent_list.base_class);
               undefine_memory2.add_last(Result);
            else
               Result := undefine_memory2.item(index);
            end;
         else
            Result := f;
         end;
      end;

   undefine_memory1: FIXED_ARRAY[STRING];

   undefine_memory2: FIXED_ARRAY[E_FEATURE];

   has_undefine(fn: FEATURE_NAME): FEATURE_NAME is
      do
         if undefine_list /= Void then
            Result := undefine_list.feature_name(fn.to_key);
         end;
      end;

   select_conflict(fn1, fn2: FEATURE_NAME) is
      do
         eh.add_position(fn1.start_position)
         eh.add_position(fn2.start_position)
         fatal_error("Select conflict for these features.");
      end;

   missing_select(fn1, fn2: FEATURE_NAME) is
      do
         eh.add_position(fn1.start_position)
         eh.add_position(fn2.start_position)
         fatal_error("Missing select clause for these features.");
      end;

   Vmss: STRING is "Cannot select non-existent feature (VMSS).";

   Vdrs1: STRING is "Cannot redefine non-existent feature (VDRS.1).";

   consider_export(fn: FEATURE_NAME): CLIENT_LIST is
      require
         fn /= Void
      do
         if export_list = Void then
            Result := base_class.clients_for(fn);
         else
            Result := export_list.clients_for(fn);
            if Result = Void then
               Result := base_class.clients_for(fn);
            end;
         end;
      end;

invariant

   not type.is_anchored;

   not start_position.is_unknown;

end -- PARENT
