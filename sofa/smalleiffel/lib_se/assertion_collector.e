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
class ASSERTION_COLLECTOR
   --
   -- Singleton object in charge of assertion lookup.
   -- This singleton is shared via the GLOBALS.`assertion_collector' once function.
   --

inherit GLOBALS;

creation make

feature {NONE}

   processing_require: BOOLEAN;
         -- When processing require collection only.

   header_comment: COMMENT;

   make is
      do
      end;

feature {RUN_CLASS}

   invariant_start is
         -- Called to start the collection of a class invariant.
      do
         collector.clear;
         header_comment := Void;
      end;

   invariant_end(ct: TYPE): CLASS_INVARIANT is
         -- Called to finish the collection of `ct' class invariant.
      require
         ct /= Void
      local
         r: ARRAY[ASSERTION];
         position: POSITION;
      do
         r := runnable(collector,ct,Void,'_');
         if r /= Void then
            small_eiffel.incr_magic_count;
            position := ct.base_class.name.start_position;
            !!Result.make_runnable(position,r,ct,Void);
            Result.set_header_comment(header_comment);
         end;
      end;

feature {BASE_CLASS}

   invariant_add_last(ci: CLASS_INVARIANT) is
      require
         ci /= Void
      local
         hc2: COMMENT;
         bc, bc2: BASE_CLASS;
      do
         ci.add_into(collector);
         hc2 := ci.header_comment;
         if header_comment = Void then
            header_comment := hc2;
         elseif hc2 = Void then
         else
            bc := header_comment.start_position.base_class;
            bc2 := hc2.start_position.base_class;
            if bc2 = bc or else bc2.is_subclass_of(bc) then
               header_comment := hc2;
            end;
         end;
      end;

   require_start is
         -- Called to start the collection of require assertions.
      do
         collector.clear;
         header_comment := Void;
         processing_require := true;
      end;

   require_end(rf: RUN_FEATURE; ct: TYPE): RUN_REQUIRE is
         -- Called to finish the collection of `ct' require assertion.
      require
         ct = rf.current_type
      local
         i: INTEGER;
         sp: POSITION;
         bc: BASE_CLASS;
         a: ASSERTION;
         r, r2: ARRAY[ASSERTION];
         er: E_REQUIRE;
      do
         processing_require := false;
         r := runnable(collector,ct,rf,'R');
         if r /= Void then
            from
               !!r2.with_capacity(r.count,1);
               a := r.item(1);
               r2.add_last(a);
               sp := a.start_position;
               bc := sp.base_class;
               i := 2;
            until
               i > r.upper or else r.item(i).start_position.base_class /= bc
            loop
               r2.add_last(r.item(i));
               i := i + 1;
            end;
            !!er.make_runnable(sp,r2,ct,rf);
            !!Result.make(er);
            from
            until
               i > r.upper
            loop
               from
                  !!r2.with_capacity(r.count,1);
                  a := r.item(i);
                  r2.add_last(a);
                  sp := a.start_position;
                  bc := sp.base_class;
                  i := i + 1;
               until
                  i > r.upper or else r.item(i).start_position.base_class /= bc
               loop
                  r2.add_last(r.item(i));
                  i := i + 1;
               end;
               !!er.make_runnable(sp,r2,ct,rf);
               Result.add(er);
            end;
         end;
      end;

   ensure_start is
         -- Called to start the collection of ensure assertions.
      do
         collector.clear;
         header_comment := Void;
      end;

   ensure_end(rf: RUN_FEATURE; ct: TYPE): E_ENSURE is
         -- Called to finish the collection of `ct' ensure assertion.
      require
         ct = rf.current_type
      local
         r: ARRAY[ASSERTION];
         position: POSITION;
      do
         r := runnable(collector,ct,rf,'E');
         if r /= Void then
            position := ct.base_class.name.start_position;
            !!Result.make_runnable(position,r,ct,rf);
            Result.set_header_comment(header_comment);
         end;
      end;

   assertion_add_last(f: E_FEATURE) is
         -- To add some require/ensure assertion.
      local
         r: E_REQUIRE;
         e: E_ENSURE;
      do
         if processing_require then
            r := f.require_assertion;
            if r /= Void then
               if header_comment = Void then
                  header_comment := r.header_comment;
               end;
               r.add_into(collector);
            end;
         else
            e := f.ensure_assertion;
            if e /= Void then
               if header_comment = Void then
                  header_comment := e.header_comment;
               end;
               e.add_into(collector);
            end;
         end;
      end;

feature {ASSERTION_LIST}

   runnable(collected: ARRAY[ASSERTION];
            ct: TYPE;
            for:RUN_FEATURE;
            assertion_check_tag: CHARACTER): ARRAY[ASSERTION] is
         -- Produce a runnable `collected'.
      require
         collected.lower = 1;
         for /= Void implies ct = for.current_type;
      local
         i: INTEGER;
         a: ASSERTION;
      do
         if not collected.is_empty then
            from
               Result := collected.twin;
               i := Result.upper;
            until
               i = 0
            loop
               small_eiffel.push(for);
               a := Result.item(i).to_runnable(ct,assertion_check_tag);
               if a = Void then
                  error(Result.item(i).start_position,fz_bad_assertion);
               else
                  Result.put(a,i);
               end;
               small_eiffel.pop;
               i := i - 1;
            end;
         end;
      end;

feature {NONE}

   collector: ARRAY[ASSERTION] is
      once
         !!Result.make(1,12);
      end;

   singleton_memory: ASSERTION_COLLECTOR is
      once
         Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- ASSERTION_COLLECTOR
