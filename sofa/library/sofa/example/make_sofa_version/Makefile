
CFLAGS =
#CFLAGS = -l sofa:lib/sofa.lib

.PHONY : make_sofa_version_options.e make_sofa_version_info.e

sofa:tool/make_sofa_version : make_sofa_version.e make_sofa_version_options.e make_sofa_version_info.e
	compile -boost -no_split -no_gc $(CFLAGS) $< -o $@

make_sofa_version_options.e :
	sofa:tool/readarghh to=make_sofa_version_options template="to/k/a,version/n/a,revision/n/a,application/a,description/a,quiet/s"

make_sofa_version_info.e :
	sofa:tool/make_sofa_version to=make_sofa_version_info 1 0 make_sofa_version "BumpRev for Eiffel"

clean :
	clean make_sofa_version

sterile : clean
	delete quiet all force sofa
	delete quit make_sofa_version
