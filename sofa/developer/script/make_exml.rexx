/* make_exml.rexx -- Create exml.lha archive
 *
 * $VER: make_exml_lha.rexx 1.2 (10.10.99)
 */
AddLib('rexxsupport.library', 0, -30, 0)
Address Command

sofa_path    = 'sofa:'
archive_path = 'sofa:archive/'
library_path = 'sofa:library/'
exml_lib     = 'sofa:lib/exml.lib'
exml_path    = 'sofa:library/exml/'

exml_lha = 't:exml.lha'
temp_lib = 't:exml.lib'
temp_file = 't:make_exml_lha.tmp'

old_path = Pragma('Directory', exml_path || 'library')

/* clean exml directories from useless files:
 * - put aside exml.lib (because it will be deleted by smake)
 * - remove compiler junk files
 * - call "smake sterile" on all directories with a smakefile
 * - restore exml.lib */
Say 'clean exml directories'
'copy quiet clone ' || exml_lib || ' ' || temp_lib
'list ' || exml_path || ' pat=#?.(o|lnk) all lformat="delete *"%p%n*"" >' || temp_file
'execute ' || temp_file
'list ' || exml_path || ' pat=smakefile all lformat="cd %p*Nsmake sterile" >' || temp_file
'execute ' || temp_file
'copy quiet clone ' || temp_lib || ' ' || exml_lib
call Delete(temp_lib)

/* Make exml archive */
Say 'make exml.lha'
Say
old_path = Pragma('Directory', library_path)
'lha -xadern a "' || exml_lha || '" exml'
Say
'list nohead "' || exml_lha || '"'
'copy quiet clone "' || exml_lha || '" "' || archive_path || 'exml.lha"'

/* Clean up */
call Delete(exml_lha)
call Delete(temp_file)
Pragma('Directory', old_path)

exit 0

