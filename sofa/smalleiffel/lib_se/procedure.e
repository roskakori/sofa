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
class PROCEDURE

inherit EFFECTIVE_ROUTINE rename make_effective_routine as make end;

creation make, attribute_writer

feature

   result_type: TYPE is
      do
      end;

   to_run_feature(t: TYPE; fn: FEATURE_NAME): RUN_FEATURE_3 is
      do
         !!Result.make(t,fn,Current);
      end;

feature {BASE_CLASS}

   a_default_rescue(rc: RUN_CLASS; fn: FEATURE_NAME): RUN_FEATURE_3 is
         -- Non Void when the corresponding `default_rescue' really
         -- make something.
      local
         non_empty_default_rescue: BOOLEAN;
      do
         if local_vars /= Void then
            non_empty_default_rescue := true;
         elseif routine_body /= Void then
            non_empty_default_rescue := not routine_body.empty_or_null_body;
         end;
         if non_empty_default_rescue then
	    Result ?= rc.at(fn);
	    if Result = Void then
	       Result := to_run_feature(rc.current_type,fn);
	    end;
	 end;
      end;

feature {NONE}

   attribute_writer(bc: like base_class; 
		    set_attribute_name: SIMPLE_FEATURE_NAME;
		    attribute_name: SIMPLE_FEATURE_NAME) is
	 -- Allow the creation of an implicit procedure to write an 
	 -- attribute written in class `bc'. As an example, this routine 
	 -- is used to create `set_first', `set_second', ... TUPLE implicit 
	 -- attributes writers.
      local
	 sp: POSITION;
	 fnl: like names;
	 a1: ARGUMENT_NAME1;
	 a2: ARGUMENT_NAME2;
	 d1: DECLARATION_1;
	 ad: ARRAY[DECLARATION];
	 formal_arg_list: like arguments;
	 assignment: ASSIGNMENT;
	 body: like routine_body;
      do
	 sp.set_in(bc);
	 base_class := bc;
	 !!fnl.make_1(set_attribute_name);
	 !!a1.make(sp,as_item);
	 !!d1.make(a1,attribute_name.result_type);
	 ad := <<d1>>;
	 !!formal_arg_list.make(ad);
	 !!a2.refer_to(sp,formal_arg_list,1);
	 !!assignment.make(attribute_name,a2);
	 !!body.make(Void,assignment,Void);
	 make(fnl,formal_arg_list,Void,Void,Void,Void,body);
	 !!clients.omitted;
      end;

   try_to_undefine_aux(fn: FEATURE_NAME;
                       bc: BASE_CLASS): DEFERRED_ROUTINE is
      do
         !DEFERRED_PROCEDURE!Result.from_effective(fn,arguments,
                                                   require_assertion,
                                                   ensure_assertion,
                                                   bc);
      end;

   pretty_print_once_or_do is
      do
         fmt.keyword(fz_do);
      end;

end -- PROCEDURE

