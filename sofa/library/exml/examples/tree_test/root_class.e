indexing
	description:	"demonstration of using the tree based xml parser";
	note:			 	"this example compiles with ISE Eiffel and SmallEiffel.%
						%Therefore GOBO library must be correctly installed.";

class
	ROOT_CLASS
inherit
	EXPAT_ERROR_CODES
	KL_INPUT_STREAM_ROUTINES
creation

	make

feature -- Initialization

	make is
		do
			!! parser.make

			-- TODO: Use enviroment variables instead !
			-- ?Is there an easy way to do this?
	
				-- uncomment the following line for ise
			-- parse_file ("..\..\..\test_data\test.xml")
				-- uncomment the following line for se
			parse_file ("..\test_data\test.xml")
			
		end;

	parser: XML_TREE_PARSER

	parse_file (file_name: STRING) is
		require
			file_name_not_void: file_name /= Void
			
		local
			in_file: like INPUT_STREAM_TYPE
			buffer: STRING
		do
			in_file := make_file_open_read (file_name)

			check
				file_open: is_open_read (in_file)
			end

			from
			until
				end_of_input (in_file) or not parser.is_correct
			loop
		
				buffer := read_string (in_file, 10)

				--check
				--	file_state_consitency_check: (buffer.count = 0) = end_of_input (in_file)
				--end
				-- TODO: check doesn't work with se ??!?!

				if
					buffer.count > 0
				then
					parser.parse_string (buffer)
				else
					parser.set_end_of_file	
				end

				if
					not parser.is_correct
				then
					print (parser.last_error_extended_description)
				end
			end
			close (in_file)
			print (parser.out)
				
		end
end -- class ROOT_CLASS
