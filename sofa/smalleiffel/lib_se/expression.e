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
deferred class EXPRESSION
   --
   -- Any kind of Eiffel expression.
   --

inherit GLOBALS;

feature

   start_position: POSITION is
         -- Of the expression if any.
      deferred
      end;

   is_current: BOOLEAN is
         -- Is it a `Current' like expression (really written 
         -- `Current' or some implicit non-written `Current') ?
      deferred
      end;

   is_manifest_string: BOOLEAN is
         -- Is it a manifest string ?
      deferred
      end;

   is_manifest_array: BOOLEAN is
         -- Is it a manifest array ?
      deferred
      end;

   is_void: BOOLEAN is
         -- Is it the built-in Void ?
      deferred
      end;

   is_result: BOOLEAN is
         -- Is it the pseudo local variable `Result' ?
      deferred
      end;

   is_writable: BOOLEAN is
         -- Is is something that one can find on the left-hand-side 
         -- of the := operator ?
      deferred
      end;

   static_result_base_class: BASE_CLASS is
         -- The static BASE_CLASS of the `result_type' (according to the
         -- `start_position').
         -- Void when it is too difficult to compute, when some error 
         -- occurs or when this is the class NONE.
      deferred
      end;

   result_type: TYPE is
         -- The `result_type' is available only when the expression 
         -- has been checked (see `to_runnable').
      deferred
      ensure
         Result /= Void
      end;

   use_current: BOOLEAN is
         -- True if `Current' is used.
         -- As for `result_type', available only for checked expression.
      require
         small_eiffel.is_ready
      deferred
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      require
         small_eiffel.is_ready;
         run_control.boost;
         r.count > 1
      deferred
      end;

   to_runnable(ct: TYPE): EXPRESSION is
         -- Gives the corresponding expression checked in `ct'.
      require
         ct.run_type = ct;
         ct.run_class /= Void
      deferred
      ensure
         nb_errors = 0 implies Result.result_type.is_run_type
      end;

feature

   isa_dca_inline_argument: INTEGER is
         -- Interpretation of the Result :
         --    -1 : yes and no ARGUMENT_NAME used
         --     0 : not inlinable
         --   > 0 : inlinable and ARGUMENT_NAME rank is used.
      require
         run_control.boost and small_eiffel.is_ready
      deferred
      ensure
         Result >= -1
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      require
         formal_arg_type /= Void;
         isa_dca_inline_argument /= 0
      deferred
      end;

   assertion_check(tag: CHARACTER) is
         -- Assume the current code in inside some assertion (a
         -- require clause or some class invariant for example)..
         -- The `tag' mangling is :
         --   'R' when we are inside some require clause.
         --   'E' when we are inside some ensure clause.
         --   '_' for all other assertions.
         -- This flag is used to check VAPE and VEEN as well.
      require
         run_control.no_check;
         ("RE_").has(tag)
      deferred
      end;

feature  -- Handling of precedence (priority of expressions) :

   precedence: INTEGER is
      deferred
      ensure
         1 <= Result and Result <= atomic_precedence
      end;

feature

   frozen add_comment(c: COMMENT): EXPRESSION is
         -- Attach `c' to the receiver.
      do
         if c = Void or else c.count = 0 then
            Result := Current;
         else
            !EXPRESSION_WITH_COMMENT!Result.make(Current,c);
         end;
      end;

   frozen base_class_written: BASE_CLASS is
         -- The base class where this expression is written.
      do
         Result := start_position.base_class;
      end;

   frozen written_in: CLASS_NAME is
         -- The name of the base class where this expression is written.
      do
         Result := start_position.base_class_name;
      end;

   afd_check is
         -- After Falling Down Check.
      deferred
      end;

feature -- To produce C code :

   collect_c_tmp is
         -- Traverse the expression to collect needed C tmp variables
         -- just before `compile_to_c'.
      require
         small_eiffel.is_ready
      deferred
      end;

   compile_to_c is
         -- Produce C code to access the value of the Current
         -- expression : user's expanded are no longuer pointer.
      require
         small_eiffel.is_ready;
         cpp.on_c
      deferred
      ensure
         cpp.on_c
      end;

   mapping_c_target(formal_type: TYPE) is
         -- Produce C code in order to pass Current expression as
         -- the target of a feature call.
         -- When it is needed, C code to check invariant is
         -- automatically added as well as a C cast according to
         -- the destination `formal_type'.
      require
         small_eiffel.is_ready;
         formal_type.at_run_time
      deferred
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
         -- Produce C code in order to pass Current expression as an
         -- argument of the feature called.
         -- Thus, it is the same jobs as `mapping_c_target' without
         -- the invariant call.
      require
         small_eiffel.is_ready
      deferred
      end;

   c_declare_for_old is
         -- Produce C code to declare `old' expression variables.
      require
         small_eiffel.is_ready;
         cpp.on_c
      deferred
      ensure
         cpp.on_c
      end;

   compile_to_c_old is
         -- Produce C code to memorize `old' expression values.
      require
         small_eiffel.is_ready;
         cpp.on_c
      deferred
      ensure
         cpp.on_c
      end;

feature  -- To produce C code :

   c_simple: BOOLEAN is
         -- True when the C code of `compile_c' has no side effect at
         -- and `compile_to_c' on the corresponding simple expression
         -- can be called more than once without any problem.
      deferred
      end;

   can_be_dropped: BOOLEAN is
         -- True if evaluation of current expression has NO possible
         -- side effects. Thus, in such a case, an unused expression
         -- can be dropped (for example target of real procedure or
         -- real function).
      require
         small_eiffel.is_ready
      deferred
      end;

feature  -- Finding `int' Constant C expression :

   is_static: BOOLEAN is
         -- True if expression has always the same static
         -- value: INTEGER or BOOLEAN value is always the same
         -- or when reference is always the same (Void or the
         -- same manifest string for example).
      require
         small_eiffel.is_ready
      deferred
      end;

   static_value: INTEGER is
         -- Note: the result could be an EXPRESSION ... it seems
         -- to be a good idea.
      require
         is_static
      deferred
      end;

   is_pre_computable: BOOLEAN is
         -- Can the current expression be pre-computed in main
         -- function to speed up a once function ?
      require
         small_eiffel.is_ready
      deferred
      end;

feature -- For `compile_to_jvm' :

   compile_to_jvm is
         -- Produce Java byte code in order to push expression value
         -- on the jvm stack.
      require
         small_eiffel.is_ready
      deferred
      end;

   compile_target_to_jvm is
         -- Same as `compile_to_jvm', but add class invariant check
         -- when needed.
      require
         small_eiffel.is_ready
      deferred
      end;

   compile_to_jvm_old is
         -- Produce Java byte code to memorize `old' expression values.
      require
         small_eiffel.is_ready
      deferred
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
         -- Assume `result_type' conforms to `dest'.
         -- Produce Java byte code in order to convert the expression
         -- into `dest' (comparisons = and /=, argument passing and
         -- assignment).
         -- Result gives the space in the JVM stack.
         -- *** SHOULD BE REMOVE AS SOON AS IMPLICIT_CAST WILL BE 
         --     CORRECT ***
      require
         conversion_check(dest,result_type)
      deferred
      ensure
         Result >= 1
      end;

   frozen standard_compile_target_to_jvm is
      do
         compile_to_jvm;
         result_type.jvm_check_class_invariant;
      end;

   frozen standard_compile_to_jvm_into(dest: TYPE): INTEGER is
      require
         conversion_check(dest,result_type)
      do
         compile_to_jvm;
         Result := result_type.run_type.jvm_convert_to(dest);
      ensure
         Result >= 1
      end;

   conversion_check(dest, rt: TYPE): BOOLEAN is
      do
         Result := true;
         if rt.is_a(dest) then
         else
            eh.cancel;
            if dest.is_a(rt) then
            else
               warning(start_position,
                ". Impossible conversion (EXPRESSION).");
            end;
         end;
      end;

   jvm_branch_if_false: INTEGER is
         -- Gives the `program_counter' to be resolved.
      require
         result_type.is_boolean
      deferred
      end;

   jvm_branch_if_true: INTEGER is
         -- Gives the `program_counter' to be resolved.
      require
         result_type.is_boolean
      deferred
      end;

   jvm_assign is
         -- Basic assignment using value on top of stack.
      require
         is_writable
      deferred
      end;

feature {NONE}

   frozen jvm_standard_branch_if_false: INTEGER is
         -- Gives the `program_counter' to be resolved.
      require
         result_type.is_boolean
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifeq;
      end;

   frozen jvm_standard_branch_if_true: INTEGER is
         -- Gives the `program_counter' to be resolved.
      require
         result_type.is_boolean
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifne
      end;

feature

   to_integer: INTEGER is
      do
         error(start_position,fz_iinaiv);
      end;

feature -- Pretty printing :

   pretty_print is
         -- Start the `pretty_print' process.
      require
         fmt.indent_level >= 1;
      deferred
      ensure
         fmt.indent_level = old fmt.indent_level;
      end;

   print_as_target is
         -- Print the expression viewed as a target plus the
         -- corresponding dot when it is necessary.
      deferred
      end;

   bracketed_pretty_print is
         -- Add bracket only when it is necessary.
      deferred
      end;

feature -- For `short' :

   short is
      deferred
      end;

   short_target is
         -- A target with the following dot if needed.
      deferred
      end;

   frozen bracketed_short is
      do
         short_print.hook_or("open_b","(");
         short;
         short_print.hook_or("close_b",")");
      end;

end -- EXPRESSION
