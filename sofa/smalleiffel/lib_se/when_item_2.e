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
class WHEN_ITEM_2
--
-- To store a slice value of a when clause in an inspect instruction.
--
-- Exemple :
--          inspect ...
--              when foo .. bar, then ...
--

inherit WHEN_ITEM;

creation {E_WHEN,WHEN_ITEM_2}
   make

feature {ANY}

   lower, upper: EXPRESSION;

   lower_value, upper_value: INTEGER;

feature {NONE}

   make(l, u: EXPRESSION) is
      require
         l /= Void;
         u /= Void
      do
         lower := l;
         upper := u;
      ensure
         lower = l;
         upper = u
      end;

feature {ANY}

   start_position: POSITION is
      do
         Result := lower.start_position;
      end;

feature {E_WHEN,WHEN_ITEM_2}

   to_runnable_integer(ew: like e_when): like Current is
      local
         ct: TYPE;
         v: like lower;
      do
         if e_when = Void then
            e_when := ew;
            ct := small_eiffel.top_rf.current_type;
            v := lower.to_runnable(ct);
            if v /= Void and then v.result_type.is_integer then
               lower := v;
               lower_value := lower.to_integer;
            else
               error(lower.start_position,fz_biv);
            end;
            v := upper.to_runnable(ct);
            if v /= Void and then v.result_type.is_integer then
               upper := v;
               upper_value := upper.to_integer;
            else
               error(upper.start_position,fz_biv);
            end;
            e_when.add_when_item_2(Current);
            Result := Current;
         else
            !!Result.make(lower,upper);
            Result := Result.to_runnable_integer(ew);
         end;
      end;

   to_runnable_character(ew: like e_when): like Current is
      local
         ct: TYPE;
         v: like lower;
      do
         if e_when = Void then
            e_when := ew;
            ct := small_eiffel.top_rf.current_type;
            v := lower.to_runnable(ct);
            if v /= Void and then v.result_type.is_character then
               lower := v;
               lower_value := lower.to_integer;
            else
               error(lower.start_position,fz_bcv);
            end;
            v := upper.to_runnable(ct);
            if v /= Void and then v.result_type.is_character then
               upper := v;
               upper_value := upper.to_integer;
            else
               error(upper.start_position,fz_bcv);
            end;
            e_when.add_when_item_2(Current);
            Result := Current;
         else
            !!Result.make(lower,upper);
            Result := Result.to_runnable_character(ew);
         end;
      end;

   pretty_print is
      do
         lower.pretty_print;
         fmt.put_string("..");
         upper.pretty_print;
      end;

feature {E_WHEN}

   eval(exp: INTEGER): BOOLEAN is
      do
         Result := (lower_value <= exp) and (exp <= upper_value);
      end;

end -- WHEN_ITEM_2

