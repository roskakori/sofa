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
class E_REQUIRE
   --
   -- To store a `require' clause.
   --

inherit ASSERTION_LIST;

creation make, make_runnable

feature

   is_require_else: BOOLEAN;

feature

   name: STRING is
      do
         if is_require_else then
            Result := "require else";
         else
            Result := "require";
         end;
      end;

   short(h1,r1: STRING) is
      local
         i: INTEGER;
      do
         short_print.hook_or(h1,r1);
         if header_comment = Void then
            short_print.hook_or("hook412","");
         else
            short_print.hook_or("hook413","");
            header_comment.short("hook414","         -- ","hook415","%N");
            short_print.hook_or("hook416","");
         end;
         if list = Void then
            short_print.hook_or("hook417","");
         else
            short_print.hook_or("hook418","");
            from
               i := 1;
            until
               i = list.upper
            loop
               list.item(i).short("hook419","         ", -- before each assertion
                                  "hook420","", -- no tag
                                  "hook421","", -- before tag
                                  "hook422",": ", -- after tag
                                  "hook423","", -- no expression
                                  "hook424","", -- before expression
                                  "hook425",";", -- after expression except last
                                  "hook426","%N", -- no comment
                                  "hook427","", -- before comment
                                  "hook428"," -- ", -- comment begin line
                                  "hook429","%N", -- comment end of line
                                  "hook430","", -- after comment
                                  "hook431",""); -- end of each assertion

               i := i + 1;
            end;
            list.item(i).short("hook419","         ", -- before each assertion
                               "hook420","", -- no tag
                               "hook421","", -- before tag
                               "hook422",": ", -- after tag
                               "hook423","", -- no expression
                               "hook424","", -- before expression
                               "hook432","", -- after expression except last
                               "hook426","%N", -- no comment
                               "hook427","", -- before comment
                               "hook428"," -- ", -- comment begin line
                               "hook429","%N", -- comment end of line
                               "hook430","", -- after comment
                               "hook431","");
            short_print.hook_or("hook433","");
         end;
         short_print.hook_or("hook434","");
      ensure
         fmt.indent_level = old fmt.indent_level;
      end;

feature {TMP_FEATURE}

   set_require_else is
      do
         is_require_else := true;
      end;

feature {NONE}

   check_assertion_mode: STRING is
      do
         Result := "req";
      end;

end -- E_REQUIRE
