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
deferred class E_FEATURE
   --
   -- For all possible Features : procedure, function, attribute,
   -- constants, once procedure, once function, ...
   --

inherit GLOBALS;

feature

   base_class: BASE_CLASS;
         -- The class where the feature is really written if any.
	 -- Because of the undefine option for example, `base_class' may be 
	 -- Void.

   names: FEATURE_NAME_LIST;
         -- All the names of the feature.
   
   arguments: FORMAL_ARG_LIST is
         -- Arguments if any.
      deferred
      end;
   
   result_type: TYPE is
         -- Result type if any.
      deferred
      end;
   
   header_comment: COMMENT;
         -- Header comment for a routine or following comment for
         -- an attribute.
   
   obsolete_mark: MANIFEST_STRING is
         -- The `obsolete' mark if any.
      deferred
      end;
   
   require_assertion: E_REQUIRE is
         -- Not Void if any.
      deferred
      end;
   
   ensure_assertion: E_ENSURE is
         -- Not Void if any.
      deferred
      end;
   
   clients: CLIENT_LIST;
         -- Authorized clients list of the corresponding feature
         -- clause in the base definition class.
   
   is_deferred: BOOLEAN is
         -- Is it a deferred feature ?
      deferred
      end;
   
   frozen base_class_name: CLASS_NAME is
         -- Name of the class where the feature is really written.
      do
         Result := base_class.name;
      end;
   
   frozen first_name: FEATURE_NAME is
      do
         Result := names.first;
      ensure
         Result /= void
      end;
   
   frozen start_position: POSITION is
      do
         Result := first_name.start_position;
      end;
   
   to_run_feature(ct: TYPE; fn: FEATURE_NAME): RUN_FEATURE is
         -- If possible, gives the checked runnable feature for `ct'
         -- using `fn' as the final name.
      require
	 ct.run_type = ct
         ct.run_class.at(fn) = Void
      deferred
      ensure
         Result /= Void implies ct.run_class.at(fn) = Result;
         Result = Void implies nb_errors > 0
      end;
   
   can_hide(other: E_FEATURE; rc: RUN_CLASS): BOOLEAN is
         -- True when headings of Current can be hide with
         -- heading of `other' in `rc'.
      require
         Current /= other
      do
         if result_type /= other.result_type then
            if result_type = Void or else other.result_type = Void then
               eh.add_position(other.start_position);
               error(start_position,em_ohrbnto);
            end;
         end;
         if arguments /= other.arguments then
            if arguments = Void or else other.arguments = Void then
               eh.add_position(other.start_position);
               error(start_position,em_ohabnto);
            elseif arguments.count /= other.arguments.count then
               eh.add_position(other.start_position);
               error(start_position,em_ina);
            end;
         end;
         if nb_errors = 0 then
            if result_type /= Void then
               if not result_type.is_a_in(other.result_type,rc) then
                  eh.append(em_chtfi);
                  eh.append(rc.current_type.run_time_mark);
                  eh.append(fz_dot);
                  eh.print_as_error;
               end;
            end;
         end;
         if nb_errors = 0 then
            if arguments /= Void then
               if not arguments.is_a_in(other.arguments,rc) then
                  eh.add_position(other.start_position);
                  eh.add_position(start_position)
                  eh.append(em_chtfi);
                  eh.append(rc.current_type.run_time_mark);
                  eh.append(fz_dot);
                  eh.print_as_error;
               end;
            end;
         end;
         Result := nb_errors = 0;
         if Result then
            merge_header_comments(other);
         end;
      end;
   
   frozen check_obsolete(caller: POSITION) is
      require
         not caller.is_unknown
      do
         if obsolete_mark /= Void then
            if not small_eiffel.short_flag then
               eh.add_position(caller);
               eh.append("This feature is obsolete :%N");
               eh.append(obsolete_mark.to_string);
               eh.add_position(start_position);
               eh.print_as_warning;
            end
         end;
      end;
   
   set_header_comment(hc: like header_comment) is
      do
         header_comment := hc;
      end;
   
   pretty_print is
      require
         fmt.indent_level = 1
      deferred
      ensure
         fmt.indent_level = 1
      end;

   frozen pretty_print_profile is
      do
         pretty_print_names;
         fmt.set_indent_level(2);
         pretty_print_arguments;
         fmt.set_indent_level(3);
         if result_type /= Void then
            fmt.put_string(": ");
            result_type.pretty_print;
         end;
      end;

feature {PARENT_LIST}

   frozen is_not_mergeable_with(other: E_FEATURE): BOOLEAN is
         -- True when `Current' and `other' are clearly not mergeable 
         -- because of a different number of arguments or result.
      require
         Current /= other;
         eh.is_empty
      do
         if result_type = Void then
            Result := other.result_type /= Void;
         else
            Result := other.result_type = Void;
         end;
         if Result then
            eh.append(em_ohrbnto);
         else
            if arguments = Void then
               Result := other.arguments /= Void;
            else
               Result := other.arguments = Void;
            end;
            if Result then
               eh.append(em_ohabnto);
            elseif arguments = Void then
            elseif arguments.count /= other.arguments.count then
               eh.append(em_ina);
               Result := true;
            end;
         end;
         merge_header_comments(other);
      ensure
         Result = not eh.is_empty
      end;

feature {PARENT}

   frozen try_to_undefine(fn: FEATURE_NAME; bc: BASE_CLASS):
      DEFERRED_ROUTINE is
         -- Compute the corresponding deferred feature for `Current'.
         -- This occurs for example when `bc' has an undefine clause 
         -- for `fn' which refer to `Current'.
         -- The Result is never Void because `fatal_error' may be called. 
         -- Also check VDUS.
      require
         fn /= Void;
         bc.name.is_subclass_of(base_class_name)
      local
         fn2: FEATURE_NAME;
      do
         -- For (VDUS) :
         eh.add_position(fn.start_position);
         fn2 :=  names.feature_name(fn.to_key);
         if fn2 /= Void then
            fn2.undefine_in(bc);
         end;
         eh.cancel;
         --
         Result := try_to_undefine_aux(fn,bc);
         if Result /= Void then
            Result.set_clients(clients);
            merge_header_comments(Result);
         else
            bc.fatal_undefine(fn);
         end;
      ensure
         Result /= Void
      end;

feature {FEATURE_CLAUSE,E_FEATURE}

   set_clients(c: like clients) is
      require
         c /= Void
      do
         clients := c;
      ensure
         clients = c
      end;

feature {FEATURE_CLAUSE}

   frozen add_into(fd: DICTIONARY[E_FEATURE,STRING]) is
         -- Also check for multiple definitions.
      local
         i: INTEGER;
         fn: FEATURE_NAME;
	 key: STRING;
      do
         base_class := names.item(1).start_position.base_class;
         from
            i := 1;
         until
            i > names.count
         loop
            fn := names.item(i);
	    key := fn.to_key;
            if fd.has(key) then
               fn := fd.at(key).first_name;
               eh.add_position(fn.start_position);
               eh.add_position(names.item(i).start_position);
               eh.append("Double definition of feature ");
               eh.append(fn.to_string);
               eh.append(fz_dot);
               eh.print_as_error;
            else
               fd.add(Current,key);
            end;
            i := i + 1;
         end;
      end;

feature {NONE}

   frozen pretty_print_names is
         -- Print only the names of the feature.
      local
         i: INTEGER;
      do
         from
            i := 1;
            names.item(i).declaration_pretty_print;
            i := i + 1;
         until
            i > names.count
         loop
            fmt.put_string(", ");
            names.item(i).declaration_pretty_print;
            i := i + 1;
         end;
      end;

   pretty_print_arguments is
      deferred
      end;

   make_e_feature(n: like names) is
      require
         n.count >= 1
      do
         names := n;
      ensure
         names = n
      end;

   try_to_undefine_aux(fn: FEATURE_NAME;
                       bc: BASE_CLASS): DEFERRED_ROUTINE is
      require
         fn /= Void;
         bc /= Void
      deferred
      end;

   frozen merge_header_comments(other: E_FEATURE) is
         -- Falling down of the `header_comment' for command short.
      do
         if small_eiffel.short_flag then
            if header_comment = Void then
               header_comment := other.header_comment;
            elseif other.header_comment = Void then
               other.set_header_comment(header_comment);
            end;
         end;
      end;

   em_chtfi: STRING is " Cannot inherit these features in ";

   em_ohrbnto: STRING is "One has Result but not the other.";

   em_ohabnto: STRING is "One has argument(s) but not the other.";

   em_ina: STRING is "Incompatible number of arguments.";

invariant

   names /= Void;

end -- E_FEATURE

