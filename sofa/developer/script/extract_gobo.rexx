/* extract_gobo.rexx -- Extract gobo#?.zip and modify it to work with Sofa.
 *
 * in more detail, the following operations are performed
 * - the ZIP archive is extracted, and CR/LF in text files are converted to LF
 * - #?.exe and #?.ge files are removed
 * - rename.se files are created for classes with too long filenames
 * - empty lines and "--" lines are removed from loadpath.se
 * - for every se.sh script, a se.amiga script is created
 *
 * $VER: extract_gobo.rexx 1.3 (9.11.99)
 */
AddLib('rexxsupport.library', 0, -30, 0)

gobo_zip     = 'sofa_archive:gobo16.zip'
sofa_path    = 'sofa:'
archive_path = 'sofa:archive/'
library_path = 'sofa:library/'
gobo_path    = 'sofa:library/gobo/'
make_rename  = 'sofa:library/sofa/example/make_rename_se/make_rename_se'

temp_file = 't:make_gobo_conversion.tmp'
path_file = 't:make_gobo_conversion.loadpath'

/* Flags to specify which operations are to be executed */
no_extract = 0
no_remove = 0
no_loadpath = 0
no_script = 0
no_rename = 0

/* Ensure that make_rename exists */
if ~exists(make_rename) then do
   Say 'cannot find tool "' || make_rename || '":'
   Say 'the developer archive must be installed, and the tool must be compiled'
   exit 10
end

old_path = Pragma('Directory', gobo_path)
Address Command

/* Extract archive with the following options
 * -a  convert CR/LF in text files
 * -q  quiet operation
 * -o  overwrite without asking
 */
Say 'extract ' || gobo_zip
if ~no_extract then do
   'unzip -aqo ' || gobo_zip
end
else do
   Say '   skipped'
end

/* Remove useless files */
Say 'remove useless files'
if ~no_remove then do
   Say '   remove #?.exe'
   'rx sofa:developer/script/recursive_remove_pattern bin pattern=#?.exe'

   Say '   remove #?.ge'
   'unzip -l ' || gobo_zip || ' *.ge >' || temp_file
   if ~Open('list', temp_file, 'read') then do
      Say 'cannot read archive list from "' || temp_file || '"'
      exit 10
   end

   do while ~eof('list')
      line = ReadLn('list')
      Parse Var line length date time name
      if Right(name, 3) = '.ge' then do
         name = Strip(name, 'L')
         Say '   ' || name
         call Delete(name)
      end
   end

   Say '   remove gepp scripts'
   call Delete(gobo_path || 'bin/ge2e.sh')
   call Delete(gobo_path || 'bin/make_spec.bat')

   call Close('list')
end
else do
   Say '   skipped'
end

/* Make rename.se */
Say 'make rename.se'
if ~no_rename then do
   make_rename || ' amiga ' || gobo_zip
end
else do
   Say '   skipped'
end

/* Change directory into library */
Pragma('Directory', gobo_path || 'library')

/* convert loadpath.se */
Say 'convert loadpath.se'
if ~no_loadpath then do
   Say '   looking for loadpath.se'
   'list ' || gobo_path || ' pat=loadpath.se lformat=%p%n all >' || temp_file
   if ~Open('list', temp_file, 'read') then do
      Say 'cannot read list of loadpath.se files from "' || temp_file || '"'
      exit 10
   end

   do while ~eof('list')
      file = ReadLn('list')
      if file ~= '' then do
         Say '   ' || file
         if Open('loadpath', file, 'read') then do
            if Open('temppath', path_file, 'write') then do
               do while ~eof('loadpath')
                  line = ReadLn('loadpath')
                  if Left(line, 2) = '--' then do
                     Say '      stripped "' || line || '"'
                     line = ''
                  end
                  if line ~= '' then do
                     call WriteLn('temppath', line)
                  end
               end
               call Close('temppath')
            end
            else do
               Say 'cannot write temporary loadpath to "' || path_file || '"'
               exit 10
            end
            call Close('loadpath')
         end
         else do
            Say 'cannot read loadpath from "' || file || '"'
            exit 10
         end
         'copy clone quiet "' || path_file || '" "' || file || '"'
      end
   end
   call Close('list')
end
else do
   Say '   skipped'
end

/* Make se.amiga scripts and copy SCOPTIONS */
Say 'make se.amiga'
if ~no_script then do
   Say '   looking for "se.sh" scripts'
   'list ' || gobo_path || ' pat=se.sh lformat=%p%n all >' || temp_file
   if ~Open('list', temp_file, 'read') then do
      Say 'cannot read list of se.sh files from "' || temp_file || '"'
      exit 10
   end

   do while ~eof('list')
      sh_script = ReadLn('list')
      if sh_script ~= '' then do
         amiga_script = Left(sh_script, Length(sh_script) - 2) || 'amiga'
         Say '   ' || amiga_script
         path = Left(sh_script, LastPos('/', sh_script))
         /* 'copy quiet clone sofa:settings/sofa.with ' || path || 'SCOPTIONS' */
         if Open('sh', sh_script, 'read') then do
            if Open('amiga', amiga_script, 'write') then do
               last_line = ''
               do while ~eof('sh')
                  line = ReadLn('sh')
                  if Left(line, 2) = '#!' then do
                     line = ''
                  end

                  if Left(line, 1) = '#' then do
                     line = Overlay(';', line)
                  end
                  else do
                     Parse Var line 'export ' rest
                     if rest ~= '' then do
                        Parse Var rest variable '=' value
                        line = 'set ' || variable || ' ' || value
                     end
                     Parse Var line head '>' tail
                     if tail ~= '' then do
                        line = head || ' >' || tail
                     end
                  end

                  if (line ~= '') | (last_line ~= '') then do
                     call WriteLn('amiga', line)
                  end
                  last_line = line
               end
               call Close('amiga')
               'protect ' || amiga_script || ' add s'
            end
            else do
               Say 'cannot write script to "' || amiga_script || '"'
               exit 10
            end
            call Close('sh')
         end
         else do
            Say 'cannot read script from "' || sh_script || '"'
            exit 10
         end
      end
   end
   call Close('list')
end
else do
   Say '   skipped'
end

/* Clean up */
call Delete(path_file)
call Delete(temp_file)
Pragma('Directory', old_path)

exit 0

