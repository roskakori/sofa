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
deferred class FEATURE_NAME
   --
   -- Root of SIMPLE_FEATURE_NAME, INFIX_NAME, PREFIX_NAME and 
   --                      FROZEN_FEATURE_NAME.
   --

inherit NAME;

feature

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   c_simple: BOOLEAN is true;

feature

   to_key: STRING is
         -- To avoid clash between different kinds of names (for
         -- example when using same infix/prefix operator).
         -- Also used to compute the C name or the JVM name.
      deferred
      ensure
         not Result.is_empty;
         Result = string_aliaser.item(Result)
      end;

   is_frozen: BOOLEAN is
      deferred
      end;

   mapping_c_in(str: STRING) is
      deferred
      end;

   frozen origin_base_class: BASE_CLASS is
         -- Void or the BASE_CLASS where Current is written in.
      do
         Result := start_position.base_class;
      end;
   
feature

   is_freeop: BOOLEAN is
      do
         inspect
            to_string @ 1
         when '@', '#', '|', '&' then
            Result := true;
         else
         end;
      end;

   declaration_in(str: STRING) is
      require
         str /= Void
      deferred
      end

   declaration_pretty_print is
      deferred
      end;

   short is
      deferred
      end;

   frozen afd_check is
      do
      end;

feature {E_FEATURE}

   undefine_in(bc: BASE_CLASS) is
      require
         bc /= Void
      do
         if is_frozen then
            error(start_position,
                  "A frozen feature must not be undefined (VDUS).");
            bc.fatal_undefine(Current);
         end;
      end;

feature {RUN_FEATURE,FEATURE_NAME}

   put_cpp_tag is
      deferred
      end;

end -- FEATURE_NAME
