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
class IFTHENELSE
   --
   -- The conditionnal instruction : 
   --              "if ... then ... elseif ... else ... end".
   --

inherit INSTRUCTION; IF_GLOBALS;

creation make

feature

   start_position: POSITION;
	 -- Of keyword "if".

   ifthenlist: IFTHENLIST;

   else_compound: COMPOUND;
	 -- Not Void if any.

feature {NONE}

   current_type: TYPE;

feature {NONE}

   make(sp: like start_position) is
      do
	 start_position := sp;
      end;

feature

   is_pre_computable: BOOLEAN is false;

   end_mark_comment: BOOLEAN is true;

feature

   use_current: BOOLEAN is
      do
	 if ifthenlist.use_current then
	    Result := true;
	 elseif else_compound /= Void then
	    Result := else_compound.use_current;
	 end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
	 Result := ifthenlist.stupid_switch(r) and then
	 (else_compound = Void or else else_compound.stupid_switch(r));
      end;

   afd_check is
      do
	 ifthenlist.afd_check;
	 if else_compound /= Void then
	    else_compound.afd_check;
	 end;
      end;

   collect_c_tmp is
      do
	 ifthenlist.collect_c_tmp;
      end;

   compile_to_c is
      local
	 static_value: INTEGER;
      do
	 check
	    ifthenlist.count > 0
	 end;
	 cpp.put_string("/*[IF*/%N");
	 static_value := ifthenlist.compile_to_c;
	 inspect
	    static_value
	 when static_false then
	    cpp.put_string("/*AE*/%N");
	    if else_compound /= Void then
	       else_compound.compile_to_c;
	    end;
	 when static_true then
	 when non_static then
	    if else_compound /= Void then
	       cpp.put_string(fz_else);
	       cpp.put_string(fz_11);
	       else_compound.compile_to_c;
	       cpp.put_string(fz_12);
	    end;
	 end;
	 cpp.put_string("/*FI]*/%N");
      end;

   compile_to_jvm is
      local
	 static_value: INTEGER;
      do
	 check
	    ifthenlist.count > 0
	 end;
	 static_value := ifthenlist.compile_to_jvm;
	 inspect
	    static_value
	 when static_false then
	    -- Always else :
	    if else_compound /= Void then
	       else_compound.compile_to_jvm;
	    end;
	 when static_true then
	    -- Never else :
	    ifthenlist.compile_to_jvm_resolve_branch;
	 when non_static then
	    -- Else is possible :
	    if else_compound /= Void then
	       else_compound.compile_to_jvm;
	    end;
	    ifthenlist.compile_to_jvm_resolve_branch;
	 end;
      end;

   to_runnable(ct: TYPE): like Current is
      local
	 ne: INTEGER;
	 itl: like ifthenlist;
	 ec: like else_compound;
      do
	 ne := nb_errors;
	 if current_type = Void then
	    current_type := ct;
	    itl := ifthenlist.to_runnable(ct);
	    if itl = Void then
	       check
		  nb_errors - ne > 0
	       end;
	    else
	       ifthenlist := itl;
	    end;
	    if nb_errors - ne = 0 and then else_compound /= Void then
	       ec := else_compound.to_runnable(ct);
	       if ec = Void then
		  check
		     nb_errors - ne > 0
		  end;
	       else
		  else_compound := ec;
	       end;
	    end;
	    if itl /= Void then
	       Result := Current
	    end;
	 else
	    Result := twin;
	    Result.clear_current_type;
	    Result := Result.to_runnable(ct);
	 end;
      end;

   add_if_then(expression: EXPRESSION; then_compound: COMPOUND) is
      require
	 expression /= void;
      local
	 ifthen: IFTHEN;
      do
	 !!ifthen.make(expression,then_compound);
	 if ifthenlist = Void then
	    !!ifthenlist.make(ifthen);
	 else
	    ifthenlist.add_last(ifthen);
	 end;
      end;

   pretty_print is
      do
	 check
	    ifthenlist.count > 0;
	 end;
	 fmt.keyword("if");
	 ifthenlist.pretty_print;
	    if else_compound /= Void then
	       fmt.indent;
	       fmt.keyword("else");
	       else_compound.pretty_print;
	    end;
	    fmt.indent;
	    if fmt.semi_colon_flag then
	       fmt.keyword("end;");
	    else
	       fmt.keyword("end");
	    end;
	    if fmt.print_end_if then
	       fmt.put_end("if");
	       end;
	    end;

feature {IFTHENELSE}

   clear_current_type is
      do
	 current_type := Void;
      ensure
	 current_type = Void
      end;

feature {EIFFEL_PARSER}

   set_else_compound(ec: like else_compound) is
      do
	 else_compound := ec;
      ensure
	 else_compound = ec;
      end;

end -- IFTHENELSE

