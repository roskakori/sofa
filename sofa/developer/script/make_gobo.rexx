/* make_gobo.rexx -- Create gobo.lha archive.
 *
 * $VER: make_gobo.rexx 1.2 (10.10.99)
 */
AddLib('rexxsupport.library', 0, -30, 0)
Address Command

sofa_path    = 'sofa:'
archive_path = 'sofa:archive/'
library_path = 'sofa:library/'
gobo_path    = 'sofa:library/gobo/'

gobo_lha = 't:gobo.lha'
temp_file = 't:make_gobo_lha.tmp'

old_path = Pragma('Directory', gobo_path || 'library')

/* Create gobo.lha */
Say 'clean gobo directories'
call Delete(gobo_path || 'src/gelex/gelex')
call Delete(gobo_path || 'src/gepp/gepp')
call Delete(gobo_path || 'src/geyacc/geyacc')
'list ' || gobo_path || ' pat=#?.(o|lnk) all lformat="delete *"%p%n*"" >' || temp_file
'execute ' || temp_file

/* Make gobo archive */
Say 'make gobo.lha'
Say
old_path = Pragma('Directory', library_path)
'lha -xadern a "' || gobo_lha || '" gobo'
Say
'list nohead "' || gobo_lha || '"'
'copy quiet clone "' || gobo_lha || '" "' || archive_path || 'gobo.lha"'

/* Clean up */
call Delete(gobo_lha)
call Delete(temp_file)
Pragma('Directory', old_path)

exit 0

