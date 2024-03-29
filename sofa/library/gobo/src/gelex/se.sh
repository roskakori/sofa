#!/bin/sh

# system:     "Gobo Eiffel Lex: lexical analyzer generator"
# compiler:   "SmallEiffel -0.76"
# author:     "Eric Bezault <ericb@gobosoft.com>"
# copyright:  "Copyright (c) 1997-2000, Eric Bezault and others"
# license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
# date:       "$Date: 2000/08/20 18:01:44 $"
# revision:   "$Revision: 1.4 $"


echo ${GOBO}/src/gelex/>				loadpath.se
echo ${GOBO}/library/loadpath.se>>		loadpath.se

export geoptions="-boost -no_split -no_style_warning -no_gc"
compile $geoptions GELEX execute
