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
class STRING_ALIASER
   --
   -- Singleton object used to share constant immutable strings.
   -- This singleton is shared via the GLOBALS.`string_aliaser' once function.
   --
   -- The goal is to optimize immutable strings comparisons. Thus, any
   -- immutable name must be registered here to get the corresponding
   -- unique reference.
   --

inherit GLOBALS;

creation make

feature

   item(model: STRING): STRING is
      require
         not model.is_empty
      do
         if memory.has(model) then
            Result := memory.at(model);
         else
            Result := model.twin;
            memory.put(Result,Result);
         end;
      ensure
         Result.is_equal(model)
      end;

   ecoop99_item(model: STRING): STRING is
         -- *** `item' for ECOOP'99 benchmark ***
      do
         Result := model.twin;
      end;

feature {PREFIX_NAME}

   for_prefix(to_string: STRING): STRING is
      do
         Result := key_for_prefix_infix("_ix_",to_string);
      end;

feature {INFIX_NAME}

   for_infix(to_string: STRING): STRING is
      do
         Result := key_for_prefix_infix("_px_",to_string);
      end;

feature {COMPILE_TO_C,COMPILE_TO_JVM}

   echo_information is
      do
         echo.put_string("Aliased Strings: ");
         echo.put_integer(memory.count);
         echo.put_string(fz_b6);
      end;

feature {NONE}

   make is
      do 
         -- -------------------------------------- Class names :
         add1(as_any);
         add1(as_array);
         add1(as_bit);
         add1(as_bit_n);
         add1(as_bit_n_ref);
         add1(as_boolean);
         add1(as_boolean_ref);
         add1(as_character);
         add1(as_character_ref);
         add1(as_dictionary);
         add1(as_double);
         add1(as_double_ref);
         add1(as_exceptions);
         add1(as_fixed_array);
         add1(as_general);
         add1(as_integer);
         add1(as_integer_ref);
         add1(as_memory);
         add1(as_native_array);
         add1(as_none);
         add1(as_platform);
         add1(as_pointer);
         add1(as_pointer_ref);
         add1(as_real);
         add1(as_real_ref);
         add1(as_string);
         add1(as_std_file_read);
         add1(as_std_file_write);
         -- ----------------------- Operator/Infix/Prefix list :
         add1(as_and);
         add1(as_and_then);
         add1(as_at);
         add1(as_backslash_backslash);
         add1(as_eq);
         add1(as_ge);
         add1(as_gt);
         add1(as_implies);
         add1(as_le);
         add1(as_lt);
         add1(as_minus);
         add1(as_muls);
         add1(as_neq);
         add1(as_not);
         add1(as_or);
         add1(as_or_else);
         add1(as_plus);
         add1(as_pow);
         add1(as_shift_left);
         add1(as_shift_right);
         add1(as_slash);
         add1(as_slash_slash);
         add1(as_std_neq);
         add1(as_xor);
         -- ------------------------------------ Feature names :
         add1(as_add_last);
         add1(as_blank);
         add2(as_boolean_bits);
         add1(as_calloc);
         add1(as_capacity);
         add2(as_character_bits);
         add1(as_clear_all);
         add1(as_count);
         add1(as_code);
         add1(as_conforms_to);
         add1(as_copy);
         add1(as_c_inline_c);
         add1(as_c_inline_h);
         add1(as_default_rescue);
         add1(as_deep_clone);
         add1(as_deep_equal);
         add1(as_deep_memcmp);
         add1(as_deep_twin);
         add1(as_deep_twin_from);
         add1(as_dispose);
         add1(as_double_bits);
         add1(as_double_floor);
         add1(as_die_with_code);
         add1(as_element_sizeof);
         add1(as_eof_code);
         add1(as_exception);
         add1(as_fclose);
         add1(as_feof);
         add1(as_first);
         add1(as_floor);
         add1(as_flush_stream);
         add1(as_from_pointer);
         add1(as_generating_type);
         add1(as_generator);
         add1(as_io);
         add2(as_integer_bits);
         add1(as_is_basic_expanded_type);
         add1(as_is_deep_equal);
         add1(as_is_expanded_type);
         add1(as_is_equal);
         add1(as_is_not_null);
         add1(as_item);
         add1(as_last);
         add1(as_lower);
         add1(as_malloc);
         add1(as_make);
         add2(as_minimum_character_code);
         add2(as_minimum_double);
         add2(as_minimum_integer);
         add2(as_minimum_real);
         add2(as_maximum_character_code);
         add2(as_maximum_double);
         add2(as_maximum_integer);
         add2(as_maximum_real);
         add1(as_object_size);
         add1(as_pointer_bits);
         add1(as_pointer_size);
         add1(as_print);
         add1(as_print_on);
         add1(as_print_run_time_stack);
         add1(as_put);
         add1(as_put_0);
         add1(as_put_1);
         add1(as_raise_exception);
         add1(as_read_byte);
         add1(as_real_bits);
         add1(as_realloc);
         add1(as_se_argc);
         add1(as_se_argv);
         add1(as_se_getenv);
         add1(as_se_remove);
         add1(as_se_rename);
         add1(as_se_string2double);
         add1(as_se_system);
         add1(as_sfr_open);
         add1(as_signal_number);
         add1(as_sfw_open);
         add1(as_sprintf_double);
         add1(as_sprintf_pointer);
         add1(as_standard_copy);
         add1(as_standard_is_equal);
         add1(as_standard_twin);
         add1(as_stderr);
         add1(as_stdin);
         add1(as_stdout);
         add1(as_std_error);
         add1(as_std_input);
         add1(as_std_output);
         add1(as_storage);
         add1(as_to_bit);
         add1(as_to_character);
         add1(as_to_double);
         add1(as_to_integer);
         add1(as_to_pointer);
         add1(as_to_real);
         add1(as_trace_switch);
         add1(as_truncated_to_integer);
         add1(as_twin);
         add1(as_upper);
         add1(as_with_capacity);
         add1(as_write_byte);
         -- -------------------------------------- Other names :
         add1(as_current);
         add1(as_native_array_character);
         add1(as_like_current);
         add1(as_precursor);
         add1(as_result);
         add1(as_void);
      end;

   add1(str: STRING) is
      require
         not memory.has(str)
      do
         memory.put(str,str);
      end;

   add2(str: STRING) is
      do
         if eiffel_parser.case_insensitive then
            str.to_lower;
         end;
         add1(str);
      end;

   tmp_string: STRING is "..............................................";

   key_for_prefix_infix(tag_prefix_or_infix, to_string: STRING): STRING is
      local
         i: INTEGER;
         c: CHARACTER;
      do
         tmp_string.copy(tag_prefix_or_infix);
         from
            i := 1;
         until
            i > to_string.count
         loop
            c := to_string.item(i);
            if c.is_letter then
               tmp_string.extend(c);
            else
               c.code.append_in(tmp_string);
            end;
            i := i + 1;
         end;
         Result := item(tmp_string);
      end;

   memory: DICTIONARY[STRING,STRING] is
      once
         !!Result.with_capacity(16384);
      end;

   singleton_memory: STRING_ALIASER is
      once
         Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- STRING_ALIASER

