#!/local/bin/bash

# system:     "Gobo Eiffel Grep"
# compiler:   "SmallEiffel -0.78"
# author:     "Eric Bezault <ericb@gobosoft.com>"
# copyright:  "Copyright (c) 1999, Eric Bezault and others"
# license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
# date:       "$Date: 1999/10/02 12:48:15 $"
# revision:   "$Revision: 1.3 $"


echo ${GOBO}/example/lexical/gegrep/>	loadpath.se
echo ${GOBO}/library/loadpath.se>>		loadpath.se

export geoptions="-boost -no_split -no_style_warning -no_gc"
compile $geoptions GEGREP execute