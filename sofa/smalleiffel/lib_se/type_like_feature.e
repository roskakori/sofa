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
class TYPE_LIKE_FEATURE
   --
   -- For an anchored declaration type mark using a feature name.
   --
   -- See also TYPE_LIKE_ARG and TYPE_LIKE_CURRENT.
   --

inherit TYPE_ANCHORED redefine is_like_feature, like_feature end;

creation make, with

feature

   like_what: FEATURE_NAME;

   written_mark: STRING;

   run_type: TYPE;
         -- When runnable.

feature {NONE}

   make(sp: like start_position; lw: like like_what) is
      require
         not sp.is_unknown;
         lw /= Void
      do
         start_position := sp;
         like_what := lw;
         written_mark_buffer.copy(fz_like);
         written_mark_buffer.extend(' ');
         like_what.declaration_in(written_mark_buffer);
         written_mark := string_aliaser.item(written_mark_buffer);
      ensure
         start_position = sp
      end;

   with(model: like Current; rt: like run_type) is
      require
         model /= Void;
         rt /= Void
      do
         start_position := model.start_position;
         like_what := model.like_what;
         written_mark := model.written_mark;
         run_type := rt;
      ensure
         start_position = model.start_position;
         like_what = model.like_what;
         written_mark = model.written_mark;
         run_type = rt;
      end;

feature

   is_like_feature: BOOLEAN is true;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   static_base_class_name: CLASS_NAME is
      local
         bc: BASE_CLASS;
         e_feature: E_FEATURE;
         rt: TYPE;
      do
         bc := start_position.base_class;
         e_feature := bc.e_feature(like_feature);
         if e_feature /= Void then
            rt := e_feature.result_type;
            if rt /= Void then
               Result := rt.static_base_class_name;
            end;
         else
            eh.append(fz_bad_anchor);
            eh.add_position(start_position);
            eh.print_as_fatal_error;
         end;
      end;

   like_feature: FEATURE_NAME is
      do
         Result := like_what;
      end;

   is_run_type: BOOLEAN is
      do
         Result := run_type /= Void;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         rc: RUN_CLASS;
         rt: TYPE;
      do
         anchor_cycle_start;
         rc := ct.run_class;
         rt := rc.get_result_type(like_what);
         if run_type = Void then
            run_type := rt;
            Result := Current;
         elseif run_type = rt then
            Result := Current;
         else
            !!Result.with(Current,rt);
         end;
         anchor_cycle_end;
      end;

   is_a(other: TYPE): BOOLEAN is
      local
         tlf: like Current;
      do
         if other.is_like_feature then
            tlf ?= other;
            if like_what.to_string = tlf.like_what.to_string then
               Result := true;
               --eh.add_position(other.start_position);
               --warning(start_position,"YOO");
            else
               Result := run_type.is_a(other);
            end;
         else
            Result := run_type.is_a(other);
         end;
         if not Result then
            eh.add_position(start_position);
         end;
      end;

feature {TYPE}

   short_hook is
      do
         short_print.hook_or("like","like ");
         like_what.short;
      end;

end -- TYPE_LIKE_FEATURE

