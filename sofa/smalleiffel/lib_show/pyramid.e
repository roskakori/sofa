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
class PYRAMID
   --
   -- Solving the problem of the Pyramid for small pyramid only.
   --
   -- This program uses the back-tracking method.
   -- Its goal is to try to fill a pyramid by making a substraction
   -- between two succesive columns and to take its absolute value.
   -- The result is put on the next line.
   -- Example:
   --  6   14   15   3   13
   --    8    1   12  10
   --       7   11   2
   --         4    9
   --            5
   --
   -- See also pyramid2, which run faster than this first solution.
   
inherit ANY redefine out_in_tagged_out_memory end;

creation make

feature

   size: INTEGER;

   make is
      do
         if argument_count = 0 then
            std_output.put_string("Want to compute a small pyramid ?%N%
                                  %Enter a small number (> 1): ");
            std_output.flush;
            std_input.read_integer;
            size := std_input.last_integer;
         else
            size := argument(1).to_integer;
         end;
         if size <= 1 then
            std_output.put_string("You feel sick ?%N");
         elseif size > biggest_one then
            std_output.put_string("Value too big for this method.%N");
         else
            !!elem.make(1,max);
            if fill_up(1) then
               std_output.put_string("Full pyramid:%N");
               print_on(std_output);
            else
               std_output.put_string("Unable to fill_up such one.%N");
            end;
         end;
      end;
   
   max: INTEGER is
      do
         Result := (size * (size + 1)) // 2;
      end;

   out_in_tagged_out_memory is
      local
         lig,col,nb: INTEGER;
      do
         from
            lig := 1;
            col := 1;
            nb := 0;
         until
            nb = max
         loop
            if col = 1 then
               tagged_out_memory.extend('%N');
            end;
            (elem.item(indice(lig,col))).append_in(tagged_out_memory);
            tagged_out_memory.append(" ");
            if col = size - lig + 1 then
               col := 1 ;
               lig := lig + 1 ;
            else
               col := col + 1;
            end;
            nb := nb + 1;
         end;
         tagged_out_memory.extend('%N');
      end;

   belongs_to(nb: INTEGER): BOOLEAN is
      require
         too_small: nb >= 1;
         too_large: nb <= max
      local
         i: INTEGER;
         found: BOOLEAN;
      do
         from
            i := 1;
         until
            ((i > max) or found)
         loop
            found := (nb = elem.item(i));
            i := i + 1;
         end;
         Result := found;
      end;

   propagate (col, val_column_1: INTEGER): BOOLEAN is
      require
         val_column_1.in_range(1,max);
         col.in_range(1,size)
      local
         stop: BOOLEAN;
         lig: INTEGER;
         val: INTEGER;
      do
         if belongs_to(val_column_1) then
            Result := false ;
         else
            from
               elem.put(val_column_1,indice(1,col));
               lig := 1;
               val := val_column_1;
               stop := false;
               Result := true;
            until
               stop
            loop
               lig := lig + 1;
               if lig > col then
                  stop := true;
               else
                  val := val - elem.item(indice(lig-1,col-lig+1));
		  val := val.abs;
                  if belongs_to(val) then
                     clear_column(col);
                     stop := true;
                     Result := false;
                  else
                     elem.put(val,indice(lig,col-lig+1));
                  end;
               end;
            end;
         end;
      end;

   fill_up (col: INTEGER): BOOLEAN is
      require
         col >= 1;
      local
         stop: BOOLEAN;
         nb: INTEGER;
      do
         if col > size then
            Result := true;
         else
            from
               stop := false;
               nb := max;
            until
               stop
            loop
               if belongs_to(nb) then
                  nb := nb - 1;
                  stop := (nb = 0);
               elseif propagate(col,nb) then
                  if  fill_up(col + 1) then
                     stop := true;
                  else
                     clear_column(col);
                     nb := nb - 1;
                     stop := (nb = 0);
                  end;
               else
                  nb := nb - 1;
                  stop := (nb = 0);
               end;
            end;
            Result := (nb > 0);
         end;
      end;

feature {NONE}

   elem: ARRAY[INTEGER];

   case_vide: INTEGER is 0;

   biggest_one: INTEGER is 10;

   indice (lig,col: INTEGER): INTEGER is
      require
         lig_trop_petit: lig >= 1 ;
         lig_trop_grand: lig <= size ;
         col_trop_petit: col >= 1 ;
         col_trop_grand: col <= size ;
      local
         l: INTEGER ;
      do
         l:= size - lig + 1;
         Result := max - ((l * (l + 1)) // 2) + col;
      ensure
         Result >= 1 ;
         Result <= max ;
      end;

   clear_column (col: INTEGER) is
      require
         col >= 1;
         col <= size;
      local
         lig: INTEGER;
      do
         from
            lig := 1;
         until
            lig > col
         loop
            elem.put(case_vide,indice(lig,col-lig+1));
            lig := lig + 1;
         end;
      end; -- clear_column

end --  PYRAMID
