-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT 
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of 
-- another product.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr 
--                       http://SmallEiffel.loria.fr
--
class GENERAL
   --
   -- Platform-independent universal properties.
   -- This class is an ancestor to all developer-written classes.
   --

feature -- Access :
   
   generating_type: STRING is
         -- Name of current object's generating type (type of 
         -- which it is a direct instance).
      external "SmallEiffel"
      end;
  
   generator: STRING is
         -- Name of current object's generating class (base class
         -- of the type of which it is a direct instance).
      external "SmallEiffel"
      end;
   
   stripped(other: GENERAL): like other is
 	 -- Newly created object with fields copied from current object,
 	 -- but limited to attributes of type of `other'.
      require
         conformance: conforms_to(other);
      do
         not_yet_implemented;
      ensure
         stripped_to_other: Result.same_type(other);
      end;
   
feature -- Status report :
   
   frozen conforms_to(other: GENERAL): BOOLEAN is
         -- Is dynamic type of `Current' a descendant of dynamic type of
         -- `other' ?
         -- 
         -- Note: because of automatic conversion from expanded to reference
         -- type when passing argument `other', do not expect a correct  
         -- behavior with  expanded types.
      require 
         not is_expanded_type;
         other_not_void: other /= Void
      do
         Result := other.se_assigned_from(Current);
      end;

   frozen same_type(other: GENERAL): BOOLEAN is
         -- Is type of current object identical to type of `other' ?
      require
         not is_expanded_type;
         other_not_void: other /= Void
      do
         if conforms_to(other) then
            Result := other.conforms_to(Current);
         end;
      ensure
         definition: Result = (conforms_to(other) 
                               and 
                               other.conforms_to(Current));
      end;
   
feature -- Comparison :
   
   frozen equal(some: ANY; other: like some): BOOLEAN is
         -- Are `some' and `other' both Void or attached to
         -- objects considered equal ?
      do
         if some = other then
            Result := true;
         elseif some = Void then
         elseif other = Void then
         else
            Result := some.is_equal(other);
         end;
      ensure
         definition: Result = (some = Void and other = Void) or else
                     ((some /= Void and other /= Void) and then
                      some.is_equal(other));
      end;

   is_equal(other: like Current): BOOLEAN is
         -- Is `other' attached to an object considered equal to 
         -- current object ?
      require
         other_not_void: other /= Void
      external "SmallEiffel"
      ensure
         consistent: standard_is_equal(other) implies Result;
         symmetric: Result implies other.is_equal(Current);
      end;
   
   frozen standard_equal(some: ANY; other: like some): BOOLEAN is
         -- Are `some' and `other' both Void or attached to
         -- field-by-field objects of the same type ?
         -- Always use the default object comparison criterion.
      do
         if some = other then
            Result := true;
         elseif some = Void then
         elseif other = Void then
         elseif some.same_type(other) then
            Result := some.standard_is_equal(other);
         end;
      ensure
         definition: Result = (some = Void and other = Void) or else
                     ((some /= Void and other /= Void) and then
                      some.standard_is_equal(other));
      end;

   frozen standard_is_equal(other: like Current): BOOLEAN is
         -- Are Current and `other' field-by-field identical?
      require
         other /= Void
      external "SmallEiffel"
      ensure
         symmetric: Result implies other.standard_is_equal(Current);
      end;
   
feature -- Deep Comparison :

   frozen deep_equal(some: ANY; other: like some): BOOLEAN is
         -- Are `some' and `other' either both Void or attached to 
         -- recursively isomorphic object structures ?
      do
         if some = other then
            Result := true;
         elseif some = Void then
         elseif other = Void then
         else
            Result := some.is_deep_equal(other);
         end;
      ensure
         shallow_implies_deep: standard_equal(some,other) implies Result
      end;
   
   is_deep_equal(other: like Current): BOOLEAN is
         -- Is `Current' recursively isomorph with `other' ?
      require
         other_not_void: other /= Void
      external "SmallEiffel"
      end;
   
feature -- Duplication :
   
   frozen clone(other: ANY): like other is
         -- When argument `other' is Void, return Void
         -- otherwise return `other.twin'.
      do
         if other /= Void then
            Result := other.twin;
         end;
      ensure
         equal: equal(Result,other);
      end;

   frozen twin: like Current is
         -- Return a new object with the dynamic type of Current.
         -- Before being returned, the new object is initialized using
         -- feature `copy' (Current is passed as the argument).
         -- Thus, when feature `copy' of GENERAL is not redefined, 
         -- `twin' has exactly the same behaviour as `standard_twin'.
      external "SmallEiffel"
      ensure
         equal: Result.is_equal(Current);
      end;

   copy(other: like Current) is
         -- Update current object using fields of object attached
         -- to `other', so as to yield equal objects.
      require
         other_not_void: other /= Void
      external "SmallEiffel"
      ensure
         is_equal: is_equal(other)
      end;
   
   frozen standard_clone(other: ANY): like other is
         -- Void if `other' is Void; otherwise new object 
         -- field-by-field identical to `other'. 
         -- Always use the default copying semantics.
      do
         if other /= Void then
            Result := other.standard_twin;
         end;
      ensure
         equal: standard_equal(Result,other);
      end;

   frozen standard_twin: like Current is
         -- Return a new object with the dynamic type of Current.
         -- Before being returned, the new object is initialized using
         -- feature `standard_copy' (Current is passed as the argument).
      external "SmallEiffel"
      end;
      
   frozen standard_copy(other: like Current) is
         -- Copy every field of `other' onto corresponding field of 
         -- current object.
      require
         other_not_void: other /= Void
      external "SmallEiffel"
      ensure
         standard_is_equal(other);
      end;
   
feature -- Deep Duplication :

   frozen deep_clone(other: ANY): like other is
         -- When argument `other' is Void, return Void
         -- otherwise return `other.deep_twin'.
      do
	 if other /= Void then
	    Result := other.deep_twin;
	 end;
      ensure
	 deep_equal(other,Result)
      end;
   
   deep_twin: like Current is
         -- Return a new object with the dynamic type of Current.
         -- The new object structure is recursively duplicated from the one 
         -- attached to `Current'.
      external "SmallEiffel"
      end;

feature -- Basic operations :
   
   frozen default: like Current is
         -- Default value of current type.
      do
      end;
   
   frozen default_pointer: POINTER is
         -- Default value of type POINTER (avoid the need to
         -- write p.default for some `p' of type POINTER).
      do
      ensure
         Result = Result.default;
      end;
   
   default_rescue is
         -- Handle exception if no Rescue clause.
         -- (Default: do nothing.)   
      do
      end;
   
   frozen do_nothing is
         -- Execute a null action.
      do
      end;
   
feature -- Input and Output :
   
   io: STD_INPUT_OUTPUT is
         -- Handle to standard file setup.
         -- To use the standard input/output file.
         -- Has type STD_FILES in ELKS 95.
      once
         !!Result.make;
      ensure
         Result /= Void;
      end; 
   
   std_input: STD_INPUT is
         -- To use the standard input file.
      once
         !!Result.make;
      end; 
   
   std_output: STD_OUTPUT is
         -- To use the standard output file.
      once
         !!Result.make;
      end; 
   
   std_error: STD_ERROR is
         -- To use the standard error file.
      once
         !!Result.make;
      end; 
   
feature -- Object Printing :

   frozen print(some: GENERAL) is
         -- Write terse external representation of `some' on
         -- `standard_output'.
         -- To customize printing, one may redefine 
         -- `fill_tagged_out_memory' or `out_in_tagged_out_memory' (see 
         -- for example how it works in class COLLECTION).
 	 -- Not frozen in ELKS 95.
      do
         if some = Void then
            std_output.put_string("Void");
         else
            some.print_on(std_output);
         end;
      end;
   
   print_on(file: OUTPUT_STREAM) is
         -- Default printing of current object on a `file'.
         -- One may redefine `fill_tagged_out_memory' or 
         -- `out_in_tagged_out_memory' to adapt the behavior of 
         -- `print_on'.
         --
      do
         tagged_out_memory.clear;
         out_in_tagged_out_memory;
         file.put_string(tagged_out_memory);
      end;

   frozen tagged_out: STRING is
         -- New string containing printable representation of current 
         -- object, each field preceded by its attribute name, a 
         -- colon and a space.
      do
         tagged_out_memory.clear;
         fill_tagged_out_memory;
         Result := tagged_out_memory.twin;
      end;
   
   out: STRING is
         -- Create a new string containing terse printable 
         -- representation of current object.
      do
         tagged_out_memory.clear;
         out_in_tagged_out_memory;
         Result := tagged_out_memory.twin;
      end;
   
   out_in_tagged_out_memory is
         -- Append terse printable represention of current object
         -- in `tagged_out_memory'.
      do
         tagged_out_memory.append(generating_type);
         if not is_expanded_type then
            tagged_out_memory.extend('#');
            Current.to_pointer.append_in(tagged_out_memory);
         end;
         tagged_out_memory.extend('[');
         fill_tagged_out_memory;
         tagged_out_memory.extend(']');
      end;
   
   frozen tagged_out_memory: STRING is
      once
         !!Result.make(1024);
      end;
   
   fill_tagged_out_memory is
         -- Append a viewable information in `tagged_out_memory' in 
         -- order to affect the behavior of `out', `tagged_out', etc.
      do
         -- Should be an external "SmallEiffel" to provide a default 
         -- view of Current contents (not yet implemented).
      end;
   
feature -- Basic named file handling :

   frozen file_tools: FILE_TOOLS is
      once
      end;
   
   file_exists(path: STRING): BOOLEAN is
         -- True if `path' is an existing readable file.
      require
         not path.is_empty
      do
         Result := file_tools.is_readable(path);
      end;
   
   remove_file(path: STRING) is
      require
         path /= Void;
      do
         file_tools.delete(path);
      end;
   
   rename_file(old_path, new_path: STRING) is
      require
         old_path /= Void;
         new_path /= Void
      do
         file_tools.rename_to(old_path,new_path);
      end;

feature -- Access to command-line arguments :
   
   argument_count: INTEGER is
         -- Number of arguments given to command that started
         -- system execution (command name does not count).
      do
         Result := command_arguments.upper;
      ensure
         Result >= 0;
      end;
   
   argument(i: INTEGER): STRING is
         -- `i' th argument of command that started system execution 
         -- Gives the command name if `i' is 0.
      require
         i >= 0;
         i <= argument_count;
      do
         Result := command_arguments.item(i);
      ensure
         Result /= Void
      end;

   frozen command_arguments: FIXED_ARRAY[STRING] is
         -- Give acces to arguments command line including the
         -- command name at index 0.
      local
         i: INTEGER;
         arg: STRING;
      once
         from
            i := se_argc;
            !!Result.make(i);
         until
            i = 0
         loop
            i := i - 1;
            arg := se_argv(i);
            Result.put(arg,i);
         end;
      ensure
         not Result.is_empty
      end;
   
   get_environment_variable(name: STRING): STRING is
         -- Try to get the value of the `name' system environment 
         -- variable or some `name' in the system registry. 
	 -- Gives Void when no information about `name' is available.
	 -- Under UNIX like system, this is in fact the good way to 
	 -- know about some system environment variable.
	 -- Under Windows, this function also look in the system 
	 -- registery.
      require
         name /= Void
      local
         p, null: POINTER;
      do
         p := name.to_external;
	 p := basic_getenv(p);
	 if p /= null then
	    !!Result.from_external_copy(p);
	 end;
      end;
   
feature -- System calls and crashs :
   
   frozen crash is
         -- Print Run Time Stack and then exit with `exit_failure_code'.
      do
         print_run_time_stack;
         die_with_code(exit_failure_code);
      end;

   frozen trace_switch(flag: BOOLEAN) is
         -- May be used in combination with option "-trace" of
         -- command `compile_to_c' (see compile_to_c.hlp for
         -- details).
      external "SmallEiffel"
      end;

   system(system_command_line: STRING) is
         -- To execute a `system_command_line' as for example, "ls -l" on UNIX.
      local
         p: POINTER;
      do
         p := system_command_line.to_external;
         se_system(p);
      end;
   
   frozen die_with_code(code:INTEGER) is
         -- Terminate execution with exit status code `code'.
         -- Do not print any message.
         -- Note: you can use predefined `exit_success_code' or
         -- `exit_failure_code' as well as another code you need.
      external "SmallEiffel"
      end;
   
   exit_success_code: INTEGER is 0;
   
   exit_failure_code: INTEGER is 1;
   
feature -- Maths constants :

   Pi    : DOUBLE is  3.1415926535897932384626; 
  	 
   Evalue: DOUBLE is  2.7182818284590452353602;
     
   Deg   : DOUBLE is 57.2957795130823208767981; -- Degrees/Radian
     
   Phi   : DOUBLE is  1.6180339887498948482045; -- Golden Ratio

feature -- Character names :

   Ctrl_a: CHARACTER is '%/1/';
   Ctrl_b: CHARACTER is '%/2/';
   Ctrl_c: CHARACTER is '%/3/';
   Ctrl_d: CHARACTER is '%/4/';
   Ctrl_e: CHARACTER is '%/5/';
   Ctrl_f: CHARACTER is '%/6/';
   Ctrl_g: CHARACTER is '%/7/';
   Ch_bs : CHARACTER is '%/8/';
   Ch_tab: CHARACTER is '%/9/';
   Ctrl_j: CHARACTER is '%/10/';
   Ctrl_k: CHARACTER is '%/11/';
   Ctrl_l: CHARACTER is '%/12/';
   Ctrl_m: CHARACTER is '%/13/';
   Ctrl_n: CHARACTER is '%/14/';
   Ctrl_o: CHARACTER is '%/15/';
   Ctrl_p: CHARACTER is '%/16/';
   Ctrl_q: CHARACTER is '%/17/';
   Ctrl_r: CHARACTER is '%/18/';
   Ctrl_s: CHARACTER is '%/19/';
   Ctrl_t: CHARACTER is '%/20/';
   Ctrl_u: CHARACTER is '%/21/';
   Ctrl_v: CHARACTER is '%/22/';
   Ctrl_w: CHARACTER is '%/23/';
   Ctrl_x: CHARACTER is '%/24/';
   Ctrl_y: CHARACTER is '%/25/';
   Ctrl_z: CHARACTER is '%/26/';
   Ch_del: CHARACTER is '%/63/';

feature -- Should not exist :
   
   not_yet_implemented is
      do
         std_error.put_string(
          "Sorry, Some Feature is Not Yet Implemented.%N%
           %Please, if you can write it by yourself and if you send me%N%
           %the corresponding tested Eiffel code, I may put it in the%N% 
           %standard library!%N%
           %Many Thanks in advance.%N%  
           %D.Colnet e-mail: colnet@loria.fr%N");
         crash;
       end;

feature -- For ELS Compatibility :

   id_object(id: INTEGER): ANY is
         -- Object for which `object_id' has returned `id';
         -- Void if none.
      require
         id /= 0;
      do
         Result := object_id_memory.item(id);
      end;
   
   object_id: INTEGER is
         -- Value identifying current reference object.
      require
         not is_expanded_type
      do
         Result := object_id_memory.fast_index_of(Current);
         if Result > object_id_memory.upper then
            object_id_memory.add_last(Current);
         end;
      end;
   
feature -- The Guru section :
   
   to_pointer: POINTER is
         -- Explicit conversion of a reference into POINTER type.
      require
         not is_expanded_type
      external "SmallEiffel"
      end;

   frozen is_expanded_type: BOOLEAN is
         -- Target is not evaluated (Statically computed).
         -- Result is true if target static type is an expanded type.
         -- Useful for formal generic type.
      external "SmallEiffel"
      end;
   
   frozen is_basic_expanded_type: BOOLEAN is
         -- Target is not evaluated (Statically computed).
         -- Result is true if target static type is one of the 
         -- following types: BOOLEAN, CHARACTER, INTEGER, REAL,
         -- DOUBLE or POINTER.
      external "SmallEiffel"
      ensure
         Result implies is_expanded_type
      end;
   
   frozen object_size: INTEGER is
         -- Gives the size of the current object at first level 
         -- only (pointed-to sub-object are not concerned).  
         -- The result is given in number of CHARACTER.
      external "SmallEiffel"
      end;

feature {NONE} -- The Guru section :
   
   c_inline_h(c_code: STRING) is
         -- Target must be Current and `c_code' must be a manifest
         -- string. Write `c_code' in the heading C file.
      external "SmallEiffel"
      end;

   c_inline_c(c_code: STRING) is
         -- Target must be Current and `c_code' must be a manifest
         -- string. Write `c_code' in the stream at current position.
      external "SmallEiffel"
      end;

feature {NONE} -- Implementation of GENERAL (do not use directly) :
      
   object_id_memory: ARRAY[ANY] is
         -- For a portable implementation of `id_object'/`object_id'.
         -- Note: I think that the pair `id_object'/`object_id' is
         -- a stupid one. It should be removed.
      once
         !!Result.with_capacity(256,1);
      end;

   print_run_time_stack is
         -- Prints the run time stack.
         -- The result depends both on compilation mode and 
         -- target langage used (C or Java byte code).
         -- Usually, in mode -boost, no information is printed.
      external "SmallEiffel"
      end;

   se_argc: INTEGER is
         -- To implement `command_arguments'
      external "SmallEiffel"
      end;

   se_argv(i: INTEGER): STRING is
         -- To implement `command_arguments'
      external "SmallEiffel"
      end;

   basic_getenv(environment_variable: POINTER): POINTER is
         -- To implement `get_environment_variable'.
      external "SmallEiffel"
      end;

   se_system(system_command_line: POINTER) is
      external "SmallEiffel"
      end;

feature -- Implementation of GENERAL (do not use directly) :
      
   frozen se_assigned_from(other: GENERAL): BOOLEAN is
         -- To implement `conforms_to' (must only be called inside
         -- `conforms_to' because of VJRV rule).
      require
         not is_expanded_type
      local
         x: like Current;
      do
         x ?= other;
         Result := x /= Void;
      end;

end -- GENERAL

