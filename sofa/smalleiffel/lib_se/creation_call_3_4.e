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
deferred class CREATION_CALL_3_4

inherit CREATION_CALL;

feature

   call: PROC_CALL;

   frozen collect_c_tmp is
      local
         arguments: EFFECTIVE_ARG_LIST;
      do
         run_feature.collect_c_tmp;
         arguments := run_args;
         if arguments /= Void then
            arguments.collect_c_tmp;
         end;
      end;

feature

   afd_check is
      do
         if arg_count > 0 then
            run_args.afd_check;
         end;
      end;

feature {NONE}

   run_args: EFFECTIVE_ARG_LIST is
      do
         Result := call.arguments;
      end;

   check_creation_clause(t: TYPE) is
      require
         t.is_run_type
      local
         ct: TYPE;
         fn: FEATURE_NAME;
         bottom, top: BASE_CLASS;
         args: like run_args;
      do
         fn := call.feature_name;
         top := fn.start_position.base_class;
         bottom := t.base_class;
         if t.is_like_current then
            check
               bottom = top or else bottom.is_subclass_of(top)
            end;
            fn := bottom.new_name_of(top,fn);
            if fn = Void then
               fn := call.feature_name;
               eh.feature_not_found(fn);
               eh.append(" Type to create is %"");
               eh.append(t.run_time_mark);
               fatal_error(fz_03);
            end;
         end;
         run_feature := t.run_class.get_feature(fn);
         if run_feature = Void then
            cp_not_found(fn);
         end;
         if small_eiffel.short_flag then
         elseif not t.has_creation(fn) then
            eh.add_position(call.feature_name.start_position);
            eh.add_position(fn.start_position);
            eh.append(fn.to_string);
            eh.append(" is not in the creation list of ");
            eh.add_type(t,fz_dot);
            eh.print_as_fatal_error;
         end;
         run_feature.run_class.add_client(current_type.run_class);
         if run_feature.result_type /= Void then
            eh.add_position(run_feature.start_position);
            eh.add_position(fn.start_position);
            fatal_error("Feature found is not a procedure.");
         end;
         if arg_count = 0 and then run_feature.arguments /= Void then
            eh.add_position(run_feature.start_position);
            eh.add_position(start_position);
            fatal_error("Procedure found has argument(s).");
         end;
         if arg_count > 0 then
            ct := small_eiffel.top_rf.current_type;
            args := call.arguments.to_runnable(ct);
            if args = Void then
               error(call.arguments.start_position,fz_bad_arguments);
            else
               args.match_with(run_feature,ct);
            end;
         end;
         call := call.make_runnable(writable,args,run_feature);
      end;

   is_pre_computable: BOOLEAN is
      local
         rfct: TYPE;
         rfn, rfctbcn: STRING;
      do
         if writable.is_result then
            if run_args = Void then
               Result := true;
            else
               Result := run_args.is_pre_computable;
            end;
            if Result then
               if run_feature.is_pre_computable then
               else
                  rfct := run_feature.current_type;
                  rfctbcn := rfct.base_class.name.to_string;
                  rfn := run_feature.name.to_string;
                  if as_make= rfn then
                     if as_array = rfctbcn then
                     elseif as_fixed_array = rfctbcn then
                     elseif as_string = rfctbcn then
                     elseif as_dictionary = rfctbcn then
                     elseif as_std_file_read = rfctbcn then
                     elseif as_std_file_write = rfctbcn then
                     else
                        Result := false;
                     end;
                  elseif as_blank = rfn then
                     if as_string = rfctbcn then
                     else
                        Result := false;
                     end;
                  elseif as_with_capacity = rfn then
                     if as_array = rfctbcn then
                     elseif as_fixed_array = rfctbcn then
                     elseif as_dictionary = rfctbcn then
                     else
                        Result := false;
                     end;
                  else
                     Result := false;
                  end;
               end;
            end;
         end;
      end;

feature {NONE}

   cp_not_found(fn: FEATURE_NAME) is
      do
         eh.add_position(call.feature_name.start_position);
         eh.add_position(fn.start_position);
         fatal_error("Creation procedure not found.");
      end;

   c2c_expanded_initializer(t: TYPE) is
      local
         rf3: RUN_FEATURE_3;
      do
         rf3 := t.expanded_initializer;
         if rf3 /= Void then
            cpp.expanded_writable(rf3,writable);
         end;
      end;

end -- CREATION_CALL_3_4


