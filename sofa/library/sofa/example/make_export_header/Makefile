# Makefile for make_export_header

sofa:tool/make_export_header : make_export_header.e
	compile -boost -no_split make_export_header
	copy quiet clone make_export_header sofa:tool/make_export_header

debug:
	clean make_export_header
	compile -debug_check -no_split make_export_header

clean :
	clean make_export_header
	delete quiet make_export_header "#?.o"
	delete quiet all force sofa

