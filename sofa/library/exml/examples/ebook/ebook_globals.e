indexing
	description:"Global options for the eBOOK application"
	status:		"See notice at end of class."
	author:		"Andreas Leitner"

	-- TODO: Make this stuff configurable (get info through xml-tags of xml-file?)
class
	EBOOK_GLOBALS

feature -- Initialization
	html_page_extension: STRING is ".html"
		-- the extension that will be added to each html output file.
		-- in most cases this will be ".html"

	input_directory: STRING is "c:\prog\source\eiffel\exml\examples\test_data\ebook\input"
		-- directory where the input data files are stored

	output_directory: STRING is "c:\prog\source\eiffel\exml\examples\test_data\ebook\output"
		-- directory where the output data files should be created

	page_key_prefix: STRING is "ebp_"
		-- prefix for page keys

	local_url_prefix: STRING is ""
		-- prefix for links to local html-pages.
		-- in most cases this will be ""

	directory_seperator: STRING is "\"
		-- character that will be used to seperate directories and files

	pre_body_title_file: STRING is "c:\prog\source\eiffel\exml\examples\test_data\ebook\input\pre_body_title.html"

	ccs_definitions_file: STRING is "c:\prog\source\eiffel\exml\examples\test_data\ebook\input\ccs_defs.html"

--	ebook_xml_file_name: STRING is "c:\prog\source\eiffel\exml\examples\test_data\ebook\input\ebook_sample.xml"
	ebook_xml_file_name: STRING is "c:\prog\source\eiffel\exml\examples\test_data\ebook\input\exml.xml"
end -- class EBOOK_GLOBALS
--|-------------------------------------------------------------------------
--| eXML, Eiffel XML Parser Toolkit
--| Copyright (C) 1999  Andreas Leitner
--| See the file forum.txt included in this package for licensing info.
--|
--| Comments, Questions, Additions to this library? please contact:
--|
--| Andreas Leitner
--| Arndtgasse 1/3/5
--| 8010 Graz
--| Austria
--| email: andreas.leitner@teleweb.at
--| web: http://exml.dhs.org
--|-------------------------------------------------------------------------