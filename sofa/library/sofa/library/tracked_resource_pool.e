indexing
	description: "Tracked resource pool to collect logically related %
					 %resources and dispose all of them together.";
	status: "incomplete";

class TRACKED_RESOURCE_POOL

inherit 
	MEMORY
		redefine dispose
		end; 
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		do  
			handle := tracked_pool_make;
			if handle.is_null then 
				Exceptions.raise_exception(Exceptions.No_more_memory);
			end; 
		end -- make

feature {ANY} -- Element change

	tracked_resource_make(pool, resource, kind: POINTER): POINTER is 
		external "C"
		end -- tracked_resource_make
	
	tracked_resource_dispose(pool, resource: POINTER) is 
		external "C"
		end -- tracked_resource_dispose

feature {ANY} -- Removal

	dispose is 
		-- Dispose all resources in `handle'.
		do  
			tracked_pool_dispose(handle);
		end -- dispose

feature {ANY} -- Access

	handle: POINTER;
		-- internal handle
	
feature {NONE} 
	-- Implementation

	Exceptions: EXCEPTIONS is 
		once 
			!!Result;
		end -- Exceptions
	
	tracked_pool_make: POINTER is 
		external "C"
		end -- tracked_pool_make
	
	tracked_pool_dispose(some: POINTER) is 
		external "C"
		end -- tracked_pool_dispose

invariant 
	
	handle_not_null: handle.is_not_null; 

end -- class TRACKED_RESOURCE_POOL
