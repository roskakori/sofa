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
deferred class FROZEN_STRING_LIST
   --
   -- Shared Frozen String list.
   --

feature {NONE}

-----------------------------------------------------------------------------
-- Frozen list of some keywords :

   fz_alias:              STRING is "alias";
   fz_all:                STRING is "all";
   fz_as:                 STRING is "as";
   fz_check:              STRING is "check";
   fz_class:              STRING is "class";
   fz_create:             STRING is "create";
   fz_creation:           STRING is "creation";
   fz_debug:              STRING is "debug";
   fz_deferred:           STRING is "deferred";
   fz_do:                 STRING is "do";
   fz_else:               STRING is "else";
   fz_elseif:             STRING is "elseif";
   fz_end:                STRING is "end";
   fz_ensure:             STRING is "ensure";
   fz_expanded:           STRING is "expanded";
   fz_export:             STRING is "export";
   fz_external:           STRING is "external";
   fz_false:              STRING is "false";
   fz_feature:            STRING is "feature";
   fz_from:               STRING is "from";
   fz_frozen:             STRING is "frozen";
   fz_if:                 STRING is "if";
   fz_indexing:           STRING is "indexing";
   fz_infix:              STRING is "infix";
   fz_inherit:            STRING is "inherit";
   fz_inspect:            STRING is "inspect";
   fz_invariant:          STRING is "invariant";
   fz_is:                 STRING is "is";
   fz_like:               STRING is "like";
   fz_local:              STRING is "local";
   fz_loop:               STRING is "loop";
   fz_obsolete:           STRING is "obsolete";
   fz_old:                STRING is "old";
   fz_once:               STRING is "once";
   fz_prefix:             STRING is "prefix";
   fz_redefine:           STRING is "redefine";
   fz_rename:             STRING is "rename";
   fz_require:            STRING is "require";
   fz_rescue:             STRING is "rescue";
   fz_retry:              STRING is "retry";
   fz_runtime:            STRING is "runtime";
   fz_select:             STRING is "select";
   fz_separate:           STRING is "separate";
   fz_basic_:             STRING is "basic_";
   fz_strip:              STRING is "strip";
   fz_then:               STRING is "then";
   fz_true:               STRING is "true";
   fz_undefine:           STRING is "undefine";
   fz_unique:             STRING is "unique";
   fz_until:              STRING is "until";
   fz_variant:            STRING is "variant";
   fz_when:               STRING is "when";

-----------------------------------------------------------------------------
-- Frozen list of messages :

   fz_arrow_id:          STRING is "->id";
   fz_bad_anchor:        STRING is "Bad anchor.";
   fz_bad_argument:      STRING is "Bad argument.";
   fz_bad_arguments:     STRING is "Bad arguments.";
   fz_bad_assertion:     STRING is "Bad Assertion.";
   fz_bcv:               STRING is "Bad CHARACTER value.";
   fz_bga:               STRING is "Bad generic argument.";
   fz_biv:               STRING is "Bad INTEGER value.";
   fz_bnga:              STRING is "Bad number of generic arguments.";
   fz_blhsoa:            STRING is "Bad left hand side of assignment.";
   fz_brhsoa:            STRING is "Bad right hand side of assignment.";
   fz_cad:               STRING is "Cyclic anchored definition.";
   fz_cbe:               STRING is " cannot be expanded. ";
   fz_cnf:               STRING is "Class not found.";
   fz_dot:               STRING is ".";
   fz_dtideena: STRING is " has no compiler-defined `deep_twin' or `is_deep_equal' %
		%because the corresponding allocated size is not part of the %
		%NATIVE_ARRAY object. The client class of this NATIVE_ARRAY %
		%type is supposed to use a `capacity' attribute which contains %
		%the corresponding number of allocated items (see STRING or %
                %ARRAY for example).";
   fz_error_stars:       STRING is "****** ";
   fz_feature_not_found: STRING is "Feature not found";
   fz_iinaiv:            STRING is "It is not an integer value.";
   fz_ich:               STRING is "Incompatible headings.";
   fz_inako:             STRING is " is not a kind of ";
   fz_is_invalid:        STRING is " is invalid.";
   fz_is_not_boolean:    STRING is " is not BOOLEAN.";
   fz_jvm_error:         STRING is "Incompatible with Java bytecode.";
   fz_not_found:         STRING is "%" not found.";
   fz_vuar4:             STRING is "The $ operator must be followed by the %
			           %final name of a feature which is not a %
				   %constant attribute (VUAR.4)."

-----------------------------------------------------------------------------
-- Frozen list of other names :

   fz_bin:                     STRING is "bin";
   fz_char:                    STRING is "char";
   fz_close_c_comment:         STRING is "*/";
   fz_cast_gcfsh_star:         STRING is "(gcfsh*)";
   fz_cast_gcnah_star:         STRING is "(gcnah*)";
   fz_cast_t0_star:            STRING is "(T0*)";
   fz_cast_void_star:          STRING is "(void*)";
   fz_c_eq:                    STRING is "==";
   fz_c_if_neq_null:           STRING is "if(NULL!=";
   fz_c_if_eq_null:            STRING is "if(NULL==";
   fz_c_neq:                   STRING is "!=";
   fz_c_no_args_procedure:     STRING is "();%N";
   fz_c_no_args_function:      STRING is "()";
   fz_c_shift_left:            STRING is "<<";
   fz_c_shift_right:           STRING is ">>";
   fz_c_void_args:             STRING is "(void)";
   fz_define:                  STRING is "define";
   fz_eq_h:                    STRING is "=H";
   fz_exit:                    STRING is "exit";
   fz_extern:                  STRING is "extern ";
   fz_eiffel_root_object:      STRING is "eiffel_root_object";
   fz_gc:                      STRING is "gc";
   fz_gc_info:                 STRING is "gc_info";
   fz_gc_lib:                  STRING is "gc_lib";
   fz_gc_mark:                 STRING is "gc_mark";
   fz_gc_sweep:                STRING is "gc_sweep";
   fz_gc_sweep_chunk:          STRING is "gc_sweep_chunk";
   fz_i:                       STRING is "I";
   fz_int:                     STRING is "int";
   fz_java_io_inputstream:     STRING is "java/io/InputStream";
   fz_java_io_outputstream:    STRING is "java/io/OutputStream";
   fz_java_lang_double:        STRING is "java/lang/Double";
   fz_java_lang_float:         STRING is "java/lang/Float";
   fz_java_lang_integer:       STRING is "java/lang/Integer";
   fz_java_lang_math:          STRING is "java/lang/Math";
   fz_java_lang_object:        STRING is "java/lang/Object";
   fz_java_lang_string:        STRING is "java/lang/String";
   fz_java_lang_system:        STRING is "java/lang/System";
   fz_java_util_bitset:        STRING is "java/util/BitSet";
   fz_jvm_root:                STRING is "_any"
   fz_main:                    STRING is "main";
   fz_max_value:               STRING is "MAX_VALUE";
   fz_new:                     STRING is "new";
   fz_new_chunk:               STRING is "new_chunk";
   fz_null:                    STRING is "NULL";
   fz_open_c_comment:          STRING is "/*";
   fz_printf:                  STRING is "printf";
   fz_return:                  STRING is "return";
   fz_se:                      STRING is "SmallEiffel";
   fz_se_cmpt:                 STRING is "se_cmpT";
   fz_se_i:                    STRING is "se_i";
   fz_size:                    STRING is "size";
   fz_sizeof:                  STRING is "sizeof";
   fz_se_runtime:              STRING is "SmallEiffelRuntime";
   fz_static:                  STRING is "static ";
   fz_struct:                  STRING is "struct ";
   fz_sys:                     STRING is "sys";
   fz_system_se:               STRING is "system.se";
   fz_t0_star:                 STRING is "T0*";
   fz_t7_star:                 STRING is "T7*";
   fz_to_t:                    STRING is "toT";
   fz_typedef:                 STRING is "typedef ";
   fz_unsigned:                STRING is "unsigned";
   fz_void:                    STRING is "void";
   fz_0x:                      STRING is "0x";

-----------------------------------------------------------------------------
-- Frozen list numbered not in UNIQUE_STRING :

   fz_00: STRING is ";%N";
   fz_01: STRING is "File %"";
   fz_02: STRING is "Done.%N";
   fz_03: STRING is "%"."
   fz_04: STRING is "Pre-Computed Once Function";
   fz_05: STRING is "(s):%N";
   fz_06: STRING is " is concerned.";
   fz_07: STRING is " is ever created.";
   fz_08: STRING is "Unknown flag : ";
   fz_09: STRING is "Feature %"";
   fz_10: STRING is " : %%d\n%",";
   fz_11: STRING is "{%N";
   fz_12: STRING is "}%N";
   fz_13: STRING is "))";
   fz_14: STRING is ");%N";
   fz_15: STRING is "return R;%N}%N";
   fz_16: STRING is "));%N"
   fz_17: STRING is "((";
   fz_18: STRING is "%"%N";
   fz_19: STRING is ")V";
   fz_20: STRING is "),(";
   fz_21: STRING is "Ljava/lang/Object;";
   fz_22: STRING is ")(";
   fz_23: STRING is "([Ljava/lang/String;)V";
   fz_24: STRING is "string";
   fz_25: STRING is "java/io/PrintStream";
   fz_27: STRING is "(I)V";
   fz_28: STRING is "_initialize_eiffel_runtime";
   fz_29: STRING is "()V";
   fz_30: STRING is "=NULL;%N";
   fz_31: STRING is "[B";
   fz_33: STRING is "getBytes";
   fz_34: STRING is "()[B";
   fz_35: STRING is "<init>";
   fz_37: STRING is "in";
   fz_38: STRING is "Ljava/io/InputStream;";
   fz_39: STRING is "out";
   fz_40: STRING is "Ljava/io/PrintStream;";
   fz_41: STRING is "B";
   fz_42: STRING is "close";
   fz_44: STRING is "(Ljava/lang/Object;)Ljava/lang/Object;";
   fz_49: STRING is "err";
   fz_50: STRING is "Assertion failed.";
   fz_51: STRING is "println";
   fz_52: STRING is "traceInstructions";
   fz_54: STRING is "(Z)V";
   fz_55: STRING is "getRuntime";
   fz_56: STRING is "()Ljava/lang/Runtime;";
   fz_57: STRING is "(Ljava/lang/String;)V";
   fz_58: STRING is "check_flag";
   fz_59: STRING is "0.";
   fz_60: STRING is "valueOf0";
   fz_61: STRING is "(Ljava/lang/String;)D";
   fz_63: STRING is "toString";
   fz_64: STRING is "(D)Ljava/lang/String;";
   fz_65: STRING is "([BII)V";
   fz_66: STRING is "String";
   fz_68: STRING is "(Ljava/lang/String;)V";
   fz_70: STRING is "read";
   fz_71: STRING is "()I";
   fz_73: STRING is "Z";
   fz_74: STRING is "args";
   fz_75: STRING is "[Ljava/lang/String;";
   fz_76: STRING is "<clinit>";
   fz_77: STRING is "D";
   fz_78: STRING is "F";
   fz_80: STRING is "(Ljava/lang/String;)Ljava/lang/String;";
   fz_82: STRING is "parseInt";
   fz_83: STRING is "(Ljava/lang/String;)I";
   fz_86: STRING is "exists";
   fz_87: STRING is "()Z";
   fz_88: STRING is "(Ljava/io/File;)V";
   fz_89: STRING is "exec";
   fz_90: STRING is "(Ljava/lang/String;)Ljava/lang/Process;";
   fz_91: STRING is "waitFor";
   fz_94: STRING is "(D)D";
   fz_96: STRING is "()D";
   fz_97: STRING is "()F";
   fz_99: STRING is "(DD)D";
   fz_a1: STRING is "equals";
   fz_a2: STRING is "get";
   fz_a3: STRING is "(I)Z";
   fz_a4: STRING is "set";
   fz_a5: STRING is "clear";
   fz_a6: STRING is "clone";
   fz_a7: STRING is "()Ljava/lang/Object;";
   fz_a8: STRING is "(Ljava/lang/Object;)Z";
   fz_a9: STRING is "Ljava/util/BitSet;";
   fz_b0: STRING is "%".%N";
   fz_b1: STRING is "(Ljava/util/BitSet;)V";
   fz_b2: STRING is "delete";
   fz_b3: STRING is "renameTo";
   fz_b4: STRING is "(Ljava/io/File;)Z";
   fz_b6: STRING is ".%N";
   fz_b7: STRING is "((T";

end -- FROZEN_STRING_LIST

