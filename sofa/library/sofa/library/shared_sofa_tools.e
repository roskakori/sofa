indexing
	description: "Shared internal sofa tools"
	pattern: "Singleton"

class SHARED_SOFA_TOOLS

feature -- Access

	Sofa_tools: SOFA_TOOLS is
			-- Shared internal sofa tools
		once
			!!Result.make_or_die
		ensure
			not_void: Result /= Void
			running: Result.running
		end;

end -- class SHARED_SOFA_TOOLS


