#!/local/bin/bash

# system:     "'gepp' preprocessor"
# compiler:   "SmallEiffel -0.78"
# author:     "Eric Bezault <ericb@gobosoft.com>"
# copyright:  "Copyright (c) 1999, Eric Bezault and others"
# license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
# date:       "$Date: 1999/10/02 14:17:53 $"
# revision:   "$Revision: 1.3 $"


echo ${GOBO}/src/gepp/>					loadpath.se
echo ${GOBO}/library/loadpath.se>>		loadpath.se

export geoptions="-boost -no_split -no_style_warning -no_gc"
compile $geoptions GEPP execute
