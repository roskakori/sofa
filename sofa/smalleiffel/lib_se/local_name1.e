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
class LOCAL_NAME1
   --
   -- A local name in some declaration list.
   --

inherit LOCAL_ARGUMENT1; LOCAL_NAME;

creation make

feature {NONE}

   is_used: BOOLEAN;
         -- Is the local name really used inside the living
         -- code ?

feature {NONE}

   make(sp: POSITION; n: STRING) is
      require
         not sp.is_unknown;
         n = string_aliaser.item(n)
      do
         start_position := sp;
         to_string := n;
      ensure
         start_position = sp;
         to_string = n
      end;

feature

   assertion_check(tag: CHARACTER) is
      do
      end;

   to_runnable(ct: TYPE): like Current is
      require
	 result_type /= Void
      local
         rt: TYPE;
      do
         rt := result_type.to_runnable(ct);
         if rt = Void then
            eh.add_position(result_type.start_position);
            error(start_position,"Bad local variable.");
         elseif rt.run_class = Void then
	    -- To make this RUN_CLASS live.
         end;
         if rt = result_type then
            Result := Current;
         else
            Result := twin;
            Result.set_result_type(rt);
         end;
      end;

   produce_c: BOOLEAN is
         -- True if C code must be produced (local is really
         -- used or it is a user expanded with possibles
         -- side effects).
      local
         t: TYPE;
      do
         if is_used then
            Result := true;
         else
            t := result_type.run_type;
            if t.is_expanded then
               Result := not t.is_basic_eiffel_expanded;
            end;
         end;
      end;

feature {LOCAL_VAR_LIST}

   c_declare is
         -- C declaration of the local.
      local
         t: TYPE;
      do
         if produce_c then
            t := result_type.run_type;
            tmp_string.clear;
            t.c_type_for_result_in(tmp_string);
            tmp_string.extend(' ');
            cpp.put_string(tmp_string);
            cpp.print_local(to_string);
            cpp.put_character('=');
            t.c_initialize;
            cpp.put_string(fz_00);
         elseif run_control.debug_check then
            warning(start_position,"Unused local variable.");
         end;
      end;

   c_frame_descriptor(t: TYPE) is
      require
         run_control.no_check
      do
         if produce_c then
            c_frame_descriptor_local_count.increment;
            c_frame_descriptor_format.append(to_string);
            c_frame_descriptor_locals.append("(void**)&_");
            c_frame_descriptor_locals.append(to_string);
            c_frame_descriptor_locals.extend(',');
            t.c_frame_descriptor;
         end;
      end;

feature {DECLARATION_LIST}

   name_clash(ct: TYPE) is
      do
         name_clash_for(ct,"Conflict between local/feature name (VRLE).");
      end;

feature {LOCAL_NAME2}

   set_is_used is
      do
         is_used := true;
      end;

end -- LOCAL_NAME1

