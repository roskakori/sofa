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
deferred class CREATION_CALL
--
-- For creation all kinds of creation call : CREATION_CALL_1,
-- CREATION_CALL_2, CREATION_CALL_3 and CREATION_CALL_4.
--
-- Sorry for the following class names, but I have no more ideas at this
-- time :-(. Classification used is :
--      CREATION_CALL_1    -->    !!foo
--      CREATION_CALL_2    -->    !BAR!foo
--      CREATION_CALL_3    -->    !!foo.bar(...)
--      CREATION_CALL_4    -->    !BAR!foo.bar(...)
--

inherit INSTRUCTION;

feature

   end_mark_comment: BOOLEAN is false;

   start_position: POSITION;
         -- Of the first character '!'.

   type: TYPE is
         -- Explicit optional generator name if any.
      deferred
      end;

   writable: EXPRESSION;
         -- The target of the creation call.

   call: PROC_CALL is
         -- Optional initialisation call if any.
         -- Target of `call' is `writable'.
      deferred
      end;

   run_feature: RUN_FEATURE;
         -- When checked, if any, the only one corresponding
         -- creation procedure.

   arg_count: INTEGER is
      do
         if call /= Void then
            Result := call.arg_count;
         end;
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      local
         t: TYPE;
      do
         if type /= Void then
            t := type;
         else
            t := writable.result_type;
         end;
         if t.is_anchored then
         elseif t.is_generic then
         else
            if call = Void then
               Result := writable.stupid_switch(r);
            else
               Result := call.stupid_switch(r);
            end;
         end;
      end;

feature {CREATION_CALL}

   current_type: TYPE;

feature {NONE}

   check_writable(ct: TYPE) is
      require
         current_type = Void;
         ct /= Void
      local
         w: like writable;
      do
         current_type := ct;
         w := writable.to_runnable(ct);
         if w = Void then
            eh.add_position(writable.start_position);
            fatal_error("Bad writable target for creation.");
         else
            writable := w;
         end;
      ensure
         current_type = ct
      end;

   check_created_type(t: TYPE) is
      require
         t.is_run_type
      local
         rt: like t;
      do
         rt := t.run_type;
         if small_eiffel.short_flag then
         elseif rt.base_class.is_deferred then
            eh.add_type(rt," is deferred. ");
            warning(start_position,"Cannot create object.");
         end;
         if t.is_formal_generic then
            eh.add_position(start_position);
            eh.append("Creation call on formal generic type (");
            eh.add_type(t,").");
            eh.print_as_fatal_error;
         end;
         rt.run_class.set_at_run_time;
      end;

   frozen c2c_opening(t: TYPE) is
      require
         t.is_reference
      local
         rc: RUN_CLASS;
         once_result: ONCE_RESULT;
      do
         rc := t.run_class;
         cpp.se_trace_ins(start_position);
         cpp.put_character('{');
         gc_handler.allocation(rc);
         cpp.expanded_attributes(t);
         once_result ?= writable;
         if once_result /= Void then
            cpp.put_string(once_result.c_variable_name);
            cpp.put_string("=((T0*)n);%N");
         end;
      end;

   frozen c2c_closing(t: TYPE) is
      require
         t.is_reference
      local
         once_result: ONCE_RESULT;
      do
         once_result ?= writable;
         if once_result = Void then
            writable.compile_to_c;
            cpp.put_string("=((T0*)n);%N");
         end;
         if cpp.call_invariant_start(t) then
            cpp.put_character('n');
            cpp.call_invariant_end;
            cpp.put_character(';');
         end;
         cpp.put_character('}');
         cpp.put_character('%N');
      end;

   frozen c2c_clear_expanded(id: INTEGER) is
         -- Produce C code to reset the writable expanded
         -- to the default value.
      do
         writable.compile_to_c;
         cpp.put_character('=');
         cpp.put_character('M');
         cpp.put_integer(id);
         cpp.put_string(fz_00);
      end;

   compile_to_jvm0(t: TYPE) is
         -- Push the new object with default initialization.
      require
         t /= Void
      local
         dummy: INTEGER;
      do
         if t.is_reference then
            t.run_class.jvm_basic_new;
         else
            dummy := t.jvm_push_default;
         end;
      end;

invariant

   not start_position.is_unknown;

   writable.is_writable;

end -- CREATION_CALL

