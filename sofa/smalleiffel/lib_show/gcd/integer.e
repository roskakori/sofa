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
expanded class INTEGER

inherit
   INTEGER_REF
      redefine
         infix "+", infix "-", infix "*", infix "/", infix "\\", infix "//",
         infix "<", prefix "-", prefix "+"
      end;

feature {ANY}

   infix "+"(other: INTEGER): INTEGER is
         -- Add `other' to Current.
      external "SmallEiffel"
      end;

   infix "-" (other : INTEGER): INTEGER is
         -- Subtract `other' from Current.
      external "SmallEiffel"
      end;

   infix "*" (other : INTEGER) : INTEGER is
         -- Multiply `other' by Current.
      external "SmallEiffel"
      end;

   infix "/" (other : INTEGER): INTEGER is
         -- Divide Current by `other'.
         -- Note : Integer division
      external "SmallEiffel"
      end;

   infix "//" (other : INTEGER) : INTEGER is
         -- Divide Current by `other'.
         -- Note : Integer division
      external "SmallEiffel"
      end;

   infix "\\" (other : INTEGER) : INTEGER is
         -- Remainder of division of Current by `other'.
      external "SmallEiffel"
      end;

   infix "<" (other: INTEGER): BOOLEAN is
         -- Is Current less than `other'?
      external "SmallEiffel"
      end;

   prefix "+": INTEGER is
      do
         Result := Current
      end;

   prefix "-" : INTEGER is
         -- Unary minus of Current
      external "SmallEiffel"
      end;

   to_string: STRING is
         -- Convert the INTEGER into a new allocated STRING.
         -- Note: see `append_in' to save memory.
      do
         !!Result.make(0);
         append_in(Result);
      end;

   append_in(str: STRING) is
         -- Append the equivalent of `to_string' at the end of
         -- `str'. Thus you can save memory because no other
         -- STRING is allocate for the job.
      require
         str /= Void;
      local
         val, i: INTEGER;
      do
         if Current = 0 then
            str.extend('0');
         else
            if Current < 0 then
               str.extend('-');
               (- Current).append_in(str);
            else
               from
                  i := str.count + 1;
                  val := Current;
               until
                  val = 0
               loop
                  str.extend((val \\ 10).digit);
                  val := val // 10;
               end;
               from
                  val := str.count;
               until
                  i >= val
               loop
                  str.swap(i,val);
                  val := val - 1;
                  i := i + 1;
               end;
            end;
         end;
      end;

   to_string_format(s: INTEGER): STRING is
         -- Same as `to_string' but the result is on `s' character and the
         -- number is right aligned.
         -- Note: see `append_in_format' to save memory.
      require
         to_string.count <= s;
      do
         from
            tmp_string.clear;
            append_in(tmp_string);
         until
            tmp_string.count >= s
         loop
            tmp_string.add_first(' ');
         end;
         Result := clone(tmp_string);
      ensure
         Result.count = s;
      end;

   append_in_format(str: STRING; s: INTEGER) is
         -- Append the equivalent of `to_string_format' at the end of
         -- `str'. Thus you can save memory because no other
         -- STRING is allocate for the job.
      do
         from
            tmp_string.clear;
            append_in(tmp_string);
         until
            tmp_string.count >= s
         loop
            tmp_string.add_first(' ');
         end;
         str.append(tmp_string);
      ensure
         str.count >= (old str.count) + s;
      end;

   digit: CHARACTER is
         -- Gives the corresponding CHARACTER for range 0..9.
      require
         0 <= Current;
         Current <= 9;
      do
         Result := ("0123456789").item(Current + 1);
      ensure
         ("0123456789").has(Result);
         Result.value = Current;
      end;

   gcd(other: INTEGER): INTEGER is
         -- Great Common Divisor of `Current' and `other'.
      require
         Current > 0;
         other > 0;
      local
         the_other: INTEGER;
      do
         from
            Result := Current;
            the_other := other;
         invariant
            Result > 0;
            the_other > 0;
            Result.gcd(the_other) = Current.gcd(other);
         variant
            Result.max(the_other)
         until
            Result = the_other
         loop
            if Result > the_other then
               Result := Result - the_other;
            else
               the_other := the_other - Result;
            end;
         end;
      ensure
         Result = other.gcd(Current);
      end;

feature {NONE}

   tmp_string: STRING is "0123456789";

   to_character_table : STRING is "%
         %%/000/%/001/%/002/%/003/%/004/%/005/%/006/%/007/%
         %%/008/%/009/%/010/%/011/%/012/%/013/%/014/%/015/%
         %%/016/%/017/%/018/%/019/%/020/%/021/%/022/%/023/%
         %%/024/%/025/%/026/%/027/%/028/%/029/%/030/%/031/%
         %%/032/%/033/%/034/%/035/%/036/%/037/%/038/%/039/%
         %%/040/%/041/%/042/%/043/%/044/%/045/%/046/%/047/%
         %%/048/%/049/%/050/%/051/%/052/%/053/%/054/%/055/%
         %%/056/%/057/%/058/%/059/%/060/%/061/%/062/%/063/%
         %%/064/%/065/%/066/%/067/%/068/%/069/%/070/%/071/%
         %%/072/%/073/%/074/%/075/%/076/%/077/%/078/%/079/%
         %%/080/%/081/%/082/%/083/%/084/%/085/%/086/%/087/%
         %%/088/%/089/%/090/%/091/%/092/%/093/%/094/%/095/%
         %%/096/%/097/%/098/%/099/%/100/%/101/%/102/%/103/%
         %%/104/%/105/%/106/%/107/%/108/%/109/%/110/%/111/%
         %%/112/%/113/%/114/%/115/%/116/%/117/%/118/%/119/%
         %%/120/%/121/%/122/%/123/%/124/%/125/%/126/%/127/%
         %";

end -- INTEGER
