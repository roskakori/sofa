#
# Makefile for sofa.lib
#

SOFA_LIB       = sofa:lib/sofa.lib
PROTO_FILE     = sofa:library/sofa/include/proto/sofa.h
ALL_C = assert.c dos.c exec.c resource.c rexx.c tool.c
ALL_O = assert.o dos.o exec.o resource.o rexx.o tool.o

#CC = dcc
#CFLAGS = -mD -mC -lm

CC = scc
CFLAGS =


all : $(SOFA_LIB)

#
# cleanup
#
clean :
	delete quiet $(ALL_O)

sterile : clean
	delete quiet $(SOFA_LIB) $(PROTO_FILE)

#
# sofa.lib
#
$(SOFA_LIB) : $(PROTO_FILE) $(ALL_O)
#   alib R $(SOFA_LIB) $(ALL_O)
	oml $(SOFA_LIB) r $(ALL_O)


#
# Prototype generation
#
proto : $(PROTO_FILE)

$(PROTO_FILE) : $(ALL_C)
	make_export_header $(PROTO_FILE) $(ALL_C)

#
# Update dependencies
#
depend :
	MkDepend verbose include=sofa:library/amiga/include $(ALL_C)


# --- DO NOT MODIFY THIS LINE -- AUTO-DEPENDS FOLLOW ---
assert.o : global.h

dos.o : global.h

exec.o : global.h

resource.o : global.h

rexx.o : global.h

tool.o : global.h

# --- DO NOT MODIFY THIS LINE -- AUTO-DEPENDS PRECEDE ---
