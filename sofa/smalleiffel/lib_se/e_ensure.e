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
class E_ENSURE
   --
   -- To store a `ensure' clause.
   --

inherit ASSERTION_LIST;

creation make, make_runnable

feature

   is_ensure_then: BOOLEAN;

feature

   name: STRING is
      do
         if is_ensure_then then
            Result := "ensure then";
         else
            Result := "ensure";
         end;
      end;

   c_declare_for_old is
         -- Produce C declarations for `old' expressions.
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.lower;
            until
               i > list.upper
            loop
               list.item(i).c_declare_for_old;
               i := i + 1;
            end;
         end;
      end;

   compile_to_c_old is
         -- Initialization for `old' expressions.
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.lower;
            until
               i > list.upper
            loop
               list.item(i).compile_to_c_old;
               i := i + 1;
            end;
         end;
      end;

   compile_to_jvm_old is
         -- If needed, add some more local variable to store the
         -- result of Eiffel "old".
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.lower;
            until
               i > list.upper
            loop
               list.item(i).compile_to_jvm_old;
               i := i + 1;
            end;
         end;
      end;

   short is
      local
         i: INTEGER;
      do
         short_print.hook_or("hook511","      ensure%N");
         if header_comment = Void then
            short_print.hook_or("hook512","");
         else
            short_print.hook_or("hook513","");
            header_comment.short("hook514","         --","hook515","%N");
            short_print.hook_or("hook516","");
         end;
         if list = Void then
            short_print.hook_or("hook517","");
         else
            short_print.hook_or("hook518","");
            from
               i := 1;
            until
               i = list.upper
            loop
               list.item(i).short("hook519","         ", -- before each assertion
                                  "hook520","", -- no tag
                                  "hook521","", -- before tag
                                  "hook522",": ", -- after tag
                                  "hook523","", -- no expression
                                  "hook524","", -- before expression
                                  "hook525",";", -- after expression except last
                                  "hook526","%N", -- no comment
                                  "hook527","", -- before comment
                                  "hook528"," --", -- comment begin line
                                  "hook529","%N", -- comment end of line
                                  "hook530","", -- after comment
                                  "hook531",""); -- end of each assertion

               i := i + 1;
            end;
            list.item(i).short("hook519","         ", -- before each assertion
                               "hook520","", -- no tag
                               "hook521","", -- before tag
                               "hook522",": ", -- after tag
                               "hook523","", -- no expression
                               "hook524","", -- before expression
                               "hook532","", -- after expression except last
                               "hook526","%N", -- no comment
                               "hook527","", -- before comment
                               "hook528"," --", -- comment begin line
                               "hook529","%N", -- comment end of line
                               "hook530","", -- after comment
                               "hook531","");
            short_print.hook_or("hook533","");
         end;
         short_print.hook_or("hook534","");
      ensure
         fmt.indent_level = old fmt.indent_level;
      end;

feature {EIFFEL_PARSER}

   set_ensure_then is
      do
         is_ensure_then := true;
      end;


feature {NONE}

   check_assertion_mode: STRING is
      do
         Result := "ens";
      end;

end -- E_ENSURE

