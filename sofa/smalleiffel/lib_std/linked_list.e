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
class LINKED_LIST[E]
   -- 
   -- One way linked list with internal automatic memorization of
   -- the last access.
   --

inherit LINKED_COLLECTION[E];

creation make, from_collection

feature {LINKED_LIST,ITERATOR_ON_LINKED_LIST}
   
   first_link: LINK[E];
         -- Void when empty or gives access to the first element.
   
feature {LINKED_LIST}

   last_link: like first_link; 
         -- Void when empty or gives access to the last element.
   
   mem_idx: INTEGER; mem_lnk: like first_link; 
         -- To speed up accessing, `mem_idx' and `mem_lnk' is the 
         -- memory of the last access done. For example, after 
         -- item(1), `mem_idx' is 1 and `mem_lnk' is `first_link'.
         -- When list is empty, `first_link' is Void as well as 
         -- `mem_lnk' and `mem_idx' is 0;

feature 
   
   make is
         -- Make an empty list;
      do
         first_link := Void;
         upper := 0;
         last_link := Void;
         mem_idx := 0;
         mem_lnk := Void;
      ensure
         count = 0
      end;

   is_empty: BOOLEAN is
      do
	 Result := first_link = Void;
      end;

   add_first(element: like item) is
      do
         if first_link = Void then
            !!first_link.make(element,Void);
            upper := 1;
            last_link := first_link;
            mem_idx := 1;
            mem_lnk := first_link;
         else 
            !!first_link.make(element,first_link);
            upper := upper + 1;
            mem_idx := mem_idx + 1;
         end;
      end;

   add_last(element: like item) is
      local
         lnk: like first_link;
      do
         if first_link = Void then
            !!first_link.make(element,Void);
            upper := 1;
            last_link := first_link;
            mem_idx := 1;
            mem_lnk := first_link;
         else
            !!lnk.make(element,Void);
            last_link.set_next(lnk);
            upper := upper + 1;
            last_link := lnk;
         end;
      end;
   
   add(element: like item; index: INTEGER) is
      local
         link: like first_link;
      do
         if index = 1 then
            add_first(element);
         elseif index = upper + 1 then
            add_last(element);
         else
            if (index - 1) /= mem_idx then
               go_item(index - 1);
            end;
            !!link.make(element,mem_lnk.next);
            mem_lnk.set_next(link);
            upper := upper + 1;
         end;
      end;

   remove_first is
      do
         if upper = 1 then
            make;
         else
            mem_lnk := first_link;
            first_link := first_link.next;
            mem_lnk := first_link;
            mem_idx := 1;
            upper := upper - 1;
         end;
      end;

   remove(index: INTEGER) is
      local
         link: like first_link;
      do
         if index = 1 then
            remove_first;
         elseif index = upper then
            remove_last;
         else
            if (index - 1) /= mem_idx then
               go_item(index - 1);
            end;
            link := mem_lnk.next;
            mem_lnk.set_next(link.next);
            upper := upper - 1;
         end;
      end;

   first: like item is
      do
         Result := first_link.item;
      end;
   
   last: like item is
      do
         Result := last_link.item;
      end;

   item, infix "@" (index: INTEGER): E is
      do
         if index /= mem_idx then
            go_item(index);
         end;
         Result := mem_lnk.item;
      end;
   
   put(element: like item; index: INTEGER) is
      do
         if index /= mem_idx then
            go_item(index);
         end;
         mem_lnk.set_item(element);
      end;

   count: INTEGER is
      do
         Result := upper;
      end;

   set_all_with(v: like item) is
      do
         if first_link /= Void then
            first_link.set_all_with(v);
         end;
      end;

   copy(other: like Current) is
      do
         from_collection(other);
      end;

   is_equal(other: like Current): BOOLEAN is
      local
         lnk1, lnk2: like first_link;
      do
         if Current = other then
            Result := true;
         elseif upper = other.upper then
            from
               Result := true;
               lnk1 := first_link;
               lnk2 := other.first_link;
            until
               lnk1 = Void or not Result
            loop
               Result := lnk1.item = lnk2.item;
               lnk1 := lnk1.next;
               lnk2 := lnk2.next;
            end;
         end;
      end;

   is_equal_map(other: like Current): BOOLEAN is
      local
         lnk1, lnk2: like first_link;
      do
         if Current = other then
            Result := true;
         elseif upper = other.upper then
            from
               Result := true;
               lnk1 := first_link;
               lnk2 := other.first_link;
            until
               lnk1 = Void or not Result
            loop
               Result := safe_equal(lnk1.item,lnk2.item);
               lnk1 := lnk1.next;
               lnk2 := lnk2.next;
            end;
         end;
      end;

   index_of(x: like item): INTEGER is
      do
         from  
            Result := lower;
         until
            (Result > upper) or else safe_equal(x,item(Result))
         loop
            Result := Result + 1;
         end;
      end;
   
   fast_index_of(x: like item): INTEGER is
      local
         u: like upper;
      do
         from
            Result := lower;
            u := upper;
         until
            (Result > u) or else x = item(Result)
         loop
            Result := Result + 1;
         end;
      end;
   
   clear is
      do
         if first_link /= Void then
            first_link := Void;
            mem_idx := 0;
            mem_lnk := Void;
            upper := 0;
            last_link := Void;
         end;
      ensure then
         upper = 0
      end;

   from_collection(model: COLLECTION[like item]) is
      local
         i, up: INTEGER;
         lnk: like first_link;
      do
         if first_link = Void then
            from
               i := model.lower;
               up := model.upper;
            until
               i > up
            loop
               add_last(model.item(i));
               i := i + 1;
            end;
         else
            from
               lnk := first_link;
               i := model.lower;
               up := model.upper;
            until
               i > up
            loop
               if lnk = Void then
                  add_last(model.item(i));
               else
                  lnk.set_item(model.item(i));
                  lnk := lnk.next;
               end;
               i := i + 1;
            end;
            if lnk = first_link then
               check
                  model.count = 0
               end;
               clear;
            elseif lnk /= Void then
               i := model.count;
               if mem_idx /= i then
                  go_item(i);
               end;
               check
                  lnk = mem_lnk.next
               end;
               mem_lnk.set_next(Void);
               upper := i;
               last_link := mem_lnk;
            end;
         end;
      end;

   slice(low, up: INTEGER): like Current is
      local
         lnk: like first_link;
         i: INTEGER;
      do
         from
            !!Result.make;
            if mem_idx /= low then
               go_item(low);
            end;
            lnk := mem_lnk;
            i := up - low + 1;
         until
            i = 0
         loop
            Result.add_last(lnk.item);
            lnk := lnk.next;
            i := i - 1;
         end;
      end;

   nb_occurrences(element: like item): INTEGER is
      local
         lnk: like first_link;
      do
         from
            lnk := first_link;
         until
            lnk = Void
         loop
            if safe_equal(element,lnk.item) then
               Result := Result + 1;
            end;
            lnk := lnk.next;
         end;
      end;

   fast_nb_occurrences(element: like item): INTEGER is
      local
         lnk: like first_link;
      do
         from
            lnk := first_link;
         until
            lnk = Void
         loop
            if element = lnk.item then
               Result := Result + 1;
            end;
            lnk := lnk.next;
         end;
      end;

   force(element: E; index: INTEGER) is
      local
         v: like element;
      do
         from
         until
            index <= upper
         loop
            add_last(v);
         end;
         put(element,index);
      end;

   all_default: BOOLEAN is
      local
         l: like first_link;
         d: like item;
      do
         from
            Result := true;
            l := first_link;
         until
            not Result or else l = Void
         loop
            Result := d = l.item;
            l := l.next;
         end;
      end;

   remove_last is
      do
         if upper = 1 then
            make;
         else
            if upper - 1 /= mem_idx then
               go_item(upper - 1);
            end;
            upper := upper - 1;
            last_link := mem_lnk;
            last_link.set_next(Void);
         end;
      end;

   replace_all(old_value, new_value: like item) is
      local
         i: INTEGER;
      do
         from
            i := lower;
         until 
            i > upper
         loop
            if safe_equal(item(i),old_value) then
               put(new_value,i);
            end;
            i := i + 1;
         end;
      end;
   
   fast_replace_all(old_value, new_value: like item) is
      local
         i: INTEGER;
      do
         from 
            i := lower;
         until
            i > upper
         loop
            if item(i) = old_value then
               put(new_value, i);
            end;
            i := i + 1;
         end;
      end;

   get_new_iterator: ITERATOR[E] is
      do
         !ITERATOR_ON_LINKED_LIST[E]!Result.make(Current);
      end;

feature {NONE}

   go_item(i: INTEGER) is
      require
         valid_index(i);
         mem_idx /= i;
         mem_idx > 0;
         mem_lnk /= Void
      do
         if mem_idx > i then
            mem_idx := 1;
            mem_lnk := first_link;
         end;
         from
         until
            i = mem_idx
         loop
            mem_lnk := mem_lnk.next;
            mem_idx := mem_idx + 1;
         end;
      ensure
         mem_idx = i;
         mem_lnk /= Void
      end;

invariant

   empty_status:
      first_link = Void implies 
         (last_link = Void and upper = 0 and mem_idx = 0 
          and mem_lnk = Void);

   not_empty_status:
      first_link /= Void implies 
         (last_link /= Void and upper > 0 and mem_idx > 0 
          and mem_lnk /= Void);
   
end -- LINKED_LIST[E]
