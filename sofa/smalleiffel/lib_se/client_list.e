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
class CLIENT_LIST
   --
   -- To store a list of clients class like : {FOO,BAR}
   --

inherit GLOBALS;

creation make, omitted, merge

feature

   start_position: POSITION;
         -- Of the the opening bracket when list is really written.

feature {CLIENT_LIST}

   list: CLASS_NAME_LIST;

feature {NONE}

   make(sp: like start_position; l: like list) is
         -- When the client list is really written.
         --
         -- Note : {NONE} has the same meaning as {}.
      require
         not sp.is_unknown
      do
         start_position := sp;
         list := l;
      ensure
         start_position = sp;
         list = l
      end;

   omitted is
         -- When the client list is omitted.
         --
         -- Note : it has the same meaning as {ANY}.
      do
      end;

   merge(sp: like start_position; l1, l2: like list) is
      require
         not sp.is_unknown
      do
         start_position := sp;
         !!list.merge(l1,l2);
      end;

feature

   is_omitted: BOOLEAN is
      do
         Result := start_position.is_unknown;
      end;

   pretty_print is
      do
         if is_omitted then
            if fmt.zen_mode then
            else
               fmt.put_string("{ANY} ");
            end
         else
            if list = Void then
               if fmt.zen_mode then
                  fmt.put_string("{} ");
               else
                  fmt.put_string("{NONE} ");
               end;
            else
               fmt.put_character('{');
               fmt.set_indent_level(2);
               list.pretty_print;
               fmt.put_character('}');
               fmt.put_character(' ');
            end;
         end;
      end;

   gives_permission_to(cn: CLASS_NAME): BOOLEAN is
         -- True if the client list give permission to `cn'.
         -- When false, `eh' is preloaded with beginning of
         -- error message.
      require
         cn /= Void
      do
         if is_omitted then
            -- It is as {ANY} :
            Result := true;
         elseif list = Void then
            -- Because it is as : {NONE}.
         else
            Result := list.gives_permission_to(cn);
         end;
         gives_permission_error(Result,cn.to_string);
      end;

feature {EXPORT_LIST}

   merge_with(other: like Current): like current is
      require
         other /= Void
      local
         sp: POSITION;
      do
         if gives_permission_to_any then
            Result := Current;
         elseif other.gives_permission_to_any then
            Result := other;
         else
            sp := start_position;
            if sp.is_unknown then
               sp := other.start_position;
            end;
            !!Result.merge(sp,list,other.list);
         end;
      end;

feature {PARENT_LIST}

   append(other: like Current): like Current is
      require
         other /= Void
      do
         if Current = other or else is_omitted then
            Result := Current;
         else
            if gives_permission_to_any then
               Result := Current;
            else
               eh.cancel;
               if other.is_omitted then
                  Result := other;
               elseif other.gives_permission_to_any then
                  Result := other;
               else
                  eh.cancel;
                  !!Result.merge(start_position,list,other.list);
               end;
            end;
         end;
      end;

feature

   gives_permission_to_any: BOOLEAN is
      do
         if is_omitted then
            Result := true;
            -- Because it is as : {ANY}.
         elseif list = Void then
            -- Because it is as : {NONE}.
         else
            Result := list.gives_permission_to_any;
         end;
         gives_permission_error(Result,as_any);
      end;

feature {RUN_FEATURE}

   vape_check(call_site: POSITION; other: like Current) is
         -- To enforce VAPE, all clients of Current object must
         -- be allowed by `other'.
      require
         run_control.require_check;
         other /= Void
      local
         vape: BOOLEAN;
         i: INTEGER;
         caller: RUN_FEATURE;
         cn: CLASS_NAME;
      do
         if is_omitted then
            -- It is as {ANY}
            vape := other.gives_permission_to_any;
         elseif list = Void then
            -- It is {NONE}
            vape := true;
            eh.cancel;
         else
            from
               vape := true;
               i := list.count;
            until
               not vape or else i = 0
            loop
               cn := list.item(i);
               vape := other.gives_permission_to(cn);
               i := i - 1;
            end;
         end;
         if not vape then
            if cn /= Void then
               eh.add_position(cn.start_position);
            else
               eh.add_position(start_position);
            end;
            eh.add_position(call_site);
            eh.append("Invalid require assertion (VAPE).");
            eh.print_as_error;
            eh.add_position(call_site);
            eh.add_position(other.start_position);
            caller := small_eiffel.top_rf;
            eh.append(caller.current_type.run_time_mark);
            eh.append(" is the validation-context of the call. %
                      %This feature cannot be called in this %
                      %require clause (VAPE).");
            eh.print_as_error;
            eh.append("VAPE error in require clause of ");
            if cn /= Void then
               eh.add_position(cn.start_position);
            else
               eh.add_position(start_position);
            end;
            eh.add_position(caller.start_position);
            eh.append(caller.name.to_string);
            eh.print_as_fatal_error;
         end;
      end;

feature {NONE}

   gives_permission_error(no_error: BOOLEAN; cn: STRING) is
      do
         if no_error then
            eh.cancel;
         else
            if start_position.is_unknown then
               if list /= Void then
                  eh.add_position(list.item(1).start_position);
               end;
            else
               eh.add_position(start_position);
            end;
            eh.append(cn);
            eh.append(" is not allowed to use this feature. ");
         end;
      end;

end -- CLIENT_LIST
