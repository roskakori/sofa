@rem system:     "Calculator with memory"
@rem compiler:   "SmallEiffel -0.78"
@rem author:     "Eric Bezault <ericb@gobosoft.com>"
@rem copyright:  "Copyright (c) 1999, Eric Bezault and others"
@rem license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
@rem date:       "$Date: 1999/10/02 12:51:47 $"
@rem revision:   "$Revision: 1.2 $"


@echo ${GOBO}\example\parse\mcalc\>				loadpath.se
@echo ${GOBO}\library\parse\skeleton\>>			loadpath.se
@echo ${GOBO}\library\structure\loadpath.se>>	loadpath.se
@echo ${GOBO}\library\kernel\loadpath.se>>		loadpath.se

set options= -boost -no_split -no_style_warning
compile %options% MCALC execute
