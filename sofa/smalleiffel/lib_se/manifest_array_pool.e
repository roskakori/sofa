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
class MANIFEST_ARRAY_POOL
   --
   -- Unique global object in charge of MANIFEST_ARRAY used.
   --

inherit GLOBALS;

feature {NONE}

   manifest_array_types: DICTIONARY[TYPE,INTEGER] is
         -- Gives the type for all kind of used MANIFEST_ARRAY.
      once
         !!Result.make;
      end;

   as_se_ma: STRING is "se_ma";

feature {MANIFEST_ARRAY,E_STRIP}

   register(ma_type: TYPE) is
      require
         ma_type /= Void
      local
         id: INTEGER;
      do
         id := ma_type.id;
         if not manifest_array_types.has(id) then
            manifest_array_types.put(ma_type,id);
         end;
      end;

   c_call(ma_type: TYPE) is
      require
         small_eiffel.is_ready
      local
         id: INTEGER;
      do
         id := ma_type.id;
         cpp.put_string(as_se_ma);
         cpp.put_integer(id);
      end;

feature {SMALL_EIFFEL}

   c_define is
      require
         small_eiffel.is_ready
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > manifest_array_types.count
         loop
            c_define_for(manifest_array_types.item(i));
            i := i + 1;
         end;
      end;

feature {NONE}

   c_define_for(ma_type: TYPE) is
      local
         ma_id, elt_id: INTEGER;
         elt_type: TYPE;
         rf: RUN_FEATURE;
      do
         ma_id := ma_type.id;
         elt_type := ma_type.generic_list.item(1).run_type;
         elt_id := elt_type.id;
         -- Prepare header :
         header.copy(fz_void);
         header.extend('*');
         header.append(as_se_ma);
         ma_id.append_in(header);
         header.append("(int argc,...)");
         -- Prepare body :
         body.clear;
         body.extend('T');
         ma_id.append_in(body);
         body.append("*m;%N%
                     %va_list pa;%N");
         if elt_type.is_reference then
            body.append(fz_t0_star);
         else
            body.extend('T');
            elt_id.append_in(body);
         end;
         body.append("*s;%N%
                     %m=");
         if gc_handler.is_off then
            body.append(
               "malloc(sizeof(*m));%N%
               %*m=M");
            ma_id.append_in(body);
            body.append(
               ";%N%
               %if(argc){%N%
               %s=malloc(argc*sizeof(*s));%N");
         else
            body.append(fz_new);
            ma_id.append_in(body);
            body.append(
               "();%N%
               %if(argc){%N%
               %s=((void*)new");
            rf := ma_type.run_class.get_feature_with(as_storage);
            rf.result_type.id.append_in(body);
            body.append("(argc));%N");
         end;
         body.append(
           "m->_storage=s;%N%
           %m->_capacity=argc;%N%
           %m->_lower=1;%N%
           %m->_upper=argc;%N%
           %va_start(pa,argc);%N%
           %while(argc--){%N");
         if (elt_type.is_integer or else
             elt_type.is_boolean or else
             elt_type.is_character)
          then
               body.append("*(s++)=va_arg(pa,int);%N");
         elseif elt_type.is_real or else elt_type.is_double then
               body.append("*(s++)=va_arg(pa,double);%N");
         elseif elt_type.is_user_expanded then
            body.append(
             "memcpy(s++,va_arg(pa,char*),sizeof(*s));%N");
         else
            body.append("*(s++)=((void*)(va_arg(pa,char*)));%N");
         end;
         body.append("}%N%
                     %va_end(pa);%N}%N%
                     %else{%N%
                     %m->_storage=NULL;%N%
                     %m->_capacity=0;%N%
                     %m->_lower=1;%N%
                     %m->_upper=0;%N%
                     %}%N%
                     %return m;%N");
         --
         cpp.put_c_function(header,body);
      end;

feature {NONE}

   header: STRING is
      once
         !!Result.make(64);
      end;

   body: STRING is
      once
         !!Result.make(1024);
      end;

end -- MANIFEST_ARRAY_POOL

