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
class TYPE_LIKE_CURRENT
   --
   -- For : like Current
   --

inherit TYPE_ANCHORED;

creation make, with

feature

   run_type: TYPE;

feature

   is_like_current: BOOLEAN is true;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

feature {NONE}

   make(sp: like start_position) is
      require
         not sp.is_unknown
      do
         start_position := sp;
      ensure
         start_position = sp
      end;

   with(model: like Current; rt: TYPE) is
      require
         model /= Void;
         rt /= Void
      do
         start_position := model.start_position;
         run_type := rt;
      ensure
         start_position = model.start_position;
         run_type = rt
      end;

feature

   static_base_class_name: CLASS_NAME is
      do
         Result := start_position.base_class_name;
      end;

   is_run_type: BOOLEAN is
      do
         Result := run_type /= Void;
      end;

   to_runnable(ct: TYPE): like Current is
      do
         if run_type = Void then
            run_type := ct;
            Result := Current;
         elseif run_type = ct then
            Result := Current;
         else
            !!Result.with(Current,ct);
         end;
      end;

   written_mark: STRING is
      do
         Result := as_like_current;
      end;

   is_a(other: TYPE): BOOLEAN is
      do
         if other.is_like_current then
            Result := true;
         else
            Result := run_type.is_a(other)
         end;
      end;

feature {TYPE}

   short_hook is
      do
         short_print.hook_or("like","like ");
         short_print.hook_or(as_current,as_current);
      end;

end -- TYPE_LIKE_CURRENT
