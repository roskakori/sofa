indexing
   description: "Rexx tools";
   usage: "Don't use this class. Instead, inherit from SHARED_REXX_TOOLS";

class REXX_TOOLS

inherit 
   SHARED_SOFA_TOOLS;
   
creation {ANY} 
   make, make_or_die

feature {ANY} -- Initialization

   make is 
      -- Initialize Rexx by opening "rexxsyslib.library".
      -- If successful, set `running'.
      do  
         if not running then 
            running := rexx_make;
         end; 
      end -- make
   
   make_or_die is 
      -- Initialize Rexx by opening "rexxsyslib.library".
      --
      -- In case of error, `die_screaming' and exit program.
      do  
         make;
         if not running then 
            Sofa_tools.die_screaming("cannot open %"rexxsys.library%"");
         end; 
      ensure 
         running: running; 
      end -- make_or_die

feature {ANY} -- Status report

   running: BOOLEAN;
      -- is Rexx running ?
   
feature {NONE} 
   -- Implementation

   Exceptions: EXCEPTIONS is 
      once 
         !!Result;
      end -- Exceptions
   
   rexx_make: BOOLEAN is 
      external "C"
      end -- rexx_make

end -- class REXX_TOOLS
