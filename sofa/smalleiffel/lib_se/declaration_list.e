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
deferred class DECLARATION_LIST
   --
   -- For a formal arguments list (FORMAL_ARG_LIST) or for a local
   -- variable list (LOCAL_VAR_LIST).
   --
   -- Exemple :
   --
   --   foo, bar : ZOO; x : INTEGER
   --

inherit GLOBALS;

feature {DECLARATION_LIST}

   list: ARRAY[DECLARATION];
         -- Really written list including declaration groups.

   flat_list: ARRAY[like name];
         -- The same contents as `list' but flat.

feature {NONE}

   declaration_list_make(l: like list) is
         -- Common part of creation.
      require
         l.lower = 1;
         not l.is_empty
      local
         il, actual_count: INTEGER;
      do
         list := l;
         from
            il := list.upper;
         until
            il = 0
         loop
            actual_count := actual_count + list.item(il).count;
            il := il - 1;
         end;
         from
            !!flat_list.make(1,actual_count);
            il := 1;
         until
            il > list.upper
         loop
            list.item(il).append_in(Current);
            il := il + 1;
         end;
      ensure
         list = l;
         flat_list /= Void
      end;

feature

   start_position: POSITION is
      do
         Result := flat_list.first.start_position;
      end;

   pretty_print is
      require
         fmt.indent_level >= 2;
      deferred
      ensure
         fmt.indent_level = old fmt.indent_level;
      end;

   count: INTEGER is
      do
         Result := flat_list.upper;
      end;

   rank_of(n: STRING): INTEGER is
         -- Result is greater than 0 when `n' is in the list.
      require
         string_aliaser.item(n) = n
      do
         from
            Result := count
         until
            Result = 0 or else n = name(Result).to_string
         loop
            Result := Result - 1;
         end;
      ensure
         0 <= Result;
         Result <= count;
      end;

   name(i: INTEGER): LOCAL_ARGUMENT1 is
      require
         1 <= i;
         i <= count
      deferred
      ensure
         Result /= Void
      end;

   type(i: INTEGER): TYPE is
      require
         1 <= i;
         i <= count;
      do
         Result := name(i).result_type;
      ensure
         Result /= Void
      end;

feature {DECLARATION}

   add_last(n: like name) is
      local
         i: INTEGER;
         n2: like name;
      do
         from
            i := 1;
         until
            flat_list.item(i) = Void
         loop
            n2 := flat_list.item(i);
            if n2.to_string = n.to_string then
               eh.add_position(n.start_position);
               eh.add_position(n2.start_position);
               fatal_error("Same name appears twice.");
            end;
            i := i + 1;
         end;
         flat_list.put(n,i);
         n.set_rank(i);
      end;

feature {RUN_FEATURE}

   frozen jvm_stack_space: INTEGER is
         -- Number of needed words in the JVM stack.
      local
         i: INTEGER;
      do
         from
            i := count;
         until
            i = 0
         loop
            Result := Result + type(i).run_type.jvm_stack_space;
            i := i - 1;
         end;
      end;

feature {RUN_FEATURE}

   frozen jvm_offset_of(la: LOCAL_ARGUMENT): INTEGER is
      local
         i, rank: INTEGER;
      do
         from
            rank := la.rank;
            i := 1;
         variant
            count - i
         until
            i = rank
         loop
            Result := Result + type(i).run_type.jvm_stack_space;
            i := i + 1;
         end;
      end;

feature {NONE}

   em1: STRING is "Bad declaration.";

feature

   frozen is_runnable(ct: TYPE): BOOLEAN is
      local
         i: INTEGER;
         n: like name;
         t: TYPE;
      do
         from
            Result := true;
            i := flat_list.upper;
         until
            not Result or else i = 0
         loop
            t := type(i);
            if t.is_run_type then
               if t.run_type /= t then
                  Result := false;
               end;
            else
               Result := false;
            end;
            i := i - 1;
         end;
         if Result then
            from
               i := flat_list.upper;
            until
               i = 0
            loop
               n := flat_list.item(i);
               if n.to_runnable(ct) = Void then
                  error(n.start_position,em1);
                  i := 0;
               else
                  i := i - 1;
               end;
            end;
            check_name_clash(ct);
         end;
      end;

feature {DECLARATION_LIST}

   frozen check_name_clash(ct: TYPE) is
      local
         i: INTEGER;
      do
         from
            i := flat_list.upper;
         until
            i = 0
         loop
            name(i).name_clash(ct);
            i := i - 1;
         end;
      end;

   frozen dynamic_runnable(ct: TYPE) is
      local
         i: INTEGER;
         n1, n2: like name;
      do
         flat_list := flat_list.twin;
         from
            i := flat_list.upper;
         until
            i = 0
         loop
            n1 := flat_list.item(i);
            n2 := n1.to_runnable(ct);
            if n2 = Void then
               error(n1.start_position,em1);
            else
               flat_list.put(n2,i);
            end;
            i := i - 1;
         end;
      end;

invariant

   count > 0;

   flat_list.lower = 1;

   count = flat_list.count;

   list.count <= count;

end -- DECLARATION_LIST

