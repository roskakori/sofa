@rem system:     "'ascii2ps' pretty-printer"
@rem compiler:   "SmallEiffel -0.76"
@rem author:     "Eric Bezault <ericb@gobosoft.com>"
@rem copyright:  "Copyright (c) 1997-2000, Eric Bezault and others"
@rem license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
@rem date:       "$Date: 2000/08/20 17:55:23 $"
@rem revision:   "$Revision: 1.5 $"


@echo ${GOBO}/example/lexical/ascii2ps/>	loadpath.se
@echo ${GOBO}/library/lexical/skeleton/>>	loadpath.se
@echo ${GOBO}/library/kernel/loadpath.se>>	loadpath.se

set options= -boost -no_split -no_style_warning -no_gc
compile %options% ASCII2PS make
