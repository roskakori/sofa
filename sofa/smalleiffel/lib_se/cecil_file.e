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
class CECIL_FILE
   --
   -- Handle the content of one -cecil file.
   --

inherit GLOBALS;

creation make

feature {CECIL_POOL}

   parse is
	 -- Parse the corresponding `path' file.
      local
	 tuple: TUPLE[STRING,RUN_FEATURE];
         t: TYPE;
	 aux: FIXED_ARRAY[TUPLE[TYPE,FEATURE_NAME]];
         fn: FEATURE_NAME;
         rf: RUN_FEATURE;
         i: INTEGER;
         rc: RUN_CLASS;
      do
	 !!entries.with_capacity(4);
	 path_h := eiffel_parser.connect_to_cecil(path);
	 from
	    !!aux.with_capacity(4);
	 until
	    eiffel_parser.end_of_input
	 loop
	    tuple := [eiffel_parser.parse_c_name,Void];
	    entries.add_last(tuple);
	    t := eiffel_parser.parse_run_type;
	    fn := eiffel_parser.parse_feature_name;
	    aux.add_last([t,fn]);
	 end;
	 eiffel_parser.disconnect;
	 echo.put_string("Loading cecil features:%N");
	 from
	    i := aux.lower;
	 until
	    i > aux.upper
	 loop
	    t := aux.item(i).first;
	    fn := aux.item(i).second;
	    t := t.to_runnable(type_any);
	    rc := t.run_class;
	    rf := rc.get_feature(fn);
	    if rf = Void then
	       eh.add_position(fn.start_position);
	       fatal_error("Error while loading feature of cecil file.");
	    end;
	    if rf.is_deferred then
	    elseif rc.running = Void then
	       rc.set_at_run_time;
	    end;
	    cecil_pool.echo_for(rf);
	    entries.item(i).set_second(rf);
	    i := i + 1;
	 end;
      end;

   c_define_users is
      local
         i: INTEGER;
	 tuple: TUPLE[STRING,RUN_FEATURE];
      do
         if entries /= Void then
            echo.put_string("Cecil (C function for external code) :%N");
            cpp.connect_cecil_out_h(path_h);
	    from
	       i := entries.upper;
	    until
	       i < entries.lower
	    loop
	       tuple := entries.item(i);
	       cecil_pool.c_define_for(tuple.first,tuple.second);
	       i := i - 1;
	    end;
            cpp.disconnect_cecil_out_h;
         end;
      end;

   afd_check is
      local
	 i: INTEGER;
	 rf: RUN_FEATURE;
      do
	 if entries /= Void then
	    from
	       i := entries.upper;
	    until
	       i < entries.lower
	    loop
	       rf := entries.item(i).second;
	       switch_collection.update_with(rf);
	       i := i - 1;
	    end;
	 end;
      end;
   
feature {CECIL_POOL,RUN_FEATURE}

feature {NONE}

   path: STRING;
	 -- The `path' given after the -cecil flag.

   path_h: STRING;
	 -- The name of the include file to be generated (ie. first 
	 -- information inside file `path'.

   entries: FIXED_ARRAY[TUPLE[STRING,RUN_FEATURE]];
	 -- List of user's `entries'. For each TUPLE entry `first' is the C user's 
	 -- name and `second' the corresponding Eiffel feature.
   
   make(p: like path) is
      require
	 p /= Void
      do
	 path := p;
      ensure
	 path = p
      end;

end

   
