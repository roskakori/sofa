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
class LOOP_VARIANT_2

inherit LOOP_VARIANT;

creation {ANY}
   make

feature {ANY}

   tag: TAG_NAME;

   make(t: like tag; exp: like expression; c: like comment) is
      require
         t /= Void;
         exp /= Void;
      do
         comment := c;
         tag := t;
         expression := exp;
      ensure
         comment = c;
         tag = t;
         expression = exp;
      end;

   pretty_print is
      do
         if comment /= Void then
            comment.pretty_print;
         else
            fmt.indent;
         end;
         fmt.put_string(tag.to_string);
         fmt.put_string(": ");
         expression.pretty_print
      end;

invariant

   tag /= Void

end -- LOOP_VARIANT_2

