@rem system:     "Gobo Eiffel Lex: lexical analyzer generator"
@rem compiler:   "SmallEiffel -0.76"
@rem author:     "Eric Bezault <ericb@gobosoft.com>"
@rem copyright:  "Copyright (c) 1997-2000, Eric Bezault and others"
@rem license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
@rem date:       "$Date: 2000/08/20 18:01:40 $"
@rem revision:   "$Revision: 1.5 $"


@echo ${GOBO}/src/gelex/>				loadpath.se
@echo ${GOBO}/library/loadpath.se>>		loadpath.se

set options= -boost -no_split -no_style_warning -no_gc
compile %options% GELEX execute
