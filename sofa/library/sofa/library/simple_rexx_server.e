indexing
	description: "Simple Rexx server.";

class SIMPLE_REXX_SERVER

inherit 
	SHARED_REXX_TOOLS;
	
creation {ANY} 
	make

feature {ANY} -- Creation

	make(base_name: STRING) is 
		-- Create new port with basic name `base_name' and a default
		-- `suffix' when looking for scripts to execute.
		--
		-- The actual `name' assigned is of the form "BASENAME.x", where
		-- x is a number.
		require 
			rexx_running: Rexx_tools.running; 
			base_name_not_empty: base_name /= Void and then not base_name.is_empty;
			short_base_name: base_name.count <= 16; 
		do  
			make_with_suffix(base_name,"rexx");
		end -- make
	
	make_with_suffix(base_name: STRING; new_suffix: STRING) is 
		-- Same as `make', but use `new_suffix' for `suffix'.
		require 
			rexx_running: Rexx_tools.running; 
			base_name_not_empty: base_name /= Void and then not base_name.is_empty;
			suffix_not_void: new_suffix /= Void; 
			suffix_without_dot: not new_suffix.has('.'); 
		do  
			internal_context := rexx_server_make(base_name.to_external,new_suffix.to_external);
			if internal_context.is_not_null then
				!!name.from_external_copy(rexx_server_name(internal_context));
				signal_mask := rexx_server_signal_mask(internal_context);
				suffix := clone(new_suffix);
			else 
				Sofa_tools.Exceptions.raise("cannot establish Rexx server");
			end; 
		ensure 
			suffix_stored: suffix.is_equal(new_suffix); 
		end -- make_with_suffix

feature {ANY} -- Status report

	name: STRING;
		-- actual name of port, based on `base_name' passed to `make'
	
	suffix: STRING;
		-- default suffix when executing scripts
	
	empty: BOOLEAN is 
		-- Is there an `item' ?
		--
		-- TODO: handle REXX_RETURN_ERROR
		do  
			if not has_internal_message then 
				debug ("SIMPLE_REXX_SERVER")
					print("checking for new rexx message%N");
				end; 
				internal_message := rexx_server_get_message(internal_context);
				has_internal_message := internal_message.is_not_null;
				if has_internal_message then 
					!!internal_item.from_external_copy(rexx_server_item(internal_message));
					debug ("SIMPLE_REXX_SERVER")
						print("  yep: new item = %"");
						print(internal_item);
						print("%"%N");
					end; 
				else
					internal_item := Void
				end; 
			end; 
			Result := not has_internal_message;
		ensure 
			not Result = has_internal_message -- and internal_item /= Void and internal_message.is_not_null;
		end -- empty

feature {ANY} -- Access

	item: STRING is 
		-- last item sent to server
		require 
			not_empty: not empty; 
		do  
			Result := internal_item;
		end -- item

feature {ANY} -- Status change

	wait is 
		-- Wait for `item' or until Control-C is sent.
		do  
			from 
			until 
				not empty
			loop 
				rexx_server_wait(internal_context);
			end; 
		end -- wait
	
	close is
		-- Close server and remove it from system.
		do  
			-- rexx_server_close(internal_context);
			-- TODO: make this work together with resource tracking
		end -- disconnect

feature {ANY} -- Element change

	remove is 
		-- Remove `item' and set Rexx variables RESULT to "" and RC to 0.
		require 
			not_empty: not empty;
		do  
			remove_with_result_and_code("",0);
		end -- remove
	
	remove_with_result(text: STRING) is 
		-- Remove `item' and set Rexx variables RESULT to `text' and
		-- RC to 0.
		require 
			not_empty: not empty;
		do  
			remove_with_result_and_code(text,0);
		end -- remove_with_result
	
	remove_with_result_and_code(text: STRING; code: INTEGER) is 
		-- Remove `item' and set Rexx variables RESULT to `text' and
		-- RC to `code'.
		require 
			not_empty: not empty;
			text /= Void; 
			code >= 0 and code <= 9; 
		do  
			rexx_server_reply_message(internal_context,internal_message,text.to_external,code);
			has_internal_message := false;
		end -- remove_with_result_and_code
	
	remove_with_error_and_code(text: STRING; code: INTEGER) is 
		-- Remove `item' and set Rexx variables RC to `code' and
		-- `name'.LASTERROR to `text'.
		--
		-- Note: LASTERROR can only be set for "real" Rexx scripts.
		-- Class SIMPLE_EIFFEL_CLIENT does not support this feature.
		require 
			not_empty: not empty;
			text /= Void; 
			code >= 10; 
		do  
			last_error_set:= rexx_server_set_last_error(internal_context,internal_message,text.to_external)
			rexx_server_reply_message(internal_context,internal_message,("").to_external,code);
			has_internal_message := false;
		end -- remove_with_error_and_code

feature {ANY} -- The Guru section

	signal_mask: INTEGER;
		-- internal AmigaOS signal mask to be used with Wait()

	last_error_set: BOOLEAN
		-- Did last call to `remove_with_error_and_code' also set
		-- Rexx variable LASTERROR (only possible for scripts).

feature {SIMPLE_REXX_SERVER} 
	-- Implementation

	internal_context: POINTER;
		-- internal context set by `make' and maintained by SimpleRexx
	
	internal_message: POINTER;
		-- last rexx message obtained by `rexx_server_get_message'
	
	has_internal_message: BOOLEAN;
		-- has a new message arrived ?
	
	internal_item: STRING;
		-- last rexx command obtained with `rexx_server_item'
	
feature {NONE} 
	-- Implementation

	rexx_server_make(base_name, new_suffix: POINTER): POINTER is
		external "C"
		end -- rexx_server_make
	
	rexx_server_close(context: POINTER) is
		-- Wait until new command or Control-C arrives.
		external "C"
		end -- rexx_server_dispose
	
	rexx_server_wait(context: POINTER) is 
		-- Wait until new command or Control-C arrives.
		external "C"
		end -- rexx_server_wait
	
	rexx_server_item(message: POINTER): POINTER is
		external "C"
		end -- rexx_server_item
	
	rexx_server_signal_mask(context: POINTER): INTEGER is 
		external "C"
		end -- rexx_server_signal_mask
	
	rexx_server_name(context: POINTER): POINTER is 
		external "C"
		end -- rexx_server_name
	
	rexx_server_command(context, command: POINTER): BOOLEAN is 
		external "C"
		end -- rexx_server_command
	
	rexx_server_script(context, script: POINTER): BOOLEAN is 
		external "C"
		end -- rexx_server_script
	
	rexx_server_get_message(context: POINTER): POINTER is 
		external "C"
		end -- rexx_server_get_message
	
	rexx_server_is_message_in_error(message: POINTER): BOOLEAN is 
		external "C"
		end -- rexx_server_is_message_in_error
	
	rexx_server_reply_message(context, message, result: POINTER; error: INTEGER) is 
		external "C"
		end -- rexx_server_reply_message
	
	rexx_server_set_last_error(context, message, description: POINTER): BOOLEAN is 
		external "C"
		end -- rexx_server_set_last_error

invariant 
	
	name_not_void: name /= Void; 
	
	suffix_not_void: suffix /= Void; 

	mask_not_null: signal_mask /= 0;

end -- class SIMPLE_REXX_SERVER
