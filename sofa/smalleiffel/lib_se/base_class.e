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
class BASE_CLASS
   --
   -- Internal representation of an Eiffel source base class.
   --

inherit GLOBALS;

creation {EIFFEL_PARSER, TYPE_NONE} make

feature

   id: INTEGER;
	 -- To produce compact C code.

   path: STRING;
	 -- Access to the corresponding file.

   index_list: INDEX_LIST;
	 -- For the indexing of the class.

   heading_comment1: COMMENT;
	 -- Comment before keyword `class'.

   is_deferred: BOOLEAN;
	 -- True if class itself is deferred or if at least one
	 -- feature is deferred;

   is_expanded: BOOLEAN;
	 -- True if class itself is expanded.

   name: CLASS_NAME;
	 -- The name of the class.

   formal_generic_list: FORMAL_GENERIC_LIST;
	 -- Formal generic args if any.

   heading_comment2: COMMENT;
	 -- Comment after class name.

   obsolete_type_string: MANIFEST_STRING;
	 -- To warn user if any.

      parent_list: PARENT_LIST;
      -- The contents of the inherit clause if any.

      creation_clause_list: CREATION_CLAUSE_LIST;
      -- Constructor list.

      feature_clause_list: FEATURE_CLAUSE_LIST;
      -- Features.

      class_invariant: CLASS_INVARIANT;
      -- If any, the class invariant.

      end_comment: COMMENT;
      -- Comment after end of class.

feature {NONE}

   feature_dictionary: DICTIONARY[E_FEATURE,STRING];
	 -- All features really defined in the current class.
	 -- Thus, it is the same features contained in
	 -- `feature_clause_list' (this dictionary speed up
	 -- feature look up).
	 -- To avoid clash between infix and prefix names,
	 -- access key IS NOT `to_string' but `to_key' of class
	 -- NAME.

   make(my_path, my_name: STRING; my_id: INTEGER) is
      require
	 my_path = string_aliaser.item(my_path);
	 my_name = string_aliaser.item(my_name);
	 my_name /= as_none implies my_id > 0
      do
	 path := my_path;
	 !!name.unknown_position(my_name);
	 id := my_id;
	 small_eiffel.add_base_class(Current);
	 !!isom.with_capacity(16);
	 !!feature_dictionary.make;
      end;

feature {TYPE_CLASS}

   smallest_ancestor(type, other: TYPE): TYPE is
	 -- To help implementation of TYPE.smallest_ancestor while one
	 -- have to consider parents.
	 -- Note that `type' is directly related to `Current'.
      require
	 type.is_run_type;
	 other.is_run_type;
	 type.base_class = Current;
	 not other.is_any;
	 not other.is_none;
	 other.base_class /= Void
      do
	 if is_any then
	    Result := type;
	 elseif type.run_time_mark = other.run_time_mark then
	    Result := type;
	 elseif parent_list = Void then
	    Result := type_any;
	 elseif other.base_class.parent_list = Void then
	    Result := type_any;
	 else
	    Result := parent_list.smallest_ancestor(type,other);
	 end;
      ensure
	 Result /= Void
      end;

feature {SHORT,PARENT_LIST}

   up_to_any_in(pl: FIXED_ARRAY[BASE_CLASS]) is
      do
	 if is_general then
	 else
	    if not pl.fast_has(Current) then
	       pl.add_last(Current);
	    end;
	    if parent_list = Void then
	       if not pl.fast_has(class_any) then
		  pl.add_last(class_any);
	       end;
	    else
	       parent_list.up_to_any_in(pl);
	    end;
	 end;
      end;

feature

   expanded_initializer(t: TYPE): RUN_FEATURE_3 is
      require
	 t.is_expanded
      do
	 if creation_clause_list /= Void then
	    Result := creation_clause_list.expanded_initializer(t);
	 end;
      end;

feature {RUN_CLASS}

   get_default_rescue(rc: RUN_CLASS; n: FEATURE_NAME): RUN_FEATURE_3 is
      local
	 general: BASE_CLASS;
	 p: PROCEDURE;
	 fn1, fn2: FEATURE_NAME;
      do
	 general := class_general;
	 if Current /= general then
	    p := general.general_default_rescue;
	    if p /= Void then
	       fn1 := p.first_name;
	       fn2 := new_name_of(general,fn1);
	       if fn2.to_string /= n.to_string then
		  p ?= look_up_for(rc,fn2);
		  if p /= Void then
		     Result := p.a_default_rescue(rc,fn2);
		  end;
	       end;
	    end;
	 end;
      end;

   check_expanded_with(t: TYPE) is
      require
	 t.is_expanded;
	 t.base_class = Current
      local
	 rf: RUN_FEATURE;
      do
	 if is_deferred then
	    eh.add_type(t,fz_is_invalid);
	    fatal_error(" A deferred class must not be expanded (VTEC.1).");
	 end;
	 if creation_clause_list /= Void then
	    creation_clause_list.check_expanded_with(t);
	 end;
	 rf := expanded_initializer(t);
      end;

feature {RUN_FEATURE,ONCE_ROUTINE_POOL}

   once_flag(mark: STRING): BOOLEAN is
	 -- Flag used to avoid double C definition of globals
	 -- C variables for once routines.
      require
	 mark = string_aliaser.item(mark);
	 small_eiffel.is_ready
      do
	 if once_mark_list = Void then
	    !!once_mark_list.with_capacity(4);
	    once_mark_list.add_last(mark);
	 elseif once_mark_list.fast_has(mark) then
	    Result := true;
	 else
	    once_mark_list.add_last(mark);
	 end;
      ensure
	 once_flag(mark)
      end;

feature {NONE}

   once_mark_list: FIXED_ARRAY[STRING];
	 -- When the tag is in the list, the corresponding routine
	 -- does not use Current and C code is already written.

feature {TYPE_FORMAL_GENERIC}

   first_parent_for(other: like Current): PARENT is
	 -- Assume `other' is a parent of Current, gives
	 -- the closest PARENT of Current going to `other'.
      require
	 is_subclass_of(other);
	 parent_list /= Void
      do
	 Result := parent_list.first_parent_for(other);
      ensure
	 Result /= Void
      end;

   next_parent_for(other: like Current; previous: PARENT): like previous is
	 -- Gives the next one or Void.
      require
	 is_subclass_of(other);
	 parent_list /= Void
      do
	 Result := parent_list.next_parent_for(other,previous);
      end;

feature

   new_name_of(top: BASE_CLASS; top_fn: FEATURE_NAME): FEATURE_NAME is
	 -- Assume, `top_fn' is a valid notation to denote a feature of `top'.
	 -- It computes the corresponding name (taking in account possible 
	 -- rename/select) to use this feature down in class hierarchy (in 
	 -- the Current base_class).
      require
	 Current = top or else Current.is_subclass_of(top);
	 top_fn /= Void
      do
	 if Current = top then
	    Result := top_fn;
	 else
	    Result := top.up_to_original(Current,top_fn);
	    if Result = Void then
	       eh.add_position(top_fn.start_position);
	       eh.append(fz_09);
	       eh.append(top_fn.to_string);
	       eh.append("%" from %"");
	       eh.append(top.name.to_string);
	       eh.append("%" not found in %"");
	       eh.append(name.to_string);
	       fatal_error("%".");
	    end;
	 end;
      ensure
	 Result /= Void
      end;

feature {BASE_CLASS,PARENT}

   up_to_original(bottom: BASE_CLASS; top_fn: FEATURE_NAME): FEATURE_NAME is
	 -- Assume `top_fn' is a valid name in `bottom'. Try to go up in the 
	 -- hierarchy to retrieve the original name of the feature.
      require
	 top_fn /= Void;
	 Current = bottom or else bottom.is_subclass_of(Current)
      do
	 if proper_has(top_fn) then
	    if parent_list = Void then
	       Result := bottom.new_name_of_original(Current,top_fn);
	    else
	       Result := parent_list.up_to_original(bottom,top_fn);
	       if Result = Void then
		  Result := bottom.new_name_of_original(Current,top_fn);
	       end;
	    end;
	 elseif parent_list /= Void then
	    Result := parent_list.up_to_original(bottom,top_fn);
	 elseif is_general then
	 else
	    Result := class_any.up_to_original(bottom,top_fn);
	 end;
      end;

feature {RUN_FEATURE_1,PARENT,BASE_CLASS}

   original_name(top: BASE_CLASS; bottom_fn: FEATURE_NAME): FEATURE_NAME is
	 -- Assume that `bottom_fn' is a valid name in `Current'. Compute the 
	 -- original definition name going up in the hierarchy to `top'.
      require
	 bottom_fn /= Void;
	 Current = top or else Current.is_subclass_of(top)
      do
	 if Current = top then
	    check proper_has(bottom_fn) end;
	    Result := bottom_fn;
	 elseif parent_list /= Void then
	    Result := parent_list.original_name(top,bottom_fn);
	 else
	    Result := top.original_name(top,bottom_fn);
	    if Result = Void then
	       Result := bottom_fn;
	       eh.add_position(bottom_fn.start_position);
	       eh.append(top.name.to_string);
	       eh.append("<---");
	       eh.append(name.to_string);
	       eh.append(". BASE_CLASS.original_name, Not Yet Implemented.");
	       eh.print_as_warning;
	    end;
	 end;
      ensure
	 Result /= Void
      end;

feature {BASE_CLASS}

   new_name_of_original(top: BASE_CLASS; top_fn: FEATURE_NAME): FEATURE_NAME is
	 -- Compute rename/select to go down in class hierarchy. In the very 
	 -- first call, `top_fn' is the name used in `top'.
      require
	 top_fn /= Void;
	 top.proper_has(top_fn);
	 Current = top or else Current.is_subclass_of(top)
      do
	 if Current = top then
	    Result := top_fn;
	 elseif is_general then
	    Result := top_fn;
	 else
	    if parent_list = Void then
	       Result := class_any.new_name_of(top,top_fn);
	    else
	       going_up_trace.clear;
	       Result := parent_list.going_up(going_up_trace,top,top_fn);
	    end;
	 end;
      ensure
	 Result /= Void
      end;

   general_default_rescue: PROCEDURE is
      do
	 if feature_dictionary.has(as_default_rescue) then
	    Result ?= feature_dictionary.at(as_default_rescue);
	 end;
      end;

feature {BASE_CLASS,PARENT_LIST,PARENT}

   going_up(trace: FIXED_ARRAY[PARENT]; top: BASE_CLASS;
	    top_fn: FEATURE_NAME;): FEATURE_NAME is
      require
	 Current /= top;
      do
	 if parent_list = Void then
	    Result := class_any.going_up(trace,top,top_fn);
	 else
	    Result := parent_list.going_up(trace,top,top_fn);
	 end;
      end;

feature {NONE}

   going_up_trace: FIXED_ARRAY[PARENT] is
      once
	 !!Result.with_capacity(8);
      end;

feature

   mapping_c_in(str: STRING) is
      do
	 str.extend('B');
	 str.extend('C');
	 id.append_in(str);
      end;

   mapping_c is
      local
	 s: STRING;
      do
	 s := "        ";
	 s.clear;
	 mapping_c_in(s);
	 cpp.put_string(s);
      end;

feature {EIFFEL_PARSER}

   add_index_clause(index_clause: INDEX_CLAUSE) is
      require
	 index_clause /= Void
      do
	 if index_list = Void then
	    !!index_list.make(index_clause);
	 else
	    index_list.add_last(index_clause);
	 end;
      end;

   add_creation_clause(cc: CREATION_CLAUSE) is
      require
	 cc /= Void
      do
	 if creation_clause_list = Void then
	    !!creation_clause_list.make(cc);
	 else
	    creation_clause_list.add_last(cc);
	 end;
      end;

   add_feature_clause(fc: FEATURE_CLAUSE) is
      require
	 fc /= Void
      do
	 if feature_clause_list = Void then
	    !!feature_clause_list.make(fc);
	 else
	    feature_clause_list.add_last(fc);
	 end;
      end;

   set_is_deferred is
      do
	 if is_expanded then
	    error_vtec1;
	 end;
	 is_deferred := true;
      end;

   set_is_expanded is
      do
	 if is_deferred then
	    error_vtec1;
	 end;
	 is_expanded := true;
      end;

   set_formal_generic_list(fgl: like formal_generic_list) is
      do
	 formal_generic_list := fgl;
      end;

   set_heading_comment1(hc: like heading_comment1) is
      do
	 heading_comment1 := hc;
      end;

   set_heading_comment2(hc: like heading_comment2) is
      do
	 heading_comment2 := hc;
      end;

   set_parent_list(sp: POSITION; c: COMMENT; l: ARRAY[PARENT]) is
      require
	 not sp.is_unknown;
	 c /= Void or else l /= Void;
	 l /= Void implies not l.is_empty;
      do
	 !!parent_list.make(Current,sp,c,l);
      end;

   set_end_comment(ec: like end_comment) is
      do
	 end_comment := ec;
      end;

   set_obsolete_type_string(ots: like obsolete_type_string) is
      do
	 obsolete_type_string := ots;
	 if obsolete_type_string /= Void then
	    if small_eiffel.short_flag then
	    elseif small_eiffel.pretty_flag then
	    else
	       eh.append("Class ");
	       eh.append(name.to_string);
	       eh.append(" is obsolete :%N");
	       eh.append(obsolete_type_string.to_string);
	       eh.add_position(name.start_position);
	       eh.print_as_warning;
	       end
	    end;
	 end;

	 set_invariant(sp: POSITION; hc: COMMENT; al: ARRAY[ASSERTION]) is
      do
	 if hc /= Void or else al /= Void then
	    !!class_invariant.make(sp,hc,al);
	 end;
      end;

   get_started is
      do
	 if feature_clause_list /= Void then
	    feature_clause_list.get_started(feature_dictionary);
	 end;
	 if parent_list /= Void then
	    parent_list.get_started;
	 end;
	 if end_comment /= Void then
	    end_comment.good_end(name);
	 end;
	 if parent_list /= Void then
	    visited.clear;
	    visited.add_last(Current);
	    parent_list.inherit_cycle_check;
	 end;
	 if run_control.all_check and then
	    is_deferred and then
	    creation_clause_list /= Void
	  then
	    eh.add_position(name.start_position);
	    warning(creation_clause_list.start_position,
		    "Deferred class should not have %
		    %creation clause (VGCP.1).");
	 end;
      end;

feature

   get_copy: E_FEATURE is
      do
	 Result := feature_dictionary.at(as_copy);
      ensure
	 Result /= Void
      end;

   clients_for(fn: FEATURE_NAME): CLIENT_LIST is
	 -- Looking up for the clients list when calling feature `fn' with 
	 -- some object from current class. Assume `fn' exists.
      do
	 if proper_has(fn) then
	    Result := feature_dictionary.at(fn.to_key).clients;
	 elseif is_general then
	 elseif parent_list = Void then
	    Result := class_any.clients_for(fn);
	 else
	    check
	       parent_list.count >= 1
	    end;
	    Result := parent_list.clients_for(fn);
	 end;
      ensure
	 -- *** ??? Result /= Void
      end;

   has_creation_clause: BOOLEAN is
      do
	 Result := creation_clause_list /= Void;
      end;

   has_creation(proc_name: FEATURE_NAME): BOOLEAN is
	 -- Is `proc_name' the name of a creation procedure ?
	 -- Also check that `proc_name' is written in an allowed
	 -- base class for creation.
      require
	 proc_name.origin_base_class /= Void
      local
	 cc: CREATION_CLAUSE;
	 bc: BASE_CLASS;
	 cn: CLASS_NAME;
      do
	 if creation_clause_list = Void then
	    eh.append(name.to_string);
	    eh.append(" has no creation clause.");
	    eh.add_position(proc_name.start_position);
	    eh.print_as_error;
	 else
	    cc := creation_clause_list.get_clause(proc_name);
	    if cc = Void then
	       eh.append(fz_09);
	       eh.append(proc_name.to_string);
	       eh.append("%" does not belong to a creation clause of ");
	       eh.append(name.to_string);
	       error(proc_name.start_position,fz_dot);
	    else
	       Result := true;
	       bc := proc_name.origin_base_class;
	       if bc /= Void then
		  cn := bc.name;
		  Result := cc.clients.gives_permission_to(cn);
	       end;
	    end;
	 end;
	 if not Result then
	    error(proc_name.start_position,"Creation Call not allowed.");
	 end;
      end;

feature {SMALL_EIFFEL,BASE_CLASS}

   root_procedure_name(procedure_name: STRING): SIMPLE_FEATURE_NAME is
	 -- Look for the root procedure to start execution here.
	 -- Check that `procedure_name' is really a creation procedure.
      require
	 not procedure_name.is_empty
      do
	 if creation_clause_list = Void then
	    eh.add_position(name.start_position);
	    fatal_error("Bad root class (this class has no creation clause).");
	 else
	    Result := creation_clause_list.root_procedure_name(procedure_name);
	    if Result = Void then
	       eh.add_position(name.start_position);
	       eh.append("Bad root procedure name (%"");
	       eh.append(procedure_name);
	       fatal_error("%" is not a creation procedure of this class).");
	    end;
	 end;
      ensure
	 Result /= Void
      end;

feature {SMALL_EIFFEL}

   root_procedure(procedure_name: SIMPLE_FEATURE_NAME): PROCEDURE is
	 -- Look for the root procedure to start execution here.
	 -- Do some checking on the root class (not deferred, not generic,
	 -- really has `procedure_name' as a creation procedure etc.).
	 -- Return Void and print errors if needed.
      require
	 procedure_name = root_procedure_name(procedure_name.to_string)
      local
	 rc: RUN_CLASS;
	 f: E_FEATURE;
      do
	 if is_generic then
	    eh.append(name.to_string);
	    eh.append(" cannot be a root class since it is a generic class.");
	    eh.print_as_fatal_error;
	 end;
	 if is_deferred then
	    eh.append(name.to_string);
	    eh.append(" cannot be a root class since it is a deferred class.");
	    eh.print_as_warning;
	 end;
	 rc := run_class;
	 rc.set_at_run_time;
	 f := look_up_for(rc,procedure_name);
	 if f = Void then
	    eh.add_position(procedure_name.start_position);
	    fatal_error("Root procedure not found.");
	 end;
	 Result ?= f;
	 if Result = Void then
	    eh.add_position(f.start_position);
	    fatal_error("Invalid Root (not a procedure).");
	 end;
      ensure
	 Result /= Void
      end;

   check_generic_formal_arguments is
      do
	 if formal_generic_list /= Void then
	    formal_generic_list.check_generic_formal_arguments;
	 end;
      end;

   id_extra_information(sfw: STD_FILE_WRITE) is
      do
	 sfw.put_string("class-name: ");
	 sfw.put_string(name.to_string);
	 sfw.put_string(" parent-count: ");
	 if parent_list /= Void then
	    parent_list.id_extra_information(sfw);
	 else
	    sfw.put_string("0 ");
	 end;
      end;

feature

   run_class: RUN_CLASS is
      require
	 not is_generic
      local
	 rcd: DICTIONARY[RUN_CLASS,STRING];
	 n: STRING;
	 type: TYPE_CLASS;
      do
	 n := name.to_string;
	 rcd := small_eiffel.run_class_dictionary;
	 if rcd.has(n) then
	    Result := rcd.at(n);
	 else
	    !!type.make(name);
	    Result := type.run_class;
	 end;
      end;

   current_type: TYPE is
      do
	 Result := run_class.current_type;
      end;

   is_generic: BOOLEAN is
	 -- When class is defined with generic arguments.
      do
	 Result := formal_generic_list /= Void;
      end;

   proper_has(fn: FEATURE_NAME): BOOLEAN is
	 -- True when `fn' is really written in current class.
      do
	 Result := feature_dictionary.has(fn.to_key);
      end;

   is_subclass_of(other: BASE_CLASS): BOOLEAN is
	 -- Is Current a subclass of `other' ?
      require
	 other /= Current
      do
	 if isom = Void then
	    -- Yes, it is the NONE class.
	    Result := true;
	 elseif isom.fast_has(other) then
	    Result := true;
	 elseif other.isom = Void then
	 else
	    if other.is_any then
	       Result := true;
	    else
	       visited.clear;
	       Result := is_subclass_of_aux(other);
	    end;
	    if Result then
	       isom.add_last(other);
	    end;
	 end;
      end;

feature {NONE}

   visited: FIXED_ARRAY[BASE_CLASS] is
	 -- List of all visited classes to detects loops during
	 -- `is_subclass_of' processing.
      once
	 !!Result.with_capacity(32);
      end;

feature {PARENT_LIST,BASE_CLASS}

   inherit_cycle_check is
      local
	 i: INTEGER;
      do
	 visited.add_last(Current);
	 if visited.first = Current then
	    eh.append("Cyclic inheritance graph : ");
	    from
	       i := 0;
	    until
	       i > visited.upper
	    loop
	       eh.append(visited.item(i).name.to_string);
	       if i < visited.upper then
		  eh.append(", ");
	       end;
	       i := i + 1;
	    end;
	    fatal_error(", ...");
	 elseif parent_list /= Void then
	    parent_list.inherit_cycle_check;
	 end;
      end;

   is_subclass_of_aux(c: BASE_CLASS): BOOLEAN is
      require
	 not c.is_any;
	 Current /= c
      do
	 if visited.fast_has(Current) then
	 else
	    visited.add_last(Current);
	    if parent_list /= Void then
	       Result := parent_list.has_parent(c);
	    elseif not visited.fast_has(class_any) then
	       Result := class_any.is_subclass_of_aux(c);
	    end;
	 end;
      end;

feature

   is_any: BOOLEAN is
      do
	 Result := as_any = name.to_string;
      end;

   is_general: BOOLEAN is
      do
	 Result := as_general = name.to_string;
      end;

   has_redefine(fn: FEATURE_NAME): BOOLEAN is
      require
	 fn /= Void
      do
	 if parent_list /= Void then
	    Result := parent_list.has_redefine(fn)
	 end;
      end;

   e_feature(fn: FEATURE_NAME): E_FEATURE is
	 -- Simple (and fast) look_up to see if `fn' exists here.
      local
	 key: STRING;
      do
	 key := fn.to_key;
	 if feature_dictionary.has(key) then
	    Result := feature_dictionary.at(key);
	 else
	    Result := super_e_feature(fn);
	 end;
      end;

   has(fn: FEATURE_NAME): BOOLEAN is
	 -- Simple (and fast) look_up to see if `fn' exists here.
      require
	 fn /= Void
      do
	 Result := e_feature(fn) /= Void;
      end;

feature {CALL_PROC_CALL}

   run_feature_for(rc: RUN_CLASS; target: EXPRESSION; 
		   fn: FEATURE_NAME; ct: TYPE): RUN_FEATURE is
	 -- Fetch the corresponding one in context `ct' (the type of Current).
	 -- Exporting rules are automatically checked and possible
	 -- rename are also done.
	 -- No return when an error occurs because `fatal_error' is called.
      require
	 target.result_type.base_class = Current
      local
	 top_bc: BASE_CLASS;
	 nfn: FEATURE_NAME;
	 constraint: TYPE;
	 type_formal_generic: TYPE_FORMAL_GENERIC;
	 bcn: CLASS_NAME;
      do
	 check  
	    fn.to_string /= as_eq;
	    fn.to_string /= as_neq;
	 end;
	 -- Check constrained genericity first :
	 type_formal_generic ?= target.result_type;
	 if type_formal_generic /= Void then
	    constraint := type_formal_generic.constraint;
	    if constraint = Void then
	    elseif not type_formal_generic.is_a(constraint) then
	       eh.print_as_error;
	       eh.add_position(fn.start_position);
	       fatal_error("Constraint genericity violation.");
	    end;
	 end;
	 -- Then, compute possible rename :
	 nfn := fn;
	 top_bc := target.static_result_base_class;
	 if top_bc /= Void then
	    if Current = top_bc or else is_subclass_of(top_bc) then
	       if top_bc.has(fn) then
		  nfn := new_name_of(top_bc,fn);
	       end;
	    end;
	 end;
	 -- Search for the feature :
	 Result := rc.get_feature(nfn);
	 if Result = Void then
	    eh.feature_not_found(fn);
	    eh.print_as_fatal_error;
	 end;
	 -- Check export rules :
	 if not target.is_current then
	    bcn := ct.base_class.name;
	    if not Result.is_exported_in(bcn) then
	       eh.add_position(Result.start_position);
	       eh.append(" Cannot use feature %"");
	       eh.append(fn.to_string);
	       error(fn.start_position,"%" here.");
	       eh.add_position(fn.start_position);
	       eh.append("Forbidden call when type of Current is ");
	       eh.append(ct.run_time_mark);
	       fatal_error(fz_dot);
	    end;
	 end;
	 -- Finally, check for obsolete usage :
	 Result.base_feature.check_obsolete(fn.start_position);
      ensure
	 Result /= Void
      end;

feature {LOCAL_ARGUMENT,RUN_CLASS}

   has_simple_feature_name(sfn: STRING): BOOLEAN is
	 -- Simple (and fast) look_up to see if one feature of name
	 -- `n' exists here.
      require
	 sfn = string_aliaser.item(sfn)
      local
	 unknown_position: POSITION;
      do
	 mem_fn.make(sfn,unknown_position);
	 Result := has(mem_fn);
      end;

feature

   look_up_for(rc: RUN_CLASS; fn: FEATURE_NAME): E_FEATURE is
	 -- Gives Void or the good one to compute the runnable
	 -- version of `fn' in `rc'.
	 -- All inheritance rules are checked.
      local
	 super: E_FEATURE;
	 fn_key: STRING;
	 cst_att: CST_ATT;
	 fnl: FEATURE_NAME_LIST;
	 super_fn: like fn;
	 i: INTEGER;
      do
	 fn_key := fn.to_key;
	 if feature_dictionary.has(fn_key) then
	    Result := feature_dictionary.at(fn_key);
	    super :=  super_look_up_for(rc,fn);
	    if super /= Void then
	       vdrd6(rc,super,Result);
	       cst_att ?= super;
	       if cst_att /= Void then
		  eh.add_position(super.start_position);
		  eh.add_position(Result.start_position);
		  fatal_error("Constant feature cannot be redefined.");
	       end;
	       from
		  fnl := super.names;
		  i := fnl.count;
	       until
		  i < 1
	       loop
		  super_fn := fnl.item(i)
		  if super_fn.is_frozen then
		     if super_fn.to_key = fn_key then
			eh.add_position(super_fn.start_position);
			eh.add_position(Result.start_position);
			fatal_error("Cannot redefine a frozen feature.");
		     end;
		  end;
		  i := i - 1;
	       end;
	       if not Result.can_hide(super,rc) then
		  eh.add_position(super.start_position);
		  eh.add_position(Result.start_position);
		  eh.append("Incompatible headings for redefinition.");
		  eh.print_as_warning;
	       end;
	       if super.is_deferred then
	       elseif has_redefine(fn) then
	       else
		  eh.add_position(Result.start_position);
		  eh.add_position(super.start_position);
		  eh.append("Invalid redefinition in ");
		  eh.append(name.to_string);
		  eh.append(". Missing redefine ?");
		  eh.print_as_error;
	       end;
	    end;
	 else
	    Result := super_look_up_for(rc,fn);
	 end;
      end;

feature {NONE}

   super_look_up_for(rc: RUN_CLASS; fn: FEATURE_NAME): E_FEATURE is
	 -- Same work as `look_up_for' but do not look in current
	 -- base class.
      require
	 rc /= Void;
	 fn /= Void;
      do
	 if parent_list = Void then
	    if is_general then
	       Result := Void;
	    else
	       Result := class_any.look_up_for(rc,fn);
	    end;
	 else
	    Result := parent_list.look_up_for(rc,fn);
	 end;
      end;

feature {RUN_CLASS,PARENT_LIST}

   collect_invariant(rc: RUN_CLASS) is
      require
	 rc /= Void
      do
	 if parent_list /= Void then
	    parent_list.collect_invariant(rc);
	 end;
	 if class_invariant /= Void then
	    assertion_collector.invariant_add_last(class_invariant);
	 end;
      end;

feature {CLASS_INVARIANT,PARENT_LIST}

   header_comment_for(ci: CLASS_INVARIANT) is
      local
	 ia: like class_invariant;
      do
	 ia := class_invariant;
	 if ia /= Void and then ia.header_comment /= Void then
	    ci.set_header_comment(ia.header_comment);
	 elseif parent_list /= Void then
	    parent_list.header_comment_for(ci);
	 end;
      end;

feature {RUN_FEATURE}

   run_require(rf: RUN_FEATURE): RUN_REQUIRE is
	 -- Collect all (inherited) require assertions for `rf'.
      require
	 rf.current_type.base_class = Current
      local
	 ct: TYPE;
      do
	 assertion_collector.require_start;
	 ct := rf.current_type;
	 collect_assertion(rf.name);
	 Result := assertion_collector.require_end(rf,ct);
      end;

   run_ensure(rf: RUN_FEATURE): E_ENSURE is
	 -- Collect all (inherited) ensure assertions for `rf'.
      require
	 rf.current_type.base_class = Current
      local
	 ct: TYPE;
      do
	 assertion_collector.ensure_start;
	 ct := rf.current_type;
	 collect_assertion(rf.name);
	 Result := assertion_collector.ensure_end(rf,ct);
      end;

feature {BASE_CLASS,PARENT_LIST}

   collect_assertion(fn: FEATURE_NAME) is
      require
	 fn /= Void
      local
	 fn_key: STRING;
      do
	 fn_key := fn.to_key;
	 if feature_dictionary.has(fn_key) then
	    assertion_collector.assertion_add_last(feature_dictionary.at(fn_key));
	 end;
	 if parent_list = Void then
	    if is_general then
	    else
	       class_any.collect_assertion(fn);
	    end;
	 else
	    parent_list.collect_assertion(fn);
	 end;
      end;

feature {NONE}

   mem_fn: SIMPLE_FEATURE_NAME is
	 -- Dummy once name to avoid memory leaks.
      local
	 unknown_position: POSITION;
      once
	 !!Result.make(as_malloc,unknown_position);
      end;

feature {BASE_CLASS}

   isom: FIXED_ARRAY[BASE_CLASS];
	 -- Memorize results to speed ud `is_subclass_of'.

   super_e_feature(fn: FEATURE_NAME): E_FEATURE is

      do
	 if parent_list = Void then
	    if is_general then
	    else
	       Result := class_any.e_feature(fn);
	    end;
	 else
	    Result := parent_list.e_feature(fn);
	 end;
      end;

feature

   pretty_print is
      do
	 fmt.set_indent_level(0);
	 if index_list /= Void then
	    index_list.pretty_print;
	    fmt.indent;
	 end;
	 if heading_comment1 /= Void then
	    heading_comment1.pretty_print;
	    fmt.indent;
	 end;
	 if is_deferred then
	    fmt.keyword("deferred");
	 elseif is_expanded then
	    fmt.keyword(fz_expanded);
	    end;
	    fmt.keyword("class");
	    name.pretty_print;
	    if is_generic then
	       formal_generic_list.pretty_print;
	    end;
	    fmt.indent;
	    if obsolete_type_string /= Void then
	       fmt.keyword("obsolete");
	       obsolete_type_string.pretty_print;
	    end;
	    fmt.indent;
	    if heading_comment2 /= Void then
	       heading_comment2.pretty_print;
	    end;
	    if parent_list /= Void then
	       parent_list.pretty_print;
	    end;
	    if creation_clause_list /= Void then
	       creation_clause_list.pretty_print;
	    end;
	    if feature_clause_list /= Void then
	       feature_clause_list.pretty_print;
	    end;
	    if class_invariant /= Void then
	       class_invariant.pretty_print;
	    end;
	    fmt.set_indent_level(0);
	    if fmt.zen_mode then
	       fmt.skip(0);
	    else
	       fmt.skip(1);
	    end;
	    fmt.keyword(fz_end);
	    if end_comment /= Void and then not end_comment.dummy then
	       end_comment.pretty_print;
	    elseif not fmt.zen_mode then
	       fmt.put_string("-- class ");
	       fmt.put_string(name.to_string);
	    end;
	    if fmt.column /= 1 then
	       fmt.put_character('%N');
	    end;
	 end;

feature {NONE}

   error_vtec1 is
      do
	 error(name.start_position,
	       "A class cannot be expanded and deferred (VTEC.1).");
      end;

feature {FEATURE_NAME,E_FEATURE}

   fatal_undefine(fn: FEATURE_NAME) is
      do
	 eh.append("Problem with undefine of %"");
	 eh.append(fn.to_string);
	 eh.append("%" in %"");
	 eh.append(name.to_string);
	 fatal_error("%".");
      end;

feature {TYPE,PARENT}

   is_a_vncg(t1, t2: TYPE): BOOLEAN is
	 -- Direct conformance VNCG
      require
	 t1.is_run_type;
	 t2.is_run_type;
	 t1.base_class = Current;
	 t2.generic_list /= Void;
	 eh.is_empty
      do
	 if parent_list /= Void then
	    Result := parent_list.is_a_vncg(t1.run_type,t2.run_type);
	 end;
      ensure
	 eh.is_empty
      end;

feature {NONE}

   vdrd6(rc: RUN_CLASS; super, redef: E_FEATURE) is
      require
	 super /= Void;
	 redef /= Void;
	 super /= redef
      local
	 writable_attribute: WRITABLE_ATTRIBUTE;
	 ct, rt1, rt2: TYPE;
      do
	 writable_attribute ?= super;
	 if writable_attribute /= Void then
	    writable_attribute ?= redef;
	    if writable_attribute = Void then
	       fatal_error_vdrd6(super,redef,
				 "An attribute must be redefined as an attribute %
				 %only (VDRD.6).");
	    else
	       ct := rc.current_type;
	       rt1 := super.result_type.to_runnable(ct);
	       rt2 := redef.result_type.to_runnable(ct);
	       if rt1.is_reference then
		  if rt2.is_reference then
		  else
		     fatal_error_vdrd6(super,redef,vdrd6_types);
		  end;
	       elseif rt2.is_reference then
		  fatal_error_vdrd6(super,redef,vdrd6_types);
	       end;
	    end;
	 end;
      end;

   vdrd6_types: STRING is "Result types must be both expanded or %
   %both non-expanded (VDRD.6)."

   fatal_error_vdrd6(super, redef: E_FEATURE; msg: STRING) is
      do
	 eh.add_position(super.start_position);
	 eh.add_position(redef.start_position);
	 eh.append("Bad redefinition. ");
	 eh.append(msg);
	 eh.print_as_fatal_error;
      end;

invariant

   name /= Void;

end -- BASE_CLASS
