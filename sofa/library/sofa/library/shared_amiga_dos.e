indexing
	description: "Shared access to amiga dos low level routines"
	pattern: "Singleton"

class SHARED_AMIGA_DOS

feature -- Access

	Amiga_dos: AMIGA_DOS is
			-- shared access to amiga dos low level routines
		once
			!!Result
		ensure
			not_void: Result /= Void
		end;

end -- class SHARED_AMIGA_DOS


