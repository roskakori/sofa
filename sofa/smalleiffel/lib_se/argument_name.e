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
deferred class ARGUMENT_NAME
   --
   -- Handling of arguments.
   --

inherit LOCAL_ARGUMENT;

feature

   is_writable: BOOLEAN is false;

   frozen assertion_check(tag: CHARACTER) is
      do
      end;

   frozen isa_dca_inline_argument: INTEGER is
      do
         Result := rank;
      end;

   frozen dca_inline_argument(formal_arg_type: TYPE) is
      do
         cpp.put_ith_argument(rank);
      end;

   frozen pretty_print is
      do
         fmt.put_string(to_string);
      end;

   frozen mapping_c_target(target_type: TYPE) is
      local
         flag: BOOLEAN;
         rt: TYPE;
      do
         flag := cpp.call_invariant_start(target_type);
         rt := result_type.run_type;
         if rt.is_reference then
            if target_type.is_reference then
               -- Reference into Reference :
               cpp.put_string(fz_b7);
               cpp.put_integer(target_type.id);
               cpp.put_string(fz_b8);
               cpp.print_argument(rank);
               cpp.put_character(')');
            else
               -- Reference into Expanded :
               cpp.print_argument(rank);
            end;
         elseif target_type.is_reference then
            -- Expanded into Reference :
            cpp.print_argument(rank);
         elseif rt.is_user_expanded then
            -- User Expanded into User Expanded :
            if not rt.is_dummy_expanded then
               cpp.put_character('&');
            end;
            cpp.print_argument(rank);
         else
            -- Kernel Expanded into Kernel Expanded :
            cpp.print_argument(rank);
         end;
         if flag then
            cpp.call_invariant_end;
         end;
      end;

   frozen mapping_c_arg(formal_arg_type: TYPE) is
      do
         cpp.print_argument(rank);
      end;

   frozen compile_to_c is
      do
         cpp.print_argument(rank);
      end;

   frozen compile_to_jvm is
      local
         jvm_offset: INTEGER;
      do
         jvm_offset := jvm.argument_offset_of(Current);
         result_type.run_type.jvm_push_local(jvm_offset);
      end;

   frozen jvm_branch_if_false: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifeq;
      end;

   frozen jvm_branch_if_true: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifne;
      end;

   frozen compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

   frozen jvm_assign is
      do
         check false end;
      end;

end -- ARGUMENT_NAME


