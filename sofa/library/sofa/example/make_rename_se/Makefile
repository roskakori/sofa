#
# Makefile for make_rename_se
#
# (For GNUmake under AmigaOS)

.PHONY : boost clean sterile make_rename_se

all : make_rename_se

make_rename_se :
	compile make_rename_se

boost :
	compile -boost -no_split -clean make_rename_se

clean :
	clean make_rename_se

sterile : clean
	delete quiet make_rename_se "#?.lnk" "#?.o"
	delete quiet force all sofa
