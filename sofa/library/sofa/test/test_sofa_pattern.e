indexing
	description: "Test SOFA_PATTERN";

class TEST_SOFA_PATTERN

creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		do  
			!!Exceptions;
			test_good_pattern("#?.e", "sepp.e", true, true)
			test_good_pattern("#?.e", "SEPP.E", true, false)
			test_good_pattern("#?.e", "sepp.pas", false, false)
			test_bad_pattern("[a-");
		end -- make

feature {NONE} 
	-- Implementation

	pattern: SOFA_PATTERN;
	
	Exceptions: EXCEPTIONS;
	
	test_good_pattern(pattern_text, some: STRING; no_case, case: BOOLEAN) is 
		-- Test if `some' matches `pattern_text' and compare result
		-- with expectation `no_case' and `case'.
		require 
			some /= Void; 
		local 
			actual_no_case, actual_case: BOOLEAN;
		do  
			print("testing: (%"");
			print(pattern_text);
			print("%", %"");
			print(some);
			print("%")");
			std_output.flush
			!!pattern.make(pattern_text);
			actual_no_case := pattern.matches(some);
			!!pattern.make_case_sensitive(pattern_text);
			actual_case := pattern.matches(some);
			print(" -> ");
			print_test_flag(actual_no_case, no_case)
			print(" : ");
			print_test_flag(actual_case, case)
			print('%N');
		end -- test_good_pattern
	
	print_test_flag(flag, expectation: BOOLEAN) is
		-- If `flag' is equal `expectation', print `flag',
		-- otherwise "ERROR".
		do  
			print(flag);
			if flag /= expectation then 
				print("*** test failed ***%N");
				Exceptions.raise("test failed");
			end; 
		end -- print_flag_or_error
	
	test_bad_pattern(pattern_text: STRING) is 
		-- Test, if `pattern_text' is recognized as bad pattern.
		require 
			pattern_text /= Void; 
		local 
			tried: BOOLEAN;
			message: STRING
		do  
			if not tried then 
				print("testing: %"");
				print(pattern_text);
				print("%" -> ");
				!!pattern.make(pattern_text);
			end; 
			if tried then 
				print(message)
				print('%N')
			end 
		rescue
			if Exceptions.is_developer_exception then
				tried := True
				message := clone(Exceptions.developer_exception_name)
				retry
			end
		end -- test_bad_pattern

end -- class TEST_SOFA_PATTERN
