indexing
	description: "Test SOFA_ARGUMENT_PARSER.";

class TEST_ARGUMENT_PARSER

creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		local 
			i: INTEGER;
		do  
			!!parser.make(Template);
			parser.parse;
			if parser.is_parsed then 
				hugo := parser.item_as_boolean(1);
				sepp := parser.item_as_boolean(2);
				resi := parser.item_as_integer(3);
				susi := parser.item_as_string(4);
				files := parser.item_as_array(5);
				print_all
			else 
				print("parser error: ");
				print(parser.error_description);
				print('%N');
			end; 
		end -- make

feature {NONE} -- Implementation

	parser: SOFA_ARGUMENT_PARSER;

	Template: STRING is "hugo/s,sepp/s,resi/k/n,susi,files/m";
	
	hugo, sepp: BOOLEAN;
	
	resi: INTEGER;
	
	susi: STRING;
	
	files: ARRAY[STRING];
	

	print_all is
		local
			i: INTEGER
		do
				print("hugo=");
				print(hugo);
				print('%N');
				print("sepp=");
				print(sepp);
				print('%N');
				print("resi=");
				print(resi);
				print('%N');
				print("susi=");
				print(susi);
				print('%N');
				from 
					i := 1;
				variant
					files.count - i
				until 
					i > files.count
				loop 
					print("file.");
					print(i);
					print('=');
					print(files.item(i));
					print('%N');
					i := i + 1;
				end; 
		end;

end -- class TEST_ARGUMENT_PARSER
