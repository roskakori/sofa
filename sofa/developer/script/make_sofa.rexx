/* make_sofa.rexx -- Make Readme, release version and backup of sofa.lha.
 * $VER: make_sofa.rexx 1.2 (3.4.99) */

failat 1

sofa_version = '1.1'
Parse Var sofa_version version '.' release

list_file      = 't:lha_list_' || Pragma('ID') || '.tmp'
temp_lha       = 'tt:sofa_temporary.lha'
readme         = 'sofa:Readme'
sofa_readme    = 'release:sofa.readme'
sofa_lha       = 'release:sofa.lha'
sofa_xy_lha    = 'release:backup/sofa_' || version || release || '.lha'
sofa_xy_readme = 'release:backup/sofa_' || version || release || '.readme'
sofa_other_lha = 'sofa:archive/other.lha'
sofa_dev_lha   = 'sofa:archive/developer.lha'

Address Command
old_path = Pragma('Directory', 'sofa:developer/script')

/* Some cleanup */
'delete quiet sofa:library/sofa/source/#?.o'

/* Make Readme */
Say 'make ' || readme
'echo >' || readme || ' "TITLE*N*N  Sofa - SmallEiffel obviously fits Amiga*N*NVERSION*N*N  ' || sofa_version || '*N"'
'type >>' || readme || ' readme.body'

/* Make sofa.readme */
Say 'make ' || sofa_readme
'type >' || sofa_readme || ' readme.aminet'
'echo >>' || sofa_readme || ' "Version:  ' || sofa_version || '*N"'
'type >>' || sofa_readme || ' ' || readme
'copy quiet clone ' || sofa_readme || ' ' || sofa_xy_readme

Say

/* Rebuild SmallEiffel/install */
Say 'make SmallEiffel/install'
Say
Pragma('Directory', 'sofa:SmallEiffel')
'compile -clean -boost -no_split -no_gc install'
'delete quiet install.(id|make|lnk|o)'


/* Make sofa archive */
Say 'make ' || sofa_lha
Say
Pragma('Directory', 'sofa:')

'echo  >' || list_file || ' sofa.info'
'list  >>' || list_file || ' lformat=sofa/%p%n #?.info readme welcome.html install'
'list  >>' || list_file || ' all lformat=sofa/%p%n developer lib library manual SmallEiffel tool'

Pragma('Directory', 'sofa:/')
'lha -xadern a "' || temp_lha || '" @' || list_file

Say

/* copy archives */
Say 'copy archives'
'copy quiet clone "' || temp_lha || '" "' || sofa_lha || '"'
'list nohead "' || sofa_lha || '"' /* ' "' || sofa_dev_lha || '" "' || sofa_other_lha || '"' */
'copy quiet clone "' || temp_lha || '" "' || sofa_lha || '"'
'copy quiet clone "' || temp_lha || '" "' || sofa_xy_lha || '"'
'delete quiet "' || temp_lha || '"'

Pragma('Directory', old_path)

