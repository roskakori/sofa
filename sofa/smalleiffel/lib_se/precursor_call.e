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
deferred class PRECURSOR_CALL
   --
   -- Handling of the `Precursor' construct. Common ancestor of 
   -- PRECURSOR_CALL_EXPRESSION (when `Precursor' is inside a function call) and 
   -- PRECURSOR_CALL_INSTRUCTION (when `Precursor' is inside a procedure call).
   --

inherit GLOBALS;

feature

   use_current: BOOLEAN is true;

   start_position: POSITION;


   parent: CLASS_NAME;
         -- {{<CLASS_NAME>}} to remove the ambiguity if any.

   frozen afd_check is
      do
         if arguments /= Void then
            arguments.afd_check;
         end;
      end;

   frozen compile_to_c is
      do
         cpp.push_precursor(run_feature,arguments);
         run_feature.mapping_c;
         cpp.pop;
      end;

   frozen pretty_print is
      do
         if parent /= Void then
            fmt.put_character('{');
            parent.pretty_print;
            fmt.put_character('}');
         end;
         fmt.put_string(as_precursor);
         if arguments /= Void then
            fmt.level_incr;
            arguments.pretty_print;
            fmt.level_decr;
         end;
         put_semi_colon;
      end;

   frozen compile_to_jvm is
      do
         jvm.push_precursor(run_feature,arguments);
         run_feature.mapping_jvm;
         jvm.pop;
      end;

feature {NONE}

   current_type: TYPE;

   arguments: EFFECTIVE_ARG_LIST;

   run_feature: RUN_FEATURE;
         -- Corresponding super feature.

   make(sp: like start_position; pc: like parent; pal: like arguments) is
      require
         not sp.is_unknown
      do
         start_position := sp;
         parent := pc;
         arguments := pal;
      ensure
         start_position = sp;
         parent = pc;
         arguments = pal;
      end;

   super_feature(wrf: RUN_FEATURE): EFFECTIVE_ROUTINE is
         -- Gives the one to be called where `wrf' is the
         -- written runable feature which contains Current.
      require
         wrf /= Void
      local
         e_feature: E_FEATURE;
         wbc: BASE_CLASS;
         pl: PARENT_LIST;
      do
         e_feature := wrf.base_feature;
         wbc := e_feature.base_class;
         pl := wbc.parent_list;
         if pl = Void then
            eh.add_position(start_position);
            fatal_error("Precursor call is allowed only when the %
                        %enclosing routine is redefined.");
         else
            Result := pl.precursor_for(Current,wrf);
         end;
      ensure
         Result /= Void
      end;

   prepare_arguments(ct: TYPE) is
         -- Called after `super_feature' in order to prepare runnable `arguments'.
      require
         run_feature /= Void
      local
         a: like arguments;
      do
         if arguments /= Void then
            a := arguments.to_runnable(ct);
            if a = Void then
               error(arguments.start_position,fz_bad_arguments);
            else
               arguments := a;
            end;
            if nb_errors = 0 then
               arguments.match_with(run_feature,ct);
            end;
         elseif run_feature.arguments /= Void then
            eh.add_position(run_feature.start_position);
            eh.add_position(start_position);
            fatal_error("Precursor must pass argument(s).");
         end;
      end;

   precursor_name(wfn: FEATURE_NAME; super: E_FEATURE): PRECURSOR_NAME is
      require
         wfn /= Void;
         super /= Void
      do
         !!Result.refer_to(super.base_class.id,wfn);
      end;

   put_semi_colon is
      deferred
      end;

end -- PRECURSOR_CALL
