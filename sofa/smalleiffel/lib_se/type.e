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
deferred class TYPE
--
-- Handling of an Eiffel type mark.
--
-- Handling of Eiffel kernel classes :
--
--      Type Mark         |         Handle by Class
--      -------------------------------------------
--      BOOLEAN           |            TYPE_BOOLEAN
--      CHARACTER         |          TYPE_CHARACTER
--      INTEGER           |            TYPE_INTEGER
--      REAL              |               TYPE_REAL
--      DOUBLE            |             TYPE_DOUBLE
--      POINTER           |            TYPE_POINTER
--      NONE              |               TYPE_NONE
--      ANY               |                TYPE_ANY
--      STRING            |             TYPE_STRING
--      ARRAY[FOO]        |              TYPE_ARRAY
--      NATIVE_ARRAY[BAR] |       TYPE_NATIVE_ARRAY
--      BIT 45            |              TYPE_BIT_1
--      BIT Foo           |              TYPE_BIT_2
--
-- Handling of other classes :
--
--      TYPE_CLASS : when original type mark is not generic,
--            not outside expanded and it is not a formal
--            generic argument. Thus, this is the most common
--            case.
--
--      TYPE_FORMAL_GENERIC : when original declaration type mark
--            is a formal generic argument.
--
--      TYPE_LIKE_CURRENT : when written `like Current'
--
--      TYPE_LIKE_FEATURE : `like' <feature_name>
--
--      TYPE_LIKE_ARGUMENT : `like' <argument>
--
--      TYPE_EXPANDED : when original type is outside expanded (for
--            example when written   `foo : expanded BAR').
--
--      TYPE_GENERIC : when original type is generic, is not ARRAY,
--            not NATIVE_ARRAY and is not outside expanded.
--
--      TYPE_BIT_REF : corresponding reference type for TYPE_BIT.
--
--      TYPE_REF_TO_EXP : corresponding reference type for some
--            expanded type.
--

inherit GLOBALS;

feature

   written_mark: STRING is
         -- The original written type mark (what's in the source code).
      deferred
      ensure
         Result = string_aliaser.item(Result)
      end;

   start_position: POSITION is
         -- Of the written mark.
      deferred
      end;

   frozen written_in: CLASS_NAME is
      do
         if start_position /= Void then
            Result := start_position.base_class_name;
         end;
      end;

   pretty_print is
      deferred
      end;

   frozen short is
      do
         short_print.hook("Btm");
         short_hook;
         short_print.hook("Atm");
      end;

   is_anchored: BOOLEAN is
         -- Is it written "like ..." ?
      do
      end;

   is_like_current: BOOLEAN is
         -- Is it written "like Current" ?
      deferred
      ensure
         Result implies is_anchored
      end;

   is_like_feature: BOOLEAN is
         -- Is it written "like <feature>" ?
      deferred
      ensure
         Result implies is_anchored
      end;

   is_like_argument: BOOLEAN is
         -- Is it written "like <argument>" ?
      deferred
      ensure
         Result implies is_anchored
      end;

   is_generic: BOOLEAN is
         -- Is the written type a generic type ?
      deferred
      ensure
         is_array implies Result
      end;

   is_formal_generic: BOOLEAN is
         -- Is it a formal generic argument ?
      do
      end;

feature

   is_run_type: BOOLEAN is
         -- True when the running type is known (ie, when anchors
         -- are computed and when formal generic names are
         -- substitutes with real class names.
      deferred
      ensure
         Result implies run_type /= Void
      end;

feature  -- Working with the run TYPE :

   run_type: TYPE is
         -- Corresponding running type mark.
      require
         is_run_type
      deferred
      ensure
         Result.run_type = Result
      end;

   is_expanded: BOOLEAN is
      require
         is_run_type
      deferred
      ensure
         Result implies not is_reference
      end;

   is_reference: BOOLEAN is
      require
         is_run_type
      deferred
      ensure
         Result implies not is_expanded
      end;

   like_feature: FEATURE_NAME is
      require
         is_like_feature
      do
      ensure
         Result /= Void
      end;

   generic_list: ARRAY[TYPE] is
         -- Assume this is really a generic type, otherwise, print
         -- a fatal error message with `fatal_error_generic_list'.
      deferred
      ensure
         Result.lower = 1;
         not Result.is_empty
      end;

   run_time_mark: STRING is
         -- The corresponding type mark at execution time.
      require
         is_run_type
      deferred
      ensure
         Result = string_aliaser.item(Result)
      end;

   is_boolean: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_character: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_integer: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_real: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_double: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_string: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_array: BOOLEAN is
      require
         is_run_type
      deferred
      ensure
         Result implies generic_list.count = 1
      end;

   is_bit: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_any: BOOLEAN is
      require
         is_run_type
      deferred
      end;

   is_none: BOOLEAN is
      require
         is_run_type
      deferred
      end;

   is_pointer: BOOLEAN is
      require
         is_run_type
      do
      end;

   is_basic_eiffel_expanded: BOOLEAN is
         -- True for BOOLEAN, CHARACTER, INTEGER, REAL, DOUBLE
         -- and POINTER.
         -- Note : all these types have the corresponding foo_REF
         -- class with the `item' attribute.
      require
         is_run_type
      deferred
      end;

   frozen is_native_array: BOOLEAN is
      local
         tna: TYPE_NATIVE_ARRAY;
      do
         tna ?= Current;
         Result := tna /= Void;
      end;

   actual_reference(destination: TYPE): TYPE is
         -- If `destination' is the exact concrete corresponding reference type
         -- of `Current', `destination' is returned without any modification (as 
         -- an example, this occurs when `Current' represents the INTEGER type
         -- while `destination' represents the INTEGER_REF type).
         -- Otherwise, when `destination' is not specialized enough the actual
         -- concrete Result type is created (as an example, this occurs when
         -- `Current' represents the INTEGER type while destination represents
         -- the ANY type; a representation of INTEGER_REF is thus created).
      require
         is_expanded;
	 destination.is_reference;
	 is_a(destination)
      deferred
      ensure
         Result.is_reference
      end;

   frozen convertible_to(other: TYPE): BOOLEAN is
      require
         is_run_type;
         other.is_run_type;
         eh.is_empty
      do
         if is_a(other) then
            Result := true;
         else
            eh.cancel;
            if other.is_a(Current) then
               Result := true;
            else
               eh.cancel;
            end;
         end;
      ensure
         eh.is_empty
      end;

feature

   base_class_name: CLASS_NAME is
      require
         is_run_type
      deferred
      ensure
         Result /= Void
      end;

   static_base_class_name: CLASS_NAME is
         -- Try to compute statically the good one.
         -- It is not alway possible to compute this information
         -- because some error may occurs for example.
      deferred
      end;

   to_runnable(ct: TYPE): like Current is
         -- Compute the run time mark when the receiver is
         -- written in `ct'.
         -- Example : INTEGER always gives INTEGER.
         --           `like Current' gives `ct'.
         --           ...
      require
         ct.run_type = ct
      deferred
      ensure
         no_errors implies written_mark = Result.written_mark;
         no_errors implies start_position = Result.start_position;
         no_errors implies Result.is_run_type;
         no_errors implies Result.run_type = Result.run_type.run_type
      end;

   base_class: BASE_CLASS is
      local
         bcn: CLASS_NAME;
      do
         bcn := base_class_name;
         if bcn /= Void then
            Result := bcn.base_class;
         else
            eh.append("Cannot find Base Class for ");
            eh.add_type(Current,fz_dot);
            eh.print_as_fatal_error;
         end;
      end;
   
   frozen path: STRING is
      -- Of the corresponding `base_class'.
      do
         Result := base_class.path;
      end;

feature

   is_a(other: TYPE): BOOLEAN is
         -- Type conformance checking : Is it a kind of `other' ?
         -- Assume that the context is identical.
         --
         -- When false, `eh' is filled if needed with the corresponding
         -- bad types, but the error report is not printed for the caller
         -- to add some comments or for the caller to cancel `eh'.
         --
      require
         is_run_type;
         other.is_run_type
      deferred
      ensure
         nb_errors = old nb_errors;
         (not Result) implies (not eh.is_empty)
      end;

   frozen is_a_in(other: TYPE; rc: RUN_CLASS): BOOLEAN is
         -- Is the written type mark `other' interpreted in `rc'
         -- is a kind of Current written type mark interpreted in `rc' ?
      require
         other /= Void;
         rc /= Void
      local
         t1, t2, ct: TYPE;
      do
         if written_mark = other.written_mark then
            Result := true;
         else
            ct := rc.current_type;
            t1 := to_runnable(ct); -- ** Memory LEAKS
            t2 := other.to_runnable(ct); -- ** Memory LEAKS
            if t1.run_time_mark = t2.run_time_mark then
               Result := true;
            else
               Result := t1.is_a(t2);
            end;
         end;
      ensure
         (not Result) implies (not eh.is_empty)
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
         -- Is `fn' the name of procedure of creation.
      require
         not fn.start_position.is_unknown;
         is_run_type
      deferred
      end;

   smallest_ancestor(other: TYPE): TYPE is
         -- Return the smallest common ancestor.
      require
         is_run_type;
         other.is_run_type
      deferred
      ensure
         Result.run_type = Result;
         Current.is_a(Result);
         other.is_a(Result)
      end;

   run_class: RUN_CLASS is
      require
         is_run_type
      deferred
      ensure
         Result /= Void
      end;

   frozen at_run_time: BOOLEAN is
      require
         is_run_type
      do
         Result := run_type.run_class.at_run_time;
      end;

   expanded_initializer: RUN_FEATURE_3 is
         -- Non Void when it is an `is_user_expanded' with a user
         -- creation procedure.
      require
         is_run_type
      deferred
      end;
   
   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
         -- True when `t' drives exactely to the same `t.run_type' for all `r'.
      require
         small_eiffel.is_ready;
         r.count > 1
      deferred
      end;

feature

   c_header_pass1 is
      require
         cpp.on_h;
         run_class.at_run_time
      deferred
      ensure
         cpp.on_h
      end;

   c_header_pass2 is
      require
         cpp.on_h;
         run_class.at_run_time
      deferred
      ensure
         cpp.on_h
      end;

   c_header_pass3 is
      require
         cpp.on_h;
         run_class.at_run_time
      deferred
      ensure
         cpp.on_h
      end;

   c_header_pass4 is
      require
         cpp.on_h;
         run_class.at_run_time
      deferred
      ensure
         cpp.on_h
      end;

feature

   id: INTEGER is
         -- All `at_run_time' has a Tid C type.
      require
         is_run_type
      deferred
      ensure
         Result > 0
      end;

   is_dummy_expanded: BOOLEAN is
         -- True when is it a user's expanded type with no attribute.
      require
         is_run_type;
         small_eiffel.is_ready
      deferred
      end;

   is_user_expanded: BOOLEAN is
         -- Is it really a user expanded type ?
      require
         is_run_type
      deferred
      end;

   c_type_for_argument_in(str: STRING) is
         -- Append in `str' the C type to use when current
         -- Eiffel type is used for an argument of a feature.
      require
         small_eiffel.is_ready;
         str /= Void
      deferred
      end;

   c_type_for_target_in(str: STRING) is
         -- Append in `str' the C type to use when current
         -- Eiffel type is used for an argument of a feature.
      require
         small_eiffel.is_ready;
         str /= Void
      deferred
      end;

   c_type_for_result_in(str: STRING) is
         -- Append in `str' the C type to use when current Eiffel
         -- type is used as a result type of a C function.
      require
         small_eiffel.is_ready;
         str /= Void
      deferred
      end;

   frozen c_type_for_external_in(str: STRING) is
      do
         if is_reference then
            str.append(fz_void);
            str.extend('*');
         else
            c_type_for_result_in(str);
         end;
      end;

   frozen mapping_cast is
         -- Produce a C cast for conversion into current C type.
      require
         is_run_type;
         run_type.run_class.at_run_time
      do
         mapping_cast_memory.clear;
         mapping_cast_memory.extend('(');
         c_type_for_target_in(mapping_cast_memory);
         mapping_cast_memory.extend(')');
         cpp.put_string(mapping_cast_memory);
      end;

feature {NONE}

   mapping_cast_memory: STRING is "................";

feature

   cast_to_ref is
         -- Produce the good C cast to use INTEGER_REF, BOOLEAN_REF,
         -- CHARACTER_REF, REAL_REF or DOUBLE_REF.
      require
         is_run_type;
         is_basic_eiffel_expanded
      do
         run_type.cast_to_ref;
      end;

   need_c_struct: BOOLEAN is
         -- Is it necessary to define a C struct ?
      require
         small_eiffel.is_ready
      deferred
      end;

   c_sizeof: INTEGER is
         -- Result of C sizeof for a variable which has the `Current' type.
      require
         is_run_type
      deferred
      ensure
         Result >= 1
      end;

   c_initialize is
         -- Produce C code for initialisation of local variables
         -- or attributes.
      require
         is_run_type;
         small_eiffel.is_ready
      deferred
      end;

   c_initialize_in(str: STRING) is
         -- In order to initialize local variables or attributes
         -- with the default simple value (0, NULL, 0.0, etc.).
      require
         is_run_type;
         small_eiffel.is_ready
      deferred
      end;

   frozen c_frame_descriptor is
      do
         c_frame_descriptor_format.extend('%%');
         if is_reference then
            c_frame_descriptor_format.extend('R');
         else
            c_frame_descriptor_format.extend('E');
         end;
         id.append_in(c_frame_descriptor_format);
         c_frame_descriptor_format.extend('%%');
      end;

feature

   need_gc_mark_function: BOOLEAN is
         -- True when objects of the current type must be marked
         -- or when `gc_mark_to_follow' is true in corresponding run
         -- class.
      deferred
      end;

feature {RUN_CLASS,TYPE}

   gc_define1 is
         -- Define prototypes and C struct for the Garbage Collector
      require
         not gc_handler.is_off;
         cpp.on_h;
         run_class.at_run_time
      deferred
      end;

   gc_define2 is
         -- Define C functions for the Garbage Collector
      require
         not gc_handler.is_off;
         cpp.on_c;
         run_class.at_run_time
      deferred
      end;

   gc_info_in(str: STRING) is
         -- Produce C code to print GC information.
      require
         not gc_handler.is_off;
         gc_handler.info_flag;
         run_class.at_run_time
      deferred
      end;

   just_before_gc_mark_in(str: STRING) is
      require
         not gc_handler.is_off;
         run_class.at_run_time
      deferred
      end;

feature {NONE}

   standard_just_before_gc_mark_in(str: STRING) is
      require
         not gc_handler.is_off;
         run_class.at_run_time
      do
         gc_free_in(str);
         str.extend('=');
         str.append(fz_null);
         str.append(fz_00);
      end;

feature {NATIVE_SMALL_EIFFEL,GC_HANDLER}

   gc_call_new_in(str: STRING) is
      do
         str.append(fz_new);
         id.append_in(str);
         str.extend('(');
         str.extend(')');
      end;

feature

   jvm_method_flags: INTEGER is
         -- Return the appropriate flag (static/virtual) when the
         -- receiver has this type.
      deferred
      end;

   frozen jvm_stack_space: INTEGER is
      require
         is_run_type
      do
         if is_double then
            Result := 2;
         else
            Result := 1;
         end;
      ensure
         Result >= 1
      end;

   jvm_descriptor_in(str: STRING) is
         -- Append in `str' the appropriate JVM type descriptor for
         -- arguments and Result of a method.
      require
         str /= Void
      deferred
      end;

   jvm_target_descriptor_in(str: STRING) is
         -- Append in `str' the appropriate JVM type descriptor for
         -- the target only.
      require
         str /= Void;
         run_class.at_run_time
      deferred
      end;

   jvm_return_code is
         -- Add the good JVM opcode to return Result.
      require
         run_type = Current
      deferred
      end;

   jvm_push_local(offset: INTEGER) is
         -- Push value of the local variable at `offset'.
      deferred
      end;

   jvm_push_default: INTEGER is
         -- Push the default value for the Current type.
         -- Result gives the space in the JVM stack;
      deferred
      end;

   jvm_write_local(offset: INTEGER) is
         -- Write the local variable at `offset' using the stack top.
      deferred
      end;

   jvm_check_class_invariant is
         -- If needed, add some byte code to check the class invariant
         -- of the pushed object.
      deferred
      end;

   jvm_xnewarray is
         -- Produce the appropriate byte-code to create a new JVM
         -- array with elements of `Current' type.
         -- Assume the count of the new array to create is already
         -- pushed.
      deferred
      end;

   jvm_xastore is
      deferred
      end;

   jvm_xaload is
      deferred
      end;

   jvm_if_x_eq: INTEGER is
         -- Assume two operands of the same type are pushed.
      deferred
      end;

   jvm_if_x_ne: INTEGER is
         -- Assume two operands of the same type are pushed.
      deferred
      end;

   jvm_convert_to(destination: TYPE): INTEGER is
         -- Convert the pushed value (which is an object of
         -- the current type) into an object of `destination' type.
      require
         convertible_to(destination)
      deferred
      ensure
         Result >= 1
      end;

   jvm_standard_is_equal is
         -- Produce byte-code for `standard_is_equal' for the
         -- top objects pair.
      deferred
      end;

feature {NONE}

   frozen standard_jvm_check_class_invariant is
      do
         if run_control.invariant_check then
            run_class.jvm_check_class_invariant;
         end;
      end;

feature {TYPE}

   jvm_to_reference is
         -- If needed, convert the pushed value into the
         -- corresponding reference type.
      deferred
      end;

   jvm_expanded_from_reference(other: TYPE): INTEGER is
         -- Convert the pushed value of type `other' which is a reference
         -- type into the corresponding expanded type.
      require
         is_expanded;
         other.is_reference;
         is_a(other)
      deferred
      ensure
         Result >= 1
      end;

feature {NONE}

   c_initialize_expanded is
      require
         is_user_expanded or is_dummy_expanded
      local
         wa: ARRAY[RUN_FEATURE_2];
         i: INTEGER;
         rf: RUN_FEATURE_2;
      do
         if is_dummy_expanded then
            cpp.put_character('0');
         else
            cpp.put_character('{');
            wa := run_class.writable_attributes;
            from
               i := wa.upper;
            until
               i = 0
            loop
               rf := wa.item(i);
               rf.result_type.c_initialize;
               i := i - 1;
               if i > 0 then
                  cpp.put_character(',');
               end;
            end;
            cpp.put_character('}');
         end;
      end;

feature {PARENT,TYPE}

   frozen look_up_for(rc: RUN_CLASS; fn: FEATURE_NAME): E_FEATURE is
      -- Look for the good one to compute `rc' X `fn'.
      require
         rc /= Void;
         fn /= Void;
         not is_anchored;
         not is_formal_generic;
      do
         Result := base_class.look_up_for(rc,fn);
      end;

feature {RUN_CLASS}

   frozen id_extra_information(sfw: STD_FILE_WRITE) is
      do
         sfw.put_string("reference: ");
         if is_reference then
            sfw.put_string("yes ");
         else
            sfw.put_string("no ");
         end;
      end;

   frozen demangling_in(str: STRING) is
      do
         if is_reference then
            str.extend('R');
         else
            str.extend('E');
         end;
         str.extend(' ');
         str.append(run_time_mark);
      end;

feature {NONE}

   tmp_string: STRING is "................................................................%
                         %................................................................";

   header: STRING is "................................................................%
                     %................................................................";

   body: STRING is "................................................................%
                   %................................................................%
                   %................................................................%
                   %................................................................";

feature {TYPE}

   short_hook is
      deferred
      end;

feature {NONE}

   fatal_error_generic_list is
      do
         check
            not is_generic;
         end;
         eh.add_type(Current," is (not) generic ?");
         eh.print_as_fatal_error;
      end;

feature {NONE}

   frozen standard_gc_info_in(str: STRING) is
      do
         -- Print gc_info_nbXXX :
         str.append("fprintf(SE_GCINFO,%"");
         str.append(run_time_mark);
         str.append(fz_10);
         gc_info_nb_in(str);
         str.append(fz_14);
         -- Print store_leftXXX :
         str.append("fprintf(SE_GCINFO,%"");
         gc_store_left_in(str);
         str.append(fz_10);
         gc_store_left_in(str);
         str.append(fz_14);
      end;

   frozen standard_gc_define1 is
         -- For Fixed Size Objects.
      require
         not gc_handler.is_off;
         cpp.on_h;
         run_class.at_run_time
      local
         rc: RUN_CLASS;
         rcid: INTEGER;
      do
         rc := run_class;
         rcid := rc.id;
         -- --------------- Define struct BXXX and typedef gcXXX :
         header.copy(fz_typedef);
         header.append(fz_struct);
         header.extend('B');
         rcid.append_in(header);
         header.extend(' ');
         header.append(fz_gc);
         rcid.append_in(header);
         header.append(fz_00);
         header.append(fz_struct);
         header.extend('B');
         rcid.append_in(header);
         header.append("{T");
         rcid.append_in(header);
         header.append(" object;union {int flag;gc");
         rcid.append_in(header);
         header.append("*next;} header;};%N");
         cpp.put_string(header);
         -- ----------------------------------- Declare storeXXX :
         header.copy(fz_gc);
         rcid.append_in(header);
         header.extend('*');
         gc_store_in(header);
         cpp.put_extern5(header,fz_null);
         -- ------------------------------ Declare store_leftXXX :
         header.copy(fz_int);
         header.extend(' ');
         gc_store_left_in(header);
         cpp.put_extern2(header,'0');
         -- ----------------------------------- Declare store_chunkXXX :
         header.copy("fsoc*");
         gc_store_chunk_in(header);
         cpp.put_extern5(header,fz_null);
         -- --------------------------------- Declare gc_freeXXX :
         header.copy(fz_gc);
         rcid.append_in(header);
         header.extend('*');
         gc_free_in(header);
         cpp.put_extern5(header,fz_null);
         -- -------------------------------- Declare gc_info_nbXXX :
         if gc_handler.info_flag then
            header.copy(fz_int);
            header.extend(' ');
            gc_info_nb_in(header);
            cpp.put_extern2(header,'0');
         end;
      end;

   frozen standard_gc_define2 is
      require
         is_reference;
         not gc_handler.is_off;
         cpp.on_c;
         run_class.at_run_time
      local
         rc: RUN_CLASS;
         rcid: INTEGER;
         gc_check_id: BOOLEAN;
      do
         rc := run_class;
         rcid := rc.id;
         -- --------------------------- Definiton for gc_sweepXXX :
         header.copy(fz_void);
         header.extend(' ');
         header.append(fz_gc_sweep);
         rcid.append_in(header);
         header.append("(fsoc*c)");
         body.copy("gc");
         rcid.append_in(body);
         body.append(
            "*o1,*o2,*flt,flh;%N%
            %o1=((gc");
         rcid.append_in(body);
         body.append(
            "*)(&(c->first_object)));%N%
            %if(c->header.state_type==FSO_STORE_CHUNK){%N%
            %for(;o1<");
         gc_store_in(body);
         body.append(
            ";o1++){%N%
            %if((o1->header.flag)==FSOH_MARKED){%N%
            %o1->header.flag=FSOH_UNMARKED;%N}%N%
            %else{%N");
         gc_handler.memory_dispose(body,"o1",run_class);
         body.append("o1->header.next=");
         gc_free_in(body);
         body.append(fz_00);
         gc_free_in(body);
         body.append(
            "=o1;%N%
            %}%N}%N}%N%
            %else{%N%
            %int dead=1;%N%
            %flh.header.next=NULL;%N%
            %flt=&flh;%N%
            %o2=o1+c->count_minus_one;%N%
            %for(;o1<=o2;o2--){%N%
            %if((o2->header.flag)==FSOH_MARKED){%N%
            %o2->header.flag=FSOH_UNMARKED;%N%
            %dead=0;}%N%
            %else{%N");
         gc_handler.memory_dispose(body,"o2",run_class);
         body.append(
            "flt->header.next=o2;%N%
            %flt=o2;%N%
            %}%N}%N%
            %if (dead){%N%
            %c->next=fsocfl;%N%
            %fsocfl=c;%N%
            %c->header.state_type=FSO_FREE_CHUNK;%N}%N%
            %else if(flh.header.next!=NULL){%N%
            %flt->header.next=");
         gc_free_in(body);
         body.append(fz_00);
         gc_free_in(body);
         body.append(
            "=flh.header.next;%N%
            %}%N}%N");
         cpp.put_c_function(header,body);
         -- ----------------------------- Definiton for gc_markXXX :
         header.copy(fz_void);
         header.extend(' ');
         gc_mark_in(header);
         header.append("(T");
         rcid.append_in(header);
         header.append("*o)");
         body.clear;
         gc_check_id := rc.is_tagged and then run_control.no_check;
         if gc_check_id then
            body.append("se_gc_check_id(o,");
            rcid.append_in(body);
            body.append(");%N{");
         end;
         rc.gc_mark_fixed_size(false,body);
         if gc_check_id then
            body.append("%N}");
         end;
         cpp.put_c_function(header,body);
         -- ----------------------- Definiton for gc_align_markXXX :
         header.copy(fz_void);
         header.extend(' ');
         gc_align_mark_in(header);
         header.append("(fsoc*c,gc");
         rcid.append_in(header);
         header.append("*p)");
         body.clear;
         rc.gc_align_mark_fixed_size(body);
         cpp.put_c_function(header,body);
         -- ------------------------ Definiton of chunk model HXXX :
         header.copy("fsoc H");
         rcid.append_in(header);
         body.copy(
            "{{FSOC_SIZE,FSO_STORE_CHUNK,%N%
            %(void(*)(mch*,void*))gc_align_mark");
         rcid.append_in(body);
         body.append(
            ",%N%
            %(void(*)(mch*))gc_sweep");
         rcid.append_in(body);
         body.append(
            "},NULL,(((FSOC_SIZE-sizeof(fsoc)+sizeof(double))/sizeof(gc");
         rcid.append_in(body);
         body.append("))-1)}");
         cpp.put_extern5(header,body);
         -- --------------------------------- Definiton for newXXX :
         header.clear;
         header.extend('T');
         rcid.append_in(header);
         header.extend('*');
         header.append(fz_new);
         rcid.append_in(header);
         header.append(fz_c_void_args);
         body.copy(fz_gc);
         rcid.append_in(body);
         body.append("*n;%N");
         if gc_handler.info_flag then
            gc_info_nb_in(body);
            body.append("++;%N");
         end;
         --
         body.append("if(");
         gc_store_left_in(body);
         body.append(">1){%N")
         gc_store_left_in(body);
         body.append("--;%Nn=");
         gc_store_in(body);
         body.append("++;%N}%N%
                     %else if (");
         gc_free_in(body);
         body.append("!=NULL){%N%
                     %n=");
         gc_free_in(body);
         body.append(fz_00);
         gc_free_in(body);
         body.append("=n->header.next;%N}%N%
                     %else if(");
         gc_store_left_in(body);
         body.append("==1){%N");
         gc_store_left_in(body);
         body.append("=0;%N");
         gc_store_chunk_in(body);
         body.append("->header.state_type=FSO_USED_CHUNK;%N%
                     %n=");
         gc_store_in(body);
         body.append("++;%N}%N%
                     %else if(");
         body.append("fsocfl!=NULL) {%N");
         gc_store_chunk_in(body);
         body.append("=fsocfl;%N%
                     %fsocfl=fsocfl->next;%N");
	 --++++++++++++++++++++++++++++++++++
	 gc_initialize_chunk(rcid,body);
--         body.extend('*');
--         gc_store_chunk_in(body);
--         body.append(fz_eq_h);
--         rcid.append_in(body);
--         body.append(fz_00);
--         gc_store_in(body);
--         body.append("=(void*)(&(");
--         gc_store_chunk_in(body);
--         body.append("->first_object));%N");
--         gc_store_left_in(body);
--         body.append(fz_eq_h);
--         rcid.append_in(body);
--         body.append(".count_minus_one;%N%
--                     %n=");
--         gc_store_in(body);
--         body.append("++;%N}%N");
	 -------------------------------------
         body.append("else if(fsoc_count_ceil>fsoc_count) {%N");
         gc_store_chunk_in(body);
         body.append(
            "=((fsoc*)malloc(FSOC_SIZE));%N%
            %fsoc_count++;%N%
            %{mch**p;%N%
            %if(gcmt_used==gcmt_max){%N%
            %gcmt_max<<=1;%N%
            %gcmt=((mch**)realloc(gcmt,(gcmt_max+1)*sizeof(void*)));%N}%N%
            %for(p=gcmt+(gcmt_used++ -1);(p>=gcmt)&&(*p>((mch*)");
         gc_store_chunk_in(body);
         body.append("));p--)%N%
                     %*(p+1)=*p;%N%
                     %*(p+1)=(mch*)");
         gc_store_chunk_in(body);
         body.append(";%N}%N");
	 --++++++++++++++++++++++++++++++++++
	 gc_initialize_chunk(rcid,body);
--         body.extend('*');
--         gc_store_chunk_in(body);
--         body.append(fz_eq_h);
--         rcid.append_in(body);
--         body.append(fz_00);
--         gc_store_in(body);
--         body.append("=(void*)(&(");
--         gc_store_chunk_in(body);
--         body.append("->first_object));%N");
--         gc_store_left_in(body);
--         body.append(fz_eq_h);
--         rcid.append_in(body);
--         body.append(".count_minus_one;%N%
--                     %n=");
--         gc_store_in(body);
--         body.append("++;%N}%N");
	 -------------------------------------
         body.append("else{%N%
                     %gc_start();%N%
                     %if(NULL!=");
         gc_free_in(body);
         body.append("){%N%
                     %n=");
         gc_free_in(body);
         body.append(fz_00);
         gc_free_in(body);
         body.append("=n->header.next;%N}%Nelse{%N");
         gc_store_chunk_in(body);
         body.append("=new_fsoc();%N");
	 --++++++++++++++++++++++++++++++++++
	 gc_initialize_chunk(rcid,body);
--         body.extend('*');
--         gc_store_chunk_in(body);
--         body.append(fz_eq_h);
--         rcid.append_in(body);
--         body.append(fz_00);
--         gc_store_in(body);
--         body.append("=(void*)(&(");
--         gc_store_chunk_in(body);
--         body.append("->first_object));%N");
--         gc_store_left_in(body);
--         body.append(fz_eq_h);
--         rcid.append_in(body);
--         body.append(".count_minus_one;%N%
--                     %n=");
--         gc_store_in(body);
--         body.append("++;%N}%N");
	 -------------------------------------
         body.append("}%N%
                     %n->header.flag=FSOH_UNMARKED;%N");
         if need_c_struct then
            body.append("n->object=M");
            rcid.append_in(body);
            body.append(fz_00);
         end;
         body.append("return((T")
	 rcid.append_in(body);
	 body.append("*)n);%N");
         cpp.put_c_function(header,body);
      end;

   frozen standard_gc_define2_for_expanded is
         -- For user's expanded with reference attribute to mark.
      require
         is_expanded;
         not gc_handler.is_off;
         cpp.on_c;
         run_class.at_run_time
      local
         rc: RUN_CLASS;
         rcid: INTEGER;
      do
         rc := run_class;
         if rc.gc_mark_to_follow then
            rcid := rc.id;
            -- -------------------------- Definiton for gc_markXXX :
            header.copy(fz_void);
            header.extend(' ');
            gc_mark_in(header);
            header.append("(T");
            rcid.append_in(header);
            header.append("*o)");
            body.clear;
            rc.gc_mark_fixed_size(true,body);
            cpp.put_c_function(header,body);
         end;
      end;

   frozen gc_store_in(str: STRING) is
      do
         str.append("store");
         id.append_in(str);
      end;

   frozen gc_store_left_in(str: STRING) is
      do
         str.append("store_left");
         id.append_in(str);
      end;

   frozen gc_store_chunk_in(str: STRING) is
      do
         str.append("store_chunk");
         id.append_in(str);
      end;

   frozen gc_free_in(str: STRING) is
      do
         str.append("gc_free");
         id.append_in(str);
      end;

   frozen gc_align_mark_in(str: STRING) is
      do
         str.append("gc_align_mark");
         id.append_in(str);
      end;

   frozen gc_info_nb_in(str: STRING) is
      do
         str.append("gc_info_nb");
         id.append_in(str);
      end;

   frozen gc_initialize_chunk(rcid: INTEGER; str: STRING) is
      do
         str.extend('*');
         gc_store_chunk_in(str);
         str.append(fz_eq_h);
         rcid.append_in(str);
         str.append(fz_00);
         gc_store_in(str);
         str.append("=((gc");
	 rcid.append_in(str);
         str.append("*)(&(");
         gc_store_chunk_in(str);
         str.append("->first_object)));%N");
         gc_store_left_in(str);
         str.append(fz_eq_h);
         rcid.append_in(str);
         str.append(".count_minus_one;%N%
                     %n=");
         gc_store_in(str);
         str.append("++;%N}%N");
      end;

feature {TYPE, GC_HANDLER}

   frozen gc_mark_in(str: STRING) is
      do
         str.append(fz_gc_mark);
         id.append_in(str);
      end;

feature {NONE}

   frozen standard_c_typedef is
      require
         cpp.on_h;
         run_class.at_run_time
      local
         mem_id: INTEGER;
      do
         mem_id := id;
         tmp_string.clear;
         if need_c_struct then
            tmp_string.append(fz_typedef);
            tmp_string.append(fz_struct);
            tmp_string.extend('S');
            mem_id.append_in(tmp_string);
            tmp_string.extend(' ');
            tmp_string.extend('T');
            mem_id.append_in(tmp_string);
            tmp_string.append(fz_00);
         elseif is_dummy_expanded then
            tmp_string.append(fz_typedef);
            tmp_string.append(fz_int);
            tmp_string.extend(' ');
            tmp_string.extend('T');
            mem_id.append_in(tmp_string);
            tmp_string.append(fz_00);
         elseif is_reference then
            tmp_string.append(fz_typedef);
            tmp_string.append(fz_void);
            tmp_string.extend('*');
            tmp_string.extend('T');
            mem_id.append_in(tmp_string);
            tmp_string.append(fz_00);
         end;
         cpp.put_string(tmp_string);
      ensure
         cpp.on_h
      end;

   frozen standard_c_struct is
         -- Produce C code for the standard C struct (for user's
         -- expanded or reference as well).
      require
         run_type = Current;
         need_c_struct;
         cpp.on_h
      local
         wa: ARRAY[RUN_FEATURE_2];
         i, mem_id: INTEGER;
         a: RUN_FEATURE_2;
         t: TYPE;
      do
         mem_id := id;
         wa := run_class.writable_attributes;
         tmp_string.copy(fz_struct);
         tmp_string.extend('S');
         mem_id.append_in(tmp_string);
         tmp_string.extend('{');
         if is_reference then
            if run_class.is_tagged then
               tmp_string.append("Tid id;");
            end;
         end;
         if wa /= Void then
            from
               i := wa.upper;
            until
               i = 0
            loop
               a := wa.item(i);
               t := a.result_type.run_type;
               t.c_type_for_result_in(tmp_string);
               tmp_string.extend(' ');
               tmp_string.extend('_');
               tmp_string.append(a.name.to_string);
               tmp_string.extend(';');
               i := i - 1;
            end;
         end;
         tmp_string.extend('}');
         tmp_string.append(fz_00);
         cpp.put_string(tmp_string);
         if is_expanded then
            -- For expanded comparison :
            tmp_string.copy(fz_int);
            tmp_string.extend(' ');
            tmp_string.append(fz_se_cmpt);
            mem_id.append_in(tmp_string);
            tmp_string.append("(T");
            mem_id.append_in(tmp_string);
            tmp_string.append(" o1,T");
            mem_id.append_in(tmp_string);
            tmp_string.append(" o2)");
            cpp.put_c_function(tmp_string,
            "return memcmp(&o1,&o2,sizeof(o1));");
         end;
      ensure
         cpp.on_h
      end;

   frozen standard_c_object_model is
         -- Produce C code to define the model object.
      require
         run_type = Current;
         cpp.on_h
      local
         mem_id: INTEGER;
         rc: RUN_CLASS;
      do
         rc := run_class;
         mem_id := rc.id;
         tmp_string.clear;
         tmp_string.extend('T');
         mem_id.append_in(tmp_string);
         tmp_string.extend(' ');
         tmp_string.extend('M');
         mem_id.append_in(tmp_string);
         cpp.put_extern7(tmp_string);
         cpp.swap_on_c;
         tmp_string.clear;
         rc.c_object_model_in(tmp_string);
         tmp_string.append(fz_00);
         cpp.put_string(tmp_string);
         cpp.swap_on_h;
      ensure
         cpp.on_h
      end;

   frozen standard_c_print_function is
         -- Produce `prinTid' function.
      require
         run_type = Current
      do
         if run_control.no_check then
            run_class.c_print_function;
         end;
      end;

   frozen c_sizeof_pointer: INTEGER is
      local
         p: POINTER;
      do
         Result := p.object_size;
      end;

    frozen standard_stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      local
         rc: RUN_CLASS;
         ct, dyn_t: TYPE;
         rtm1, rtm2: STRING;
         i: INTEGER;
      do
         from
            Result := true;
            i := r.upper;
            rc := r.item(i);
            i := i - 1;
            ct := rc.current_type;
            dyn_t := to_runnable(ct);
            if dyn_t = Void then
               Result := false;
               eh.cancel;
            else
               rtm1 := dyn_t.run_time_mark;
            end;
         until
            not Result or else i = 0
         loop
            rc := r.item(i);
            i := i - 1;
            ct := rc.current_type;
            dyn_t := to_runnable(ct);
            if dyn_t = Void then
               Result := false;
               eh.cancel;
            else
               rtm2 := dyn_t.run_time_mark;
               if rtm1 /= rtm2 then
                  Result := false;
               end;
            end;
         end;
      end;
   
invariant

   written_mark = string_aliaser.item(written_mark)

end -- TYPE
