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
deferred class LOCAL_ARGUMENT
   --
   -- Common root to handle local variables (LOCAL_NAME) or formal
   -- argument names (ARGUMENT_NAME).
   --

inherit NAME; EXPRESSION;

feature

   start_position: POSITION;
         -- Of the first character of the name.

   is_void: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_current: BOOLEAN is false;

   is_result: BOOLEAN is false;

   can_be_dropped: BOOLEAN is true;

   c_simple: BOOLEAN is true;

   is_pre_computable: BOOLEAN is false;

   is_static: BOOLEAN is false;

   use_current: BOOLEAN is false;

   to_string: STRING is
      deferred
      end;

   rank: INTEGER is
         -- in the corresponding flat list.
      deferred
      ensure
         Result >= 1
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         if small_eiffel.stupid_switch(result_type,r) then
            Result := true;
         end;
      end;

   frozen static_result_base_class: BASE_CLASS is
      local
         bcn: CLASS_NAME;
      do
         bcn := result_type.static_base_class_name;
         if bcn /= Void then
            Result := bcn.base_class;
         end;
      end;

   frozen afd_check is
      do
      end;

   frozen static_value: INTEGER is
      do
      end;

   frozen to_key: STRING is
      do
         Result := to_string;
      end;

   frozen collect_c_tmp is
      do
      end;

   frozen c_declare_for_old is
      do
      end;

   frozen compile_to_c_old is
      do
      end;

   frozen compile_to_jvm_old is
      do
      end;

   frozen compile_target_to_jvm is
      do
         standard_compile_target_to_jvm;
      end;

   frozen precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   frozen print_as_target is
      do
         fmt.put_string(to_string);
         fmt.put_character('.');
      end;

   frozen short is
      local
         i: INTEGER;
         c: CHARACTER;
      do
         short_print.hook("Ban");
         from
            i := 1;
         until
            i > to_string.count
         loop
            c := to_string.item(i);
            if c = '_' then
               short_print.hook_or("Uan","_");
            else
               short_print.a_character(c);
            end;
            i := i + 1;
         end;
         short_print.hook("Aan");
      end;

   frozen short_target is
      do
         short;
         short_print.a_dot;
      end;

invariant

   not start_position.is_unknown;

end -- LOCAL_ARGUMENT

