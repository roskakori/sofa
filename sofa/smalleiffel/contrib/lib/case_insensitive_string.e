-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT 
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of 
-- another product.
--
-- This file is copyrighted and maintained by P.M. Hegt
-- E-mail: p_m_hegt@hotmail.com
--

indexing

	description: "Case-insensitive strings."

	author: "P.M. Hegt (mailto: p_m_hegt@hotmail.com)"

	copyright: "Freeware. No warranty."

	note: "Create a case-insensitive string as follows: %
		% local %
		%	s: CASE_INSENSITIVE_STRING %
		% do %
		%	!! s.make_from_string (%"aBcD%") %
		% end %
		% %
		% Some features are slower because we cannot use the fast %
		% C functions anymore. "

class
	CASE_INSENSITIVE_STRING

inherit
	STRING
		redefine
			is_equal
		,	index_of
		,	index_of_string
		,	infix "<"
		,	hash_code
		,	compare
		,	occurrences_of
		,	occurrences
		end

creation
	make, copy, blank, from_external, copy_from_string

feature -- Modification

	copy_from_string (other: STRING) is
			-- Copy `other' onto Current.
		do
			count := other.count;
			if count > 0 then
				if capacity < count then
					storage := storage.calloc(count);
					capacity := count;
				end;
				storage.copy_from(other.storage,count-1);
			end;
		ensure then
			count = other.count
		end;

feature -- Testing

	is_equal(other: like Current): BOOLEAN is
			-- Has Current the same case insensitive text as `other'?
		do
			if Current = other then
				Result := true
			elseif count = other.count then
				Result := same_as (other)
			end
		end

	index_of (ch: CHARACTER): INTEGER is
		-- Gives the index of the first occurrence `ch' or 
		-- `count + 1' if none.
		local
			c: CHARACTER
		do
			from
				c := ch.to_lower -- Speed optimization
				Result := 1
			invariant
				valid_index (Result)
			variant
				count - Result
			until
				not ( Result <= count and c /= item(Result).to_lower)
			loop
				Result := Result + 1
			end
		ensure
			(Result /= count + 1) implies (item(Result).to_lower = ch.to_lower)
		end;

	index_of_string(other: STRING): INTEGER is
			-- Position of the first occurrence of `other'
			-- `count + 1' if none.
		require
			not other.empty
		local
			stop: BOOLEAN
			i1, i2, i3: INTEGER
		do
			from
				i1 := 1
				i2 := other.count
				i3 := i2
				invariant
				i3 = i2 - i1 + 1;
			variant
				count - i1 + 1
			until
				Result /= 0
			loop
				if i2 > count then
					Result := count + 1
				else
					from
						stop := false
					invariant
						i3 = i2 - i1 + 1
					variant
						(i3 + i2)
					until
						stop
					loop
						if i3 = 0 then
							stop := true
							Result := i1
						elseif other.item(i3).to_lower /= item(i2).to_lower then
							stop := true
						end;
						i3 := i3 - 1
						i2 := i2 - 1
					end
				end
				i1 := i1 + 1
				i3 := other.count
				i2 := i1 + i3 - 1
			end
		end

	occurrences_of, occurrences (ch: CHARACTER): INTEGER is
			-- How many character `ch' in the receiver.
		local
			c: CHARACTER
			i: INTEGER
		do
			from
				c := ch.to_lower
				i := 1
			invariant
				valid_index (i)
				Result >= 0
			variant
				count - i
			until
				not (i <= count)
			loop
				if item (i).to_lower = c then
					Result := Result + 1
				end

				i := i + 1
			end
		ensure
			Result >= 0
		end

	infix "<" (other: like Current): BOOLEAN is
			-- Is Current less than `other' ?
		local
			i: INTEGER;
		do
			from  
				i := 1;
			until
				count < i or else other.count < i 
					or else item(i).to_lower /= other.item(i).to_lower
			loop
				i := i + 1;
			end;

			if count < i then
				Result := other.count >= i;
			elseif other.count < i then
				Result := false;
			else
				Result := item(i).to_lower < other.item(i).to_lower;
			end;
		end;

	compare (other: like Current): INTEGER is
			-- Compare `Current' with `other'.
			-- `<'  <==> `Result < 0'
			-- `>'  <==> `Result > 0'
			-- Otherwise `Result = 0'.
		local
			i: INTEGER;
		do
			from  
				i := 1;
			until
				count < i or else other.count < i 
					or else item(i).to_lower /= other.item(i).to_lower
			loop
				i := i + 1;
			end;

			if count < i then
				if other.count < i then
					Result := 0;
				else
					Result := -1;
				end;
			elseif other.count < i then
				Result := +1;
			elseif item(i).to_lower < other.item(i).to_lower then
				Result := -1;
			else
				Result := +1;
			end;
		end;

	hash_code: INTEGER is
			-- Case insensitive has code.
		local
			i: INTEGER
		do
			i := count
			if i > 5 then
				Result := i * item(i).to_lower.code
				i := 5
			end
			from until i <= 0 loop
				Result := Result + i + item(i).to_lower.code
				i := i - 1
			end
			Result := Result * count
		end

	has_suffix(s: STRING): BOOLEAN is
			-- True if suffix of Current is `s'.
		require
			s /= Void
		local
			i1, i2: INTEGER
		do
			if s.count <= count then
				from  
				   i1 := count - s.count + 1;
				i2 := 1;
				until
					i1 > count or else
					i2 > s.count or else
					item(i1).to_lower /= s.item(i2).to_lower
				loop
					i1 := i1 + 1
					i2 := i2 + 1
				end

				Result := i1 > count
			end
		end

	has_prefix (p: STRING): BOOLEAN is
			-- True if prefix of Current is `p'.
		require
			p /= Void
		local
			i: INTEGER
		do
			if p.count <= count then
				from  
					i := p.count
				until
				   i = 0 or else item(i).to_lower /= p.item(i).to_lower
				loop
					i := i - 1
				end

				Result := i = 0
			end
		end

	substring_index (other: STRING; start: INTEGER): INTEGER is
			-- Position of first occurrence of `other' at or after 
			-- `start';
			-- 0 if none.
		require
			start_large_enough: start >= 1;
			start_small_enough: start <= count;
			string_exist: other /= Void
		local
			i, s: INTEGER;
		do
			from
				s := start;
			until
				Result /= 0 or else (s + other.count - 1) > count
			loop
				from
					i := 1
				until
					i > other.count or else item(s + i - 1).to_lower /= other.item(i).to_lower
				loop
					i := i + 1
				end

				if i > other.count then
					Result := s
				else
					s := s + 1
				end
			end
		end

feature -- Element change

	replace_all (old_character, new_character: like item) is
			-- Replace all occurences of the element `old_character' by 
			-- `new_character'.
		local
			i: INTEGER
			c: CHARACTER
		do
			from
				c := old_character.to_lower -- Speed optimization
				i := 1
			invariant
				valid_index (i)
			variant
				count - i
			until
				not (i <= count)
			loop
				if item (i).to_lower = c then
					put (new_character, i)
				end
			end
		ensure
			count = old count;
			occurrences_of (old_character) = 0
		end

	remove_all_occurrences (ch: CHARACTER) is
			-- Remove all occurrences of `ch'.
		local
			c: CHARACTER
			i, j: INTEGER;
		do
			from
				c := c.to_lower
				i := 1
				j := 1
			until
				i > count
			loop
				if item (i).to_lower /= c then
					put (item (i), j)
					j := j + 1
				end
				i := i + 1
			end

			count := j - 1;
		ensure
			count = old count - old occurrences_of (ch)
		end

end -- class CASE_INSENSITIVE_STRING
