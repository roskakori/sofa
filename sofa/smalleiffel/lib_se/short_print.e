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
class SHORT_PRINT
   --
   -- Driver for the `short' command.
   --

inherit GLOBALS;

creation make

feature {NONE}

   format_directory: STRING;
         -- For the output style.

   base_class: BASE_CLASS;
         -- The one printed.

   run_class: RUN_CLASS;
         -- The one printed.

feature {NONE}

   make is
      do
      end;

feature {SHORT}

   start(format: STRING; bc: BASE_CLASS; rc: RUN_CLASS) is
      local
         hc2: COMMENT;
         fgl: FORMAL_GENERIC_LIST;
      do
         base_class := bc;
         run_class := rc;
         format_directory := system_tools.format_directory(format);
         -- Start output :
         hook("hook000");
         hook_and("hook002",bc.name.to_string);
         if bc.is_expanded then
            hook_or("hook010","expanded class interface ");
         elseif bc.is_deferred then
            hook_or("hook011","deferred class interface ");
         else
            hook_or("hook012","class interface ");
         end;
         hook("hook013");
         a_class_name(bc.name);
         fgl := bc.formal_generic_list;
         if fgl /= Void then
            fgl.short;
         end;
         hook_or("hook014","%N");
         hc2 := bc.heading_comment2;
         if hc2 /= Void then
            hook("hook015");
            hc2.short("hook016","   --","hook017","%N");
            hook("hook018");
         else
            hook("hook019");
         end;
      end;

   finish is
      local
         fgl: FORMAL_GENERIC_LIST;
         ci: CLASS_INVARIANT;
      do
         ci := run_class.class_invariant;
         if ci = Void then
            hook("hook800");
         else
            ci.short(base_class);
         end;
         hook("hook900");
         if base_class.is_expanded then
            hook_or("hook901","end of expanded ");
         elseif base_class.is_deferred then
            hook_or("hook902","end of deferred ");
         else
            hook_or("hook903","end of ");
         end;
         hook("hook904");
         a_class_name(base_class.name);
         fgl := base_class.formal_generic_list;
         if fgl /= Void then
            fgl.short;
         end;
         hook_or("hook905","%N");
         hook("hook999");
      end;

feature

   hook_or(h, str: STRING) is
      do
         if hook_exists(h) then
            from
               tmp_hook.read_character;
            until
               tmp_hook.end_of_input
            loop
               std_output.put_character(tmp_hook.last_character);
               tmp_hook.read_character;
            end;
            tmp_hook.disconnect;
         else
            std_output.put_string(str);
         end;
      end;

   hook_and_lower(h, name: STRING) is
         -- When hook `h' exists, the corresponding `name' is printed 
         -- one more time (using lower case letters) just before the 
         -- contents of `h' hook file.
      do
         if hook_exists(h) then
            tmp_string.copy(name);
            tmp_string.to_lower;
            std_output.put_string(tmp_string);
            from
               tmp_hook.read_character;
            until
               tmp_hook.end_of_input
            loop
               std_output.put_character(tmp_hook.last_character);
               tmp_hook.read_character;
            end;
            tmp_hook.disconnect;
         end;
      end;

   hook_and(h, name: STRING) is
         -- When hook `h' exists, the corresponding `name' is printed 
         -- just before the contents of `h' hook file.
      do
         if hook_exists(h) then
            std_output.put_string(name);
            from
               tmp_hook.read_character;
            until
               tmp_hook.end_of_input
            loop
               std_output.put_character(tmp_hook.last_character);
               tmp_hook.read_character;
            end;
            tmp_hook.disconnect;
         end;
      end;

   hook(h: STRING) is
      do
         if hook_exists(h) then
            from
               tmp_hook.read_character;
            until
               tmp_hook.end_of_input
            loop
               std_output.put_character(tmp_hook.last_character);
               tmp_hook.read_character;
            end;
            tmp_hook.disconnect;
         end;
      end;

   a_class_name(name: CLASS_NAME) is
      local
         i: INTEGER;
         c: CHARACTER;
         str: STRING;
      do
         hook("Bcn");
         hook_and_lower("Mcn",name.to_string);
         from
            str := name.to_string;
            i := 1;
         until
            i > str.count
         loop
            c := str.item(i);
            if c = '_' then
               hook_or("Ucn","_");
            else
               std_output.put_character(c);
            end;
            i := i + 1;
         end;
         hook("Acn");
      end;

   a_feature(fn: FEATURE_NAME) is
         -- Where `fn' is really the final name to print.
      local
         rf: RUN_FEATURE;
      do
         rf := run_class.get_feature(fn);
         a_run_feature(rf);
      end;

   a_run_feature(rf: RUN_FEATURE) is
      local
         args: FORMAL_ARG_LIST;
         rt: TYPE;
         hc: COMMENT;
         rr: RUN_REQUIRE;
         ea: E_ENSURE;
      do
         hook_or("hook300","   ");
         rf.name.short;
         args := rf.arguments;
         if args = Void then
            hook_or("hook301","");
         else
            args.short;
         end;
         rt := rf.result_type;
         if rt = Void then
            hook_or("hook307","%N");
         else
            hook_or("hook308",": ");
            rt.short;
            hook_or("hook309","%N");
         end;
         hc := rf.base_feature.header_comment;
         if hc /= Void then
            hook("hook310");
            hc.short("hook311","      --","hook312","%N");
            hook("hook313");
         else
            hook("hook314");
         end;
         rr := rf.require_assertion;
         if rr = Void then
            hook("hook400");
         else
            rr.short;
         end;
         ea := rf.ensure_assertion;
         if ea = Void then
            hook_or("hook500","");
         else
            ea.short;
         end;
         hook_or("hook599","");
      end;

   a_integer(value: INTEGER) is
      local
         s: STRING;
         c: CHARACTER;
         i: INTEGER;
      do
         s := "";
         s.clear;
         value.append_in(s);
         from
            i := 1;
         until
            i > s.count
         loop
            c := s.item(i);
            std_output.put_character(c);
            i := i + 1;
         end;
      end;

   a_character(c: CHARACTER) is
      do
         std_output.put_character(c);
      end;

   a_dot is
      do
         hook_or("dot",fz_dot);
      end;

feature {CALL_PREFIX}

   a_prefix_name(pn: PREFIX_NAME) is
         -- Used in an expression.
      local
         i: INTEGER;
         c: CHARACTER;
         str: STRING;
      do
         from
            str := pn.to_string;
            i := 1;
         until
            i > str.count
         loop
            c := str.item(i);
            if c = '_' then
               hook_or("Usfn","_");
            else
               std_output.put_character(c);
            end;
            i := i + 1;
         end;
         a_character(' ');
      end;

feature {CALL_INFIX,INFIX_NAME}

   a_infix_name(h1,r1,h2,r2: STRING; in: INFIX_NAME) is
      local
         i: INTEGER;
         str: STRING;
      do
         hook_or(h1,r1);
         str := in.to_string;
         if as_backslash_backslash = str then
            hook_or("rem",as_backslash_backslash);
         else
            from
               i := 1;
            until
               i > str.count
            loop
               std_output.put_character(str.item(i));
               i := i + 1;
            end;
         end;
         hook_or(h2,r2);
      end;

feature {BASE_TYPE_CONSTANT}

   a_base_type_constant(str: STRING) is
      local
         i: INTEGER;
         c: CHARACTER;
      do
         from
            i := 1;
         until
            i > str.count
         loop
            c := str.item(i);
            if c = '.' then
               hook_or("dot",".");
            else
               std_output.put_character(c);
            end;
            i := i + 1;
         end;
      end;

feature {NONE}

   hook_exists(h: STRING): BOOLEAN is
      do
         tmp_hook_path.copy(format_directory);
         tmp_hook_path.append(h);
         tmp_hook.connect_to(tmp_hook_path);
         Result := tmp_hook.is_connected;
      end;

   tmp_hook: STD_FILE_READ is
      once
         !!Result.make;
      end;

   tmp_hook_path: STRING is
      once
         !!Result.make(80);
      end;

   tmp_string: STRING is
      once
         !!Result.make(16);
      end;

end -- SHORT_PRINT

