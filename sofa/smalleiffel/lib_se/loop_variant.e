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
deferred class LOOP_VARIANT
   --
   -- For a variant clause of a loop.
   --
   --    LOOP_VARIANT_1 : no tag.
   --    LOOP_VARIANT_2 : with tag.
   --

inherit GLOBALS;

feature

   comment: COMMENT;

   expression: EXPRESSION;

   current_type: TYPE;

feature

   frozen use_current: BOOLEAN is
      do
         Result := expression.use_current;
      end;

   pretty_print is
      deferred
      end;

   start_position: POSITION is
      do
         Result := expression.start_position;
      end;

   frozen to_runnable(ct: TYPE): like Current is
      local
         e: like expression;
      do
         if current_type = Void then
            current_type := ct;
            e := expression.to_runnable(ct);
            if e = Void then
               error(start_position,"Bad loop variant.");
            else
               expression := e;
               if not expression.result_type.is_integer then
                  error(expression.start_position,
                        "Expression of variant must be INTEGER.");
               end;
            end;
            if nb_errors = 0 then
               Result := Current;
            end;
         else
            Result := twin;
            Result.set_current_type(Void);
            Result := Result.to_runnable(ct);
         end;
      end;

feature {E_LOOP}

   frozen afd_check is
      do
         expression.afd_check;
      end;

feature {LOOP_VARIANT}

   frozen set_current_type(ct: like current_type) is
      do
         current_type := ct;
      ensure
         current_type = ct;
      end;

invariant

   expression /= Void

end -- LOOP_VARIANT

