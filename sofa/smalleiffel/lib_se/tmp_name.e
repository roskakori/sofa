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
expanded class TMP_NAME
   --
   -- Singleton object used by `eiffel_parser' to have a temporary storage of
   -- an unkown name during syntax analysis.
   --

inherit GLOBALS;

feature {EIFFEL_PARSER}

   buffer: STRING is "                                                 ";

   start_position: POSITION;

   line: INTEGER is
      do
         Result := start_position.line;
      end;

   column: INTEGER is
      do
         Result := start_position.column;
      end;

   reset(sp: like start_position) is
      do
         start_position := sp;
         buffer.clear;
         aliased_string_memory := Void;
      end;

   extend(ch: CHARACTER) is
      do
         buffer.extend(ch);
      end;

   is_current: BOOLEAN is
      do
         if buffer.count = 7 then
            Result := as_current.same_as(buffer);
         end;
      end;

   is_result: BOOLEAN is
      do
         if buffer.count = 6 then
            Result := as_result.same_as(buffer);
         end;
      end;

   is_void: BOOLEAN is
      do
         if buffer.count = 4 then
            Result := as_void.same_as(buffer);
         end;
      end;

   aliased_string: STRING is
      do
         if aliased_string_memory = Void then
            aliased_string_memory := string_aliaser.item(buffer);
         end;
         Result := aliased_string_memory;
      end;

   isa_keyword: BOOLEAN is
      local
         c: CHARACTER;
      do
         c := buffer.first.to_lower;
         inspect
            c
         when 'a' then
            if fz_alias.same_as(buffer) then
               Result := true;
            elseif fz_all.same_as(buffer) then
               Result := true;
            elseif as_and.same_as(buffer) then
               Result := true;
            else
               Result := fz_as.same_as(buffer);
            end;
         when 'c' then
            if fz_check.same_as(buffer) then
               Result := true;
            elseif fz_class.same_as(buffer) then
               Result := true;
            elseif fz_create.same_as(buffer) then
	       eh.add_position(start_position);
	       eh.append("In order to be ready for the new Eiffel %
			 %definition, you should avoid the %"create%" %
                         %feature name because it may be used as a new %
                         %keyword in the next ETL definition.");
	       eh.print_as_warning;
               -- *** Waiting modification of ETL : Result := true;

            else
               Result := fz_creation.same_as(buffer);
            end;
         when 'd' then
            if fz_debug.same_as(buffer) then
               Result := true;
            elseif fz_deferred.same_as(buffer) then
               Result := true;
            else
               Result := fz_do.same_as(buffer);
            end;
         when 'e' then
            if fz_else.same_as(buffer) then
               Result := true;
            elseif fz_elseif.same_as(buffer) then
               Result := true;
            elseif fz_end.same_as(buffer) then
               Result := true;
            elseif fz_ensure.same_as(buffer) then
               Result := true;
            elseif fz_expanded.same_as(buffer) then
               Result := true;
            elseif fz_export.same_as(buffer) then
               Result := true;
            else
               Result := fz_external.same_as(buffer);
            end;
         when 'f' then
            if fz_false.same_as(buffer) then
               Result := true;
            elseif fz_feature.same_as(buffer) then
               Result := true;
            elseif fz_from.same_as(buffer) then
               Result := true;
            else
               Result := fz_frozen.same_as(buffer);
            end;
         when 'i' then
            if fz_if.same_as(buffer) then
               Result := true;
            elseif as_implies.same_as(buffer) then
               Result := true;
            elseif fz_indexing.same_as(buffer) then
               Result := true;
            elseif fz_infix.same_as(buffer) then
               Result := true;
            elseif fz_inherit.same_as(buffer) then
               Result := true;
            elseif fz_inspect.same_as(buffer) then
               Result := true;
            elseif fz_invariant.same_as(buffer) then
               Result := true;
            else
               Result := fz_is.same_as(buffer);
            end;
         when 'l' then
            if fz_like.same_as(buffer) then
               Result := true;
            elseif fz_local.same_as(buffer) then 
               Result := true;
            else
               Result := fz_loop.same_as(buffer);
            end;
         when 'o' then
            if fz_obsolete.same_as(buffer) then
               Result := true;
            elseif fz_old.same_as(buffer) then
               Result := true;
            elseif fz_once.same_as(buffer) then 
               Result := true;
            else
               Result := as_or.same_as(buffer);
            end;
         when 'p' then
            if as_precursor.same_as(buffer) then 
               Result := true;
            else
               Result := fz_prefix.same_as(buffer);
            end;
         when 'r' then
            if fz_redefine.same_as(buffer) then 
               Result := true;
            elseif fz_rename.same_as(buffer) then 
               Result := true;
            elseif fz_require.same_as(buffer) then 
               Result := true;
            elseif fz_rescue.same_as(buffer) then 
               Result := true;
            else
               Result := fz_retry.same_as(buffer);
            end;
         when 's' then
            if fz_select.same_as(buffer) then 
               Result := true;
            elseif fz_separate.same_as(buffer) then 
               Result := true;
            else
               Result := fz_strip.same_as(buffer);
            end;
         when 't' then
            if fz_then.same_as(buffer) then
               Result := true;
            else
               Result := fz_true.same_as(buffer);
            end;
         when 'u' then
            if fz_undefine.same_as(buffer) then 
               Result := true;
            elseif fz_unique.same_as(buffer) then 
               Result := true;
            else
               Result := fz_until.same_as(buffer);
            end;
         when 'v' then
            Result := fz_variant.same_as(buffer);
         when 'w' then
            Result := fz_when.same_as(buffer);
         when 'x' then
            Result := as_xor.same_as(buffer);
         else
         end;
      end;

   to_argument_name1: ARGUMENT_NAME1 is
      do
         !!Result.make(start_position,aliased_string);
      end;

   to_argument_name2(fal: FORMAL_ARG_LIST; rank: INTEGER): ARGUMENT_NAME2 is
      do
         !!Result.refer_to(start_position,fal,rank);
      end;

   to_class_name: CLASS_NAME is
      do
         !!Result.make(aliased_string,start_position);
      end;

   to_e_void: E_VOID is
      require
         is_void
      do
         !!Result.make(start_position);
      end;

   to_simple_feature_name: SIMPLE_FEATURE_NAME is
      do
         !!Result.make(aliased_string,start_position);
      end;

   to_infix_name_use: INFIX_NAME is
      do
         !!Result.make(aliased_string,start_position);
      end;

   to_infix_name(sp: POSITION): INFIX_NAME is
      do
         !!Result.make(aliased_string,sp);
      end;

   to_local_name1: LOCAL_NAME1 is
      do
         !!Result.make(start_position,aliased_string);
      end;

   to_local_name2(lvl: LOCAL_VAR_LIST; rank: INTEGER): LOCAL_NAME2 is
      do
         !!Result.refer_to(start_position,lvl,rank);
      end;

   to_prefix_name: PREFIX_NAME is
      do
         !!Result.make(aliased_string,start_position);
      end;

   to_tag_name: TAG_NAME is
      do
         !!Result.make(aliased_string,start_position);
      end;

feature {NONE}

   aliased_string_memory: STRING;

end -- TMP_NAME
