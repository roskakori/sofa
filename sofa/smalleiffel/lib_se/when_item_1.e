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
class WHEN_ITEM_1
--
-- To store a single value of a when clause in an inspect instruction.
--
-- Exemple :
--          inspect ...
--              when foo, bar, then ...
--

inherit WHEN_ITEM;

creation {E_WHEN,WHEN_ITEM_1}
   make

feature {ANY}

   expression: EXPRESSION;

   expression_value: INTEGER;

feature {NONE}

   make(v: like expression) is
      require
         v /= Void
      do
         expression := v;
      ensure
         expression = v
      end;

feature {ANY}

   start_position: POSITION is
      do
         Result := expression.start_position;
      end;

feature {E_WHEN, WHEN_ITEM_1}

   to_runnable_integer(ew: like e_when): like Current is
      local
         ct: TYPE;
         e: like expression;
      do
         if e_when = Void then
            e_when := ew;
            ct := small_eiffel.top_rf.current_type;
            e := expression.to_runnable(ct);
            if e /= Void and then e.result_type.is_integer then
               expression := e;
               expression_value := expression.to_integer;
               e_when.add_when_item_1(Current);
            else
               error(expression.start_position,fz_biv);
            end;
            Result := Current;
         else
            !!Result.make(expression);
            Result := Result.to_runnable_integer(ew);
         end;
      end;

   to_runnable_character(ew: like e_when): like Current is
      local
         ct: TYPE;
         e: like expression;
      do
         if e_when = Void then
            e_when := ew;
            ct := small_eiffel.top_rf.current_type;
            e := expression.to_runnable(ct);
            if e /= Void and then e.result_type.is_character then
               expression := e;
               expression_value := expression.to_integer;
               e_when.add_when_item_1(Current);
            else
               error(expression.start_position,fz_bcv);
            end;
            Result := Current;
         else
            !!Result.make(expression);
            Result := Result.to_runnable_character(ew);
         end;
      end;

   pretty_print is
      do
         expression.pretty_print;
      end;

feature {E_WHEN}

   eval(exp: INTEGER): BOOLEAN is
      do
         Result := expression_value = exp;
      end;

end -- WHEN_ITEM_1
