@rem system:     "Eiffel parser"
@rem compiler:   "SmallEiffel -0.78"
@rem author:     "Eric Bezault <ericb@gobosoft.com>"
@rem copyright:  "Copyright (c) 1999, Eric Bezault and others"
@rem license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
@rem date:       "$Date: 1999/10/02 12:50:48 $"
@rem revision:   "$Revision: 1.3 $"


@echo ${GOBO}\example\parse\eiffel\>		loadpath.se
@echo ${GOBO}\library\parse\skeleton\>>		loadpath.se
@echo ${GOBO}\library\lexical\skeleton\>>	loadpath.se
@echo ${GOBO}\library\utility\loadpath.se>>	loadpath.se
@echo ${GOBO}\library\kernel\loadpath.se>>	loadpath.se

set options= -boost -no_split -no_style_warning -no_gc
compile %options% EIFFEL_PARSER benchmark