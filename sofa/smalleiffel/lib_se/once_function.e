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
class ONCE_FUNCTION

inherit ONCE_ROUTINE;

creation make

feature

   result_type: TYPE;

feature

   make(n: like names;
        fa: like arguments;
        t: like result_type;
        om: like obsolete_mark;
        hc: like header_comment;
        ra: like require_assertion;
        lv: like local_vars;
        rb: like routine_body) is
      require
         t /= void
      do
         make_effective_routine(n,fa,om,hc,ra,lv,rb);
         result_type := t;
      end;

   to_run_feature(t: TYPE; fn: FEATURE_NAME): RUN_FEATURE_6 is
      do
         !!Result.make(t,fn,Current);
      end;

feature {NONE}

   try_to_undefine_aux(fn: FEATURE_NAME;
                       bc: BASE_CLASS): DEFERRED_ROUTINE is
      do
         !DEFERRED_FUNCTION!Result.from_effective(fn,arguments,
                                                  result_type,
                                                  require_assertion,
                                                  ensure_assertion,
                                                  bc);
      end;

end -- ONCE_FUNCTION

