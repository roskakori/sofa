/* extract_exml.rexx -- Extract exml#?.zip and modify it to work with Sofa.
 *
 * In more detail, the following operations are performed
 * - the ZIP archive is extracted, and CR/LF in text files are converted to LF
 * - #?.exe and #?.ge files are removed
 *
 * $VER: extract_exml.rexx 1.1 (10.10.99)
 */
AddLib('rexxsupport.library', 0, -30, 0)

exml_zip     = 'sofa_archive:exml-016.zip'
sofa_path    = 'sofa:'
archive_path = 'sofa:archive/'
library_path = 'sofa:library/'
exml_path    = 'sofa:library/exml/'

temp_file = 't:make_exml_conversion.tmp'

/* Flags to specify which operations are to be executed */
no_extract = 1
no_remove = 0
no_rename = 0

old_path = Pragma('Directory', exml_path)
Address Command

/* Extract archive with the following options
 * -a  convert CR/LF in text files
 * -q  quiet operation
 * -o  overwrite without asking
 */
Say 'extract ' || exml_zip
if ~no_extract then do
   if ~exists(exml_path) then do
      'makedir ' || exmp_path
   end
   'unzip -aqo ' || exml_zip
end
else do
   Say '   skipped'
end


/* Remove useless files */
Say 'remove useless files'
if ~no_remove then do
   'rx sofa:developer/script/recursive_remove_pattern ' || exml_path || ' pattern="#?.(dll|exe|msc|scc|dsp|lib|dsw|mak)"'
end
else do
   Say '   skipped'
end

/* Change directory into library */
Pragma('Directory', exml_path || 'library')

/* Rename files with too long names */
Say 'rename too long filenames'
if ~no_rename then do
   Pragma('Directory', exml_path || 'compiler_specific/se/clib')
   source = 'expat_parser_error_codes_wrap.c'
   target = 'expat_parser_error_codes.c'
   if exists(source) then do
      call Delete('target')
      'rename ' || source || ' ' || target
   end
   else do
      if exists(target) then do
         Say '   already renamed before'
      end
      else do
         Say '   cannot find "' || source || '"'
         exit 10
      end
   end
   Say 'make rename.se'
   Pragma('Directory', exml_path)
   'sofa:developer/make_rename_se/make_rename_se amiga ' || exml_zip
end
else do
   Say '   skipped'
end

/* Clean up */
call Delete(path_file)
call Delete(temp_file)
Pragma('Directory', old_path)

exit 0
