
all : sofa:tool/readarghh

sofa:tool/readarghh : readarghh.e option.e option_types.e
	compile -boost -no_split -no_gc $< -o $@

clean :
	clean readarghh

sterile : clean
	delete all quiet force sofa
	delete quit readarghh "#?.o"
