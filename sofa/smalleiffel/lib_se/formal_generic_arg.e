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
class FORMAL_GENERIC_ARG
   --
   -- To store one formal generic argument.
   --

inherit GLOBALS;

creation make

feature

   name: CLASS_NAME;
         -- Name of the formal generic argument.

   constraint: TYPE;
	 -- Non Void if any.

   rank: INTEGER;
         -- In the corresponding declation list.
   
   constrained: BOOLEAN is
      do
         Result := (constraint /= void);
      end;
   
   start_position: POSITION is
      do
         Result := name.start_position;
      end;
   
   pretty_print is
      do
         name.pretty_print;
         if constrained then
            fmt.level_incr;
            fmt.put_string("->");
            constraint.pretty_print;
            fmt.level_decr;
         end;
      end;
   
   short is
      do
         short_print.a_class_name(name);
         if constrained then
            short_print.hook_or("arrow","->");
            constraint.short;
         end;
      end;

feature {FORMAL_GENERIC_LIST}

   check_generic_formal_arguments is
      do
         if small_eiffel.is_used(name.to_string) then
            eh.add_position(name.start_position);
            fatal_error("A formal generic argument must not be the %
                        %name of an existing class (VCFG.1).");

         end;
      end;

   set_rank(r: like rank) is
      require
	 r > 0
      do
	 rank := r;
      ensure
	 rank = r
      end;

   constraint_substitution(fga: like Current; r: INTEGER) is
	 -- Substitute in the previously read `Current' `constraint'
	 -- all occurrences of `fga' which will be added at rank `r'.
      local
	 fgan: STRING;
	 cn: CLASS_NAME;
      do
	 if constraint /= Void then
	    fgan := fga.name.to_string;
	    if constraint.is_generic then
	       substitute(constraint.generic_list,fga,r,fgan);
	    else
	       cn := constraint.base_class_name;
	       if fgan = cn.to_string then
		  !TYPE_FORMAL_GENERIC!constraint.make(cn,fga,r);
	       end;
	    end;
	 end;
      end;
   
feature {NONE}

   substitute(gl: ARRAY[TYPE]; fga: like Current; r: INTEGER; fgan: STRING) is
	 -- Substitute recursively all occurrences of `fgan' in `gl'.
      require
	 gl /= Void;
	 fgan = fga.name.to_string
      local
	 i: INTEGER;
	 tfg: TYPE_FORMAL_GENERIC;
	 t: TYPE;
	 cn: CLASS_NAME;	 
      do
	 from
	    i := gl.upper;
	 until
	    i < gl.lower
	 loop
	    t := gl.item(i);
	    if t.is_generic then
	       substitute(t.generic_list,fga,r,fgan);
	    else
	       cn := t.base_class_name;
	       if fgan = cn.to_string then
		  !!tfg.make(cn,fga,r);
		  gl.put(tfg,i);
	       end;
	    end;
	    i := i - 1;
	 end;
      end;

   make(n: like name; c: like constraint) is
      require
         n /= Void
      do
         name := n;
         constraint := c;
      ensure
         name = n;
         constraint = c
      end;

invariant

   name /= Void;

end -- FORMAL_GENERIC_ARG

