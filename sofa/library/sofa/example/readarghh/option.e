indexing
	description: "A singel option in a Readargs template";

class OPTION

inherit
	OPTION_TYPES

creation {ANY} 
	make

feature {ANY} -- Initialization

	make(new_name: STRING; new_type: CHARACTER; new_is_keyword, new_is_required: BOOLEAN) is 
		require 
			new_name /= Void; 
			is_type(new_type); 
		local
			i: INTEGER
			merkki,  previous_merkki:CHARACTER
		do  
			name := new_name;
			type := new_type;
			is_keyword := new_is_keyword;
			is_required := new_is_required;
			!!eiffel_name.make(0)
			eiffel_name.extend(name.item(1).to_lower)
			from
				i := 2
			-- variant
				-- name.count - i - 1
			until
				i > name.count or else name.item(i) = '='
			loop
				merkki := name.item(i);
				previous_merkki := name.item(i-1)
				if previous_merkki.is_lower and merkki.is_upper then
					eiffel_name.extend('_')
				end
				eiffel_name.extend(merkki.to_lower)
				i := i + 1
			end
		ensure 
			name = new_name; 
		end -- make

feature -- Conversion

	to_template: STRING is
			-- ReadArgs() template excerpt
		do
			Result := clone(name);
			inspect
				type
			when Array_type then
				Result.append("/m")
			when Number_type then
				Result.append("/n")
			when Rest_type then
				Result.append("/f")
			when String_type then
				do_nothing
			when Switch_type then
				Result.append("/s")
			when Toggle_type then
				Result.append("/t")
			end
			if is_keyword then
				Result.append("/k");
			end
			if is_required then
				Result.append("/a");
			end
		ensure
			result_not_void: Result /= Void
		end;

	to_eiffel(at: INTEGER): STRING is
			-- Eiffel source for attribute at option array position `at'.
		local
			routine: STRING
		do
			inspect
				type
			when String_type, Rest_type then
			routine := "item_as_string"
			when Switch_type, Toggle_type then
			routine := "item_as_boolean";
			when Array_type then
			routine := "item_as_array"
			when Number_type then
			routine := "item_as_integer"
			end
			!!Result.make(0)
			Result.extend('%T');
			Result.append(eiffel_name)
			Result.append(": ")
			Result.append(type_to_eiffel(type))
			Result.append(" is%N%T%T%T-- value of argument %"")
			Result.append(name)
			Result.append("%"%N")
			Result.append("%T%Tdo%N")
			Result.append("%T%T%TResult := parser.")
			Result.append(routine)
			Result.extend('(');
			Result.append(at.to_string)
			Result.append(")%N");
			Result.append("%T%Tend%N%N")
		ensure
			result_not_void: Result /= Void
		end;

feature {ANY} -- Access

	name: STRING;
	
	type: CHARACTER;
	
	is_keyword: BOOLEAN;
		-- Did template contain "/k" ?
	
	is_required: BOOLEAN;
		-- Did template contain "/a" ?

	eiffel_name: STRING
		-- `name', but as legal Eiffel name
	
end -- class OPTION
