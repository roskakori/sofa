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
expanded class TMP_FEATURE
   --
   -- Temporary object used during syntax analysis.
   -- At the end, the good effective E_FEATURE is choose.
   --

inherit GLOBALS;

feature {EIFFEL_PARSER}

   arguments: FORMAL_ARG_LIST;

   type: TYPE;

   header_comment: COMMENT;

   obsolete_mark: MANIFEST_STRING;

   require_assertion: E_REQUIRE;

   local_vars: LOCAL_VAR_LIST;

   routine_body: COMPOUND;

   initialize is
      do
         names.clear;
         arguments := Void;
         type := Void;
         header_comment := Void;
         obsolete_mark := Void;
         require_assertion := Void;
         local_vars := Void;
         routine_body := Void;
      end;

   add_synonym(a_name: FEATURE_NAME) is
      require
         a_name /= Void
      do
         if a_name.to_string = as_void then
            eh.add_position(a_name.start_position);
            fatal_error("Feature `Void' cannot be redefined (builtin).");
         end;
         names.add_last(a_name);
      end;

   set_arguments(args: like arguments) is
      require
         args /= Void
      do
         arguments:= args;
      end;

   set_type(t: like type) is
      require
         t /= Void
      do
         type := t;
      ensure
         type = t;
      end;

   set_header_comment(hc: like header_comment) is
      do
         header_comment := hc;
      end;

   set_obsolete_mark(om: like obsolete_mark) is
      do
         obsolete_mark := om;
      end;

   set_local_vars(lv: like local_vars) is
      do
         local_vars := lv;
      end;

   set_require(sp: POSITION; hc: COMMENT; al: ARRAY[ASSERTION]) is
      do
         if hc /= Void or else al /= Void then
            !!require_assertion.make(sp,hc,al);
         end;
      end;

   set_require_else(sp: POSITION; hc: COMMENT; al: ARRAY[ASSERTION]) is
      do
         if hc /= Void or else al /= Void then
            !!require_assertion.make(sp,hc,al);
            require_assertion.set_require_else;
         end;
      end;

   set_routine_body(rb: like routine_body) is
      do
         routine_body := rb;
      end;

   to_writable_attribute: WRITABLE_ATTRIBUTE is
      do
         if type = Void then
            error(names.first.start_position,
                  "Bad feature definition.");
         elseif arguments /= Void then
            eiffel_parser.ecp("Attribute must not have formal arguments.");
         end;
         !!Result.make(n,type);
      end;

   to_cst_att_boolean(value: BOOLEAN_CONSTANT): CST_ATT_BOOLEAN is
      do
         to_cst_att_check_result_type;
         if type.is_boolean then
            !!Result.make(n,type,value);
         else
            error(type.start_position,
                  "The type of this constant feature should be BOOLEAN.");
         end;
      end;

   to_cst_att_bit(value: BIT_CONSTANT): CST_ATT_BIT is
      do
         to_cst_att_check_result_type;
         if type.is_bit then
            !!Result.make(n,type,value);
         else
            error(type.start_position,
                  "The type of this constant feature should be BIT.");
         end;
      end;

   to_cst_att_character(value: CHARACTER_CONSTANT): CST_ATT_CHARACTER is
      do
         to_cst_att_check_result_type;
         if type.is_character then
            !!Result.make(n,type,value);
         else
            error(type.start_position,
                  "The type of this constant feature should be CHARACTER.");
         end;
      end;

   to_cst_att_integer(value: INTEGER_CONSTANT): CST_ATT is
      do
         to_cst_att_check_result_type;
         if type.is_integer then
            !CST_ATT_INTEGER!Result.make(n,type,value);
         elseif type.is_real then
            !CST_ATT_REAL!Result.make(n,type,value.to_real_constant);
         elseif type.is_double then
            !CST_ATT_DOUBLE!Result.make(n,type,value.to_real_constant);
         else
            error(type.start_position,
                  "The type of this constant feature should be INTEGER %
                  %REAL or DOUBLE.");
         end;
      end;

   to_cst_att_real(value: REAL_CONSTANT): CST_ATT is
      do
         to_cst_att_check_result_type;
         if type.is_real then
            !CST_ATT_REAL!Result.make(n,type,value);
         elseif type.is_double then
            !CST_ATT_DOUBLE!Result.make(n,type,value);
         else
            eh.add_position(type.start_position);
            fatal_error("The type of this constant feature %
                        %should be REAL or DOUBLE.");
         end;
      end;

   to_cst_att_string(value: MANIFEST_STRING): CST_ATT_STRING is
      do
         to_cst_att_check_result_type;
         if type.is_string then
            !!Result.make(n,type,value);
         else
            error(type.start_position,
                  "The type of this constant feature should be STRING.");
         end;
      end;

   to_deferred_routine: DEFERRED_ROUTINE is
      do
         if type = Void then
            !DEFERRED_PROCEDURE!Result.make(n, arguments,
                                            obsolete_mark,
                                            header_comment,
                                            require_assertion);
         else
            !DEFERRED_FUNCTION!Result.make(n, arguments, type,
                                           obsolete_mark,
                                           header_comment,
                                           require_assertion);
         end;
      end;

   to_external_routine(native: NATIVE; alias_tag: STRING): EXTERNAL_ROUTINE is
      do
         if type = Void then
            !EXTERNAL_PROCEDURE!Result.make(n, arguments,
                                            obsolete_mark,
                                            header_comment,
                                            require_assertion,
                                            native,alias_tag);
         else
            !EXTERNAL_FUNCTION!Result.make(n, arguments, type,
                                           obsolete_mark,
                                           header_comment,
                                           require_assertion,
                                           native,alias_tag);
         end;
      end;

   to_once_routine: ONCE_ROUTINE is
      do
         if type = Void then
            !ONCE_PROCEDURE!Result.make(n, arguments,
                                        obsolete_mark,
                                        header_comment,
                                        require_assertion,
                                        local_vars,
                                        routine_body);
         else
            !ONCE_FUNCTION!Result.make(n, arguments, type,
                                       obsolete_mark,
                                       header_comment,
                                       require_assertion,
                                       local_vars,
                                       routine_body);
         end;
      end;

   to_procedure_or_function: EFFECTIVE_ROUTINE is
      do
         if type = Void then
            !PROCEDURE!Result.make(n, arguments,
                                   obsolete_mark,
                                   header_comment,
                                   require_assertion,
                                   local_vars,
                                   routine_body);
         else
            !FUNCTION!Result.make(n, arguments, type,
                                  obsolete_mark,
                                  header_comment,
                                  require_assertion,
                                  local_vars,
                                  routine_body);
         end;
      end;

   to_cst_att_unique: CST_ATT_UNIQUE is
      do
         if type = Void then
            eh.add_position(names.first.start_position);
            fatal_error(em01);
         elseif type.is_integer then
            !!Result.make(n,type);
         else
            eh.add_position(type.start_position);
            fatal_error(em01);
         end;
      end;

feature {NONE}

   names: FIXED_ARRAY[FEATURE_NAME] is
      once
         !!Result.make(8);
      end;

   to_cst_att_check_result_type is
      do
         if type = Void then
            eh.add_position(names.first.start_position);
            fatal_error("Bad constant declaration (no result type).");
         elseif not type.is_run_type then
            eh.add_position(type.start_position);
            fatal_error("Must not use such a type for constant.");
         end;
      end;

   n: FEATURE_NAME_LIST is
      require
         not names.is_empty;
      do
         !!Result.make_n(names);
      end;

   em01: STRING is "Unique feature must have INTEGER type.";

end -- TMP_FEATURE
