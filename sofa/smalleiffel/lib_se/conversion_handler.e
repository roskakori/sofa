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
class CONVERSION_HANDLER
   --
   -- Singleton object used to handle allowed automatic conversion from 
   -- Eiffel type to another Eiffel type.
   -- This singleton is shared via the GLOBALS.`conversion_handler' once function.
   --

inherit GLOBALS;

feature 
   
   implicit_cast(expression: EXPRESSION; destination_type: TYPE): EXPRESSION is
         -- If necessary, wrap `expression' inside an IMPLICIT_CAST invisible 
         -- wrapper object.
      require
         expression.result_type.is_a(destination_type)
      local
         source_bit, destination_bit: TYPE_BIT;
      do
         source := expression.result_type
         if source.run_time_mark = destination_type.run_time_mark then
            Result := expression;
         elseif source.is_reference then
            if destination_type.is_reference then
               -- Reference to Reference :
               Result := expression;
               generic_cast(destination_type);
            else
               -- Reference to Expanded :
               !IMPLICIT_CAST!Result.make(expression,destination_type);
            end;
         elseif destination_type.is_reference then
            -- Expanded to Reference :
            computes_for(source,destination_type);
            !IMPLICIT_CAST!Result.make(expression,destination);
         else
            -- Expanded to Expanded :
            if destination_type.is_real and then source.is_integer then
               -- INTEGER to REAL :
               !IMPLICIT_CAST!Result.make(expression,destination_type);
            elseif destination_type.is_double then
               if source.is_integer or else source.is_real then
                  -- INTEGER to DOUBLE or REAL to DOUBLE :
                  !IMPLICIT_CAST!Result.make(expression,destination_type);
               else
                  Result := expression;
               end;
            elseif destination_type.is_bit then
               source_bit ?= source.run_type;
               destination_bit ?= destination_type.run_type;
               if source_bit.nb /= destination_bit.nb then
                  !IMPLICIT_CAST!Result.make(expression,destination_type);
               else
                  Result := expression;
               end;
            else
               Result := expression;
               generic_cast(destination_type);
            end;
         end;
      ensure
         Result /= Void
      end;
   
feature {IMPLICIT_CAST}
   
   notify(expression: EXPRESSION; source_type, destination_type: TYPE) is
         -- Notify some really needed conversion of `expression' from 
         -- some `source_type' to some `destination_type'.
      require
         source_type.run_time_mark /= destination_type.run_time_mark;
         source_type.is_expanded or destination_type.is_expanded
      do
         computes_for(source_type,destination_type);
         if source_types.has(entry) then
            source := source_types.at(entry);
            if not source.is_a(source_type) then
               eh.cancel;
               source_types.put(source_type,entry);
               expressions.put(expression,entry);
            end;
         else
            if source.is_expanded then
               destination.run_class.set_at_run_time;
            end;
            source_types.put(source_type,entry);
            destination_types.put(destination_type,entry);
            if expression /= Void then
               expressions.put(expression,entry);
            end;
            -- *** To DEBUG ***
--            if true then
--               eh.append("CONVERSION_HANDLER.Notify : ");
--               eh.append(entry);
--               eh.append(" originally: from ");
--               eh.append(source_type.run_time_mark);
--               eh.append(" to ");
--               eh.append(destination_type.run_time_mark);
--               if expression /= Void then
--                  eh.add_position(expression.start_position);
--               end;
--               eh.print_as_warning;
--            end;
            --
         end;
      end;

feature {SWITCH, FORMAL_ARG_LIST, E_STRIP}

   passing(source_type, destination_type: TYPE) is
      do
         if source_type.is_expanded then
            if destination_type.is_reference then
               notify(Void,source_type,destination_type);
            end;
         elseif destination_type.is_expanded then
            notify(Void,source_type,destination_type);
         else
            source := source_type;
            generic_cast(destination_type);
         end;
      end;

feature {IMPLICIT_CAST,C_PRETTY_PRINTER,E_STRIP}

   c_function_call(source_type, destination_type: TYPE) is
      do
         computes_for(source_type,destination_type);
         if source.run_time_mark /= destination.run_time_mark then
            cpp.put_character('T');
            cpp.put_integer(source.id);
            cpp.put_string(fz_to_t);
            cpp.put_integer(destination.id);
            cpp.put_character('(');
         else
            cpp.put_string("/*NO_CONVERSION*/(");
         end;
      end;

feature {C_PRETTY_PRINTER}

   c_definitions is
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > source_types.count
         loop
            source := source_types.item(i);
            entry := source_types.key(i);
            destination := destination_types.at(entry);
            computes_for(source,destination);
            if source.is_bit then
               c_function_definition;
            elseif source.is_expanded and then destination.is_expanded then
               -- Because it is worthless or already done with #define in 
               -- "SmallEiffel/sys/runtime/base.h".
            else
               c_function_definition;
            end;
            i := i + 1;
         end;
      end;

feature {SMALL_EIFFEL}

   finish_falling_down is
      local
         i: INTEGER;
         source_type, destination_type: TYPE;
         rc1, rc2: RUN_CLASS;
      do
         from
            i := 1;
         until
            i > source_types.count
         loop
            source_type := source_types.item(i);
            entry := source_types.key(i);
            destination_type := destination_types.at(entry);
            computes_for(source_type,destination_type);
            if source.is_reference then
               if destination.is_expanded then
                  echo.put_string(entry);
                  echo.put_string(" (");
                  echo.put_string(source_type.run_time_mark);
                  echo.put_string(fz_to);
                  echo.put_string(destination_type.run_time_mark);
                  echo.put_string(")%N");
                  small_eiffel.reference_to_expanded(source_type);
               end;
            end;
            if source.is_user_expanded then
               if destination.is_reference then
                  rc1 := source.run_class;
                  rc2 := destination.run_class;
               end;
            elseif destination.is_user_expanded then
               if source.is_reference then
                  rc1 := source.run_class;
                  rc2 := destination.run_class;
               end;
            end;
            if rc1 /= Void then
               rc1.shared_attributes(rc2);
               rc2.shared_attributes(rc1);
               rc1 := Void;
            end;
            i := i + 1;
         end;
      end;

feature {NONE}

   source, destination: TYPE;
         -- Temporary memory to store actual `source' and `destination' type.

   entry: STRING;
         -- Temporary memory to store the `entry' in dictionaries.

   computes_for(source_type, destination_type: TYPE) is
         -- Compute actual `source' and `destination' as well as the 
         -- corresponding `entry' used for dictionaries.
      require
         source_type.is_expanded or destination_type.is_expanded
      do
         if source_type.is_expanded then
            source := source_type;
            if destination_type.is_expanded then
               destination := destination_type;
            else
               destination := source.actual_reference(destination_type);
            end;
         else
            destination := destination_type;
            source := destination.actual_reference(source_type);
         end;
         buffer.clear;
         buffer.append(source.run_time_mark);
         buffer.append(fz_to);
         buffer.append(destination.run_time_mark);
         entry := string_aliaser.item(buffer);
      end;

   source_types: DICTIONARY[TYPE,STRING] is
         -- All source types available from some `entry'.
      once
         !!Result.make;
      end;

   destination_types: DICTIONARY[TYPE,STRING] is
         -- All destination types available from `entry'.
      once
         !!Result.make;
      end;

   expressions: DICTIONARY[EXPRESSION,STRING] is
         -- This dictionary is used to warn the user about some 
         -- unwanted implicit objects allocation.
         -- Also use the same `entry' access key.
      once
         !!Result.make;
      end;

   c_function_definition is
         -- Called to produce the C convertion function for `entry', `source' 
         -- and `destination'.
      require
         source.run_time_mark /= destination.run_time_mark
      local
	 rc: RUN_CLASS;
      do
         echo.put_string("Conversion from ");
         echo.put_string(entry);
         echo.put_string(" in C function ");
         buffer.clear;
         destination.c_type_for_result_in(buffer);
         buffer.extend(' ');
         buffer.extend('T');
         source.id.append_in(buffer);
         buffer.append(fz_to_t);
         destination.id.append_in(buffer);
         buffer.extend('(');
         source.c_type_for_argument_in(buffer)
         buffer.append(" source)");
         echo.put_string(buffer);
         echo.put_string(fz_b6);
         if destination.is_expanded then
            if source.is_expanded then
	       -- expanded to expanded :
               buffer.copy("#define T");
               source.id.append_in(buffer);
               buffer.append(fz_to_t);
               destination.id.append_in(buffer);
               buffer.append("(x) (x)%N");
               cpp.put_string_on_h(buffer);
            else
	       -- reference to expanded :
               cpp.put_c_heading(buffer);
               buffer.copy("return (((");
               source.c_type_for_target_in(buffer);
               buffer.append(")source)->_item);%N");
               cpp.put_string(buffer);
               cpp.put_string(fz_12);
            end;
         else
	    -- expanded to reference :
            cpp.put_c_heading(buffer);
            cpp.put_character('T');
            cpp.put_integer(destination.id);
            cpp.put_character('*');
	    rc := destination.run_class;
            gc_handler.allocation_of("destination",rc);
	    if source.is_basic_eiffel_expanded then
	       cpp.put_string("destination->_item=source;%N");
	    else
	       cpp.put_string("memcpy((((Tid*)destination)");
	       if rc.is_tagged then
		  cpp.put_string("+1");
	       end;
	       cpp.put_string("),&source,sizeof(source));%N");
	    end;
            cpp.put_string("return ((T0*)destination);%N}%N");
         end;
      end;

   generic_cast(destination_type: TYPE) is
      local
         s_gl, d_gl: ARRAY[TYPE];
         s, d: TYPE;
         i, j: INTEGER;
      do
         if source.is_generic and then destination_type.is_generic then
            s_gl := source.generic_list;
            d_gl := destination_type.generic_list;
            from
               i := s_gl.upper;
            until
               i = 0
            loop
               from
                  j := d_gl.upper;
                  s := s_gl.item(i);
               until
                  j = 0
               loop
                  d := d_gl.item(j);
                  if d.is_a(s) then
                     passing(d,s);
                  else
                     eh.cancel;
                  end;
                  j := j - 1;
               end;
               i := i - 1;
            end;
         end;
      end;

   buffer: STRING is
      once
         !!Result.make(128);
      end;

   fz_to: STRING is " to ";

   singleton_memory: CONVERSION_HANDLER is
      once
         Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- CONVERSION_HANDLER
