#
# Because many Unix users are used to type 'make' in order to install
# a software.
#
all : bin/compile_to_c

bin/compile_to_c : bin_c/compile_to_c.h
	gcc -o install install.c
	./install
	rm -f ./install

interactive : ./bin_c/compile_to_c.h
	gcc -o install install.c
	./install -interactive
	rm -f ./install
