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
deferred class LOCAL_ARGUMENT1

inherit LOCAL_ARGUMENT;

feature

   to_string: STRING;

   result_type: TYPE;

   rank: INTEGER;

feature {DECLARATION_LIST}

   set_rank(r: like rank) is
      require
         r >= 1
      do
         rank := r;
      ensure
         rank = r
      end;

feature {LOCAL_ARGUMENT1,DECLARATION_LIST,DECLARATION}

   set_result_type(rt: like result_type) is
      require
         rt /= Void
      do
         result_type := rt;
      ensure
         result_type = rt
      end;

feature {DECLARATION_LIST}

   name_clash(ct: TYPE) is
         -- Check name clash between argument/feature or name clash
         -- between local/feature.
         -- Note : clash between local/argument are checked during
         --        parsing.
      require
         ct /= Void
      deferred
      end;

feature {NONE}

   name_clash_for(ct: TYPE; msg: STRING) is
      require
         ct /= Void;
         msg /= Void
      local
         rf: RUN_FEATURE;
         rc: RUN_CLASS;
         bc: BASE_CLASS;
      do
         bc := base_class_written;
         if bc.has_simple_feature_name(to_string) then
            rc := ct.run_class;
            rf := rc.get_feature_with(to_string);
            if rf /= Void then
               eh.add_position(rf.start_position);
            end;
            error(start_position,msg);
         end;
      end;

end --  LOCAL_ARGUMENT1


