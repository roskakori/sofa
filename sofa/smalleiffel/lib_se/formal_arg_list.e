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
class FORMAL_ARG_LIST
   --
   -- For the formal arguments list of a routine.
   --

inherit DECLARATION_LIST;

creation make, with

feature {NONE} -- Parsing creation procedure :

   make(l: like list) is
      require
         l.lower = 1;
         not l.is_empty
      local
         an: like name;
         tlf: TYPE_LIKE_FEATURE;
         tla, tla2: TYPE_LIKE_ARGUMENT;
         i, rank: INTEGER;
         an2: ARGUMENT_NAME2;
      do
         declaration_list_make(l);
         -- Substitution TYPE_LIKE_FEATURE/TYPE_LIKE_ARGUMENT :
         from
            i := count;
         until
            i = 0
         loop
            an := name(i);
            tlf ?= an.result_type;
            if tlf /= Void then
               rank := rank_of(tlf.like_what.to_string);
               if rank = i then
                  eh.add_position(tlf.start_position);
                  fatal_error(fz_cad);
               elseif rank > 0 then
                  !!an2.refer_to(tlf.like_what.start_position,Current,rank);
                  !!tla.make(tlf.start_position,an2);
                  an.set_result_type(tla);
               end;
            end;
            i := i - 1;
         end;
         if run_control.all_check then
            from
               i := count;
            until
               i = 0
            loop
               tla ?= name(i).result_type;
               if tla /= Void then
                  rank := rank_of(tla.like_what.to_string);
                  tla2 ?= name(rank).result_type;
                  if tla2 /= Void then
                     eh.add_position(tla.start_position);
                     eh.add_position(tla2.start_position);
                     fatal_error(fz_cad);
                  end;
               end;
               i := i - 1;
            end;
         end;
      ensure
         list = list;
         flat_list /= Void
      end;

feature {NONE} -- Runnable creation procedure :

   with(model: like Current; ct: TYPE) is
      require
         not model.is_runnable(ct)
      do
         standard_copy(model);
         dynamic_runnable(ct);
         check_name_clash(ct);
      end;

feature

   name(i: INTEGER): ARGUMENT_NAME1 is
      do
         Result := flat_list.item(i);
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.put_character('(');
         fmt.level_incr;
         from
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).pretty_print;
            i := i + 1;
            if i <= list.upper then
               fmt.put_string("; ");
            end;
         end;
         fmt.level_decr;
         fmt.put_character(')');
      end;

   short is
      local
         i: INTEGER;
      do
         short_print.hook_or("hook302"," (");
         from
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).short;
            i := i + 1;
            if i <= list.upper then
               short_print.hook_or("hook303","; ");
            end;
         end;
         short_print.hook_or("hook306",")");
      end;

   compile_to_c_in(str: STRING) is
      local
         i: INTEGER;
         t: TYPE;
      do
         from
            i := 1;
         until
            i > count
         loop
            t := type(i).run_type;
            t.c_type_for_argument_in(str);
            str.extend(' ');
            str.extend('a');
            i.append_in(str);
            if run_control.no_check then
               c_frame_descriptor_local_count.increment;
               c_frame_descriptor_format.append(name(i).to_string);
               t.c_frame_descriptor;
               c_frame_descriptor_locals.append("(void**)&a");
               i.append_in(c_frame_descriptor_locals);
               c_frame_descriptor_locals.extend(',');
            end;
            i := i + 1;
            if i <= count then
               str.extend(',');
            end;
         end;
      end;

   is_a_in(other: like Current; rc: RUN_CLASS): BOOLEAN is
         -- True when `other' interpreted in `rc' is a kind of Current
         -- interpreted in `rc'.
      require
         other /= Void;
         rc /= Void;
      local
         i: INTEGER;
         t1, t2: TYPE;
      do
         i := count;
         if other.count /= i then
            eh.add_position(other.start_position);
            error(start_position,"Bad number of arguments.");
         end;
         if nb_errors = 0 then
            from
               Result := true;
            until
               not Result or else i = 0
            loop
               t1 := type(i);
               t2 := other.type(i);
               if not t1.is_a_in(t2,rc) then
                  Result := false;
                  eh.print_as_error;
                  eh.add_position(t1.start_position);
                  eh.add_position(t2.start_position);
                  eh.append("Incompatible types in ");
                  eh.append(rc.current_type.run_time_mark);
                  eh.append(fz_dot);
                  eh.print_as_error;
               end;
               i := i - 1;
            end;
         end;
      end;

feature {JVM}

   jvm_switch_push(dyn_fal: like Current): INTEGER is
         -- Push inside switching method.
      require
         count = dyn_fal.count
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > count
         loop
            Result := Result + jvm_switch_push_ith(dyn_fal,i);
            i := i + 1;
         end;
      end;

feature {JVM}

   jvm_switch_push_ith(dyn_fal: like Current; i: INTEGER): INTEGER is
      local
         ft, at: TYPE;
         offset: INTEGER;
      do
         offset := jvm.argument_offset_of(name(i));
         ft := type(i).run_type;
         at := dyn_fal.type(i).run_type;
         ft.jvm_push_local(offset);
         Result := ft.jvm_convert_to(at);
      end;

feature {RUN_FEATURE,SWITCH,NATIVE_SMALL_EIFFEL}

   jvm_descriptor_in(str: STRING) is
      local
         i: INTEGER;
         at: TYPE;
      do
         from
            i := 1;
         until
            i > count
         loop
            at := type(i).run_type;
            if at.is_reference then
               str.append(jvm_root_descriptor);
            else
               at.jvm_descriptor_in(str);
            end;
            i := i + 1;
         end;
      end;

feature {RUN_FEATURE_3}

   inline_one_pc is
      local
         i: INTEGER;
         t: TYPE;
      do
         from
            i := 1;
         until
            i > count
         loop
            t := type(i).run_type;
            tmp_string.clear;
            t.c_type_for_argument_in(tmp_string);
            tmp_string.extend(' ');
            cpp.put_string(tmp_string);
            cpp.inline_level_incr;
            cpp.print_argument(i);
            cpp.inline_level_decr;
            cpp.put_character('=');
            cpp.put_ith_argument(i);
            cpp.put_string(fz_00);
            i := i + 1;
         end;
      end;

feature {RUN_FEATURE,CECIL_POOL}

   external_prototype_in(str: STRING) is
      local
         i: INTEGER;
         t: TYPE;
      do
         from
            i := 1;
         until
            i > count
         loop
            t := type(i).run_type;
            t.c_type_for_external_in(str);
            str.extend(' ');
            str.extend('a');
            i.append_in(str);
            i := i + 1;
            if i <= count then
               str.extend(',');
            end;
         end;
      end;

feature {SWITCH}

   afd_notify_conversion(destination: like Current) is
      local
         i: INTEGER;
         source_type, destination_type: TYPE;
      do
         from
            i := count;
         until
            i = 0
         loop
            source_type := type(i);
            destination_type := destination.type(i);
            conversion_handler.passing(source_type,destination_type);
            i := i - 1;
         end;
      end;

feature {NONE}

   tmp_string: STRING is
      once
         !!Result.make(32);
      end;

end -- FORMAL_ARG_LIST

