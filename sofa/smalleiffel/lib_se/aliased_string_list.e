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
deferred class ALIASED_STRING_LIST
   --
   -- The initial set of STRING in STRING_ALIASER.
   --

feature {NONE}

   -- Hard coded class names :

   as_any:              STRING is "ANY";
   as_array:            STRING is "ARRAY";
   as_bit:              STRING is "BIT";
   as_bit_n:            STRING is "BIT_N";
   as_bit_n_ref:        STRING is "BIT_N_REF";
   as_boolean:          STRING is "BOOLEAN";
   as_boolean_ref:      STRING is "BOOLEAN_REF";
   as_character:        STRING is "CHARACTER";
   as_character_ref:    STRING is "CHARACTER_REF";
   as_dictionary:       STRING is "DICTIONARY";
   as_double:           STRING is "DOUBLE";
   as_double_ref:       STRING is "DOUBLE_REF";
   as_exceptions:       STRING is "EXCEPTIONS";
   as_fixed_array:      STRING is "FIXED_ARRAY";
   as_general:          STRING is "GENERAL";
   as_gui_color:        STRING is "GUI_COLOR";
   as_gui_event:        STRING is "GUI_EVENT";
   as_gui_font:         STRING is "GUI_FONT";
   as_gui_gc:           STRING is "GUI_GC";
   as_gui_pixmap:       STRING is "GUI_PIXMAP";
   as_integer:          STRING is "INTEGER";
   as_integer_ref:      STRING is "INTEGER_REF";
   as_memory:           STRING is "MEMORY";
   as_native_array:     STRING is "NATIVE_ARRAY";
   as_none:             STRING is "NONE";
   as_platform:         STRING is "PLATFORM";
   as_pointer:          STRING is "POINTER";
   as_pointer_ref:      STRING is "POINTER_REF";
   as_real:             STRING is "REAL";
   as_real_ref:         STRING is "REAL_REF";
   as_string:           STRING is "STRING";
   as_std_file_read:    STRING is "STD_FILE_READ";
   as_std_file_write:   STRING is "STD_FILE_WRITE";
   as_tuple:            STRING is "TUPLE";

   -- Operator/Infix/Prefix list :

   as_and:                   STRING is "and";
   as_and_then:              STRING is "and then";
   as_at:                    STRING is "@";
   as_backslash_backslash:   STRING is "\\";
   as_eq:                    STRING is "=";
   as_ge:                    STRING is ">=";
   as_gt:                    STRING is ">";
   as_implies:               STRING is "implies";
   as_le:                    STRING is "<=";
   as_lt:                    STRING is "<";
   as_minus:                 STRING is "-";
   as_muls:                  STRING is "*";
   as_neq:                   STRING is "/=";
   as_not:                   STRING is "not";
   as_or:                    STRING is "or";
   as_or_else:               STRING is "or else";
   as_plus:                  STRING is "+";
   as_pow:                   STRING is "^";
   as_shift_left:            STRING is "@<<";
   as_shift_right:           STRING is "@>>";
   as_slash:                 STRING is "/";
   as_slash_slash:           STRING is "//";
   as_std_neq:               STRING is "#";
   as_xor:                   STRING is "xor";



   -- Hard coded feature names :

   as_add_last:                 STRING is "add_last";
   as_blank:                    STRING is "blank";
   as_boolean_bits:             STRING is "Boolean_bits";
   as_calloc:                   STRING is "calloc";
   as_capacity:                 STRING is "capacity";
   as_character_bits:           STRING is "Character_bits";
   as_clear_all:                STRING is "clear_all";
   as_count:                    STRING is "count";
   as_code:                     STRING is "code";
   as_collecting:               STRING is "collecting";
   as_collection_off:           STRING is "collection_off";
   as_collection_on:            STRING is "collection_on";
   as_conforms_to:              STRING is "conforms_to";
   as_copy:                     STRING is "copy";
   as_c_inline_c:               STRING is "c_inline_c";
   as_c_inline_h:               STRING is "c_inline_h";
   as_default_rescue:           STRING is "default_rescue";
   as_deep_clone:               STRING is "deep_clone";
   as_deep_equal:               STRING is "deep_equal";
   as_deep_memcmp:              STRING is "deep_memcmp";
   as_deep_twin:                STRING is "deep_twin";
   as_deep_twin_from:           STRING is "deep_twin_from";
   as_dispose:                  STRING is "dispose";
   as_double_bits:              STRING is "Double_bits";
   as_double_floor:             STRING is "double_floor";
   as_die_with_code:            STRING is "die_with_code";
   as_element_sizeof:           STRING is "element_sizeof";
   as_eof_code:                 STRING is "eof_code";
   as_exception:                STRING is "exception";
   as_fclose:                   STRING is "fclose";
   as_feof:                     STRING is "feof";
   as_fifth:                    STRING is "fifth";
   as_first:                    STRING is "first";
   as_floor:                    STRING is "floor";
   as_flush_stream:             STRING is "flush_stream";
   as_fourth:                   STRING is "fourth";
   as_from_pointer:             STRING is "from_pointer";
   as_full_collect:             STRING is "full_collect";
   as_generating_type:          STRING is "generating_type";
   as_generator:                STRING is "generator";
   as_io:                       STRING is "io";
   as_integer_bits:             STRING is "Integer_bits";
   as_is_basic_expanded_type:   STRING is "is_basic_expanded_type";
   as_is_deep_equal:            STRING is "is_deep_equal";
   as_is_expanded_type:         STRING is "is_expanded_type";
   as_is_equal:                 STRING is "is_equal";
   as_is_not_null:              STRING is "is_not_null";
   as_item:                     STRING is "item";
   as_last:                     STRING is "last";
   as_lower:                    STRING is "lower";
   as_make:                     STRING is "make";
   as_minimum_character_code:   STRING is "Minimum_character_code";
   as_minimum_double:           STRING is "Minimum_double";
   as_minimum_integer:          STRING is "Minimum_integer";
   as_minimum_real:             STRING is "Minimum_real";
   as_maximum_character_code:   STRING is "Maximum_character_code";
   as_maximum_double:           STRING is "Maximum_double";
   as_maximum_integer:          STRING is "Maximum_integer";
   as_maximum_real:             STRING is "Maximum_real";
   as_object_size:              STRING is "object_size";
   as_pointer_bits:             STRING is "Pointer_bits";
   as_pointer_size:             STRING is "pointer_size";
   as_print:                    STRING is "print";
   as_print_on:                 STRING is "print_on";
   as_print_run_time_stack:     STRING is "print_run_time_stack";
   as_put:                      STRING is "put";
   as_put_0:                    STRING is "put_0";
   as_put_1:                    STRING is "put_1";
   as_raise_exception:          STRING is "raise_exception";
   as_read_byte:                STRING is "read_byte";
   as_real_bits:                STRING is "Real_bits";
   as_realloc:                  STRING is "realloc";
   as_second:                   STRING is "second";
   as_se_argc:                  STRING is "se_argc";
   as_se_argv:                  STRING is "se_argv";
   as_se_remove:                STRING is "se_remove";
   as_se_rename:                STRING is "se_rename";
   as_se_string2double:         STRING is "se_string2double";
   as_se_system:                STRING is "se_system";
   as_sfr_open:                 STRING is "sfr_open";
   as_sfw_open:                 STRING is "sfw_open";
   as_signal_number:            STRING is "signal_number";
   as_sprintf_double:           STRING is "sprintf_double";
   as_sprintf_pointer:          STRING is "sprintf_pointer";
   as_standard_copy:            STRING is "standard_copy";
   as_standard_is_equal:        STRING is "standard_is_equal";
   as_standard_twin:            STRING is "standard_twin";
   as_stderr:                   STRING is "stderr";
   as_stdin:                    STRING is "stdin";
   as_stdout:                   STRING is "stdout";
   as_std_error:                STRING is "std_error";
   as_std_input:                STRING is "std_input";
   as_std_output:               STRING is "std_output";
   as_storage:                  STRING is "storage";
   as_third:                    STRING is "third";
   as_to_bit:                   STRING is "to_bit";
   as_to_character:             STRING is "to_character";
   as_to_double:                STRING is "to_double";
   as_to_integer:               STRING is "to_integer";
   as_to_pointer:               STRING is "to_pointer";
   as_to_real:                  STRING is "to_real";
   as_trace_switch:             STRING is "trace_switch";
   as_truncated_to_integer:     STRING is "truncated_to_integer";
   as_twin:                     STRING is "twin";
   as_upper:                    STRING is "upper";
   as_with_capacity:            STRING is "with_capacity";
   as_write_byte:               STRING is "write_byte";


   -- Other names :

   as_current:                 STRING is "Current";
   as_native_array_character:  STRING is "NATIVE_ARRAY[CHARACTER]";
   as_like_current:            STRING is "like Current";
   as_precursor:               STRING is "Precursor";
   as_result:                  STRING is "Result";
   as_void:                    STRING is "Void";

end -- ALIASED_STRING_LIST
