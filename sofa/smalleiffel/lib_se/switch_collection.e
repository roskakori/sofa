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
expanded class SWITCH_COLLECTION
   --
   -- Unique Global Object in charge of the `switch_collection'.
   --

inherit GLOBALS;

feature {NONE}

   dictionary: DICTIONARY[DICTIONARY[RUN_FEATURE,STRING],STRING] is
         -- First STRING key is the name of a run type corresponding
         -- to a RUN_CLASS.
         -- Embedded dictionary gives all switching points.
      once
         !!Result.with_capacity(1024);
      end;

feature {CALL_PROC_CALL}

   update(target: EXPRESSION; run_feature: RUN_FEATURE) is
      -- Update the switch_collection such that `run_feature' can be
      -- applied with `target'.
      require
         target /= Void;
         run_feature /= Void
      local
         current_type: TYPE;
         running: ARRAY[RUN_CLASS];
      do
         if target.is_current then
         elseif target.is_manifest_string then
         else
            current_type := run_feature.current_type;
            if current_type.is_reference then
               running := current_type.run_class.running;
               if running /= Void and then running.count > 1 then
                  update_with(run_feature);
               end;
            end;
         end;
      end;

feature {SMALL_EIFFEL}

   c_define is
         -- Produce C code for switches.
      local
         dictionary2: DICTIONARY[RUN_FEATURE,STRING];
         count1, count2, total: INTEGER;
         switch: SWITCH;
      do
         if not dictionary.is_empty then
            cpp.swap_on_c;
            from
               count1 := 1;
            until
               count1 > dictionary.count
            loop
               dictionary2 := dictionary.item(count1);
               from
                  count2 := 1;
               until
                  count2 > dictionary2.count
               loop
                  switch.c_define(dictionary2.item(count2));
                  total := total + 1;
                  count2 := count2 + 1;
		  if total \\ 18 = 0 then
		     cpp.padding_here;
		  end;
               end;
               count1 := count1 + 1;
            end;
         end;
         echo.print_count("Defined Switche",total);
      end;

   afd is
      local
         dictionary2: DICTIONARY[RUN_FEATURE,STRING];
         count1, count2: INTEGER;
         rf: RUN_FEATURE;
         switch: SWITCH;
      do
         from
            count1 := 1;
         until
            count1 > dictionary.count
         loop
            dictionary2 := dictionary.item(count1);
            from
               count2 := 1;
            until
               count2 > dictionary2.count
            loop
               rf := dictionary2.item(count2);
               switch.afd(rf);
               count2 := count2 + 1;
            end;
            count1 := count1 + 1;
         end;
      end;

feature {CECIL_POOL,ADDRESS_OF_POOL}

   update_with(run_feature: RUN_FEATURE) is
      require
         run_feature /= Void
      local
         current_type: TYPE;
         key1, key2: STRING;
         dictionary2: DICTIONARY[RUN_FEATURE,STRING];
         running: ARRAY[RUN_CLASS];
      do
         current_type := run_feature.current_type;
         running := current_type.run_class.running;
         if running /= Void and then running.count > 1 then
            key1 := current_type.run_time_mark;
            key2 := run_feature.name.to_key;
            if dictionary.has(key1) then
               dictionary2 := dictionary.at(key1);
               if not dictionary2.has(key2) then
                  dictionary2.put(run_feature,key2);
                  small_eiffel.incr_magic_count;     
               end;
            else
               !!dictionary2.make;
               dictionary2.put(run_feature,key2);
               dictionary.put(dictionary2,key1);
               small_eiffel.incr_magic_count;     
            end;
            check
               dictionary.at(key1).at(key2) = run_feature
            end;
         end;
      end;

feature {C_PRETTY_PRINTER}

   remove(run_feature: RUN_FEATURE) is
      require
         run_feature /= Void
      local
         current_type: TYPE;
         key1, key2: STRING;
         dictionary2: DICTIONARY[RUN_FEATURE,STRING];
      do
         current_type := run_feature.current_type;
         key1 := current_type.run_time_mark;
         if dictionary.has(key1) then
            dictionary2 := dictionary.at(key1);
            key2 := run_feature.name.to_key;
            dictionary2.remove(key2);
            check
               not dictionary.at(key1).has(key2)
            end;
         end;
      end;

feature {JVM}

   jvm_define is
         -- Produce Java byte code for switches.
      local
         dictionary2: DICTIONARY[RUN_FEATURE,STRING];
         count1, count2, total: INTEGER;
         switch: SWITCH;
         up_rf: RUN_FEATURE;
      do
         if not dictionary.is_empty then
            from
               count1 := 1;
            until
               count1 > dictionary.count
            loop
               dictionary2 := dictionary.item(count1);
               from
                  count2 := 1;
               until
                  count2 > dictionary2.count
               loop
                  up_rf := dictionary2.item(count2);
                  jvm.set_current_frame(up_rf);
                  switch.jvm_define(up_rf);
                  total := total + 1;
                  count2 := count2 + 1;
               end;
               count1 := count1 + 1;
            end;
         end;
         echo.print_count("Defined Switche",total);
      end;

end -- SWITCH_COLLECTION

