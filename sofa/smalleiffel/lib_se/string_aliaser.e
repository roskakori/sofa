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
            memory.add(Result,Result);
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
         regular_add(as_any);
         regular_add(as_array);
         regular_add(as_bit);
         regular_add(as_bit_n);
         regular_add(as_bit_n_ref);
         regular_add(as_boolean);
         regular_add(as_boolean_ref);
         regular_add(as_character);
         regular_add(as_character_ref);
         regular_add(as_dictionary);
         regular_add(as_double);
         regular_add(as_double_ref);
         regular_add(as_exceptions);
         regular_add(as_fixed_array);
         regular_add(as_general);
         regular_add(as_gui_color);
         regular_add(as_gui_event);
         regular_add(as_gui_font);
         regular_add(as_gui_gc);
         regular_add(as_gui_pixmap);
         regular_add(as_integer);
         regular_add(as_integer_ref);
         regular_add(as_memory);
         regular_add(as_native_array);
         regular_add(as_none);
         regular_add(as_platform);
         regular_add(as_pointer);
         regular_add(as_pointer_ref);
         regular_add(as_real);
         regular_add(as_real_ref);
         regular_add(as_string);
         regular_add(as_std_file_read);
         regular_add(as_std_file_write);
         regular_add(as_tuple);
         -- ----------------------- Operator/Infix/Prefix list :
         regular_add(as_and);
         regular_add(as_and_then);
         regular_add(as_at);
         regular_add(as_backslash_backslash);
         regular_add(as_eq);
         regular_add(as_ge);
         regular_add(as_gt);
         regular_add(as_implies);
         regular_add(as_le);
         regular_add(as_lt);
         regular_add(as_minus);
         regular_add(as_muls);
         regular_add(as_neq);
         regular_add(as_not);
         regular_add(as_or);
         regular_add(as_or_else);
         regular_add(as_plus);
         regular_add(as_pow);
         regular_add(as_shift_left);
         regular_add(as_shift_right);
         regular_add(as_slash);
         regular_add(as_slash_slash);
         regular_add(as_std_neq);
         regular_add(as_xor);
         -- ------------------------------------ Feature names :
         regular_add(as_add_last);
         regular_add(as_blank);
         special_add(as_boolean_bits);
         regular_add(as_calloc);
         regular_add(as_capacity);
         special_add(as_character_bits);
         regular_add(as_clear_all);
         regular_add(as_count);
         regular_add(as_code);
         regular_add(as_collecting);
         regular_add(as_collection_off);
         regular_add(as_collection_on);
         regular_add(as_conforms_to);
         regular_add(as_copy);
         regular_add(as_c_inline_c);
         regular_add(as_c_inline_h);
         regular_add(as_default_rescue);
         regular_add(as_deep_clone);
         regular_add(as_deep_equal);
         regular_add(as_deep_memcmp);
         regular_add(as_deep_twin);
         regular_add(as_deep_twin_from);
         regular_add(as_dispose);
         regular_add(as_double_bits);
         regular_add(as_double_floor);
         regular_add(as_die_with_code);
         regular_add(as_element_sizeof);
         regular_add(as_eof_code);
         regular_add(as_exception);
         regular_add(as_fclose);
         regular_add(as_feof);
         regular_add(as_fifth);
         regular_add(as_first);
         regular_add(as_floor);
         regular_add(as_flush_stream);
         regular_add(as_fourth);
         regular_add(as_from_pointer);
         regular_add(as_full_collect);
         regular_add(as_generating_type);
         regular_add(as_generator);
         regular_add(as_io);
         special_add(as_integer_bits);
         regular_add(as_is_basic_expanded_type);
         regular_add(as_is_deep_equal);
         regular_add(as_is_expanded_type);
         regular_add(as_is_equal);
         regular_add(as_is_not_null);
         regular_add(as_item);
         regular_add(as_last);
         regular_add(as_lower);
         regular_add(as_make);
         special_add(as_minimum_character_code);
         special_add(as_minimum_double);
         special_add(as_minimum_integer);
         special_add(as_minimum_real);
         special_add(as_maximum_character_code);
         special_add(as_maximum_double);
         special_add(as_maximum_integer);
         special_add(as_maximum_real);
         regular_add(as_object_size);
         regular_add(as_pointer_bits);
         regular_add(as_pointer_size);
         regular_add(as_print);
         regular_add(as_print_on);
         regular_add(as_print_run_time_stack);
         regular_add(as_put);
         regular_add(as_put_0);
         regular_add(as_put_1);
         regular_add(as_raise_exception);
         regular_add(as_read_byte);
         regular_add(as_real_bits);
         regular_add(as_realloc);
         regular_add(as_second);
         regular_add(as_se_argc);
         regular_add(as_se_argv);
         regular_add(as_se_remove);
         regular_add(as_se_rename);
         regular_add(as_se_string2double);
         regular_add(as_se_system);
         regular_add(as_sfr_open);
         regular_add(as_signal_number);
         regular_add(as_sfw_open);
         regular_add(as_sprintf_double);
         regular_add(as_sprintf_pointer);
         regular_add(as_standard_copy);
         regular_add(as_standard_is_equal);
         regular_add(as_standard_twin);
         regular_add(as_stderr);
         regular_add(as_stdin);
         regular_add(as_stdout);
         regular_add(as_std_error);
         regular_add(as_std_input);
         regular_add(as_std_output);
         regular_add(as_storage);
         regular_add(as_third);
         regular_add(as_to_bit);
         regular_add(as_to_character);
         regular_add(as_to_double);
         regular_add(as_to_integer);
         regular_add(as_to_pointer);
         regular_add(as_to_real);
         regular_add(as_trace_switch);
         regular_add(as_truncated_to_integer);
         regular_add(as_twin);
         regular_add(as_upper);
         regular_add(as_with_capacity);
         regular_add(as_write_byte);
         -- -------------------------------------- Other names :
         regular_add(as_current);
         regular_add(as_native_array_character);
         regular_add(as_like_current);
         regular_add(as_precursor);
         regular_add(as_result);
         regular_add(as_void);
      end;

   regular_add(str: STRING) is
	 -- Added as it is in the `memory'.
      do
         memory.add(str,str);
      end;

   special_add(str: STRING) is
	 -- May be added in lower case in the `memory'
      do
         if eiffel_parser.case_insensitive then
            str.to_lower;
         end;
         regular_add(str);
      end;

   buffer: STRING is 
      once
	 !!Result.make(64);
      end;

   key_for_prefix_infix(tag_prefix_or_infix, to_string: STRING): STRING is
      local
         i: INTEGER;
         c: CHARACTER;
      do
         buffer.copy(tag_prefix_or_infix);
         from
            i := 1;
         until
            i > to_string.count
         loop
            c := to_string.item(i);
            if c.is_letter then
               buffer.extend(c);
            else
               c.code.append_in(buffer);
            end;
            i := i + 1;
         end;
         Result := item(buffer);
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
