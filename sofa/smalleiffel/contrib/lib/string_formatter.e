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

	description: "String formatter."

	author: "P.M. Hegt (mailto: p_m_hegt@hotmail.com)"

	copyright: "Freeware. No warranty."

	note: "This is a simple string formatter because there is only a limited number of arguments possible."

	how_to_use: "You can use facility inheritance or a client relation. %
		% In case of facility inheritance, inherit STRING_FORMATTER %
		% and call function `format_string': %
		%     my_feature is %
		%         local %
		%             s: STRING %
		%         do %
		%             s := format_string ("1 = '~1', 2 = '~2', 1 = '~1'." , << "A", "B">>) %
		%             print (s); io.put_new_line %
		%         end %
		%  %
		% produces the following output: %
		%      1 = 'A', 2 = 'B', 1 = 'A'. %
		%  %
		% In case of a client relation, create an instance first %
		% and call function `format_string': %
		%     my_feature is %
		%         local %
		%             sf: STRING_FORMATTER
		%             s: STRING %
		%         do %
		%             !! sf
		%             s := sf.format_string ("1 = '~1', 2 = '~2', 1 = '~1'." , << "A", "B">>) %
		%             print (s); io.put_new_line %
		%         end %
		% produces identical output. %
		"

class
	STRING_FORMATTER

feature -- Formatting

	format_string (format: STRING; arguments: COLLECTION[STRING]): STRING is
			-- Format string.
			-- `Result' is a copy of `format' where substring
			-- "~1" is replaced with `arguments' @ 1, etc.
			-- Max 9 arguments if arguments.lower = 1.
			-- Max 10 arguments if arguments.lower = 0.
		require
			format /= Void
			arguments /= Void
			arguments.lower <= 1
			arguments.count <= 9
		local
			i: INTEGER
			c: CHARACTER
			j: INTEGER
		do
			from
				!! Result.make (50)
				i := 1
			invariant
				(1 <= i) and (i <= 1 + format.count)
			variant
				format.count - i
			until
				not (i <= format.count)
			loop
				c := format @ i
				if c = argument_indicator then
					if i < format.count then
						i := i + 1
						c := format @ i
						if c.is_digit then
							j := c.code - ('0').code
							if arguments.lower <= j and j <= arguments.upper then
								Result.append_string (arguments @ j)
							else
								-- Argument not present
								Result.append_character (argument_indicator)
								Result.append_character (c)
							end
						else
							-- Is not an argument.
							Result.append_character (argument_indicator)
							Result.append_character (c)
						end
					else
						-- c is last character so cannot be an argument.
						Result.append_character (c)
					end
				else
					Result.append_character (c)
				end

				i := i + 1
			end
		ensure
			Result /= Void
		end

feature -- Constants

	argument_indicator: CHARACTER is '~'

end -- class STRING_FORMATTER
