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
class LOCAL_VAR_LIST
   --
   -- To store local variables declaration list.
   --

inherit DECLARATION_LIST;

creation {EIFFEL_PARSER} make

creation {DECLARATION_LIST} runnable_from_current

feature {NONE}

   make(l: like list) is
      do
         declaration_list_make(l);
      end;

feature

   name(i: INTEGER): LOCAL_NAME1 is
      do
         Result := flat_list.item(i);
      end;

   to_runnable(ct: TYPE): like Current is
      require
         ct.run_type = ct
      do
         if is_runnable(ct) then
            Result := Current;
         else
            Result := twin;
            Result.dynamic_runnable(ct);
            Result.check_name_clash(ct);
         end;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.set_indent_level(2);
         fmt.indent;
         fmt.keyword("local");
         if fmt.zen_mode and list.count = 1 then
            list.first.pretty_print;
            fmt.put_character(';');
         else
            from
               i := 1;
            until
               i > list.upper
            loop
               fmt.set_indent_level(3);
               fmt.indent;
               list.item(i).pretty_print;
               fmt.put_character(';');
               i := i + 1;
            end;
         end;
         fmt.set_indent_level(2);
         fmt.indent;
      end;

   produce_c: BOOLEAN is
      local
         i: INTEGER;
      do
         from
            i := count;
         until
            Result or else i = 0
         loop
            Result := name(i).produce_c;
            i := i - 1;
         end;
      end;

feature {ONCE_ROUTINE_POOL,RUN_FEATURE}

   jvm_initialize is
         -- Produce code in order to initialize variables.
      local
         jvm_offset, i, dummy: INTEGER;
         t: TYPE;
      do
         from
            i := count;
         until
            i = 0
         loop
            jvm_offset := jvm.local_offset_of(name(i));
            t := type(i).run_type;
            dummy := t.jvm_push_default;
            t.jvm_write_local(jvm_offset);
            i := i - 1;
         end;
      end;

   c_declare is
      local
         i: INTEGER;
         n: like name;
      do
         from
            i := count;
         until
            i = 0
         loop
            n := name(i)
            n.c_declare;
            if run_control.no_check then
               n.c_frame_descriptor(type(i));
            end;
            i := i - 1;
         end;
      end;

   initialize_expanded is
      local
         i: INTEGER;
         t: TYPE;
         rf3: RUN_FEATURE_3;
      do
         from
            i := count;
         until
            i = 0
         loop
            t := type(i).run_type;
            if t.is_expanded then
               if not t.is_basic_eiffel_expanded then
                  rf3 := t.expanded_initializer;
                  if rf3 /= Void then
                     cpp.expanded_writable(rf3,name(i));
                  end;
               end;
            end;
            i := i - 1;
         end;
      end;

feature {RUN_FEATURE_3}

   inline_one_pc is
      local
         i: INTEGER;
      do
         from
            i := count;
         until
            i = 0
         loop
            cpp.inline_level_incr;
            name(i).c_declare;
            cpp.inline_level_decr;
            i := i - 1;
         end;
      end;

end -- LOCAL_VAR_LIST


