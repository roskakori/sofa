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
deferred class BOOLEAN_CONSTANT
   --
   -- Root class of E_FALSE and E_TRUE.
   --

inherit BASE_TYPE_CONSTANT;

feature {NONE}

   make(sp: like start_position) is
      do
         start_position := sp;
      end;

feature

   frozen c_simple: BOOLEAN is true;

   frozen static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_boolean);
      end;

   frozen result_type: TYPE_BOOLEAN is
      do
         Result := type_boolean;
      end;

   frozen compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

end -- BOOLEAN_CONSTANT

