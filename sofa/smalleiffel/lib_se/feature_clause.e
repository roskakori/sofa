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
class FEATURE_CLAUSE
--
-- The contents of a feature clause.
--
-- Note : for a `pretty' pretty_printing, it is necessary to store exactly
--        the original contents (in the source file) of a feature
--        clause.
--

inherit GLOBALS;

creation make

feature

   clients: CLIENT_LIST;
         -- The `clients' allowed to use these features.

   comment: COMMENT;
         -- The heading comment comming with the clause.

feature {NONE}

   list: FIXED_ARRAY[E_FEATURE];
         -- Only the features of the current clause.
         -- Note : all features of a class are grouped in a
         -- single DICTIONARY (see BASE_CLASS).

feature {ANY}

   make(c: like clients; cm: COMMENT; l: like list) is
      require
         c /= Void;
         l /= Void implies not l.is_empty;
      do
         clients := c;
         comment := cm;
         list := l;
      ensure
         clients = c;
         comment = cm;
         list = l;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.set_indent_level(0);
         if not fmt.zen_mode then
            fmt.skip(1);
         else
            fmt.indent;
         end;
         fmt.keyword(fz_feature);
         clients.pretty_print;
         fmt.set_indent_level(0);
         if comment /= Void then
            if fmt.zen_mode then
            elseif fmt.column > 15 then
               fmt.set_indent_level(1);
               fmt.indent;
               fmt.set_indent_level(0);
            end;
            comment.pretty_print;
            if not fmt.zen_mode then
               fmt.skip(1);
            end;
         end;
         if list /= Void then
            from
               i := 0;
            until
               i > list.upper
            loop
               fmt.set_indent_level(1);
               fmt.indent;
               if not fmt.zen_mode then
                  fmt.skip(1);
               end;
               list.item(i).pretty_print;
               i := i + 1;
            end;
         end;
         fmt.set_indent_level(0);
         if not fmt.zen_mode then
            fmt.skip(1);
         end;
      end;

feature {FEATURE_CLAUSE_LIST}

   for_short(bcn: CLASS_NAME; sort: BOOLEAN;
             rf_list: FIXED_ARRAY[RUN_FEATURE]; rc: RUN_CLASS) is
      local
         i: INTEGER;
         f: E_FEATURE;
         heading_done: BOOLEAN;
      do
         if list /= Void then
            if clients.gives_permission_to_any then
               from
                  i := 0;
               until
                  i > list.upper
               loop
                  f := list.item(i);
                  heading_done := f.names.for_short(Current,heading_done,
                                                    bcn,sort,rf_list,rc);
                  i := i + 1;
               end;
            else
               eh.cancel;
            end;
         end;
      end;

feature {FEATURE_NAME_LIST}

   do_heading_for_short(bcn: CLASS_NAME) is
      do
         if comment = Void then
            short_print.hook_or("hook202","feature(s) from ");
            short_print.a_class_name(bcn);
            short_print.hook_or("hook203","%N");
         else
            short_print.hook_or("hook204","feature(s) from ");
            short_print.a_class_name(bcn);
            short_print.hook_or("hook205","%N");
            comment.short("hook206","   -- ","hook207","%N");
            short_print.hook_or("hook208","");
         end;
      end;

feature {FEATURE_CLAUSE_LIST}

   add_into(fd: DICTIONARY[E_FEATURE,STRING]) is
      local
         i: INTEGER;
         f: E_FEATURE;
      do
         if list /= Void then
            from
               i := 0;
            until
               i > list.upper
            loop
               f := list.item(i);
               f.set_clients(clients);
               f.add_into(fd);
               i := i + 1;
            end;
         end;
      end;

invariant

   clients /= Void;

   list /= Void implies not list.is_empty;

end -- FEATURE_CLAUSE

